<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:sbml="http://www.sbml.org/sbml/level2"
                xmlns:mathml="http://www.w3.org/1998/Math/MathML"
                xmlns:gnaml="http://www-gna.inrialpes.fr/gnaml/version1"
                xmlns:extrvar="http://www-gna.inrialpes.fr/xsl/extract-variable-information"
                xmlns:state="http://www-gna.inrialpes.fr/xsl/discern_state_equation"
                xmlns:join="http://www-gna.inrialpes.fr/xsl/join-gnaml"
                exclude-result-prefixes="#all">

<xsl:import href="discern_state_equation_l2v1.xsl" />
<xsl:import href="join_gnaml_l2v1.xsl" />


<xsl:function name="extrvar:extract-variable-information">
  <xsl:param name="sbml" as="element()" />
  <xsl:apply-templates select="$sbml/sbml:model" mode="extract-variable-information" />
</xsl:function>


<xsl:template match="sbml:model" mode="extract-variable-information">
  <xsl:variable name="input-variables" as="element()*"
                select="sbml:listOfSpecies/sbml:species[@constant='true']" />
  <xsl:variable name="state-variables" as="element()*"
                select="sbml:listOfSpecies/sbml:species[not(@constant='true')]" />
  <xsl:variable name="defs" as="element()">
    <gnaml xmlns="http://www-gna.inrialpes.fr/gnaml/version1">
      <model id="{if (exists(@id)) then @id else 'import'}">
        <xsl:if test="sbml:notes">
          <notes>
            <xsl:copy-of select="sbml:notes/*" />
          </notes>
        </xsl:if>
        <xsl:for-each select="$input-variables">
          <input-variable id="{@id}" xmlns="http://www-gna.inrialpes.fr/gnaml/version1"/>
        </xsl:for-each>
        <xsl:for-each select="$state-variables">
          <state-variable id="{@id}" xmlns="http://www-gna.inrialpes.fr/gnaml/version1"/>
        </xsl:for-each>
      </model>
    </gnaml>
  </xsl:variable>
  <xsl:variable name="eqs" as="element()*">
    <xsl:apply-templates select="sbml:listOfRules/sbml:rateRule" mode="#current">
      <xsl:with-param name="vars" as="element()+">
        <xsl:for-each select="$defs//gnaml:input-variable/@id">
          <input-variable id="{.}" xmlns="http://www-gna.inrialpes.fr/gnaml/version1"/>
        </xsl:for-each>
        <xsl:for-each select="$defs//gnaml:state-variable/@id">
          <state-variable id="{.}" xmlns="http://www-gna.inrialpes.fr/gnaml/version1"/>
        </xsl:for-each>
      </xsl:with-param>
      <xsl:with-param name="model" select="if (exists(@id)) then @id else 'import'" />
    </xsl:apply-templates>
  </xsl:variable>
  <xsl:copy-of select="join:join-gnaml($defs,join:join-gnaml($eqs))" />
</xsl:template>


<xsl:template match="sbml:rateRule" mode="extract-variable-information">
  <xsl:param name="vars" as="element()+" />
  <xsl:param name="model" as="xs:string" />
  <xsl:variable name="var" select="@variable" as="xs:string" />
  <xsl:variable name="math" as="element()*"
                select="state:discern-state-equation(mathml:math,$vars,$var)" />
  <xsl:choose>
    <xsl:when test="exists($math) and $vars/@id = $var">
      <xsl:variable name="extracted" as="element()"
                    select="extrvar:from-state-equation($math,$vars,$var,$model)" />
      <xsl:choose>
        <xsl:when test="empty($math)">
          <xsl:copy-of select="$extracted" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="eq" as="element()">
            <gnaml xmlns="http://www-gna.inrialpes.fr/gnaml/version1">
              <model id="{$model}">
                <state-variable id="{@variable}">
                  <state-equation>
                    <math xmlns="http://www.w3.org/1998/Math/MathML">
                      <xsl:copy-of select="$math" />
                    </math>
                  </state-equation>
                </state-variable>
              </model>
            </gnaml>
          </xsl:variable>
          <xsl:copy-of select="join:join-gnaml($eq,$extracted)" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <gnaml xmlns="http://www-gna.inrialpes.fr/gnaml/version1" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<xsl:function name="extrvar:from-state-equation">
  <xsl:param name="expr" />
  <xsl:param name="vars" as="element()+" />
  <xsl:param name="var" as="xs:string" />
  <xsl:param name="model" as="xs:string" />
  <xsl:variable name="plus-expr" as="element()"
                select="extrvar:from-production-expression
                          ($expr/self::mathml:apply/element()[2],$vars,$var,$model)" />
  <xsl:variable name="minus-expr" as="element()"
                select="extrvar:from-degradation-expression
                          ($expr/self::mathml:apply/element()[3],$vars,$var,$model)" />
  <xsl:copy-of select="join:join-gnaml($plus-expr,$minus-expr)" />
