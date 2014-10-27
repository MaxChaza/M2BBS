<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:mathml="http://www.w3.org/1998/Math/MathML"
                xmlns:gnaml="http://www-gna.inrialpes.fr/gnaml/version1"
                xmlns:extrparam="http://www-gna.inrialpes.fr/xsl/extract-parameter-ordering"
                xmlns:order="http://www-gna.inrialpes.fr/xsl/build_order"
                xmlns:join="http://www-gna.inrialpes.fr/xsl/join-gnaml"
                xmlns:varchk="http://www-gna.inrialpes.fr/xsl/variable-check"
                xmlns:utils="http://www-gna.inrialpes.fr/xsl/utils"
                xmlns:x="http://www-gna.inrialpes.fr/xsl/structs"
                exclude-result-prefixes="#all">

<xsl:import href="build_order_l2v3.xsl" />
<xsl:import href="join_gnaml_l2v3.xsl" />
<xsl:import href="variable_check_l2v3.xsl" />


<xsl:function name="extrparam:extract-parameter-ordering">
  <xsl:param name="sbml" as="element()" />
  <xsl:param name="gnaml" as="element()" />
  <xsl:param name="graphs-map" as="element()" />
  <xsl:variable name="new-gnaml" as="element()">
    <gnaml version="1.0" xmlns="http://www-gna.inrialpes.fr/gnaml/version1">
      <model id="{$gnaml//gnaml:model/@id}">
        <xsl:for-each select="$gnaml//gnaml:state-variable">
          <xsl:variable name="state-var-info" as="element()"><xsl:copy-of select="."/></xsl:variable>
          <state-variable id="{$state-var-info/@id}" xmlns="http://www-gna.inrialpes.fr/gnaml/version1">
            <xsl:copy-of select="extrparam:select-from-order($graphs-map/x:key[@id=$state-var-info/@id]/*,
                                                             $state-var-info)" />
          </state-variable>
        </xsl:for-each>
      </model>
    </gnaml>
  </xsl:variable>
  <xsl:copy-of select="join:join-gnaml($gnaml,$new-gnaml)" />
</xsl:function>


<xsl:function name="extrparam:extract-parameter-ordering-values">
  <xsl:param name="sbml" as="element()" />
  <xsl:param name="gnaml" as="element()" />
  <xsl:param name="order-values" as="element()" />
  <xsl:variable name="new-gnaml" as="element()">
    <gnaml version="1.0" xmlns="http://www-gna.inrialpes.fr/gnaml/version1">
      <model id="{$gnaml//gnaml:model/@id}">
        <xsl:for-each select="$gnaml//gnaml:state-variable">
          <xsl:variable name="state-var-info" as="element()"><xsl:copy-of select="."/></xsl:variable>
          <state-variable id="{$state-var-info/@id}" xmlns="http://www-gna.inrialpes.fr/gnaml/version1">
            <xsl:variable name="thresholds-indices" as="xs:integer*">
              <xsl:for-each select="$order-values/x:param">
                <xsl:if test="varchk:check-term(./mathml:ci,$state-var-info)=true()">
                  <xsl:copy-of select="position()" />
                </xsl:if>
              </xsl:for-each>
            </xsl:variable>
            <xsl:variable name="thresholds-order" as="element()">
              <x:params-ordered-through-values>
                <xsl:copy-of select="$order-values/x:param[position()=$thresholds-indices]" />
              </x:params-ordered-through-values>
            </xsl:variable>
            <xsl:variable name="synthesis-indices" as="xs:integer*">
              <xsl:for-each select="$order-values/x:param">
                <xsl:if test="$state-var-info/gnaml:list-of-synthesis-parameters/gnaml:synthesis-parameter/@id
                                = ./mathml:ci">
                  <xsl:copy-of select="position()" />
                </xsl:if>
              </xsl:for-each>
            </xsl:variable>
            <xsl:variable name="synthesis-order" as="element()">
              <x:params-ordered-through-values>
                <xsl:copy-of select="$order-values/x:param[position()=$synthesis-indices]" />
              </x:params-ordered-through-values>
            </xsl:variable>
            <xsl:variable name="degradation-indices" as="xs:integer*">
              <xsl:for-each select="$order-values/x:param">
                <xsl:if test="$state-var-info/gnaml:list-of-degradation-parameters/gnaml:degradation-parameter/@id
                                = ./mathml:ci/text()">
                  <xsl:copy-of select="position()" />
                </xsl:if>
              </xsl:for-each>
            </xsl:variable>
            <xsl:variable name="degradation-order" as="element()">
              <x:params-ordered-through-values>
                <xsl:copy-of select="$order-values/x:param[position()=$degradation-indices]" />
              </x:params-ordered-through-values>
            </xsl:variable>
            <xsl:copy-of select="extrparam:select-from-order-values($thresholds-order,$synthesis-order,
                                                                    $degradation-order,$state-var-info)" />
          </state-variable>
        </xsl:for-each>
      </model>
    </gnaml>
  </xsl:variable>
  <xsl:copy-of select="join:join-gnaml($gnaml,$new-gnaml)" />
