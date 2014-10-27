<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:sbml="http://www.sbml.org/sbml/level2/version3"
                xmlns:mathml="http://www.w3.org/1998/Math/MathML"
                xmlns:gnaml="http://www-gna.inrialpes.fr/gnaml/version1"
                xmlns:extrinit="http://www-gna.inrialpes.fr/xsl/extract-initial-conditions"
                xmlns:join="http://www-gna.inrialpes.fr/xsl/join-gnaml"
                xmlns:varchk="http://www-gna.inrialpes.fr/xsl/variable-check"
                xmlns:order="http://www-gna.inrialpes.fr/xsl/build_order"
                xmlns:utils="http://www-gna.inrialpes.fr/xsl/utils"
                xmlns:x="http://www-gna.inrialpes.fr/xsl/structs"
                exclude-result-prefixes="#all">

<xsl:import href="build_order_l2v3.xsl" />
<xsl:import href="join_gnaml_l2v3.xsl" />
<xsl:import href="variable_check_l2v3.xsl" />


<xsl:function name="extrinit:extract-initial-conditions">
  <xsl:param name="sbml" as="element()" />
  <xsl:param name="gnaml" as="element()" />
  <xsl:param name="graphs-map" as="element()" />
  <xsl:variable name="new-gnaml" as="element()">
    <gnaml version="1.0" xmlns="http://www-gna.inrialpes.fr/gnaml/version1">
      <xsl:variable name="init-conds" as="element()*">
        <xsl:for-each select="$gnaml//gnaml:state-variable">
          <xsl:variable name="state-var-info" as="element()" select="." />
          <xsl:variable name="init-cond" as="element()*"
                        select="extrinit:select-from-order($graphs-map/x:key[@id=$state-var-info/@id]/*,
                                                           $state-var-info)" />
          <xsl:if test="extrinit:check-consistency($init-cond,$state-var-info)=true()">
            <xsl:copy-of select="$init-cond" />
          </xsl:if>
        </xsl:for-each>
      </xsl:variable>
      <xsl:if test="exists($init-conds)">
        <initial-conditions id="{$gnaml//gnaml:model/@id}">
          <xsl:copy-of select="$init-conds" />
        </initial-conditions>
      </xsl:if>
    </gnaml>
  </xsl:variable>
  <xsl:copy-of select="join:join-gnaml($gnaml,$new-gnaml)" />
</xsl:function>


<xsl:function name="extrinit:extract-initial-conditions-values">
  <xsl:param name="sbml" as="element()" />
  <xsl:param name="gnaml" as="element()" />
  <xsl:param name="order-values" as="element()" />
  <xsl:variable name="new-gnaml" as="element()">
    <gnaml version="1.0" xmlns="http://www-gna.inrialpes.fr/gnaml/version1">
      <xsl:variable name="init-conds" as="element()*">
        <xsl:for-each select="$gnaml//gnaml:state-variable">
          <xsl:variable name="state-var-info" as="element()" select="." />
          <xsl:variable name="var-value" as="xs:double"
                        select="if (exists($order-values/x:param[mathml:ci = $state-var-info/@id]/@value))
                                then $order-values/x:param[mathml:ci = $state-var-info/@id]/@value
                                else -1.0" />
          <xsl:if test="$var-value > 0.0">
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
                <xsl:if test="$state-var-info/gnaml:list-of-degradation-parameters
                                /gnaml:degradation-parameter/@id = ./mathml:ci/text()">
                  <xsl:copy-of select="position()" />
                </xsl:if>
              </xsl:for-each>
            </xsl:variable>
            <xsl:variable name="degradation-order" as="element()">
              <x:params-ordered-through-values>
                <xsl:copy-of select="$order-values/x:param[position()=$degradation-indices]" />
              </x:params-ordered-through-values>
            </xsl:variable>
            <xsl:variable name="init-cond" as="element()*"
                          select="extrinit:select-from-order-values($thresholds-order,$synthesis-order,
                                                                    $degradation-order,$var-value,
                                                                    $state-var-info)" />
            <xsl:if test="extrinit:check-consistency($init-cond,$state-var-info)=true()
                          and exists($state-var-info/gnaml:parameter-inequalities)">
              <xsl:copy-of select="$init-cond" />
            </xsl:if>
          </xsl:if>
        </xsl:for-each>
      </xsl:variable>
      <xsl:if test="exists($init-conds)">
        <initial-conditions id="{$gnaml//gnaml:model/@id}">
          <xsl:copy-of select="$init-conds" />
        </initial-conditions>
      </xsl:if>
    </gnaml>
  </xsl:variable>
  <xsl:copy-of select="join:join-gnaml($gnaml,$new-gnaml)" />
</xsl:function>