</xsl:function>



<xsl:function name="extrvar:from-production-expression">
  <xsl:param name="expr" as="element()" />
  <xsl:param name="vars" as="element()+" />
  <xsl:param name="var" as="xs:string" />
  <xsl:param name="model" as="xs:string" />
  <xsl:variable name="res" as="element()*"
                select="if ($expr/self::mathml:apply/mathml:plus) (: many production terms :)
                        then for $e in $expr/self::mathml:apply/element()[position()>1]
                             return extrvar:from-production-term($e,$vars,$var,$model)
                        else (: only one production term :)
                          extrvar:from-production-term($expr/self::element(),$vars,$var,$model)" />
  <xsl:copy-of select="join:join-gnaml($res)" />
</xsl:function>


<xsl:function name="extrvar:from-production-term">
  <xsl:param name="expr" as="element()" />
  <xsl:param name="vars" as="element()+" />
  <xsl:param name="var" as="xs:string" />
  <xsl:param name="model" as="xs:string" />
  <xsl:choose>
    <xsl:when test="$expr/self::mathml:apply/mathml:times">
      <xsl:variable name="prod-param" as="element()">
        <gnaml xmlns="http://www-gna.inrialpes.fr/gnaml/version1">
          <model id="{$model}">
            <state-variable id="{$var}">
              <list-of-synthesis-parameters>
                <synthesis-parameter>
                  <xsl:attribute name="id" select="$expr/self::mathml:apply/element()[2]" />
                </synthesis-parameter>
              </list-of-synthesis-parameters>
            </state-variable>
          </model>
        </gnaml>
      </xsl:variable>
      <xsl:variable name="reg-func" as="element()*">
        <xsl:for-each select="$expr/self::mathml:apply/element()[position()>2]">
          <xsl:copy-of select="extrvar:from-regulation-function(.,$vars,$model)" />
        </xsl:for-each>
      </xsl:variable>
      <xsl:copy-of select="join:join-gnaml($prod-param,join:join-gnaml($reg-func))" />
    </xsl:when>
    <xsl:otherwise>
      <gnaml xmlns="http://www-gna.inrialpes.fr/gnaml/version1">
        <model id="{$model}">
          <state-variable id="{$var}">
            <list-of-synthesis-parameters>
              <synthesis-parameter>
                <xsl:attribute name="id" select="$expr/self::mathml:ci" />
              </synthesis-parameter>
            </list-of-synthesis-parameters>
          </state-variable>
        </model>
      </gnaml>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>


<xsl:function name="extrvar:from-regulation-function">
  <xsl:param name="expr" as="element()" />
  <xsl:param name="vars" as="element()+" />
  <xsl:param name="model" as="xs:string" />
  <xsl:choose>
    <xsl:when test="$expr/self::mathml:apply/mathml:csymbol">
      <xsl:variable name="var" as="xs:string"
                    select="$expr/self::mathml:apply/mathml:ci[1]" />
      <xsl:choose>
        <xsl:when test="$vars/self::state-variable[@id=$var]">
          <gnaml xmlns="http://www-gna.inrialpes.fr/gnaml/version1">
            <model id="{$model}">
              <state-variable id="{$var}">
                <list-of-threshold-parameters>
                  <threshold-parameter id="{$expr/self::mathml:apply/mathml:ci[2]}" />
                </list-of-threshold-parameters>
              </state-variable>
            </model>
          </gnaml>
        </xsl:when>
        <xsl:otherwise>
          <gnaml xmlns="http://www-gna.inrialpes.fr/gnaml/version1">
            <model id="{$model}">
              <input-variable id="{$expr/self::mathml:apply/mathml:ci[1]}">
                <list-of-threshold-parameters>
                  <threshold-parameter id="{$expr/self::mathml:apply/mathml:ci[2]}"/>
                </list-of-threshold-parameters>
              </input-variable>
            </model>
          </gnaml>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:when test="$expr/self::mathml:apply/mathml:minus">
      <xsl:copy-of select="extrvar:from-regulation-function
                            ($expr/self::mathml:apply/element()[last()],$vars,$model)" />
    </xsl:when>
    <xsl:when test="$expr/self::mathml:apply/mathml:times">
      <xsl:variable name="extracted" as="element()*">
        <xsl:for-each select="$expr/self::mathml:apply/element()[position()>1]">
          <xsl:copy-of select="extrvar:from-regulation-function(.,$vars,$model)" />
        </xsl:for-each>
      </xsl:variable>
      <xsl:copy-of select="join:join-gnaml($extracted)" />
    </xsl:when>
  </xsl:choose>
