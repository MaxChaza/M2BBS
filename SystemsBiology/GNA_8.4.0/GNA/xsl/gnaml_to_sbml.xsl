<?xml version="1.0" encoding="UTF-8"?>
<!--
  This stylesheet is used to convert from a GNAML document to a SBML one.

  It's use requires that a parameter 'sbml' is set to one of the supported
  namespaces:
    'http://www.sbml.org/sbml/level2'          (SBML Level 2 Version 1)
    'http://www.sbml.org/sbml/level2/version2' (SBML Level 2 Version 2)
    'http://www.sbml.org/sbml/level2/version3' (SBML Level 2 Version 3)
    'http://www.sbml.org/sbml/level2/version4' (SBML Level 2 Version 4)
  If none of the above is used, a default namespace is used that corresponds
  to the SBML Level 2 Version 4 release.

  For details on the translation process, please refer to GNA's documentation.

  Simply note, that initial conditions require creating some complicated
  parameters all other the SBML document. This is why in the code you'll often
  find code related to that, notably using the variable 'species-with-ic'.

  @author Bruno Besson
-->
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:mathml="http://www.w3.org/1998/Math/MathML"
                xmlns:gnaml="http://www-gna.inrialpes.fr/gnaml/version1"
                exclude-result-prefixes="#all">

<xsl:output indent="yes" />
<xsl:strip-space elements="*" />

<!--
  The parameter that defines the SBML version.
-->
<xsl:param name="sbml" as="xs:string" required="no"
           select="'http://www.sbml.org/sbml/level2/version4'" />

<!--
  In practice, this is the namespace used, after having checked the validity
  of the parameter.
-->
<xsl:variable name="sbml-ns" as="xs:string"
              select="if ($sbml = 'http://www.sbml.org/sbml/level2'
                          or $sbml = 'http://www.sbml.org/sbml/level2/version2'
                          or $sbml = 'http://www.sbml.org/sbml/level2/version3')
                      then $sbml
                      else 'http://www.sbml.org/sbml/level2/version4'" />