<xsl:function name="extrinit:select-from-order-values">
  <xsl:param name="thresholds-order" as="element()" />
  <xsl:param name="synthesis-order" as="element()" />
  <xsl:param name="degradation-order" as="element()" />
  <xsl:param name="var-value" as="xs:double" />
  <xsl:param name="state-var-info" as="element()" />
  <xsl:variable name="variable" as="element()">
    <ci xmlns="http://www.w3.org/1998/Math/MathML">
      <xsl:value-of select="$state-var-info/@id" />
    </ci>
  </xsl:variable>
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
  <xsl:variable name="lower" as="element()*"
                select="$all-params-order/x:param[@value &lt;= $var-value]" />
  <xsl:variable name="upper" as="element()*"
                select="$all-params-order/x:param[@value >= $var-value]" />
  <xsl:variable name="lower-bound" as="element()?">
    <xsl:choose>
      <xsl:when test="exists($lower)">
        <xsl:copy-of select="$lower[last()]/mathml:*" />
      </xsl:when>
      <xsl:otherwise>
        <ci xmlns="http://www.w3.org/1998/Math/MathML">
          <xsl:value-of select="$state-var-info/gnaml:zero-parameter/@id" />
        </ci>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="upper-bound" as="element()?">
    <xsl:choose>
      <xsl:when test="exists($upper)">
        <xsl:copy-of select="$upper[1]/mathml:*" />
      </xsl:when>
      <xsl:otherwise>
        <ci xmlns="http://www.w3.org/1998/Math/MathML">
          <xsl:value-of select="$state-var-info/gnaml:box-parameter/@id" />
        </ci>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:choose>
    <xsl:when test="$lower-bound = $upper-bound">
      <constraint xmlns="http://www-gna.inrialpes.fr/gnaml/version1">
        <math xmlns="http://www.w3.org/1998/Math/MathML">
          <apply>
            <eq />
            <xsl:copy-of select="$variable" />
            <xsl:copy-of select="$lower-bound" />
          </apply>
        </math>
      </constraint>
    </xsl:when>
    <xsl:otherwise>
      <constraint xmlns="http://www-gna.inrialpes.fr/gnaml/version1">
        <math xmlns="http://www.w3.org/1998/Math/MathML">
          <apply>
            <gt xmlns="http://www.w3.org/1998/Math/MathML" />
            <xsl:copy-of select="$variable" />
            <xsl:copy-of select="$lower-bound" />
          </apply>
        </math>
      </constraint>
      <constraint xmlns="http://www-gna.inrialpes.fr/gnaml/version1">
        <math xmlns="http://www.w3.org/1998/Math/MathML">
          <apply>
            <lt xmlns="http://www.w3.org/1998/Math/MathML" />
            <xsl:copy-of select="$variable" />
            <xsl:copy-of select="$upper-bound" />
          </apply>
        </math>
      </constraint>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>


