<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:mathml="http://www.w3.org/1998/Math/MathML"
                xmlns:nary="http://www-gna.inrialpes.fr/xsl/n_arize"
                exclude-result-prefixes="#all">


<xsl:function name="nary:n-arize">
  <xsl:param as="element()" name="expr" />
  <xsl:apply-templates select="$expr" mode="n-arize" />
</xsl:function>


<xsl:template match="mathml:math" mode="n-arize">
  <xsl:copy>
    <xsl:apply-templates mode="#current" />
  </xsl:copy>
</xsl:template>


<xsl:template match="mathml:apply" mode="n-arize">
  <xsl:param name="op" select="'none'" as="xs:string" />
  <xsl:choose>
    <xsl:when test="$op!='none' and nary:is-n-arizable(., $op)">
      <xsl:apply-templates select="element()[position() > 1]" mode="#current">
        <xsl:with-param name="op" select="local-name(element()[1])" />
      </xsl:apply-templates>
    </xsl:when>
      <xsl:otherwise>
      <xsl:copy>
        <xsl:copy-of select="element()[1]" />
        <xsl:apply-templates select="element()[position() > 1]" mode="#current">
          <xsl:with-param name="op" select="local-name(element()[1])" />
        </xsl:apply-templates>
      </xsl:copy>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<xsl:template match="mathml:*" mode="n-arize">
  <xsl:copy>
    <xsl:copy-of select="@*" />
    <xsl:for-each select="node()">
      <xsl:choose>
        <xsl:when test=". instance of text()">
          <xsl:value-of select="." />
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="." mode="#current" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:copy>
</xsl:template>


<xsl:template match="*" mode="n-arize">
  <xsl:message terminate="yes">
    <xsl:text>[FATAL] Encountered a non-mathml element (</xsl:text>
    <xsl:value-of select="local-name(./element()[1])" />
    <xsl:text>) during n-arization</xsl:text>
  </xsl:message>
</xsl:template>


<xsl:function name="nary:is-n-arizable">
  <xsl:param name="expr" as="element()" />
  <xsl:param name="op" as="xs:string" />
  <xsl:sequence select="if ($expr/self::mathml:apply)
                        then (local-name($expr/element()[1])=$op and nary:is-n-ary($expr/element()[1]))
                        else true() (: only possibillity is a ci or cn element :)" />
</xsl:function>


<xsl:function name="nary:is-n-ary">
  <xsl:param name="op" as="element()" />
    <xsl:sequence select="$op/(self::mathml:plus|self::mathml:times|self::mathml:and|self::mathml:or
                          |self::mathml:xor|self::mathml:eq|self::mathml:leq|self::mathml:lt
                          |self::mathml:geq|self::mathml:gt)" />
</xsl:function>

</xsl:stylesheet>