</xsl:function>


<xsl:function name="extrparam:select-from-order-values">
  <xsl:param name="thresholds-order" as="element()" />
  <xsl:param name="synthesis-order" as="element()" />
  <xsl:param name="degradation-order" as="element()" />
  <xsl:param name="state-var-info" as="element()" />
  <xsl:variable name="zero-param" as="xs:string" select="concat('zero_',$state-var-info/@id)" />
  <xsl:variable name="box-param" as="xs:string" select="concat('max_',$state-var-info/@id)" />
  <xsl:if test="empty($state-var-info/gnaml:zero-parameter)">
    <zero-parameter xmlns="http://www-gna.inrialpes.fr/gnaml/version1" id="{$zero-param}" />
  </xsl:if>
  <xsl:if test="empty($state-var-info/gnaml:box-parameter)">
    <box-parameter xmlns="http://www-gna.inrialpes.fr/gnaml/version1" id="{$box-param}" />
  </xsl:if>

  <xsl:variable name="all-params" as="element()*">
    <xsl:copy-of select="$thresholds-order/*" />
    <xsl:if test="count($state-var-info//gnaml:degradation-parameter/@id)
                    = count($degradation-order/x:param/mathml:ci
                        [text()=$state-var-info//gnaml:degradation-parameter/@id])
                  and exists($synthesis-order/x:param/mathml:ci
                        [text()=$state-var-info//gnaml:synthesis-parameter/@id])">
      <xsl:for-each select="utils:build-all-combinations($synthesis-order/x:param/mathml:ci,true())">
        <xsl:variable name="combi" as="element()" select="." />
        <xsl:variable name="num-value" as="xs:double"
                      select="if ($combi/self::mathml:ci)
                              then $synthesis-order/x:param[mathml:ci = $combi]/@value
                              else sum(for $x in $combi/mathml:ci
                                        return $synthesis-order/x:param[mathml:ci = $x]/@value)" />
        <xsl:variable name="denom-value" as="xs:double"
                      select="sum(for $x in $degradation-order/x:param return xs:double($x/@value))" />
        <x:param value="{$num-value div $denom-value}">
          <apply xmlns="http://www.w3.org/1998/Math/MathML">
            <divide />
            <xsl:copy-of select="$combi" />
            <xsl:choose>
              <xsl:when test="count($state-var-info//gnaml:degradation-parameter/@id) > 1">
                <apply xmlns="http://www.w3.org/1998/Math/MathML">
                  <plus />
                  <xsl:for-each select="$state-var-info//gnaml:degradation-parameter/@id">
                    <ci xmlns="http://www.w3.org/1998/Math/MathML"><xsl:value-of select="."/></ci>
                  </xsl:for-each>
                </apply>
              </xsl:when>
              <xsl:otherwise>
                <xsl:for-each select="$state-var-info//gnaml:degradation-parameter/@id">
                  <ci xmlns="http://www.w3.org/1998/Math/MathML"><xsl:value-of select="."/></ci>
                </xsl:for-each>
              </xsl:otherwise>
            </xsl:choose>
          </apply>
        </x:param>
      </xsl:for-each>
    </xsl:if>
  </xsl:variable>
  <xsl:variable name="all-params-order" as="element()">
    <x:params-ordered-through-values>
      <xsl:for-each select="$all-params">
        <xsl:sort select="@value" data-type="number" />
        <xsl:copy-of select="."/>
      </xsl:for-each>
    </x:params-ordered-through-values>
  </xsl:variable>
  <xsl:if test="exists($all-params-order)
                and count(distinct-values($all-params-order/x:param/@value))
                      = count($all-params-order/x:param/@value)">
    <parameter-inequalities xmlns="http://www-gna.inrialpes.fr/gnaml/version1">
      <math xmlns="http://www.w3.org/1998/Math/MathML">
        <apply>
          <lt />
          <ci xmlns="http://www.w3.org/1998/Math/MathML">
            <xsl:value-of select="if (empty($state-var-info/gnaml:zero-parameter))
                                  then $zero-param
                                  else $state-var-info/gnaml:zero-parameter/@id" />
          </ci>
          <xsl:copy-of select="$all-params-order/x:param/*" />
          <ci xmlns="http://www.w3.org/1998/Math/MathML">
            <xsl:value-of select="if (empty($state-var-info/gnaml:box-parameter))
                                  then $box-param
                                  else $state-var-info/gnaml:box-parameter/@id" />
          </ci>
        </apply>
      </math>
    </parameter-inequalities>
  </xsl:if>
</xsl:function>


<xsl:function name="extrparam:select-from-order">
  <xsl:param name="order-graph" as="element()" />
  <xsl:param name="state-var-info" as="element()" />
  <xsl:variable name="indices" as="xs:integer*">
    <xsl:for-each select="$order-graph/x:vertices/(mathml:ci|mathml:apply)">
      <xsl:if test="varchk:check-term(.,$state-var-info)=true()">
        <xsl:copy-of select="position()" />
      </xsl:if>
    </xsl:for-each>
  </xsl:variable>
  <xsl:variable name="projected-graph" as="element()"
                select="order:projection($order-graph,$indices)" />
  <xsl:variable name="missing" as="element()*"
                select="$state-var-info/gnaml:list-of-threshold-parameters
                          /gnaml:threshold-parameter[not(@id=$projected-graph/x:vertices/mathml:ci/text())]" />
  <xsl:variable name="scc-result" as="element()"
                select="order:isolate-SCC($projected-graph)" />
  <xsl:variable name="order" as="element()"
                select="order:topological-sort($scc-result)" />
  <xsl:variable name="zero-param" as="xs:string" select="concat('zero_',$state-var-info/@id)" />
  <xsl:variable name="box-param" as="xs:string" select="concat('max_',$state-var-info/@id)" />
  <xsl:if test="empty($state-var-info/gnaml:zero-parameter)">
    <zero-parameter xmlns="http://www-gna.inrialpes.fr/gnaml/version1" id="{$zero-param}" />
  </xsl:if>
  <xsl:if test="empty($state-var-info/gnaml:box-parameter)">
    <box-parameter xmlns="http://www-gna.inrialpes.fr/gnaml/version1" id="{$box-param}" />
  </xsl:if>
  <xsl:if test="exists($order)
            and empty($order/(mathml:leq|mathml:eq))
            and empty($missing)">
    <parameter-inequalities xmlns="http://www-gna.inrialpes.fr/gnaml/version1">
      <math xmlns="http://www.w3.org/1998/Math/MathML">
        <apply>
          <lt />
          <ci xmlns="http://www.w3.org/1998/Math/MathML">
            <xsl:value-of select="if (empty($state-var-info/gnaml:zero-parameter))
                                  then $zero-param
                                  else $state-var-info/gnaml:zero-parameter/@id" />
          </ci>
          <xsl:copy-of select="$order/(mathml:ci|mathml:apply)" />
          <ci xmlns="http://www.w3.org/1998/Math/MathML">
            <xsl:value-of select="if (empty($state-var-info/gnaml:box-parameter))
                                  then $box-param
                                  else $state-var-info/gnaml:box-parameter/@id" />
          </ci>
        </apply>
      </math>
    </parameter-inequalities>
  </xsl:if>
</xsl:function>

</xsl:stylesheet>