<xsl:function name="extrinit:select-from-order">
  <xsl:param name="order-graph" as="element()" />
  <xsl:param name="state-var-info" as="element()" />
  <xsl:variable name="variable" as="element()">
    <ci xmlns="http://www.w3.org/1998/Math/MathML">
      <xsl:value-of select="$state-var-info/@id" />
    </ci>
  </xsl:variable>
  <xsl:variable name="params" as="element()*">
    <xsl:for-each select="$order-graph/x:vertices/(mathml:ci|mathml:apply)">
      <xsl:if test="varchk:check-term(.,$state-var-info)=true()">
        <xsl:copy-of select="." />
      </xsl:if>
    </xsl:for-each>
    <xsl:copy-of select="$variable" />
  </xsl:variable>
  <xsl:variable name="scc-result" as="element()"
                select="order:isolate-SCC($order-graph)" />
  <xsl:variable name="var-equalities" as="element()*"
                select="$scc-result/x:vertices/mathml:apply[*=$variable]
                         /mathml:*[position()>1 and .!=$variable]" />
  <xsl:choose>
    <xsl:when test="count($var-equalities) = 1">
      <constraint xmlns="http://www-gna.inrialpes.fr/gnaml/version1">
        <math xmlns="http://www.w3.org/1998/Math/MathML">
          <apply>
            <eq />
            <xsl:copy-of select="$variable" />
            <xsl:copy-of select="$var-equalities" />
          </apply>
        </math>
      </constraint>
    </xsl:when>
    <xsl:when test="count($var-equalities) > 1">
    </xsl:when>
    <xsl:otherwise>
      <xsl:variable name="var-idx" as="xs:integer*"
                    select="index-of($order-graph/x:vertices/*,$variable)" />
      <xsl:if test="exists($var-idx)">
        <xsl:variable name="linking-graph" as="element()"
                      select="extrinit:linking-graph($order-graph,$var-idx)" />
        <xsl:variable name="left" as="element()*"
                      select="$scc-result/x:vertices/*[.=extrinit:absolute-maximum($linking-graph)]" />
        <xsl:variable name="linked-graph" as="element()"
                      select="extrinit:linked-graph($order-graph,$var-idx)" />
        <xsl:variable name="right" as="element()*"
                      select="$scc-result/x:vertices/*[.=extrinit:absolute-minimum($linked-graph)]" />
        <xsl:if test="exists($left)">
          <xsl:variable name="left-op" as="xs:integer"
                        select="$order-graph/x:matrix
                                  /*[(index-of($order-graph/x:vertices/*,$left) 
                                      - 1)*count($order-graph/x:vertices/*) + $var-idx]" />
          <constraint xmlns="http://www-gna.inrialpes.fr/gnaml/version1">
            <math xmlns="http://www.w3.org/1998/Math/MathML">
              <apply>
                <xsl:choose>
                  <xsl:when test="$left-op=2">
                    <gt xmlns="http://www.w3.org/1998/Math/MathML" />
                  </xsl:when>
                  <xsl:when test="$left-op=1">
                    <geq xmlns="http://www.w3.org/1998/Math/MathML" />
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:message terminate="yes">[FATAL] Unexpected error for initial conditions</xsl:message>
                  </xsl:otherwise>
                </xsl:choose>
                <xsl:copy-of select="$variable" />
                <xsl:copy-of select="$left" />
              </apply>
            </math>
          </constraint>
        </xsl:if>
        <xsl:if test="exists($right)">
          <constraint xmlns="http://www-gna.inrialpes.fr/gnaml/version1">
            <math xmlns="http://www.w3.org/1998/Math/MathML">
              <apply>
                <xsl:variable name="right-op" as="xs:integer"
                              select="$order-graph/x:matrix
                                        /*[($var-idx - 1)*count($order-graph/x:vertices/*)
                                            + index-of($order-graph/x:vertices/*,$right)]" />
                <xsl:choose>
                  <xsl:when test="$right-op=2">
                    <lt xmlns="http://www.w3.org/1998/Math/MathML" />
                  </xsl:when>
                  <xsl:when test="$right-op=1">
                    <leq xmlns="http://www.w3.org/1998/Math/MathML" />
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:message terminate="yes">[FATAL] Unexpected error for initial conditions</xsl:message>
                  </xsl:otherwise>
                </xsl:choose>
                <xsl:copy-of select="$variable" />
                <xsl:copy-of select="$right" />
              </apply>
            </math>
          </constraint>
        </xsl:if>
      </xsl:if>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>


<xsl:function name="extrinit:linking-graph">
  <xsl:param name="graph" as="element()" />
  <xsl:param name="index" as="xs:integer" />
  <xsl:variable name="length" as="xs:integer" select="count($graph/x:vertices/*)" />
  <xsl:variable name="indices" as="xs:integer*">
    <xsl:for-each select="remove(1 to $length,$index)">
      <xsl:variable name="idx-xy" as="xs:integer" select="(. - 1)*$length + $index" />
      <xsl:if test="$graph/x:matrix/*[$idx-xy] != 0">
        <xsl:copy-of select="." />
      </xsl:if>
    </xsl:for-each>
  </xsl:variable>
  <xsl:copy-of select="order:projection($graph,$indices)" />
</xsl:function>


<xsl:function name="extrinit:linked-graph">
  <xsl:param name="graph" as="element()" />
  <xsl:param name="index" as="xs:integer" />
  <xsl:variable name="length" as="xs:integer" select="count($graph/x:vertices/*)" />
  <xsl:variable name="indices" as="xs:integer*">
    <xsl:for-each select="remove(1 to $length,$index)">
      <xsl:variable name="idx-yx" as="xs:integer" select="($index - 1)*$length + ." />
      <xsl:if test="$graph/x:matrix/*[$idx-yx] != 0">
        <xsl:copy-of select="." />
      </xsl:if>
    </xsl:for-each>
  </xsl:variable>
  <xsl:copy-of select="order:projection($graph,$indices)" />
</xsl:function>


<xsl:function name="extrinit:absolute-maximum">
  <xsl:param name="graph" as="element()" />
  <xsl:variable name="length" as="xs:integer" select="count($graph/x:vertices/*)" />
  <xsl:variable name="index" as="xs:integer*">
    <xsl:for-each select="1 to $length">
      <xsl:variable name="j" as="xs:integer" select="." />
      <xsl:if test="sum(for $i in remove(1 to $length,$j)
                          return if ($graph/x:matrix/*[position()=($i - 1)*$length + $j] != 0)
                                 then 1
                                 else 0) >= $length - 1">
        <xsl:sequence select="." />
      </xsl:if>
    </xsl:for-each>
  </xsl:variable>
  <xsl:if test="count($index)=1">
    <xsl:variable name="vertex" as="element()"
                  select="$graph/x:vertices/*[position()=$index]" />
    <xsl:if test="not($vertex/self::mathml:apply/mathml:eq)">
      <xsl:copy-of select="$vertex" />
    </xsl:if>
  </xsl:if>
</xsl:function>


<xsl:function name="extrinit:absolute-minimum">
  <xsl:param name="graph" as="element()" />
  <xsl:variable name="length" as="xs:integer" select="count($graph/x:vertices/*)" />
  <xsl:variable name="index" as="xs:integer*">
    <xsl:for-each select="1 to $length">
      <xsl:variable name="j" as="xs:integer" select="." />
      <xsl:if test="sum(for $i in remove(1 to $length,$j)
                            return if ($graph/x:matrix/*[position()=($j - 1)*$length + $i] != 0)
                                   then 1
                                   else 0) >= $length - 1">
        <xsl:sequence select="." />
      </xsl:if>
    </xsl:for-each>
  </xsl:variable>
  <xsl:if test="count($index)=1">
    <xsl:variable name="vertex" as="element()"
                  select="$graph/x:vertices/*[position()=$index]" />
    <xsl:if test="not($vertex/self::mathml:apply/mathml:eq)">
      <xsl:copy-of select="$vertex" />
    </xsl:if>
  </xsl:if>
</xsl:function>


<xsl:function name="extrinit:check-consistency">
  <xsl:param name="init-conds" as="element()*" />
  <xsl:param name="state-var-info" as="element()" />
  <xsl:variable name="test-upper" as="xs:boolean"
                select="count($init-conds/mathml:math/mathml:apply/(mathml:leq|mathml:lt)) &lt; 2" />
  <xsl:variable name="test-lower" as="xs:boolean"
                select="count($init-conds/mathml:math/mathml:apply/(mathml:geq|mathml:gt)) &lt; 2" />
  <xsl:choose>
    <xsl:when test="$test-upper = true() and $test-lower = true()">
      <xsl:variable name="compatible-order" as="xs:boolean">
        <xsl:choose>
          <xsl:when test="exists($state-var-info/gnaml:parameter-inequalities)">
            <xsl:variable name="low-idx" as="xs:integer">
              <xsl:variable name="apply" as="element()?"
                            select="$init-conds/mathml:math/mathml:apply[mathml:geq|mathml:gt]" />
              <xsl:choose>
                <xsl:when test="exists($apply)">
                  <xsl:variable name="idx" as="xs:integer?"
                                select="index-of($state-var-info/gnaml:parameter-inequalities
                                                    /mathml:math/mathml:apply/mathml:*,
                                                $apply/element()[3])" />
                  <xsl:value-of select="if (exists($idx)) then $idx else -1" />
                </xsl:when>
                <xsl:otherwise><xsl:value-of select="-1" /></xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <xsl:variable name="up-idx" as="xs:integer">
              <xsl:variable name="apply" as="element()?"
                            select="$init-conds/mathml:math/mathml:apply[mathml:leq|mathml:lt]" />
              <xsl:choose>
                <xsl:when test="exists($apply)">
                  <xsl:variable name="idx" as="xs:integer?"
                                select="index-of($state-var-info/gnaml:parameter-inequalities
                                                    /mathml:math/mathml:apply/mathml:*,
                                                $apply/element()[3])" />
                  <xsl:value-of select="if (exists($idx)) then $idx else -1" />
                </xsl:when>
                <xsl:otherwise><xsl:value-of select="-1" /></xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <xsl:choose>
              <xsl:when test="$low-idx != -1 and $up-idx != -1">
                <xsl:value-of select="$low-idx &lt; $up-idx" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="true()" />
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="true()" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="zero-ok" as="xs:boolean">
        <xsl:variable name="last" as="xs:string?"
                      select="$init-conds/mathml:math/mathml:apply[mathml:leq|mathml:lt]
                                /mathml:*[last()]" />
        <xsl:value-of select="empty($state-var-info/gnaml:zero-parameter[@id = $last])" />
      </xsl:variable>
      <xsl:variable name="box-ok" as="xs:boolean">
        <xsl:variable name="last" as="xs:string?"
                      select="$init-conds/mathml:math/mathml:apply[mathml:geq|mathml:gt]
                                /mathml:*[last()]" />
        <xsl:value-of select="empty($state-var-info/gnaml:box-parameter[@id = $last])" />
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="$compatible-order = true() and $zero-ok = true() and $box-ok = true()">
          <xsl:value-of select="true()" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="false()" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="false()" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

</xsl:stylesheet>