<xsl:template match="/">
  <!-- First test how many initial conditions are present within the GNAML
       document. We cannot store more than one. -->
  <xsl:if test="count(gnaml:gnaml/gnaml:initial-conditions) > 1">
    <xsl:message>
      <xsl:text>[WARNING] more than one initial-conditions found. Using first ones</xsl:text>
      <xsl:if test="exists(gnaml:gnaml/gnaml:initial-conditions[1]/@id)">
        <xsl:text>: '</xsl:text>
        <xsl:value-of select="gnaml:gnaml/gnaml:initial-conditions[1]/@id" />
        <xsl:text>'</xsl:text>
      </xsl:if>
      <xsl:if test="exists(gnaml:gnaml/gnaml:initial-conditions[1]/@gnaml:id)">
        <xsl:text>: '</xsl:text>
        <xsl:value-of select="gnaml:gnaml/gnaml:initial-conditions[1]/@gnaml:id" />
        <xsl:text>'</xsl:text>
      </xsl:if>
    </xsl:message>
  </xsl:if>

  <xsl:element name="sbml" namespace="{$sbml-ns}">
    <xsl:attribute name="level" select="2" />
    <xsl:attribute name="version"
                   select="if ($sbml-ns = 'http://www.sbml.org/sbml/level2')
                           then (1)
                           else if ($sbml-ns = 'http://www.sbml.org/sbml/level2/version2')
                           then (2)
                           else if ($sbml-ns = 'http://www.sbml.org/sbml/level2/version3')
                           then (3)
                           else (4)
                           " />
    <xsl:if test="exists(gnaml:gnaml/gnaml:notes)">
      <xsl:element name="notes" namespace="{$sbml-ns}">
        <xsl:copy-of select="gnaml:gnaml/gnaml:notes/*" />
      </xsl:element>
    </xsl:if>
    <xsl:element name="model" namespace="{$sbml-ns}">
      <xsl:attribute name="id" select="concat(gnaml:gnaml/gnaml:model/@id,gnaml:gnaml/gnaml:model/@gnaml:id)" />
      <xsl:if test="exists(gnaml:gnaml/gnaml:model/gnaml:notes)">
        <xsl:element name="notes" namespace="{$sbml-ns}">
          <xsl:copy-of select="gnaml:gnaml/gnaml:model/gnaml:notes/*" />
        </xsl:element>
      </xsl:if>
      <xsl:element name="listOfFunctionDefinitions" namespace="{$sbml-ns}">
        <xsl:element name="functionDefinition" namespace="{$sbml-ns}">
          <xsl:attribute name="id" select="'step_plus'" />
          <math xmlns="http://www.w3.org/1998/Math/MathML">
            <lambda>
              <bvar>
                <ci>x</ci>
              </bvar>
              <bvar>
                <ci>t</ci>
              </bvar>
              <piecewise>
                <piece>
                  <cn type="integer">0</cn>
                  <apply>
                    <lt />
                    <ci>x</ci>
                    <ci>t</ci>
                  </apply>
                </piece>
                <piece>
                  <cn type="integer">1</cn>
                  <apply>
                    <gt />
                    <ci>x</ci>
                    <ci>t</ci>
                  </apply>
                </piece>
              </piecewise>
            </lambda>
          </math>
        </xsl:element><!-- functionDefinition -->
        <xsl:element name="functionDefinition" namespace="{$sbml-ns}">
          <xsl:attribute name="id" select="'step_minus'" />
          <math xmlns="http://www.w3.org/1998/Math/MathML">
            <lambda>
              <bvar>
                <ci>x</ci>
              </bvar>
              <bvar>
                <ci>t</ci>
              </bvar>
              <piecewise>
                <piece>
                  <cn type="integer">1</cn>
                  <apply>
                    <lt />
                    <ci>x</ci>
                    <ci>t</ci>
                  </apply>
                </piece>
                <piece>
                  <cn type="integer">0</cn>
                  <apply>
                    <gt />
                    <ci>x</ci>
                    <ci>t</ci>
                  </apply>
                </piece>
              </piecewise>
            </lambda>
          </math>
        </xsl:element><!-- functionDefinition -->
      </xsl:element><!-- listOfFunctionDefinitions -->
      <xsl:element name="listOfCompartments" namespace="{$sbml-ns}">
        <xsl:element name="compartment" namespace="{$sbml-ns}">
          <xsl:attribute name="id" select="'cell'" />
          <xsl:attribute name="spatialDimensions" select="0" />
        </xsl:element><!-- compartment -->
      </xsl:element><!-- listOfCompartments -->
      <xsl:variable name="species" as="element()*">
        <xsl:for-each select="gnaml:gnaml/gnaml:model/(gnaml:state-variable|gnaml:input-variable)">
          <xsl:element name="species" namespace="{$sbml-ns}">
            <xsl:attribute name="id" select="concat(@id,@gnaml:id)" />
            <xsl:attribute name="compartment" select="'cell'" />
            <xsl:if test="self::gnaml:input-variable">
              <xsl:attribute name="constant" select="'true'" />
            </xsl:if>
            <xsl:if test="exists(gnaml:notes)">
              <xsl:element name="notes" namespace="{$sbml-ns}">
                <xsl:copy-of select="gnaml:notes/*" />
              </xsl:element>
            </xsl:if>
          </xsl:element><!-- species -->
        </xsl:for-each>
      </xsl:variable>
      <xsl:if test="exists($species)">
        <xsl:element name="listOfSpecies" namespace="{$sbml-ns}">
          <xsl:copy-of select="$species" />
        </xsl:element><!-- listOfSpecies -->
      </xsl:if>

      <!--
        initial conditions: define a parameter identical to species with a
        '_init_cond' suffix for every species having initial conditions defined
      -->
      <xsl:variable name="species-with-ic" as="xs:string*">
        <xsl:sequence select="distinct-values(gnaml:gnaml/gnaml:initial-conditions[1]/gnaml:constraint
                                /mathml:math/(mathml:apply|(mathml:semantics/mathml:apply))
                                /element()[2]/self::mathml:ci)" />
      </xsl:variable>

      <xsl:variable name="parameters" as="element()*">
        <xsl:for-each select="gnaml:gnaml/gnaml:model/(gnaml:state-variable|gnaml:input-variable)/
                                (gnaml:zero-parameter |
                                 gnaml:box-parameter |
                                 gnaml:list-of-threshold-parameters/gnaml:threshold-parameter |
                                 gnaml:list-of-synthesis-parameters/gnaml:synthesis-parameter |
                                 gnaml:list-of-degradation-parameters/gnaml:degradation-parameter)">
          <xsl:element name="parameter" namespace="{$sbml-ns}">
            <xsl:attribute name="id" select="concat(@id,@gnaml:id)" />
            <xsl:if test="exists(gnaml:notes)">
              <xsl:element name="notes" namespace="{$sbml-ns}">
                <xsl:copy-of select="gnaml:notes/*" />
              </xsl:element>
            </xsl:if>
          </xsl:element><!-- parameter -->
        </xsl:for-each>
        <xsl:if test="$sbml-ns != 'http://www.sbml.org/sbml/level2'"><!-- in case of ICs -->
          <xsl:for-each select="$species-with-ic">
            <xsl:element name="parameter" namespace="{$sbml-ns}">
              <xsl:attribute name="id" select="concat(.,'_init_cond')" />
            </xsl:element><!-- parameter -->
          </xsl:for-each>
        </xsl:if>
      </xsl:variable>
      <xsl:if test="exists($parameters)">
        <xsl:element name="listOfParameters" namespace="{$sbml-ns}">
          <xsl:copy-of select="$parameters" />
        </xsl:element><!-- listOfParameters -->
      </xsl:if>

      <!-- insert definitions required for initial conditions -->
      <xsl:if test="$sbml-ns != 'http://www.sbml.org/sbml/level2'
                and exists($species-with-ic)">
        <xsl:element name="listOfInitialAssignments" namespace="{$sbml-ns}">
          <xsl:for-each select="$species-with-ic">
            <xsl:element name="initialAssignment" namespace="{$sbml-ns}">
              <xsl:attribute name="symbol" select="." />
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                <ci><xsl:value-of select="."/><xsl:text>_init_cond</xsl:text></ci>
              </math>
            </xsl:element>
          </xsl:for-each>
        </xsl:element><!-- listOfInitialAssignments -->
      </xsl:if>

      <xsl:variable name="state-equations" as="element()*">
        <xsl:apply-templates select="gnaml:gnaml/gnaml:model/gnaml:state-variable/gnaml:state-equation" />
      </xsl:variable>
      <xsl:if test="exists($state-equations)">
        <xsl:element name="listOfRules" namespace="{$sbml-ns}">
          <xsl:copy-of select="$state-equations" />
        </xsl:element><!-- listOfRules -->
      </xsl:if>
      <xsl:variable name="constraints" as="element()*">
        <xsl:apply-templates select="gnaml:gnaml/gnaml:model/(gnaml:state-variable|gnaml:input-variable)
                                      /gnaml:parameter-inequalities" />
        <xsl:apply-templates select="gnaml:gnaml/gnaml:initial-conditions[1]" />
      </xsl:variable>
      <xsl:if test="exists($constraints)">
        <xsl:element name="listOfConstraints" namespace="{$sbml-ns}">
          <xsl:copy-of select="$constraints" />
        </xsl:element><!-- listOfConstraints -->
      </xsl:if>
    </xsl:element><!-- model-->
  </xsl:element><!-- sbml-->
