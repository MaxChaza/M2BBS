<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:sbml="http://www.sbml.org/sbml/level2"
                xmlns:mathml="http://www.w3.org/1998/Math/MathML"
                xmlns:gnaml="http://www-gna.inrialpes.fr/gnaml/version1"
                xmlns:plug="http://www-gna.inrialpes.fr/xsl/plug_functions"
                xmlns:rma="http://www-gna.inrialpes.fr/xsl/remove_mathml_annotations"
                xmlns:nary="http://www-gna.inrialpes.fr/xsl/n_arize"
                xmlns:rmu="http://www-gna.inrialpes.fr/xsl/remove_useless_n_ary"
                xmlns:cnci="http://www-gna.inrialpes.fr/xsl/clean-cn-ci"
                xmlns:subs="http://www-gna.inrialpes.fr/xsl/substitute-variable-assignments"
                xmlns:extrinit="http://www-gna.inrialpes.fr/xsl/extract-initial-conditions"
                xmlns:extrvar="http://www-gna.inrialpes.fr/xsl/extract-variable-information"
                xmlns:extrparam="http://www-gna.inrialpes.fr/xsl/extract-parameter-ordering"
                xmlns:cstrts="http://www-gna.inrialpes.fr/xsl/prepare-constraints"
                xmlns:order="http://www-gna.inrialpes.fr/xsl/build_order"
                xmlns:x="http://www-gna.inrialpes.fr/xsl/structs"
                exclude-result-prefixes="#all">

<xsl:import href="plug_functions_l2v1.xsl" />
<xsl:import href="remove_mathml_annotations_l2v1.xsl" />
<xsl:import href="n_arize_l2v1.xsl" />
<xsl:import href="remove_useless_n_ary_l2v1.xsl" />
<xsl:import href="clean_cn_ci_l2v1.xsl" />
<xsl:import href="prepare_constraints_l2v1.xsl" />
<xsl:import href="substitute_variable_assignments_l2v1.xsl" />

<xsl:import href="extract_variable_information_l2v1.xsl" />
<xsl:import href="extract_parameter_ordering_l2v1.xsl" />
<xsl:import href="extract_initial_conditions_l2v1.xsl" />

<xsl:import href="build_order_l2v1.xsl" />

<xsl:output indent="yes" />
<xsl:strip-space elements="*" />

<xsl:param name="skip-parameter-ordering">0</xsl:param>

<xsl:template match="/">
  <xsl:message>Cleaning up SBML document...</xsl:message>
  <xsl:variable name="sbml-clean" as="element()">
    <xsl:apply-templates select="sbml:sbml" mode="pre-treatment" />
  </xsl:variable>
  <xsl:message><xsl:value-of select="$sbml-clean/nowhere"/>Extracting variable info...</xsl:message>
  <xsl:variable name="extracted-var-info" as="element()"
                select="extrvar:extract-variable-information($sbml-clean)" />
  <xsl:choose>
    <xsl:when test="$skip-parameter-ordering != 0">
      <xsl:copy-of select="$extracted-var-info" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:choose>
        <xsl:when test="exists($extracted-var-info//
                          (gnaml:threshold-parameter|gnaml:zero-parameter|gnaml:box-parameter|
                          gnaml:synthesis-parameter|gnaml:degradation-parameter))">
          <xsl:message><xsl:copy-of select="$extracted-var-info/nowhere" />Ordering parameters and variables...</xsl:message>
          <xsl:choose>
            <xsl:when test="empty(order:nn-relations($sbml-clean))">
              <xsl:variable name="order-values" as="element()"
                            select="order:params-through-values-order($sbml-clean)" />
              <xsl:message><xsl:copy-of select="$order-values/nowhere" />Extracting parameter ordering...</xsl:message>
              <xsl:variable name="extracted-param-order" as="element()"
                            select="extrparam:extract-parameter-ordering-values($sbml-clean,$extracted-var-info,
                                                                                $order-values)" />
              <xsl:message><xsl:value-of select="$extracted-param-order/nowhere"/>Extracting initial conditions...</xsl:message>
              <xsl:copy-of select="extrinit:extract-initial-conditions-values($sbml-clean,$extracted-param-order,
                                                                                $order-values)" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:variable name="order-graph" as="element()"
                            select="order:all-stuff-order($sbml-clean,$extracted-var-info)" />
              <xsl:message><xsl:copy-of select="$order-graph/nowhere" />Extracting parameter ordering...</xsl:message>
              <xsl:variable name="extracted-param-order" as="element()"
                            select="extrparam:extract-parameter-ordering($sbml-clean,$extracted-var-info,
                                                                        $order-graph)" />
              <xsl:message><xsl:value-of select="$extracted-param-order/nowhere"/>Extracting initial conditions...</xsl:message>
              <xsl:copy-of select="extrinit:extract-initial-conditions($sbml-clean,$extracted-param-order,
                                                                      $order-graph)" />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:copy-of select="$extracted-var-info" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>
  <xsl:message>Import successful.</xsl:message>
</xsl:template>



<xsl:template match="sbml:sbml" mode="pre-treatment">
  <xsl:variable name="sbml-pre1" as="element()">
    <xsl:apply-templates select="." mode="pre-treatment-on-math-1" />
  </xsl:variable>
  <xsl:variable name="plugged-sbml" as="element()"
                select="plug:plug-functions($sbml-pre1)" />


  <xsl:variable name="sbml-pre2" as="element()">
    <xsl:apply-templates select="$plugged-sbml" mode="pre-treatment-on-math-2" />
  </xsl:variable>
  <xsl:variable name="sbml-pre3" as="element()"
                select="cstrts:prepare-constraints($sbml-pre2)" />
  <xsl:copy-of select="subs:substitute-variable-assignments($sbml-pre3)" />
</xsl:template>


<xsl:template match="mathml:math" mode="pre-treatment-on-math-1">
  <xsl:variable name="math-wo-annotation" select="rma:remove-mathml-annotations(.)" />
  <xsl:copy-of select="cnci:clean-cnci($math-wo-annotation)" />
</xsl:template>


<xsl:template match="*" mode="pre-treatment-on-math-1">
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


<xsl:template match="mathml:math" mode="pre-treatment-on-math-2">
  <xsl:variable name="math-n-arized" select="nary:n-arize(.)" />
  <xsl:copy-of select="rmu:remove-useless-n-ary($math-n-arized)" />
</xsl:template>


<xsl:template match="*" mode="pre-treatment-on-math-2">
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