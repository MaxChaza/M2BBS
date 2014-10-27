<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:mathml="http://www.w3.org/1998/Math/MathML"
                xmlns:gnaml="http://www-gna.inrialpes.fr/gnaml/version1"
                xmlns:varchk="http://www-gna.inrialpes.fr/xsl/variable-check"
                exclude-result-prefixes="#all">


<xsl:function name="varchk:check-term">
  <xsl:param name="term" as="element()" />
  <xsl:param name="state-var-info" as="element()" />
  <xsl:choose>
    <xsl:when test="$term/self::mathml:ci">
      <xsl:value-of select="exists($state-var-info/gnaml:list-of-threshold-parameters
                                    /gnaml:threshold-parameter[@id=$term])
                         or exists($state-var-info/gnaml:zero-parameter[@id=$term])
                         or exists($state-var-info/gnaml:box-parameter[@id=$term])" />
    </xsl:when>
    <xsl:when test="$term/self::mathml:apply/mathml:divide">
      <xsl:value-of select="varchk:check-numerator($term/self::mathml:apply/element()[2],
                                                 $state-var-info/gnaml:list-of-synthesis-parameters/*)
                              = true()
                        and varchk:check-denominator($term/self::mathml:apply/element()[3],
                                                   $state-var-info/gnaml:list-of-degradation-parameters/*)
                              = true()" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy-of select="false()" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>


<xsl:function name="varchk:check-numerator">
  <xsl:param name="term" as="element()" />
  <xsl:param name="state-var-info" as="element()*" />
  <xsl:value-of select="if ($term/self::mathml:ci)
                        then exists($state-var-info[@id=$term])
                        else if ($term/self::mathml:apply/mathml:plus)
                        then every $e in $term/mathml:ci satisfies exists($state-var-info[@id=$e])
                        else false()" />
</xsl:function>


<xsl:function name="varchk:check-denominator">
  <xsl:param name="term" as="element()" />
  <xsl:param name="state-var-info" as="element()*" />
  <xsl:value-of select="if ($term/self::mathml:ci)
                        then exists($state-var-info[@id=$term])
                        else if ($term/self::mathml:apply/mathml:plus)
                        then every $e in $term/mathml:ci satisfies exists($state-var-info[@id=$e])
                        else false()" />
</xsl:function>

</xsl:stylesheet>