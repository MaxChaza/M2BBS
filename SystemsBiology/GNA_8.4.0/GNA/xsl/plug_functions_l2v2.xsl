<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:sbml="http://www.sbml.org/sbml/level2/version2"
                xmlns:mathml="http://www.w3.org/1998/Math/MathML"
                xmlns:plug="http://www-gna.inrialpes.fr/xsl/plug_functions"
                exclude-result-prefixes="#all">


<xsl:function name="plug:plug-functions">
  <xsl:param name="sbml" as="element()" />
  <xsl:if test="not($sbml/self::sbml:sbml)">
    <xsl:message terminate="yes">Function 'plug-functions' must be called with an sbml:sbml document.</xsl:message>
  </xsl:if>
  <xsl:variable name="functions">
    <xsl:copy-of select="plug:function-definitions($sbml//sbml:functionDefinition)" />
  </xsl:variable>
  <xsl:apply-templates select="$sbml" mode="plug-functions">
    <xsl:with-param name="subfunctions" select="$functions" />
  </xsl:apply-templates>
</xsl:function>


<xsl:function name="plug:function-definitions">
  <xsl:param name="functions" as="element()*" />
  <xsl:choose>
    <xsl:when test="empty($functions)" />
    <xsl:when test="count($functions)=1">
      <xsl:copy-of select="$functions" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:variable name="sub-functions">
        <xsl:copy-of select="plug:function-definitions($functions[position()!=last()])" />
      </xsl:variable>
      <xsl:copy-of select="$sub-functions" />
      <xsl:apply-templates mode="plug-functions" select="$functions[position()=last()]">
        <xsl:with-param name="subfunctions" select="$sub-functions" as="document-node()" />
      </xsl:apply-templates>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>


<xsl:template match="sbml:listOfFunctionDefinitions" mode="plug-functions" />


<xsl:template match="sbml:functionDefinition" mode="plug-functions">
  <xsl:param name="subfunctions" as="document-node()" />
  <xsl:copy>
    <xsl:for-each select="@*">
      <xsl:attribute name="{name(.)}"><xsl:value-of select="." /></xsl:attribute>
    </xsl:for-each>
    <math xmlns="http://www.w3.org/1998/Math/MathML">
      <lambda>
        <xsl:copy-of select="mathml:math/mathml:lambda/mathml:bvar" />
        <xsl:apply-templates select="mathml:math/mathml:lambda/(* except mathml:bvar)" mode="#current">
          <xsl:with-param name="subfunctions" select="$subfunctions" />
        </xsl:apply-templates>
      </lambda>
    </math>
  </xsl:copy>
</xsl:template>


<xsl:template match="mathml:apply" mode="plug-functions">
  <xsl:param name="subfunctions" as="document-node()" />
  <xsl:choose>
    <xsl:when test="element()[1]/self::mathml:ci">
      <xsl:variable name="id" select="element()[1]" />
      <xsl:if test="$subfunctions/sbml:functionDefinition[@id=$id]">
        <xsl:variable name="plugged" select="plug:substitute-vars($subfunctions/sbml:functionDefinition[@id=$id],element()[position()>1])" />
        <xsl:apply-templates select="$plugged" mode="#current">
          <xsl:with-param name="subfunctions" select="$subfunctions" />
        </xsl:apply-templates>
      </xsl:if>
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy>
        <xsl:apply-templates select="*" mode="#current">
          <xsl:with-param name="subfunctions" select="$subfunctions" />
        </xsl:apply-templates>
      </xsl:copy>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<xsl:template match="mathml:*|sbml:*" mode="plug-functions">
  <xsl:param name="subfunctions" as="document-node()" />
  <xsl:copy>
    <xsl:for-each select="@*">
      <xsl:attribute name="{name(.)}"><xsl:value-of select="." /></xsl:attribute>
    </xsl:for-each>
    <xsl:for-each select="node()">
      <xsl:choose>
        <xsl:when test=". instance of text()">
          <xsl:value-of select="." />
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="." mode="#current">
            <xsl:with-param name="subfunctions" select="$subfunctions" />
          </xsl:apply-templates>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:copy>
</xsl:template>


<xsl:template match="*" mode="plug-functions">
  <xsl:copy-of select="." />
</xsl:template>





<xsl:function name="plug:substitute-vars">
  <xsl:param name="function" as="element()" />
  <xsl:param name="subs" as="element()+" />
    <xsl:apply-templates select="$function/mathml:math/mathml:lambda/element()[not(self::mathml:bvar)]" mode="plug-substitute">
      <xsl:with-param name="subs" select="$subs" />
      <xsl:with-param name="vars" select="$function/mathml:math/mathml:lambda/mathml:bvar/mathml:ci" />
    </xsl:apply-templates>
</xsl:function>


<xsl:template match="mathml:ci" mode="plug-substitute">
  <xsl:param name="subs" as="element()*" />
  <xsl:param name="vars" as="element()*" />
  <xsl:variable name="id"><xsl:value-of select="." /></xsl:variable>
  <xsl:choose>
    <xsl:when test="$vars[text()=$id]">
      <xsl:variable name="index"
                    select="count($vars[text()=$id]/parent::mathml:bvar/preceding-sibling::element())
                            + 1" />
      <xsl:copy-of select="$subs[position()=$index]" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy-of select="." />
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<xsl:template match="mathml:*" mode="plug-substitute">
  <xsl:param name="subs" as="element()*" />
  <xsl:param name="vars" as="element()*" />
  <xsl:copy>
    <xsl:for-each select="@*">
      <xsl:attribute name="{name(.)}"><xsl:value-of select="." /></xsl:attribute>
    </xsl:for-each>
    <xsl:for-each select="node()">
      <xsl:choose>
        <xsl:when test=". instance of text()">
          <xsl:value-of select="." />
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="." mode="#current">
            <xsl:with-param name="subs" select="$subs" />
            <xsl:with-param name="vars" select="$vars" />
          </xsl:apply-templates>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:copy>
</xsl:template>


<xsl:template match="*" mode="plug-substitute">
  <xsl:message terminate="yes">
    <xsl:text>Unexpected operator '</xsl:text>
    <xsl:value-of select="local-name(element()[1])" />
    <xsl:text>' in template name="*", mode="plug-substitute"</xsl:text>
  </xsl:message>
</xsl:template>

</xsl:stylesheet>