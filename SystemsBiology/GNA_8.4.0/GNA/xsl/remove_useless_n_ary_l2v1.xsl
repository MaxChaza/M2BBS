<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:mathml="http://www.w3.org/1998/Math/MathML"
                xmlns:rmu="http://www-gna.inrialpes.fr/xsl/remove_useless_n_ary"
                exclude-result-prefixes="#all">


<xsl:function name="rmu:remove-useless-n-ary">
  <xsl:param name="expr" as="element()" />
  <xsl:apply-templates select="$expr" mode="remove-useless-n-ary" />
</xsl:function>


<xsl:template match="mathml:apply[mathml:plus]" mode="remove-useless-n-ary">
  <xsl:choose>
    <xsl:when test="count(element()) = 1">
      <cn xmlns="http://www.w3.org/1998/Math/MathML">0</cn>
    </xsl:when>
    <xsl:when test="count(element()) = 2">
      <xsl:apply-templates select="element()[position() = 2]" mode="#current" />
    </xsl:when>
    <xsl:otherwise>
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
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<xsl:template match="mathml:apply[mathml:times]" mode="remove-useless-n-ary">
  <xsl:choose>
    <xsl:when test="count(element()) = 1">
      <cn xmlns="http://www.w3.org/1998/Math/MathML">1</cn>
    </xsl:when>
    <xsl:when test="count(element()) = 2">
      <xsl:apply-templates select="element()[position() = 2]" mode="#current" />
    </xsl:when>
    <xsl:otherwise>
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
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<xsl:template match="mathml:apply[mathml:and]" mode="remove-useless-n-ary">
  <xsl:choose>
    <xsl:when test="count(element()) = 1">
      <true xmlns="http://www.w3.org/1998/Math/MathML" />
    </xsl:when>
    <xsl:when test="count(element()) = 2">
      <xsl:apply-templates select="element()[position() = 2]" mode="#current" />
    </xsl:when>
    <xsl:otherwise>
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
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<xsl:template match="mathml:apply[mathml:or|mathml:xor]" mode="remove-useless-n-ary">
  <xsl:choose>
    <xsl:when test="count(element()) = 1">
      <false xmlns="http://www.w3.org/1998/Math/MathML" />
    </xsl:when>
    <xsl:when test="count(element()) = 2">
      <xsl:apply-templates select="element()[position() = 2]" mode="#current" />
    </xsl:when>
    <xsl:otherwise>
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
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<xsl:template match="mathml:*" mode="remove-useless-n-ary">
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

</xsl:stylesheet>