<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:sbml="http://www.sbml.org/sbml/level2/version2"
                xmlns:mathml="http://www.w3.org/1998/Math/MathML"
                xmlns:state="http://www-gna.inrialpes.fr/xsl/discern_state_equation"
                exclude-result-prefixes="#all">


<xsl:function name="state:discern-state-equation">
  <xsl:param as="element()" name="expr" />
  <xsl:param as="element()+" name="vars" />
  <xsl:param as="xs:string" name="var" />
  <xsl:variable name="canonized" select="state:to-canonical-state-equation($expr/element())" />
  <xsl:variable name="plus"
                select="state:to-canonical-production-expression
                          ($canonized/self::plus/*,$vars)" />
  <xsl:variable name="minus"
                select="state:to-canonical-degradation-expression
                          ($canonized/self::minus/*,$vars,$var)" />
  <xsl:if test="not(empty($plus) or empty($minus))">
    <apply xmlns="http://www.w3.org/1998/Math/MathML">
      <minus />
      <xsl:copy-of select="state:concat-plus($plus)" />
      <xsl:copy-of select="state:concat-deg($minus)" />
    </apply>
  </xsl:if>
</xsl:function>


<xsl:function name="state:to-canonical-state-equation">
  <xsl:param name="expr" as="element()" />
  <xsl:choose>
    <xsl:when test="$expr/mathml:plus">
      <xsl:variable name="nested">
        <xsl:for-each select="$expr/element()[position()>1]">
          <xsl:copy-of select="state:to-canonical-state-equation(.)" />
        </xsl:for-each>
      </xsl:variable>
      <plus>
        <xsl:copy-of select="state:concat-plus($nested/plus/*)" />
      </plus>
      <minus>
        <xsl:copy-of select="state:concat-plus($nested/minus/*)" />
      </minus>
    </xsl:when>

    <xsl:when test="$expr/mathml:minus">
      <xsl:choose>
        <xsl:when test="count($expr/element()) > 2">
          <xsl:variable name="left" select="state:to-canonical-state-equation($expr/element()[2])" />
          <xsl:variable name="right" select="state:to-canonical-state-equation($expr/element()[3])" />
          <xsl:variable name="plus">
            <xsl:variable name="both" as="element()*">
              <xsl:copy-of select="$left/self::plus/*" />
              <xsl:copy-of select="$right/self::minus/*" />
            </xsl:variable>
            <xsl:copy-of select="state:concat-plus($both)" />
          </xsl:variable>
          <xsl:variable name="minus">
            <xsl:variable name="both" as="element()*">
              <xsl:copy-of select="$left/self::minus/*" />
              <xsl:copy-of select="$right/self::plus/*" />
            </xsl:variable>
            <xsl:copy-of select="state:concat-plus($both)" />
          </xsl:variable>
          <plus>
            <xsl:copy-of select="state:concat-plus($plus)" />
          </plus>
          <minus>
            <xsl:copy-of select="state:concat-plus($minus)" />
          </minus>
        </xsl:when>

        <xsl:otherwise>
          <xsl:variable name="canonized" select="state:to-canonical-state-equation($expr/element()[2])" />
          <plus>
            <xsl:copy-of select="state:concat-plus($canonized/self::minus/*)" />
          </plus>
          <minus>
            <xsl:copy-of select="state:concat-plus($canonized/self::plus/*)" />
          </minus>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>

    <xsl:otherwise>
      <plus>
        <xsl:copy-of select="$expr" />
      </plus>
      <minus />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>


<xsl:function name="state:concat-plus">
  <xsl:param name="exprs" />
  <xsl:choose>
    <xsl:when test="count($exprs) > 1">
      <apply xmlns="http://www.w3.org/1998/Math/MathML">
        <plus/>
        <xsl:for-each select="$exprs">
          <xsl:choose>
            <xsl:when test="self::mathml:apply/mathml:plus">
              <xsl:copy-of select="element()[position()>1]" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:copy-of select="." />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </apply>
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy-of select="$exprs" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>


<xsl:function name="state:to-canonical-production-expression">
  <xsl:param name="expr" as="element()?" />
  <xsl:param as="element()+" name="vars" />
  <xsl:choose>
    <xsl:when test="empty($expr)">
    </xsl:when>
    <xsl:when test="$expr/self::mathml:apply/mathml:plus">
      <xsl:variable name="canonized" as="element()*">
        <xsl:for-each select="$expr/self::mathml:apply/element()[position()>1]">
          <xsl:copy-of select="state:to-canonical-production-term(.,$vars)" />
        </xsl:for-each>
      </xsl:variable>
      <xsl:if test="count($expr/self::mathml:apply/element()[position()>1]) 
                    = count($canonized/self::element())">
        <xsl:copy-of select="$canonized" />
      </xsl:if>
    </xsl:when>
    <xsl:otherwise>
      <xsl:variable name="canonized" select="state:to-canonical-production-term($expr,$vars)" />
      <xsl:if test="exists($canonized)">
        <xsl:copy-of select="$canonized" />
      </xsl:if>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>


<xsl:function name="state:to-canonical-production-term">
  <xsl:param name="expr" as="element()" />
  <xsl:param as="element()+" name="vars" />
  <xsl:choose>
    <xsl:when test="$expr/self::mathml:apply/mathml:times">
      <xsl:variable name="canonized" as="element()*"
                    select="state:to-canonical-production-term-internal
                              ($expr/self::mathml:apply/element()[position()>1],$vars)" />
      <xsl:if test="count($canonized/self::rate-parameter/element())=1 
                and count($canonized/self::rate-parameter/element()) + count($canonized/self::regulation-function/element())
                    = count($expr/self::mathml:apply/element()[position()>1])">
        <apply xmlns="http://www.w3.org/1998/Math/MathML">
          <times />
          <xsl:copy-of select="$canonized/self::rate-parameter/element()" />
          <xsl:copy-of select="state:concat-times($canonized/self::regulation-function/element())" />
        </apply>
      </xsl:if>
    </xsl:when>
    <xsl:when test="$expr/self::mathml:ci">
      <xsl:copy-of select="state:to-canonical-rate-parameter($expr,$vars)" />
    </xsl:when>
  </xsl:choose>
</xsl:function>


<xsl:function name="state:concat-times">
  <xsl:param name="exprs" />
  <xsl:choose>
    <xsl:when test="count($exprs) > 1">
      <apply xmlns="http://www.w3.org/1998/Math/MathML">
        <times/>
        <xsl:for-each select="$exprs">
          <xsl:choose>
            <xsl:when test="self::mathml:apply/mathml:times">
              <xsl:copy-of select="element()[position()>1]" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:copy-of select="." />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </apply>
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy-of select="$exprs" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>


<xsl:function name="state:to-canonical-production-term-internal">
  <xsl:param name="expr" as="element()+" />
  <xsl:param as="element()+" name="vars" />
  <xsl:choose>
    <xsl:when test="count($expr/self::element()) = 1">
      <xsl:variable name="rate-parameter" select="state:to-canonical-rate-parameter($expr,$vars)" />
      <xsl:choose>
        <xsl:when test="empty($rate-parameter)">
          <rate-parameter />
          <regulation-function>
            <xsl:copy-of select="state:to-canonical-regulation-function($expr,$vars)" />
          </regulation-function>
        </xsl:when>
        <xsl:otherwise>
          <rate-parameter>
            <xsl:copy-of select="$rate-parameter" />
          </rate-parameter>
          <regulation-function />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:variable name="other-terms"
                    select="state:to-canonical-production-term-internal($expr[position()>1],$vars)" />
      <xsl:variable name="rate-parameter" select="state:to-canonical-rate-parameter($expr[1],$vars)" />
      <rate-parameter>
        <xsl:if test="exists($rate-parameter)">
          <xsl:copy-of select="$rate-parameter" />
        </xsl:if>
        <xsl:copy-of select="$other-terms/self::rate-parameter/element()" />
      </rate-parameter>
      <regulation-function>
        <xsl:if test="empty($rate-parameter)">
          <xsl:copy-of select="state:to-canonical-regulation-function($expr[1],$vars)" />
        </xsl:if>
        <xsl:copy-of select="$other-terms/self::regulation-function/element()" />
      </regulation-function>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>


<xsl:function name="state:to-canonical-regulation-function">
  <xsl:param name="expr" as="element()" />
  <xsl:param as="element()+" name="vars" />
  <xsl:choose>
    <xsl:when test="$expr/self::mathml:apply[mathml:minus and count(element())=3]">
      <xsl:variable name="reg-func"
                    select="state:to-canonical-regulation-function
                              ($expr/self::mathml:apply/element()[3],$vars)" />
      <xsl:variable name="val" select="$expr/self::mathml:apply/element()[2]/self::mathml:cn" />
      <xsl:if test="exists($reg-func) and $val = '1'">
        <apply xmlns="http://www.w3.org/1998/Math/MathML">
          <minus />
          <xsl:copy-of select="$expr/self::mathml:apply/element()[2]" />
          <xsl:copy-of select="$reg-func" />
        </apply>
      </xsl:if>
    </xsl:when>
    <xsl:when test="$expr/self::mathml:apply/mathml:times">
      <xsl:variable name="reg-funcs">
        <apply xmlns="http://www.w3.org/1998/Math/MathML">
          <times />
          <xsl:for-each select="$expr/self::mathml:apply/element()[position()>1]">
            <xsl:copy-of select="state:to-canonical-regulation-function(.,$vars)" />
          </xsl:for-each>
        </apply>
      </xsl:variable>
      <xsl:if test="count($reg-funcs/mathml:apply/element()[position()>1])
                  = count($expr/self::mathml:apply/element()[position()>1])">
        <xsl:copy-of select="$reg-funcs" />
      </xsl:if>
    </xsl:when>
    <xsl:when test="$expr/self::mathml:piecewise">
      <xsl:copy-of select="state:to-canonical-step-function($expr,$vars)" />
    </xsl:when>
    <xsl:when test="$expr/self::mathml:apply/mathml:divide">
      <xsl:copy-of select="state:to-canonical-hill-function($expr,$vars)" />
    </xsl:when>
  </xsl:choose>
</xsl:function>


<xsl:function name="state:to-canonical-rate-parameter">
  <xsl:param name="expr" as="element()?" />
  <xsl:param as="element()+" name="vars" />
  <xsl:if test="$expr/self::mathml:ci and not($expr/text() = $vars/@id)">
    <xsl:copy-of select="$expr" />
  </xsl:if>
</xsl:function>


<xsl:function name="state:to-canonical-step-function">
  <xsl:param name="expr" as="element()" />
  <xsl:param as="element()+" name="vars" />
  <xsl:if test="count($expr/element()) = 2">
    <xsl:choose>
      <xsl:when test="$expr/element()[2]/self::mathml:piece">
        <xsl:variable name="piece1-value" select="$expr/mathml:piece[1]/element()[1]/self::mathml:cn" />
        <xsl:variable name="piece2-value" select="$expr/mathml:piece[2]/element()[1]/self::mathml:cn" />
        <xsl:variable name="piece1-op" select="$expr/mathml:piece[1]/mathml:apply/element()[1]" />
        <xsl:variable name="piece2-op" select="$expr/mathml:piece[2]/mathml:apply/element()[1]" />
        <xsl:variable name="piece1-var"
                      select="$expr/mathml:piece[1]/mathml:apply/element()
                                /self::mathml:ci[text()=$vars/@id]" />
        <xsl:variable name="piece2-var"
                      select="$expr/mathml:piece[2]/mathml:apply/element()
                                /self::mathml:ci[text()=$vars/@id]" />
        <xsl:variable name="piece1-param"
                      select="$expr/mathml:piece[1]/mathml:apply/element()
                                /self::mathml:ci[not(text()=$vars/@id)]" />
        <xsl:variable name="piece2-param"
                      select="$expr/mathml:piece[2]/mathml:apply/element()
                                /self::mathml:ci[not(text()=$vars/@id)]" />
        <xsl:variable name="test1"
                      select="($piece1-value='0' and $piece2-value='1')
                            or ($piece1-value='1' and $piece2-value='0')" />
        <xsl:variable name="test2"
                      select="count($piece1-var) = 1
                          and count($piece1-param) = 1
                          and count($piece2-var) = 1
                          and count($piece2-param) = 1" />
        <xsl:variable name="test3"
                      select="$piece1-var = $piece2-var
                          and $piece1-param = $piece2-param" />
        <xsl:variable name="test4">
          <xsl:variable name="pos-var1" as="xs:integer"
                        select="count($expr/mathml:piece[1]/mathml:apply/element()
                                /self::mathml:ci[following-sibling::* = $piece1-var])" />
          <xsl:variable name="pos-var2" as="xs:integer"
                        select="count($expr/mathml:piece[2]/mathml:apply/element()
                                /self::mathml:ci[following-sibling::* = $piece2-var])" />
          <xsl:choose>
            <xsl:when test="$pos-var1 = $pos-var2">
              <xsl:value-of select="(($piece1-op/self::mathml:lt or $piece1-op/self::mathml:leq)
                                  and ($piece2-op/self::mathml:gt or $piece2-op/self::mathml:geq))
                                  or (($piece1-op/self::mathml:gt or $piece1-op/self::mathml:geq)
                                  and ($piece2-op/self::mathml:lt or $piece2-op/self::mathml:leq))" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="(($piece1-op/self::mathml:lt or $piece1-op/self::mathml:leq)
                                  and ($piece2-op/self::mathml:lt or $piece2-op/self::mathml:leq))
                                  or (($piece1-op/self::mathml:gt or $piece1-op/self::mathml:geq)
                                  and ($piece2-op/self::mathml:gt or $piece2-op/self::mathml:geq))" />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:if test="$test1=true() and $test2=true() and $test3=true() and $test4=true()">
          <xsl:variable name="is-plus">
            <xsl:variable name="pos-var1" as="xs:integer"
                          select="count($expr/mathml:piece[1]/mathml:apply/element()
                                  /self::mathml:ci[following-sibling::* = $piece1-var])" />
            <xsl:choose>
              <xsl:when test="$piece1-value = '0'">
                <xsl:choose>
                  <xsl:when test="$pos-var1 = 0">
                    <xsl:value-of select="$piece1-op/self::mathml:lt or $piece1-op/self::mathml:leq" />
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="$piece1-op/self::mathml:gt or $piece1-op/self::mathml:geq" />
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>
              <xsl:otherwise>
                <xsl:choose>
                  <xsl:when test="$pos-var1 = 0">
                    <xsl:value-of select="$piece1-op/self::mathml:gt or $piece1-op/self::mathml:geq" />
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="$piece1-op/self::mathml:lt or $piece1-op/self::mathml:leq" />
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:choose>
            <xsl:when test="$is-plus = true()">
              <apply xmlns="http://www.w3.org/1998/Math/MathML">
                <csymbol definitionURL="http://www-gna.inrialpes.fr/gnaml/symbols/step-plus"
                         encoding="text">s+</csymbol>
                <xsl:copy-of select="$piece1-var" />
                <xsl:copy-of select="$piece1-param" />
              </apply>
            </xsl:when>
            <xsl:otherwise>
              <apply xmlns="http://www.w3.org/1998/Math/MathML">
                <csymbol definitionURL="http://www-gna.inrialpes.fr/gnaml/symbols/step-minus"
                         encoding="text">s-</csymbol>
                <xsl:copy-of select="$piece1-var" />
                <xsl:copy-of select="$piece1-param" />
              </apply>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="piece-value" select="$expr/mathml:piece/element()[1]/self::mathml:cn" />
        <xsl:variable name="piece-op" select="$expr/mathml:piece/mathml:apply/element()[1]" />
        <xsl:variable name="piece-var"
                      select="$expr/mathml:piece/mathml:apply/element()
                                /self::mathml:ci[text()=$vars/@id]" />
        <xsl:variable name="piece-param"
                      select="$expr/mathml:piece/mathml:apply/element()
                                /self::mathml:ci[not(text()=$vars/@id)]" />
        <xsl:if test="($piece-value='0' or $piece-value='1')
                  and ($piece-op/self::mathml:lt or $piece-op/self::mathml:leq
                                                  or $piece-op/self::mathml:gt
                                                  or $piece-op/self::mathml:geq)
                  and count($piece-var)=1
                  and count($piece-param)=1">
          <xsl:variable name="is-plus">
            <xsl:variable name="pos-var" as="xs:integer"
                          select="count($expr/mathml:piece/mathml:apply/element()
                                  /self::mathml:ci[following-sibling::* = $piece-var])" />
            <xsl:choose>
              <xsl:when test="$piece-value = '0'">
                <xsl:choose>
                  <xsl:when test="$pos-var = 0">
                    <xsl:value-of select="$piece-op/self::mathml:lt or $piece-op/self::mathml:leq" />
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="$piece-op/self::mathml:gt or $piece-op/self::mathml:geq" />
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>
              <xsl:otherwise>
                <xsl:choose>
                  <xsl:when test="$pos-var = 0">
                    <xsl:value-of select="$piece-op/self::mathml:gt or $piece-op/self::mathml:geq" />
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="$piece-op/self::mathml:lt or $piece-op/self::mathml:leq" />
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:choose>
            <xsl:when test="$is-plus = true()">
              <apply xmlns="http://www.w3.org/1998/Math/MathML">
                <csymbol definitionURL="http://www-gna.inrialpes.fr/gnaml/symbols/step-plus"
                         encoding="text">s+</csymbol>
                <xsl:copy-of select="$piece-var" />
                <xsl:copy-of select="$piece-param" />
              </apply>
            </xsl:when>
            <xsl:otherwise>
              <apply xmlns="http://www.w3.org/1998/Math/MathML">
                <csymbol definitionURL="http://www-gna.inrialpes.fr/gnaml/symbols/step-minus"
                         encoding="text">s-</csymbol>
                <xsl:copy-of select="$piece-var" />
                <xsl:copy-of select="$piece-param" />
              </apply>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:if>
</xsl:function>

<xsl:function name="state:to-canonical-hill-function">
  <xsl:param name="expr" as="element()" />
  <xsl:param as="element()+" name="vars" />
  <xsl:variable name="numerator" as="element()?"
                select="$expr/self::mathml:apply[mathml:divide]/element()[position()=2]
                          /self::mathml:apply[mathml:power]" />
  <xsl:variable name="num-ci" as="xs:string?"
                select="$numerator/element()[position()=2]/self::mathml:ci/text()" />
  <xsl:variable name="num-exp" as="xs:double?"
                select="xs:double($numerator/element()[position()=3]/self::mathml:cn/text())" />
  <xsl:variable name="denominator" as="element()?"
                select="$expr/self::mathml:apply[mathml:divide]/element()[position()=3]
                          /self::mathml:apply[mathml:plus and count(element())=3]" />
  <xsl:variable name="denom-1" as="element()?"
                select="$denominator/element()[position()=2]/self::mathml:apply[mathml:power]" />
  <xsl:variable name="denom-2" as="element()?"
                select="$denominator/element()[position()=3]/self::mathml:apply[mathml:power]" />
  <xsl:variable name="denom-ci-1" as="xs:string?"
                select="$denom-1/element()[position()=2]/self::mathml:ci/text()" />
  <xsl:variable name="denom-ci-2" as="xs:string?"
                select="$denom-2/element()[position()=2]/self::mathml:ci/text()" />
  <xsl:variable name="denom-exp-1" as="xs:double?"
                select="xs:double($denom-1/element()[position()=3]/self::mathml:cn/text())" />
  <xsl:variable name="denom-exp-2" as="xs:double?"
                select="xs:double($denom-2/element()[position()=3]/self::mathml:cn/text())" />
  <xsl:if test="exists($num-ci) and exists($num-exp) and exists($denom-ci-1) and exists($denom-ci-2)
                and $denom-exp-1=$num-exp and $denom-exp-2=$num-exp
                and ($num-ci=$denom-ci-1 or $num-ci=$denom-ci-2) and $denom-ci-1!=$denom-ci-2">
    <xsl:choose>
      <xsl:when test="$num-ci=$vars/@id and (not($denom-ci-1=$vars/@id) or not($denom-ci-2=$vars/@id))">
        <apply xmlns="http://www.w3.org/1998/Math/MathML">
          <csymbol definitionURL="http://www-gna.inrialpes.fr/gnaml/symbols/step-plus"
                    encoding="text">s+</csymbol>
          <ci><xsl:copy-of select="$num-ci" /></ci>
          <ci><xsl:copy-of select="if ($denom-ci-1=$num-ci) then $denom-ci-2 else $denom-ci-1" /></ci>
        </apply>
      </xsl:when>
      <xsl:when test="not($num-ci=$vars/@id) and (not($denom-ci-1=$vars/@id) or not($denom-ci-2=$vars/@id))">
        <apply xmlns="http://www.w3.org/1998/Math/MathML">
          <csymbol definitionURL="http://www-gna.inrialpes.fr/gnaml/symbols/step-minus"
                    encoding="text">s-</csymbol>
          <ci><xsl:copy-of select="if ($denom-ci-1=$num-ci) then $denom-ci-2 else $denom-ci-1" /></ci>
          <ci><xsl:copy-of select="$num-ci" /></ci>
        </apply>
      </xsl:when>
    </xsl:choose>
  </xsl:if>
</xsl:function>


<xsl:function name="state:to-canonical-degradation-expression">
  <xsl:param name="expr" as="element()?" />
  <xsl:param as="element()+" name="vars" />
  <xsl:param name="top-var" as="xs:string" />
  <xsl:choose>
    <xsl:when test="$expr/self::mathml:apply/mathml:times">
      <xsl:variable name="t-args" select="count($expr/self::mathml:apply/element()[position()>1])" />
      <xsl:choose>
        <xsl:when test="$t-args=2">
          <xsl:variable name="deg-term" as="element()*">
            <xsl:copy-of select="$expr/self::mathml:apply
                                   /mathml:ci[not(text()=$vars/@id)]" />
            <xsl:copy-of select="$expr/self::mathml:apply/element()[self::mathml:apply/mathml:plus]" />
          </xsl:variable>
          <xsl:variable name="var"
                        select="$expr/self::mathml:apply/mathml:ci[.=$top-var]" />
          <xsl:if test="count($deg-term)=1 and count($var)=1">
            <xsl:choose>
              <xsl:when test="$deg-term/self::mathml:apply/mathml:plus">
                <xsl:variable name="canonized-reg-plus">
                  <xsl:for-each select="$deg-term/self::mathml:apply/element()[position()>1]">
                    <xsl:copy-of select="state:to-canonical-degradation-term(.,$vars,$top-var)" />
                  </xsl:for-each>
                </xsl:variable>
                <xsl:if test="exists($canonized-reg-plus/element())
                          and count($deg-term/self::mathml:apply/element()[position()>1])
                                = count($canonized-reg-plus/element())">
                  <apply xmlns="http://www.w3.org/1998/Math/MathML">
                    <times />
                    <xsl:copy-of select="state:concat-plus($canonized-reg-plus/element())" />
                    <ci><xsl:value-of select="$top-var" /></ci>
                  </apply>
                </xsl:if>
              </xsl:when>
              <xsl:otherwise>
                <xsl:variable name="cano-deg-term"
                              select="state:to-canonical-degradation-term($deg-term,$vars,$top-var)" />
                <xsl:if test="exists($cano-deg-term)">
                  <apply xmlns="http://www.w3.org/1998/Math/MathML">
                    <times />
                    <xsl:copy-of select="$cano-deg-term" />
                    <ci><xsl:value-of select="$top-var" /></ci>
                  </apply>
                </xsl:if>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:if>
        </xsl:when>

        <xsl:when test="$t-args >= 3">
          <xsl:variable name="canonized-reg-func">
            <xsl:for-each select="$expr/self::mathml:apply/element()
                                    [position()>1 and not(self::mathml:ci)]">
              <xsl:copy-of select="state:to-canonical-regulation-function(.,$vars)" />
            </xsl:for-each>
          </xsl:variable>
          <xsl:variable name="var"
                        select="$expr/self::mathml:apply/mathml:ci[.=$top-var]" />
          <xsl:variable name="gamma">
            <xsl:for-each select="$expr/self::mathml:apply/mathml:ci">
              <xsl:copy-of select="state:to-canonical-rate-parameter(.,$vars)" />
            </xsl:for-each>
          </xsl:variable>
          <xsl:variable name="scum"
                        select="$expr/self::mathml:apply/mathml:ci[not(.=$var or .=$gamma)]" />
          <xsl:if test="(count($canonized-reg-func/element()) =
                         count($expr/self::mathml:apply/element()
                           [position()>1 and not(self::mathml:ci)]))
                    and count($var)=1
                    and count($gamma)=1
                    and empty($scum)">
            <apply xmlns="http://www.w3.org/1998/Math/MathML">
              <times />
              <xsl:copy-of select="$gamma" />
              <xsl:copy-of select="$canonized-reg-func" />
              <xsl:copy-of select="$var" />
            </apply>
          </xsl:if>
        </xsl:when>
      </xsl:choose>
    </xsl:when>
    <xsl:when test="$expr/self::mathml:apply/mathml:plus">
      <xsl:variable name="sub-exprs">
        <xsl:for-each select="$expr/self::mathml:apply/element()[position()>1]">
          <xsl:copy-of select="state:to-canonical-degradation-expression(.,$vars,$top-var)" />
        </xsl:for-each>
      </xsl:variable>
      <xsl:if test="count($sub-exprs/element())
                    = count($expr/self::mathml:apply/element()[position()>1])">
        <xsl:copy-of select="state:concat-deg($sub-exprs/element())" />
      </xsl:if>
    </xsl:when>
  </xsl:choose>
</xsl:function>


<xsl:function name="state:to-canonical-degradation-term">
  <xsl:param name="expr" as="element()?" />
  <xsl:param as="element()+" name="vars" />
  <xsl:param name="top-var" as="xs:string" />
  <xsl:choose>
    <xsl:when test="$expr/self::mathml:ci">
      <xsl:copy-of select="state:to-canonical-rate-parameter($expr,$vars)" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:if test="count($expr/self::mathml:apply/mathml:ci) = 1">
        <xsl:variable name="canonized-reg-func">
          <xsl:for-each select="$expr/self::mathml:apply/element()[position()>1 and not(self::mathml:ci)]">
            <xsl:copy-of select="state:to-canonical-regulation-function(.,$vars)" />
          </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="canonized-rate-param" select="state:to-canonical-rate-parameter($expr/self::mathml:apply/element()[position()>1 and self::mathml:ci],$vars)" />
        <xsl:if test="$expr/self::mathml:apply/mathml:times
                  and count($canonized-rate-param)=1
                  and count($canonized-reg-func/element())
                        = count($expr/self::mathml:apply/element()
                                  [position()>1 and not(self::mathml:ci)])">
          <apply xmlns="http://www.w3.org/1998/Math/MathML">
            <times />
            <xsl:copy-of select="$canonized-rate-param" />
            <xsl:copy-of select="$canonized-reg-func" />
          </apply>
        </xsl:if>
      </xsl:if>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>


<xsl:function name="state:concat-deg">
  <xsl:param name="exprs" as="element()*" />
  <xsl:choose>
    <xsl:when test="count($exprs) > 1">
      <apply xmlns="http://www.w3.org/1998/Math/MathML">
        <times />
        <apply>
          <plus />
          <xsl:for-each select="$exprs">
            <xsl:choose>
              <xsl:when test="self::mathml:apply/mathml:times">
                <xsl:choose>
                  <xsl:when test="count(self::mathml:apply/element()[position()>1])=2">
                    <xsl:copy-of select="self::mathml:apply/element()[position()=2]" />
                  </xsl:when>
                  <xsl:otherwise>
                    <apply xmlns="http://www.w3.org/1998/Math/MathML">
                      <xsl:copy-of select="self::mathml:apply/element()[position()!=last()]" />
                    </apply>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>
              <xsl:otherwise>
                <xsl:copy-of select="." />
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each>
        </apply>
        <xsl:copy-of select="$exprs[1]/self::mathml:apply/mathml:ci[position()=last()]" />
      </apply>
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy-of select="$exprs" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

</xsl:stylesheet>