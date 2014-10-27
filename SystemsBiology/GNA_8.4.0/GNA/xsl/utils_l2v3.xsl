<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:mathml="http://www.w3.org/1998/Math/MathML"
                xmlns:x="http://www-gna.inrialpes.fr/xsl/structs"
                xmlns:utils="http://www-gna.inrialpes.fr/xsl/utils"
                exclude-result-prefixes="#all">


<xsl:function name="utils:math-equals">
  <xsl:param name="math1" as="element()" />
  <xsl:param name="math2" as="element()" />
  <xsl:choose>
    <xsl:when test="local-name($math1)!=local-name($math2)
                 or count($math1/element())!=count($math2/element())">
      <xsl:sequence select="false()" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:choose>
        <xsl:when test="$math1/self::mathml:ci">
          <xsl:sequence select="$math1=$math2" />
        </xsl:when>
        <xsl:when test="$math1/self::mathml:cn">
          <xsl:sequence select="xs:double($math1)=xs:double($math2)" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="args" as="xs:boolean*"
                        select="for $i in (1 to count($math1/element()))
                                return utils:math-equals($math1/element()[$i],$math2/element()[$i])" />
          <xsl:sequence select="every $b in $args satisfies $b=true()" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>


<xsl:function name="utils:index-of">
  <xsl:param name="list" as="element()*" />
  <xsl:param name="elem" as="element()" />
  <xsl:variable name="compare" as="xs:boolean*"
                select="for $e in $list
                        return utils:math-equals($elem,$e)" />
  <xsl:sequence select="index-of($compare,true())" />
</xsl:function>


<xsl:function name="utils:build-all-combinations">
  <xsl:param name="params" as="element()+" />
  <xsl:param name="enclose-with-plus" as="xs:boolean" />
  <xsl:for-each select="1 to count($params)">
    <xsl:variable name="combinations" as="element()+"
                  select="utils:build-combinations($params,.)" />
    <xsl:for-each select="$combinations">
      <xsl:choose>
        <xsl:when test="count(mathml:ci) = 1 or $enclose-with-plus = false()">
          <xsl:copy-of select="mathml:ci" />
        </xsl:when>
        <xsl:otherwise>
          <apply xmlns="http://www.w3.org/1998/Math/MathML">
            <plus />
            <xsl:copy-of select="mathml:ci" />
          </apply>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:for-each>
</xsl:function>


<xsl:function name="utils:build-combinations">
  <xsl:param name="params" as="element()*" />
  <xsl:param name="count" as="xs:integer" />
  <xsl:choose>
    <xsl:when test="count($params) = $count">
      <x:seq>
        <xsl:copy-of select="$params" />
      </x:seq>
    </xsl:when>
    <xsl:when test="$count = 1">
      <xsl:for-each select="1 to count($params)">
        <xsl:variable name="i" as="xs:integer" select="." />
        <x:seq>
          <xsl:copy-of select="$params[$i]" />
        </x:seq>
      </xsl:for-each>
    </xsl:when>
    <xsl:otherwise>
      <xsl:for-each select="(1 to count($params) - $count)">
        <xsl:variable name="i" as="xs:integer" select="." />
        <xsl:for-each select="utils:build-combinations($params[position()>$i],$count - 1)">
          <x:seq>
            <xsl:copy-of select="$params[1]" />
            <xsl:copy-of select="*" />
          </x:seq>
        </xsl:for-each>
      </xsl:for-each>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

</xsl:stylesheet>