</xsl:template>

<!--
  This template a the few below deal with copying state equation. Although it
  is almost identical to the math in GNAML, the use of the <mathml:csymbol/>
  elements for step-functions isn't possible and must be replaced with a call
  to the function definitions.
-->
<xsl:template match="gnaml:state-equation">
  <xsl:element name="rateRule" namespace="{$sbml-ns}">
    <xsl:attribute name="variable" select="concat(../@id,../@gnaml:id)" />
    <xsl:if test="exists(gnaml:notes)">
      <xsl:element name="notes" namespace="{$sbml-ns}">
        <xsl:copy-of select="gnaml:notes/*" />
      </xsl:element>
    </xsl:if>
    <xsl:apply-templates select="mathml:math" mode="copy-equation" />
  </xsl:element><!-- rateRule -->
</xsl:template>

<xsl:template match="mathml:math" mode="copy-equation">
  <math xmlns="http://www.w3.org/1998/Math/MathML">
    <xsl:apply-templates select="mathml:*" mode="#current" />
  </math>
</xsl:template>

<xsl:template match="mathml:ci|mathml:cn" mode="copy-equation">
  <xsl:copy-of select="." />
</xsl:template>

<xsl:template match="mathml:apply[mathml:csymbol]" mode="copy-equation">
  <apply xmlns="http://www.w3.org/1998/Math/MathML">
    <xsl:choose>
      <xsl:when test="mathml:csymbol='s+'">
        <ci xmlns="http://www.w3.org/1998/Math/MathML">step_plus</ci>
      </xsl:when>
      <xsl:when test="mathml:csymbol/@mathml:definitionURL='http://www-gna.inrialpes.fr/gnaml/symbols/step_plus'">
        <ci xmlns="http://www.w3.org/1998/Math/MathML">step_plus</ci>
      </xsl:when>
      <xsl:otherwise>
        <ci xmlns="http://www.w3.org/1998/Math/MathML">step_minus</ci>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates select="mathml:*[position()>1]" mode="#current" />
  </apply>
