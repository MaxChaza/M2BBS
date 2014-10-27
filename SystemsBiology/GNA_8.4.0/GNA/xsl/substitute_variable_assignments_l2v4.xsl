<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:sbml="http://www.sbml.org/sbml/level2/version4"
                xmlns:mathml="http://www.w3.org/1998/Math/MathML"
                xmlns:gnaml="http://www-gna.inrialpes.fr/gnaml/version1"
                xmlns:x="http://www-gna.inrialpes.fr/xsl/structs"
                xmlns:subs="http://www-gna.inrialpes.fr/xsl/substitute-variable-assignments"
                xmlns:math="http://exslt.org/math"
                exclude-result-prefixes="#all">

<xsl:function name="subs:substitute-variable-assignments">
  <xsl:param name="sbml" as="element()" />
  <xsl:variable name="var-list" as="xs:string*" select="$sbml//sbml:species/@id" />
  <xsl:variable name="subs" as="element()*">
    <xsl:for-each select="$sbml//sbml:initialAssignment[@symbol = $var-list
                                               and mathml:math/mathml:ci[text() != $var-list]]">
      <x:subs src="{mathml:math/mathml:ci/text()}" dst="{@symbol}"/>
    </xsl:for-each>
  </xsl:variable>
  <xsl:apply-templates select="$sbml" mode="substitute-vars">
    <xsl:with-param name="subs" select="$subs" />
  </xsl:apply-templates>
</xsl:function>


<xsl:template match="sbml:initialAssignment" mode="substitute-vars">
  <xsl:param name="subs" as="element()*" />
  <xsl:if test="not(@symbol = $subs/@dst and mathml:math/mathml:ci[text() != $subs/@dst])">
    <xsl:copy-of select="." />
  </xsl:if>
</xsl:template>

<xsl:template match="mathml:ci" mode="substitute-vars">
  <xsl:param name="subs" as="element()*" />
  <xsl:variable name="id" as="xs:string" select="text()" />
  <xsl:choose>
    <xsl:when test="$id = $subs/@src">
      <ci xmlns="http://www.w3.org/1998/Math/MathML"><xsl:value-of select="$subs[@src = $id]/@dst" /></ci>
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy-of select="." />
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="*" mode="substitute-vars">
  <xsl:param name="subs" as="element()*" />
  <xsl:copy>
    <xsl:copy-of select="@*" />
    <xsl:for-each select="node()">
      <xsl:choose>
        <xsl:when test=". instance of text()">
          <xsl:value-of select="." />
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="." mode="#current">
            <xsl:with-param name="subs" select="$subs" />
          </xsl:apply-templates>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:copy>
</xsl:template>

</xsl:stylesheet>