<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:mathml="http://www.w3.org/1998/Math/MathML"
                xmlns:rma="http://www-gna.inrialpes.fr/xsl/remove_mathml_annotations"
                exclude-result-prefixes="#all">


<xsl:function name="rma:remove-mathml-annotations">
  <xsl:param name="expr" as="element()" />
  <xsl:apply-templates select="$expr" mode="remove-mathml-annotations" />
</xsl:function>


<xsl:template match="mathml:math" mode="remove-mathml-annotations">
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


<xsl:template match="mathml:semantics" mode="remove-mathml-annotations">
  <xsl:apply-templates select="*" mode="#current"/>
</xsl:template>

<xsl:template match="mathml:annotation|mathml:annotation-xml" mode="remove-mathml-annotations" />


<xsl:template match="mathml:*" mode="remove-mathml-annotations">
  <xsl:copy-of select="." />
</xsl:template>

</xsl:stylesheet>