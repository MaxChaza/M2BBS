<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xhtml="http://www.w3.org/1999/xhtml"
                xmlns:mathml="http://www.w3.org/1998/Math/MathML"
                xmlns:gnaml="http://www-gna.inrialpes.fr/gnaml/version1"
                xmlns:sbml="http://www.sbml.org/sbml/level2"
                xmlns:order="http://www-gna.inrialpes.fr/xsl/build_order"
                xmlns:varchk="http://www-gna.inrialpes.fr/xsl/variable-check"
                xmlns:x="http://www-gna.inrialpes.fr/xsl/structs"
                xmlns:math="http://exslt.org/math"
                xmlns:utils="http://www-gna.inrialpes.fr/xsl/utils"
                exclude-result-prefixes="#all">

<xsl:import href="utils_l2v1.xsl" />
<xsl:import href="variable_check_l2v1.xsl" />


<xsl:function name="order:all-stuff-order">
  <xsl:param name="sbml" as="element()" />
  <xsl:param name="extracted-var-info" as="element()" />
  <xsl:variable name="nn-relations" as="element()*"
                select="order:nn-relations($sbml)" />
  <xsl:variable name="classified" as="element()"
                select="order:classify-relations($nn-relations,$sbml/empty,$extracted-var-info)" />
  <xsl:variable name="num-rels" as="element()*" select="order:init-order-numeric($sbml)" />
  <xsl:variable name="num-closure" as="element()" select="order:transitive-closure($num-rels)" />
  <xsl:variable name="indices" as="xs:integer*">
    <xsl:for-each select="$num-closure/x:vertices/*[not(self::mathml:cn)]">
      <xsl:sequence select="index-of($num-closure/x:vertices/*,.)" />
    </xsl:for-each>
  </xsl:variable>
  <xsl:variable name="from-num-graph" as="element()"
                select="order:projection($num-closure,$indices)" />
  <xsl:variable name="rels-from-num" as="element()*"
                select="order:relations-from-graph($from-num-graph)" />
  <xsl:choose>
    <xsl:when test="$classified/self::x:error">
      <xsl:variable name="relations" as="element()*">
        <xsl:copy-of select="$rels-from-num" />
        <xsl:copy-of select="order:init-order-constraints
                              ($sbml/sbml:model/sbml:listOfConstraints/sbml:constraint/mathml:math,false())" />
        <xsl:copy-of select="order:init-order-assignments
                              ($sbml/sbml:model/sbml:listOfInitialAssignments/sbml:initialAssignment,false())" />
      </xsl:variable>
      <xsl:variable name="biggraph" as="element()"
                    select="order:transitive-closure($relations)" />
      <xsl:choose>
        <xsl:when test="$biggraph/self::x:error">
          <xsl:copy-of select="$biggraph" />
        </xsl:when>
        <xsl:otherwise>
          <x:map>
            <xsl:for-each select="$extracted-var-info/gnaml:model/(gnaml:state-variable|gnaml:input-variable)">
              <xsl:variable name="var-info" select="." />
              <x:key id="{@id}">
                <xsl:variable name="indices" as="xs:integer*">
                  <xsl:for-each select="$biggraph/x:vertices/(mathml:ci|mathml:apply)">
                    <xsl:if test="varchk:check-term(.,$var-info)=true() or self::mathml:ci/text()=$var-info/@id">
                      <xsl:copy-of select="position()" />
                    </xsl:if>
                  </xsl:for-each>
                </xsl:variable>
                <xsl:copy-of select="order:projection($biggraph,$indices)" />
              </x:key>
            </xsl:for-each>
          </x:map>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <x:map>
        <xsl:for-each select="$extracted-var-info/gnaml:model/(gnaml:state-variable|gnaml:input-variable)">
          <xsl:variable name="var-info" select="." />
          <x:key id="{@id}">
            <xsl:variable name="relations" as="element()*">
              <xsl:copy-of select="$classified/x:key[@id=$var-info/@id]/*" />
              <xsl:for-each select="$rels-from-num">
                <xsl:if test="(varchk:check-term(x:from/*,$var-info)=true() or x:from/mathml:ci/text()=$var-info/@id)
                          and (varchk:check-term(x:to/*,$var-info)=true() or x:to/mathml:ci/text()=$var-info/@id)">
                  <xsl:copy-of select="." />
                </xsl:if>
              </xsl:for-each>
            </xsl:variable>
            <xsl:copy-of select="order:transitive-closure($relations)" />
          </x:key>
        </xsl:for-each>
      </x:map>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>


<xsl:function name="order:nn-relations">
  <xsl:param name="sbml" as="element()" />
  <xsl:copy-of select="order:init-order-constraints
                        ($sbml/sbml:model/sbml:listOfConstraints/sbml:constraint/mathml:math,false())" />
  <xsl:copy-of select="order:init-order-assignments
                        ($sbml/sbml:model/sbml:listOfInitialAssignments/sbml:initialAssignment,false())" />
</xsl:function>


<xsl:function name="order:relations-from-graph">
  <xsl:param name="graph" as="element()" />
  <xsl:variable name="length" as="xs:integer" select="count($graph/x:vertices/*)" />
  <xsl:for-each select="1 to $length">
    <xsl:variable name="x" as="xs:integer" select="." />
    <xsl:for-each select="1 to $length">
      <xsl:variable name="y" as="xs:integer" select="." />
      <xsl:variable name="idx" as="xs:integer" select="xs:integer(($x - 1)  * $length + $y)" />
      <xsl:variable name="cell" as="element()" select="$graph/x:matrix/x:cell[$idx]" />
      <xsl:if test="$cell!=0">
        <x:rel type="{$cell}">
          <x:from>
            <xsl:copy-of select="$graph/x:vertices/element()[position()=$x]" />
          </x:from>
          <x:to>
            <xsl:copy-of select="$graph/x:vertices/element()[position()=$y]" />
          </x:to>
        </x:rel>
      </xsl:if>
    </xsl:for-each>
  </xsl:for-each>
</xsl:function>


<xsl:function name="order:classify-relations">
  <xsl:param name="relations" as="element()*" />
  <xsl:param name="classified" as="element()?" />
  <xsl:param name="gnaml" as="element()" />
  <xsl:choose>
    <xsl:when test="empty($relations)">
      <xsl:choose>
        <xsl:when test="exists($classified)">
          <xsl:copy-of select="$classified" />
        </xsl:when>
        <xsl:otherwise>
          <x:map />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:variable name="rel" as="element()" select="$relations[1]" />
      <xsl:variable name="left" as="element()" select="$rel/x:from/*" />
      <xsl:variable name="left-id" as="xs:string?"
                    select="for $v in $gnaml//(gnaml:state-variable|gnaml:input-variable) return
                              if (varchk:check-term($left,$v)=true() or $left=$v/@id)
                              then $v/@id else $v/nowhere" />
      <xsl:variable name="right" as="element()" select="$rel/x:to/*" />
      <xsl:variable name="right-id" as="xs:string?"
                    select="for $v in $gnaml//(gnaml:state-variable|gnaml:input-variable) return
                              if (varchk:check-term($right,$v)=true() or $right=$v/@id)
                              then $v/@id else $v/nowhere" />
      <xsl:choose>
        <xsl:when test="exists($left-id) and exists($right-id) and $left-id=$right-id">
          <xsl:variable name="classified_updated" as="element()">
            <x:map>
              <xsl:copy-of select="$classified/x:key[@id!=$left-id]" />
              <x:key id="{$left-id}">
                <xsl:copy-of select="$classified/x:key[@id=$left-id]/*" />
                <xsl:copy-of select="$rel" />
              </x:key>
            </x:map>
          </xsl:variable>
          <xsl:copy-of select="order:classify-relations($relations[position()>1],
                                                        $classified_updated,
                                                        $gnaml)" />
        </xsl:when>
        <xsl:when test="(some $p in $left/descendant-or-self::mathml:ci/text()
                        satisfies empty($gnaml//(gnaml:threshold-parameter|
                                                 gnaml:synthesis-parameter|
                                                 gnaml:degradation-parameter|
                                                 gnaml:zero-parameter|
                                                 gnaml:box-paramter)[@id=$p]))
                     or (some $p in $right/descendant-or-self::mathml:ci/text()
                        satisfies empty($gnaml//(gnaml:threshold-parameter|
                                                 gnaml:synthesis-parameter|
                                                 gnaml:degradation-parameter|
                                                 gnaml:zero-parameter|
                                                 gnaml:box-paramter)[@id=$p]))">
          <xsl:copy-of select="order:classify-relations($relations[position()>1],
                                                        $classified,
                                                        $gnaml)" />
        </xsl:when>
        <xsl:otherwise>
          <x:error />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>


<xsl:function name="order:init-order-numeric">
  <xsl:param name="sbml" as="element()" />
  <xsl:variable name="relations" as="element()*">
    <xsl:copy-of select="order:init-order-constraints
                          ($sbml/sbml:model/sbml:listOfConstraints/sbml:constraint/mathml:math,true())" />
    <xsl:copy-of select="order:init-order-values
                          ($sbml/sbml:model/(
                              sbml:listOfParameters/sbml:parameter[exists(@value)]
                            | sbml:listOfSpecies/sbml:species[not(empty(@initialAmount)
                                                              and empty(@initialConcentration))]),
                            $sbml/sbml:model/sbml:listOfInitialAssignments/sbml:initialAssignment)" />
    <xsl:copy-of select="order:init-order-assignments
                          ($sbml/sbml:model/sbml:listOfInitialAssignments/sbml:initialAssignment,true())" />
  </xsl:variable>
  <xsl:copy-of select="order:init-order-link-values($relations)" />
</xsl:function>




<xsl:function name="order:init-order-constraints">
  <xsl:param name="constraints" as="element()*" />
  <xsl:param name="with-numeric-values" as="xs:boolean" />
  <xsl:if test="exists($constraints)">
    <xsl:variable name="left-elem" as="element()"
                  select="$constraints[position()=last()]/mathml:apply/element()[2]" />
    <xsl:variable name="right-elem" as="element()"
                  select="$constraints[position()=last()]/mathml:apply/element()[3]" />
    <xsl:variable name="op" as="element()"
                  select="$constraints[position()=last()]/mathml:apply/element()[1]" />
    <xsl:copy-of select="order:init-order-constraints
                          ($constraints[position()!=last()],$with-numeric-values)" />
    <xsl:if test="($with-numeric-values = true()
                    and ($left-elem/self::mathml:cn or $right-elem/self::mathml:cn))
               or ($with-numeric-values = false()
                      and not($left-elem/self::mathml:cn and $right-elem/self::mathml:cn))">
      <x:rel type="{if ($op/self::mathml:leq or $op/self::mathml:geq) then 1 else 2}">
        <x:from>
          <xsl:copy-of select="if ($op/self::mathml:leq or $op/self::mathml:lt)
                                then $left-elem
                                else $right-elem" />
        </x:from>
        <x:to>
          <xsl:copy-of select="if ($op/self::mathml:leq or $op/self::mathml:lt)
                              then $right-elem
                              else $left-elem" />
        </x:to>
      </x:rel>
    </xsl:if>
  </xsl:if>
</xsl:function>


<xsl:function name="order:init-order-values">
  <xsl:param name="assignments" as="element()*" />
  <xsl:param name="init-assgnts" as="element()*" />
  <xsl:if test="exists($assignments)">
    <xsl:choose>
      <xsl:when test="$init-assgnts[@symbol=$assignments[position()=last()]/@id]">
        <xsl:copy-of select="order:init-order-values($assignments[position()!=last()],$init-assgnts)" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="variable" as="element()">
          <ci xmlns="http://www.w3.org/1998/Math/MathML">
            <xsl:value-of select="$assignments[position()=last()]/@id" />
          </ci>
        </xsl:variable>
        <xsl:variable name="value" as="element()">
          <xsl:variable name="assgnt" as="element()" select="$assignments[position()=last()]" />
          <cn xmlns="http://www.w3.org/1998/Math/MathML">
            <xsl:value-of select="if ($assgnt/self::sbml:parameter)
                                  then $assgnt/@value
                                  else if ($assgnt/self::sbml:species[exists(@initialAmount)])
                                  then $assgnt/@initialAmount
                                  else $assgnt/@initialConcentration" />
          </cn>
        </xsl:variable>
        <xsl:copy-of select="order:init-order-values
                              ($assignments[position()!=last()],$init-assgnts)" />
        <x:rel type="1">
          <x:from><xsl:copy-of select="$variable" /></x:from>
          <x:to><xsl:copy-of select="$value" /></x:to>
        </x:rel>
        <x:rel type="1">
          <x:from><xsl:copy-of select="$value" /></x:from>
          <x:to><xsl:copy-of select="$variable" /></x:to>
        </x:rel>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:if>
</xsl:function>


<xsl:function name="order:init-order-assignments">
  <xsl:param name="assignments" as="element()*" />
  <xsl:param name="with-numeric-values" as="xs:boolean" />
  <xsl:if test="exists($assignments)">
    <xsl:variable name="variable" as="element()">
      <ci xmlns="http://www.w3.org/1998/Math/MathML">
        <xsl:value-of select="$assignments[position()=last()]/@symbol" />
      </ci>
    </xsl:variable>
    <xsl:variable name="value" as="element()" select="$assignments[position()=last()]/mathml:math/*" />
    <xsl:copy-of select="order:init-order-assignments
                          ($assignments[position()!=last()],$with-numeric-values)" />
    <xsl:if test="($value/self::mathml:cn and $with-numeric-values = true())
               or (not($value/self::mathml:cn) and $with-numeric-values = false())">
      <x:rel type="1">
        <x:from><xsl:copy-of select="$value"/></x:from>
        <x:to><xsl:copy-of select="$variable"/></x:to>
      </x:rel>
      <x:rel type="1">
        <x:from><xsl:copy-of select="$variable"/></x:from>
        <x:to><xsl:copy-of select="$value"/></x:to>
      </x:rel>
    </xsl:if>
  </xsl:if>
</xsl:function>


<xsl:function name="order:init-order-link-values">
  <xsl:param name="relations" as="element()*" />
    <xsl:variable name="values" as="xs:double*">
      <xsl:perform-sort select="$relations/(x:from|x:to)/mathml:cn/text()">
        <xsl:sort select="." />
      </xsl:perform-sort>
    </xsl:variable>
    <xsl:variable name="distinct-values" as="xs:double*" select="distinct-values($values)" />
    <xsl:copy-of select="$relations" />
    <xsl:variable name="distinct-cns" as="element()*">
      <xsl:for-each select="$distinct-values">
        <cn xmlns="http://www.w3.org/1998/Math/MathML"><xsl:value-of select="." /></cn>
      </xsl:for-each>
    </xsl:variable>
    <xsl:copy-of select="order:init-order-link-values-intern($distinct-cns)" />
</xsl:function>

<xsl:function name="order:init-order-link-values-intern">
  <xsl:param name="values" as="element()*" />
  <xsl:if test="count($values)>1">
    <x:rel type="2">
      <x:from><xsl:copy-of select="$values[1]" /></x:from>
      <x:to><xsl:copy-of select="$values[2]" /></x:to>
    </x:rel>
    <xsl:copy-of select="order:init-order-link-values-intern($values[position()>1])" />
  </xsl:if>
</xsl:function>


<xsl:function name="order:transitive-closure">
  <xsl:param name="relations" as="element()*" />
  <xsl:choose>
    <xsl:when test="empty($relations)">
      <x:graph>
        <x:vertices />
        <x:matrix />
      </x:graph>
    </xsl:when>
    <xsl:otherwise>
      <xsl:variable name="e-graph" as="element()" select="order:extract-vertices-and-edges($relations)" />
      <xsl:variable name="TC" as="xs:integer*"
                    select="order:iterate-closure(order:build-0-matrix($e-graph),$e-graph/x:edges/*)" />
      <xsl:choose>
        <xsl:when test="$TC = -1">
          <x:error />
        </xsl:when>
        <xsl:otherwise>
          <x:graph>
            <xsl:copy-of select="$e-graph/x:vertices" />
            <x:matrix>
              <xsl:for-each select="$TC">
                <x:cell><xsl:value-of select="." /></x:cell>
              </xsl:for-each>
            </x:matrix>
          </x:graph>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>


<xsl:function name="order:extract-vertices-and-edges">
  <xsl:param name="relations" as="element()*" />
  <xsl:choose>
    <xsl:when test="empty($relations)">
      <x:e-graph>
        <x:vertices />
        <x:edges />
      </x:e-graph>
    </xsl:when>
    <xsl:when test="count($relations)=1">
      <x:e-graph>
        <x:vertices>
          <xsl:copy-of select="$relations/x:from/*" />
          <xsl:copy-of select="$relations/x:to/*" />
        </x:vertices>
        <x:edges>
          <x:edge type="{$relations/@type}" from="1" to="2" />
        </x:edges>
      </x:e-graph>
    </xsl:when>
    <xsl:otherwise>
      <xsl:variable name="sub-e-graph" as="element()"
                    select="order:extract-vertices-and-edges($relations[position()!=last()])" />
      <xsl:variable name="list" as="element()*"
                    select="$sub-e-graph/x:vertices/*" />
      <xsl:variable name="left" as="element()"
                    select="$relations[position()=last()]/x:from/*" />
      <xsl:variable name="left-idx" as="xs:integer*"
                    select="utils:index-of($list,$left)" />
      <xsl:variable name="right" as="element()"
                    select="$relations[position()=last()]/x:to/*" />
      <xsl:variable name="right-idx" as="xs:integer*"
                    select="utils:index-of($list,$right)" />
      <xsl:variable name="length" as="xs:integer"
                    select="count($sub-e-graph/x:vertices/*)" />
      <x:e-graph>
        <x:vertices>
          <xsl:copy-of select="$sub-e-graph/x:vertices/*" />
          <xsl:if test="empty($left-idx)">
            <xsl:copy-of select="$left" />
          </xsl:if>
          <xsl:if test="empty($right-idx)">
            <xsl:copy-of select="$right" />
          </xsl:if>
        </x:vertices>
        <x:edges>
          <xsl:copy-of select="$sub-e-graph/x:edges/*" />
          <x:edge type="{$relations[position()=last()]/@type}"
                  from="{if (exists($left-idx))
                         then $left-idx
                         else $length+1}"
                  to="{if (exists($right-idx))
                       then $right-idx
                       else if (exists($left-idx))
                       then $length+1
                       else $length+2}" />
        </x:edges>
      </x:e-graph>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>


<xsl:function name="order:build-0-matrix">
  <xsl:param name="e-graph" as="element()" />
  <xsl:variable name="length" select="count($e-graph/x:vertices/*)" as="xs:integer" />
  <xsl:sequence select="for $i in (1 to $length*$length) return 0" />
</xsl:function>

<xsl:function name="order:iterate-closure">
  <xsl:param name="P" as="xs:integer+" />
  <xsl:param name="edges" as="element()*" />
  <xsl:choose>
    <xsl:when test="empty($edges)">
      <xsl:copy-of select="$P" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:variable name="tmpP" as="xs:integer*"
                    select="if (count($edges)=1)
                            then ($P)
                            else (order:iterate-closure($P,$edges[position()>1]))" />
      <xsl:variable name="x" as="xs:integer" select="xs:integer($edges[1]/@from)" />
      <xsl:variable name="y" as="xs:integer" select="xs:integer($edges[1]/@to)" />
      <xsl:choose>
        <xsl:when test="exists($tmpP) (: no previous error :)
                    and $tmpP[xs:integer(($x - 1)*math:sqrt(count($tmpP)) + $y)] = 0
                                   (: edge not already there :)">
          <xsl:variable name="tmpP-2" as="xs:integer*"
                        select="order:insert-edge($tmpP,$x,$y,
                                                  xs:integer($edges[1]/@type))" />
          <xsl:choose>
            <xsl:when test="empty($tmpP-2)">
              <xsl:sequence select="-1" />
              <xsl:message>[WARNING] Order ignored</xsl:message>
            </xsl:when>
            <xsl:otherwise>
              <xsl:variable name="warshall" as="xs:integer*"
                            select="order:warshall($tmpP-2)" />
              <xsl:choose>
                <xsl:when test="empty($warshall)">
                  <xsl:sequence select="-1" />
                  <xsl:message>[WARNING] Order ignored</xsl:message>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:copy-of select="$warshall" />
                </xsl:otherwise>
              </xsl:choose>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:copy-of select="$tmpP" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="order:warshall">
  <xsl:param name="P" as="xs:integer*" />
  <xsl:copy-of select="order:warshall-loop($P,xs:integer(math:sqrt(count($P))))" />
</xsl:function>

<xsl:function name="order:warshall-loop">
  <xsl:param name="P" as="xs:integer+" />
  <xsl:param name="k" as="xs:integer" />

  <xsl:variable name="length" as="xs:integer" select="xs:integer(math:sqrt(count($P)))" />
  <xsl:variable name="newP" as="xs:integer+">
    <xsl:for-each select="1 to $length">
      <xsl:variable name="x" as="xs:integer" select="." />
      <xsl:for-each select="1 to $length">
        <xsl:variable name="y" as="xs:integer" select="." />
        <xsl:variable name="P-xk" as="xs:integer"
                      select="xs:integer($P[xs:integer(($x - 1)*$length + $k)])" />
        <xsl:variable name="P-ky" as="xs:integer"
                      select="xs:integer($P[xs:integer(($k - 1)*$length + $y)])" />
        <xsl:variable name="P-xy" as="xs:integer"
                      select="xs:integer($P[xs:integer(($x - 1)*$length + $y)])" />
        <xsl:variable name="P-yx" as="xs:integer"
                      select="xs:integer($P[xs:integer(($y - 1)*$length + $x)])" />
        <xsl:variable name="edge" as="xs:integer"
                      select="if ($P-xk=0 or $P-ky=0)
                              then 0
                              else if ($P-xk=2 or $P-ky=2)
                              then 2
                              else 1" />
        <xsl:sequence select="if($P-xy!=0 or $x=$y or $k=$x or $k=$y or $edge=0)
                              then $P-xy
                              else $edge" />
      </xsl:for-each>
    </xsl:for-each>
  </xsl:variable>

  <xsl:copy-of select="if ($k > 1 and exists($newP))
                       then order:warshall-loop($newP,$k - 1)
                       else $newP" />
</xsl:function>

<xsl:function name="order:insert-edge">
  <xsl:param name="P" as="xs:integer*" />
  <xsl:param name="x" as="xs:integer" />
  <xsl:param name="y" as="xs:integer" />
  <xsl:param name="edge" as="xs:integer" />
  <xsl:variable name="idx-xy" as="xs:integer"
                select="xs:integer(($x - 1)*math:sqrt(count($P)) + $y)" />
  <xsl:choose>
    <xsl:when test="$edge=0">
      <xsl:copy-of select="$P" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:variable name="cell" as="xs:integer">
        <xsl:choose>
          <xsl:when test="$P[$idx-xy]=0">
            <xsl:variable name="idx-yx" as="xs:integer"
                          select="xs:integer(($y - 1)*math:sqrt(count($P)) + $x)" />
            <xsl:choose>
              <xsl:when test="$edge=1 and $P[$idx-yx]!=2">
                <xsl:sequence select="$edge" />
              </xsl:when>
              <xsl:when test="$edge=2 and $P[$idx-yx]=0">
                <xsl:sequence select="$edge" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:sequence select="-1" />
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:choose>
              <xsl:when test="$edge = $P[$idx-xy]">
                <xsl:sequence select="$edge" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:sequence select="-1" />
              </xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="$cell = -1">
          <xsl:message>[WARNING] Error while building order: inconsistent relation when inserting edge</xsl:message>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="$P[position()&lt;$idx-xy]" />
          <xsl:sequence select="$cell" />
          <xsl:sequence select="$P[position()>$idx-xy]" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>



<xsl:function name="order:projection">
  <xsl:param name="graph" as="element()" />
  <xsl:param name="indices" as="xs:integer*" />
  <xsl:variable name="length" as="xs:integer"
                select="count($graph/x:vertices/*)" />
  <xsl:variable name="s-indices" as="xs:integer*">
    <xsl:perform-sort select="distinct-values($indices)">
      <xsl:sort select="." />
    </xsl:perform-sort>
  </xsl:variable>
  <xsl:variable name="valid-indices" as="xs:integer*"
                select="$s-indices[not(. > $length or . &lt; 1)]" />
  <xsl:if test="max($s-indices) > $length or min($s-indices) &lt; 1">
    <xsl:message>[WARNING] Projection called with invalid indices, avoiding those</xsl:message>
  </xsl:if>
  <x:graph>
    <x:vertices>
      <xsl:for-each select="$graph/x:vertices/*">
        <xsl:if test="position() = $valid-indices">
          <xsl:copy-of select="." />
        </xsl:if>
      </xsl:for-each>
    </x:vertices>
    <x:matrix>
      <xsl:for-each select="$valid-indices">
        <xsl:variable name="x" as="xs:integer" select="." />
        <xsl:for-each select="$valid-indices">
          <xsl:variable name="y" as="xs:integer" select="." />
            <xsl:variable name="idx" as="xs:integer"
                          select="xs:integer(($x - 1)*$length + $y)" />
            <xsl:copy-of select="$graph/x:matrix/x:cell[$idx]" />
        </xsl:for-each>
      </xsl:for-each>
    </x:matrix>
  </x:graph>
</xsl:function>


<xsl:function name="order:isolate-SCC">
  <xsl:param name="graph" as="element()" />
  <xsl:copy-of select="order:isolate-SCC-intern($graph,1)" />
</xsl:function>

<xsl:function name="order:isolate-SCC-intern">
  <xsl:param name="graph" as="element()" />
  <xsl:param name="index" as="xs:integer" />
  <xsl:variable name="length" as="xs:integer"
                select="count($graph/x:vertices/*)" />
  <xsl:choose>
    <xsl:when test="$index > $length">
      <x:graph>
        <x:vertices />
        <x:matrix />
      </x:graph>
    </xsl:when>
    <xsl:otherwise>
      <xsl:variable name="equal-items" as="xs:integer*">
        <xsl:for-each select="($index + 1) to $length">
          <xsl:variable name="y" as="xs:integer" select="." />
          <xsl:variable name="idx-xy" as="xs:integer"
                        select="xs:integer(($index - 1)*$length + $y)" />
          <xsl:variable name="idx-yx" as="xs:integer"
                        select="xs:integer(($y - 1)*$length + $index)" />
          <xsl:if test="$graph/x:matrix/x:cell[$idx-xy]='1' and $graph/x:matrix/x:cell[$idx-yx]='1'">
            <xsl:sequence select="$y" />
          </xsl:if>
        </xsl:for-each>
      </xsl:variable>
      <xsl:variable name="remaining-items" as="xs:integer*">
        <xsl:for-each select="1 to $length">
          <xsl:if test="not(.=$equal-items)">
            <xsl:sequence select="." />
          </xsl:if>
        </xsl:for-each>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="$index + 1 > $length - count($equal-items)">
          <xsl:variable name="projection" as="element()"
                        select="order:projection($graph,$remaining-items)" />
          <x:graph>
            <x:vertices>
              <xsl:choose>
                <xsl:when test="exists($graph/x:vertices/*[position()=$equal-items])">
                  <apply xmlns="http://www.w3.org/1998/Math/MathML">
                    <eq />
                    <xsl:copy-of select="$graph/x:vertices/*[position()=$index]" />
                    <xsl:copy-of select="$graph/x:vertices/*[position()=$equal-items]" />
                  </apply>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:copy-of select="$graph/x:vertices/*[position()=$index]" />
                </xsl:otherwise>
              </xsl:choose>
            </x:vertices>
            <xsl:copy-of select="$projection/x:matrix" />
          </x:graph>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="tmpRes" as="element()">
            <xsl:variable name="projection" as="element()"
                          select="order:projection($graph,$remaining-items)" />
            <xsl:copy-of select="order:isolate-SCC-intern($projection,$index+1)" />
          </xsl:variable>
          <x:graph>
            <x:vertices>
              <xsl:choose>
                <xsl:when test="exists($graph/x:vertices/*[position()=$equal-items])">
                  <apply xmlns="http://www.w3.org/1998/Math/MathML">
                    <eq />
                    <xsl:copy-of select="$graph/x:vertices/*[position()=$index]" />
                    <xsl:copy-of select="$graph/x:vertices/*[position()=$equal-items]" />
                  </apply>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:copy-of select="$graph/x:vertices/*[position()=$index]" />
                </xsl:otherwise>
              </xsl:choose>
              <xsl:copy-of select="$tmpRes/x:vertices/*" />
            </x:vertices>
            <xsl:copy-of select="$tmpRes/x:matrix" />
          </x:graph>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>


<xsl:function name="order:topological-sort">
  <xsl:param name="graph" as="element()" />
  <xsl:variable name="degrees" as="xs:integer*" select="order:compute-degrees($graph/x:matrix)" />
  <xsl:variable name="ordered-vertices" as="element()*"
                select="order:topological-sort-intern($graph,$degrees)" />
  <xsl:choose>
    <xsl:when test="$ordered-vertices/self::x:error">
      <x:error/>
    </xsl:when>
    <xsl:otherwise>
      <x:order>
        <xsl:for-each select="$ordered-vertices">
          <xsl:choose>
            <xsl:when test="self::mathml:apply/mathml:eq">
              <xsl:for-each select="self::mathml:apply/element()[position()>1 and position() != last()]">
                <xsl:copy-of select="." />
                <eq xmlns="http://www.w3.org/1998/Math/MathML" />
              </xsl:for-each>
              <xsl:copy-of select="self::mathml:apply/element()[position()=last()]" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:copy-of select="." />
            </xsl:otherwise>
          </xsl:choose>
          <xsl:if test="position()!=last()">
            <xsl:variable name="v" as="element()" select="." />
            <xsl:variable name="pos" as="xs:integer" select="position()" />
            <xsl:variable name="x" as="xs:integer"
                          select="count($graph/x:vertices/*[.=$v]/preceding-sibling::*)+1" />
            <xsl:variable name="y" as="xs:integer"
                          select="count($graph/x:vertices/*[.=$ordered-vertices[xs:integer($pos+1)]]
                                          /preceding-sibling::*)+1" />
            <xsl:choose>
              <xsl:when test="$graph/x:matrix/x:cell[xs:integer(($x - 1)*count($degrees) + $y)]='1'">
                <leq xmlns="http://www.w3.org/1998/Math/MathML" />
              </xsl:when>
              <xsl:otherwise>
                <lt xmlns="http://www.w3.org/1998/Math/MathML" />
              </xsl:otherwise>
            </xsl:choose>
          </xsl:if>
        </xsl:for-each>
      </x:order>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="order:topological-sort-intern">
  <xsl:param name="graph" as="element()*" />
  <xsl:param name="degrees" as="xs:integer*" />
  <xsl:choose>
    <xsl:when test="every $d in $degrees satisfies $d=-1" />
    <xsl:when test="count($degrees[.=0]) = 1">
      <xsl:variable name="top" as="element()"
                    select="$graph/x:vertices/*[position()=index-of($degrees,0)]" />
      <xsl:variable name="updt-degrees" as="xs:integer*">
        <xsl:for-each select="1 to count($degrees)">
          <xsl:variable name="y" select="." as="xs:integer" />
          <xsl:variable name="deg-y" as="xs:integer" select="$degrees[$y]" />
          <xsl:variable name="idx-xy" as="xs:integer"
                        select="xs:integer((index-of($degrees,0) - 1)*count($degrees) + $y)" />
          <xsl:sequence select="if ($deg-y=0) (: if it s 0, do not copy it again :)
                                then -1
                                else if ($graph/x:matrix/x:cell[$idx-xy] != '0')
                                then $degrees[$y] - 1 (:if edge from x to y, remove 1:)
                                else $degrees[$y]" />
        </xsl:for-each>
      </xsl:variable>
      <xsl:variable name="followers" as="element()*"
                    select="order:topological-sort-intern($graph,$updt-degrees)" />
      <xsl:choose>
        <xsl:when test="not($followers/self::x:error)">
          <xsl:copy-of select="$top" />
          <xsl:copy-of select="$followers" />
        </xsl:when>
        <xsl:otherwise>
          <x:error />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <x:error />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>


<xsl:function name="order:compute-degrees">
  <xsl:param name="matrix" as="element()" />
  <xsl:variable name="length" as="xs:integer"
                select="xs:integer(math:sqrt(count($matrix/x:cell)))" />
  <xsl:copy-of select="order:compute-degrees-intern($matrix,$length,$length)" />
</xsl:function>

<xsl:function name="order:compute-degrees-intern">
  <xsl:param name="matrix" as="element()" />
  <xsl:param name="index" as="xs:integer" />
  <xsl:param name="length" as="xs:integer" />
  <xsl:if test="$index > 0">
    <xsl:sequence select="order:compute-degrees-intern($matrix,$index - 1,$length)" />
    <xsl:sequence select="count($matrix/x:cell[position()
                                                 = (for $i in (0 to $length - 1)
                                                    return xs:integer($i*$length+$index))
                                               and .!='0'])" />
  </xsl:if>
</xsl:function>


<xsl:function name="order:params-through-values-order">
  <xsl:param name="sbml" as="element()" />
  <x:params-ordered-through-values>
    <xsl:for-each select="$sbml/sbml:model/(
                              sbml:listOfParameters/sbml:parameter[exists(@value)]
                            | sbml:listOfSpecies/sbml:species[not(empty(@initialAmount)
                                                              and empty(@initialConcentration))])">
      <xsl:sort select="if (exists(@value)) then @value
                        else if (exists(@initialAmount)) then @initialAmount
                        else @initialConcentration"
                data-type="number" />
      <x:param value="{if (exists(@value)) then @value
                      else if (exists(@initialAmount)) then @initialAmount
                      else @initialConcentration}">
        <ci xmlns="http://www.w3.org/1998/Math/MathML">
          <xsl:value-of select="@id"/>
        </ci>
      </x:param>
    </xsl:for-each>
  </x:params-ordered-through-values>
</xsl:function>

</xsl:stylesheet>
