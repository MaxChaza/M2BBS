<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:mathml="http://www.w3.org/1998/Math/MathML"
                xmlns:gnaml="http://www-gna.inrialpes.fr/gnaml/version1"
                xmlns:cnci="http://www-gna.inrialpes.fr/xsl/clean-cn-ci"
                xmlns:math="http://exslt.org/math"
                exclude-result-prefixes="#all">

<xsl:function name="cnci:clean-cnci">
  <xsl:param name="math" as="element()" />
  <xsl:apply-templates select="$math" mode="clean-cn-ci" />
</xsl:function>

<xsl:template match="mathml:cn" mode="clean-cn-ci">
  <xsl:copy-of select="cnci:to-canonical-cn(.)" />
</xsl:template>

<xsl:template match="mathml:ci" mode="clean-cn-ci">
  <ci xmlns="http://www.w3.org/1998/Math/MathML"><xsl:value-of select="normalize-space(.)"/></ci>
</xsl:template>


<xsl:template match="mathml:*" mode="clean-cn-ci">
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

<xsl:function name="cnci:to-canonical-cn">
  <xsl:param name="cn" as="element()" />
  <xsl:choose>
    <xsl:when test="not($cn/@type='rational' and cnci:to-canonical-number($cn/text()[2]) = '0')">
      <xsl:variable name="dec-value" as="xs:string"
                    select="if ($cn/@type='e-notation')
                            then xs:string($cn/text()[1] * math:power(10,$cn/text()[2]))
                            else if ($cn/@type='rational')
                            then xs:string($cn/text()[1] div $cn/text()[2])
                            else $cn" />
      <cn xmlns="http://www.w3.org/1998/Math/MathML">
        <xsl:value-of select="cnci:to-canonical-number($dec-value)" />
      </cn>
    </xsl:when>
    <xsl:otherwise>
      <infinity xmlns="http://www.w3.org/1998/Math/MathML" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="cnci:to-canonical-number">
  <xsl:param name="nb" as="xs:string" />
  <xsl:variable name="nnb" as="xs:string" select="normalize-space($nb)" />
  <xsl:value-of select="if ((ends-with($nnb,'0') and contains($nnb,'.'))
                              or ends-with($nnb,'.'))
                        then cnci:to-canonical-number(substring($nnb,1,string-length($nnb) - 1))
                        else $nnb" />
</xsl:function>

</xsl:stylesheet>
