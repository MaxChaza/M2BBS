<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:sbml="http://www.sbml.org/sbml/level2/version2"
                xmlns:mathml="http://www.w3.org/1998/Math/MathML"
                xmlns:gnaml="http://www-gna.inrialpes.fr/gnaml/version1"
                xmlns:cstrts="http://www-gna.inrialpes.fr/xsl/prepare-constraints"
                xmlns:nary="http://www-gna.inrialpes.fr/xsl/n_arize"
                exclude-result-prefixes="#all">

<xsl:import href="n_arize_l2v2.xsl" />


<xsl:function name="cstrts:prepare-constraints">
  <xsl:param name="sbml" as="element()" />
  <xsl:apply-templates select="$sbml" mode="prepare-constraints" />
</xsl:function>

<xsl:template match="sbml:sbml|sbml:model" mode="prepare-constraints">
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

<xsl:template match="sbml:listOfConstraints" mode="prepare-constraints">
  <xsl:variable name="cstrts" as="element()*">
    <xsl:apply-templates select="*" mode="#current" />
  </xsl:variable>
  <xsl:if test="exists($cstrts)">
    <xsl:copy>
      <xsl:copy-of select="$cstrts" />
    </xsl:copy>
  </xsl:if>
</xsl:template>

<xsl:template match="sbml:constraint" mode="prepare-constraints">
  <xsl:variable name="relations" as="element()*">
    <xsl:apply-templates select="mathml:math" mode="#current" />
  </xsl:variable>
  <xsl:for-each select="$relations/self::mathml:apply/element()[position()>1]">
    <constraint xmlns="http://www.sbml.org/sbml/level2/version2">
      <math xmlns="http://www.w3.org/1998/Math/MathML">
        <xsl:copy-of select="." />
      </math>
    </constraint>
  </xsl:for-each>
</xsl:template>

<xsl:template match="mathml:math" mode="prepare-constraints">
  <xsl:apply-templates select="*" mode="#current" />
</xsl:template>


<xsl:template match="mathml:apply" mode="prepare-constraints">
  <xsl:choose>
    <xsl:when test="element()[1]/self::mathml:and">
      <apply xmlns="http://www.w3.org/1998/Math/MathML">
        <and />
        <xsl:for-each select="element()[position()>1]">
          <xsl:variable name="rel" as="element()*">
            <xsl:apply-templates select="." mode="#current" />
          </xsl:variable>
          <xsl:copy-of select="$rel/element()[position()>1]" />
        </xsl:for-each>
      </apply>
    </xsl:when>
    <xsl:when test="element()[1]/self::mathml:lt
                  | element()[1]/self::mathml:gt
                  | element()[1]/self::mathml:leq
                  | element()[1]/self::mathml:geq
                  | element()[1]/self::mathml:eq">
      <xsl:variable name="parts" as="element()*">
        <xsl:apply-templates select="element()[position()>1]" mode="to-canonical-constraint-part" />
      </xsl:variable>
      <xsl:variable name="relations"
                    select="cstrts:to-binary-inequalities($parts,element()[1])" />
            <xsl:if test="exists($relations/self::mathml:apply/element()[position()>1])">
        <apply xmlns="http://www.w3.org/1998/Math/MathML">
          <and />
          <xsl:copy-of select="$relations/self::mathml:apply/element()[position()>1]" />
        </apply>
      </xsl:if>
    </xsl:when>
  </xsl:choose>
</xsl:template>

<xsl:template match="sbml:*" mode="prepare-constraints">
  <xsl:copy-of select="." />
</xsl:template>

<xsl:template match="*" mode="prepare-constraints" />


<xsl:function name="cstrts:to-binary-inequalities">
  <xsl:param name="elems" as="element()+" />
  <xsl:param name="op" as="element()" />
  <xsl:if test="count($elems)>1">
    <apply xmlns="http://www.w3.org/1998/Math/MathML">
      <and />
      <xsl:choose>
        <xsl:when test="$op/self::mathml:lt or $op/self::mathml:leq">
          <apply xmlns="http://www.w3.org/1998/Math/MathML">
            <xsl:copy-of select="$op" />
            <xsl:copy-of select="$elems[1]" />
            <xsl:copy-of select="$elems[2]" />
          </apply>
        </xsl:when>
        <xsl:when test="$op/self::mathml:eq">
          <apply xmlns="http://www.w3.org/1998/Math/MathML">
            <leq />
            <xsl:copy-of select="$elems[1]" />
            <xsl:copy-of select="$elems[2]" />
          </apply>
          <apply xmlns="http://www.w3.org/1998/Math/MathML">
            <leq />
            <xsl:copy-of select="$elems[2]" />
            <xsl:copy-of select="$elems[1]" />
          </apply>
        </xsl:when>
        <xsl:when test="$op/self::mathml:gt">
          <apply xmlns="http://www.w3.org/1998/Math/MathML">
            <lt />
            <xsl:copy-of select="$elems[2]" />
            <xsl:copy-of select="$elems[1]" />
          </apply>
        </xsl:when>
        <xsl:when test="$op/self::mathml:geq">
          <apply xmlns="http://www.w3.org/1998/Math/MathML">
            <leq />
            <xsl:copy-of select="$elems[2]" />
            <xsl:copy-of select="$elems[1]" />
          </apply>
        </xsl:when>
      </xsl:choose>

      <xsl:variable name="next-rels" as="element()*"
                    select="cstrts:to-binary-inequalities
                              ($elems[position()>1],$op)" />
      <xsl:for-each select="$next-rels/self::mathml:apply/element()[position()>1]">
        <xsl:copy-of select="." />
      </xsl:for-each>
    </apply>
  </xsl:if>
</xsl:function>



<xsl:template match="mathml:apply[mathml:times]" mode="to-canonical-constraint-part">
  <xsl:copy>
    <xsl:copy-of select="element()[1]" />
    <xsl:variable name="args" as="element()*">
      <xsl:apply-templates select="element()[position()>1]" mode="#current" />
    </xsl:variable>
    <xsl:for-each select="$args">
      <xsl:sort select="." />
      <xsl:copy-of select="." />
    </xsl:for-each>
  </xsl:copy>
</xsl:template>

<xsl:template match="mathml:apply[mathml:plus]" mode="to-canonical-constraint-part">
  <xsl:variable name="args" as="element()*">
    <xsl:apply-templates select="element()[position()>1]" mode="#current" />
  </xsl:variable>
  <xsl:choose>
    <xsl:when test="every $node in $args satisfies $node/self::mathml:apply/mathml:divide
                and count(distinct-values($args/self::mathml:apply/element()[position()=last()])) = 1">
      <xsl:variable name="grouped" as="element()">
        <apply xmlns="http://www.w3.org/1998/Math/MathML">
          <divide />
          <apply>
            <plus />
            <xsl:for-each select="$args/self::mathml:apply/element()[position()=2]">
              <xsl:sort select="." />
              <xsl:copy-of select="." />
            </xsl:for-each>
          </apply>
          <xsl:copy-of select="($args/self::mathml:apply/element()[position()=last()])[1]" />
        </apply>
      </xsl:variable>
      <xsl:copy-of select="nary:n-arize($grouped)" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy>
        <xsl:copy-of select="element()[1]" />
        <xsl:for-each select="$args">
          <xsl:sort select="." />
          <xsl:copy-of select="." />
        </xsl:for-each>
      </xsl:copy>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="mathml:*" mode="to-canonical-constraint-part">
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