</xsl:function>

<xsl:function name="extrvar:from-degradation-expression">
  <xsl:param name="expr" as="element()" />
  <xsl:param name="vars" as="element()+" />
  <xsl:param name="var" as="xs:string" />
  <xsl:param name="model" as="xs:string" />
  <xsl:variable name="extracted" as="element()*">
    <xsl:choose>
      <xsl:when test="$expr/self::mathml:apply/mathml:*[2]/self::mathml:apply/mathml:plus">
        <xsl:for-each select="$expr/self::mathml:apply/mathml:*[2]
                                /self::mathml:apply/mathml:*[position()>1]">
          <xsl:copy-of select="extrvar:from-degradation-term(.,$vars,$var,$model)" />
        </xsl:for-each>
      </xsl:when>
      <xsl:when test="$expr/self::mathml:apply/mathml:times">
        <xsl:choose>
          <xsl:when test="count($expr/self::mathml:apply/mathml:*)=3">
            <xsl:copy-of select="extrvar:from-degradation-term
                                  ($expr/self::mathml:apply/mathml:*[2],$vars,$var,$model)" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:variable name="deg-term" as="element()">
              <apply xmlns="http://www.w3.org/1998/Math/MathML">
                <times />
                <xsl:copy-of select="$expr/self::mathml:apply/mathml:*[2]" />
                <xsl:copy-of select="$expr/self::mathml:apply/mathml:*[3]" />
              </apply>
            </xsl:variable>
            <xsl:copy-of select="extrvar:from-degradation-term($deg-term,$vars,$var,$model)" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
    </xsl:choose>
  </xsl:variable>
  <xsl:copy-of select="join:join-gnaml($extracted)" />
</xsl:function>


<xsl:function name="extrvar:from-degradation-term">
  <xsl:param name="expr" as="element()" />
  <xsl:param name="vars" as="element()+" />
  <xsl:param name="var" as="xs:string" />
  <xsl:param name="model" as="xs:string" />
  <xsl:choose>
    <xsl:when test="$expr/self::mathml:apply">
      <xsl:variable name="deg-param" as="element()">
        <gnaml xmlns="http://www-gna.inrialpes.fr/gnaml/version1">
          <model id="{$model}">
            <state-variable id="{$var}">
              <list-of-degradation-parameters>
                <degradation-parameter>
                  <xsl:attribute name="id" select="$expr/self::mathml:apply/mathml:*[2]" />
                </degradation-parameter>
              </list-of-degradation-parameters>
            </state-variable>
          </model>
        </gnaml>
      </xsl:variable>
      <xsl:variable name="reg-func" as="element()*">
        <xsl:for-each select="$expr/self::mathml:apply/mathml:*[position()>2]">
          <xsl:copy-of select="extrvar:from-regulation-function(.,$vars,$model)" />
        </xsl:for-each>
      </xsl:variable>
      <xsl:copy-of select="join:join-gnaml($deg-param,join:join-gnaml($reg-func))" />
    </xsl:when>
    <xsl:otherwise>
      <gnaml xmlns="http://www-gna.inrialpes.fr/gnaml/version1">
        <model id="{$model}">
          <state-variable id="{$var}">
            <list-of-degradation-parameters>
              <degradation-parameter>
                <xsl:attribute name="id" select="$expr/self::mathml:ci" />
              </degradation-parameter>
            </list-of-degradation-parameters>
          </state-variable>
        </model>
      </gnaml>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

</xsl:stylesheet>