</xsl:template>

<xsl:template match="mathml:semantics" mode="copy-equation">
  <xsl:apply-templates select="mathml:*[1]" mode="#current" />
</xsl:template>

<xsl:template match="mathml:*" mode="copy-equation">
  <xsl:copy>
    <xsl:apply-templates select="*" mode="#current" />
  </xsl:copy>
</xsl:template>

<!--
  The templates below deal with constraints transforming.
  Initial conditions constraints cannot be directly copied, variable names
  must be changed to reflect the initial assignments.
-->
<xsl:template match="gnaml:initial-conditions">
  <xsl:apply-templates select="gnaml:constraint" />
</xsl:template>

<xsl:template match="gnaml:constraint">
  <xsl:if test="$sbml-ns != 'http://www.sbml.org/sbml/level2'">
    <xsl:element name="constraint" namespace="{$sbml-ns}">
      <xsl:if test="exists(gnaml:notes)">
        <xsl:element name="notes" namespace="{$sbml-ns}">
          <xsl:copy-of select="gnaml:notes/*" />
        </xsl:element>
      </xsl:if>
      <math xmlns="http://www.w3.org/1998/Math/MathML">
        <apply>
          <xsl:copy-of select="mathml:math/(mathml:apply|(mathml:semantics/mathml:apply))/element()[1]" />
          <ci>
            <xsl:copy-of select="concat(string(mathml:math/(mathml:apply|(mathml:semantics/mathml:apply))
                                                /element()[2]),'_init_cond')" />
          </ci>
          <xsl:copy-of select="mathml:math/(mathml:apply|(mathml:semantics/mathml:apply))/element()[3]" />
        </apply>
      </math>
    </xsl:element><!-- constraint -->
  </xsl:if>
</xsl:template>

<!--
  Parameter inequalities math.
  Contrary to other maths, there is no transformation required here.
-->
<xsl:template match="gnaml:parameter-inequalities">
  <xsl:if test="$sbml-ns != 'http://www.sbml.org/sbml/level2'">
    <xsl:element name="constraint" namespace="{$sbml-ns}">
      <xsl:if test="exists(gnaml:notes)">
        <xsl:element name="notes" namespace="{$sbml-ns}">
          <xsl:copy-of select="gnaml:notes/*" />
        </xsl:element>
      </xsl:if>
      <math xmlns="http://www.w3.org/1998/Math/MathML">
        <xsl:copy-of select="mathml:math/(mathml:apply|(mathml:semantics/mathml:apply))" />
      </math>
    </xsl:element><!-- constraint -->
  </xsl:if>
</xsl:template>

</xsl:stylesheet>