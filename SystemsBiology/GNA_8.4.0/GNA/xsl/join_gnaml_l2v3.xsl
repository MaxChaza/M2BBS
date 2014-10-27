<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:gnaml="http://www-gna.inrialpes.fr/gnaml/version1"
                xmlns:join="http://www-gna.inrialpes.fr/xsl/join-gnaml"
                exclude-result-prefixes="#all">


<xsl:function name="join:join-gnaml">
  <xsl:param name="docs" as="element()*" />
  <xsl:choose>
    <xsl:when test="empty($docs)">
      <gnaml xmlns="http://www-gna.inrialpes.fr/gnaml/version1" />
    </xsl:when>
    <xsl:when test="count($docs)=1">
      <xsl:copy-of select="$docs" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:variable name="first-gnaml" as="element()" select="$docs[1]" />
      <xsl:variable name="rest" as="element()" 
                    select="join:join-gnaml($docs[position()>1])" />
      <xsl:copy-of select="join:join-gnaml($first-gnaml,$rest)" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>


<xsl:function name="join:join-gnaml">
  <xsl:param name="doc1" as="element()" />
  <xsl:param name="doc2" as="element()" />
  <gnaml version="1.0" xmlns="http://www-gna.inrialpes.fr/gnaml/version1">
    <xsl:apply-templates select="$doc1/gnaml:model" mode="join-gnaml">
      <xsl:with-param name="doc2" select="$doc2/gnaml:model[@id = $doc1/gnaml:model/@id]" />
    </xsl:apply-templates>
    <xsl:copy-of select="for $id in distinct-values(($doc1|$doc2)/gnaml:initial-conditions/@id)
                          return if (exists($doc1/gnaml:initial-conditions[@id = $id]))
                                then $doc1/gnaml:initial-conditions[@id = $id]
                                else $doc2/gnaml:initial-conditions[@id = $id]" />
  </gnaml>
</xsl:function>



<xsl:template match="gnaml:model" mode="join-gnaml">
  <xsl:param name="doc2" as="element()?" />
  <model id="{@id}" xmlns="http://www-gna.inrialpes.fr/gnaml/version1">
    <xsl:copy-of select="if (gnaml:comment) then gnaml:comment else $doc2/gnaml:comment" />
    <xsl:variable name="doc1" as="element()" select="." />
    <xsl:for-each select="distinct-values(gnaml:state-variable/@id|$doc2/gnaml:state-variable/@id
                                          |gnaml:input-variable/@id|$doc2/gnaml:input-variable/@id)">
      <xsl:variable name="id" as="xs:string" select="." />
      <xsl:choose>
        <xsl:when test="exists($doc1/(gnaml:state-variable|gnaml:input-variable)[@id = $id])">
          <xsl:apply-templates select="$doc1/(gnaml:state-variable|gnaml:input-variable)[@id = $id]"
                               mode="#current">
            <xsl:with-param name="doc2"
                            select="$doc2/(gnaml:state-variable|gnaml:input-variable)[@id = $id]" />
          </xsl:apply-templates>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="$doc2/(gnaml:state-variable|gnaml:input-variable)[@id = $id]"
                               mode="#current" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </model>
</xsl:template>

<xsl:template match="gnaml:state-variable|gnaml:input-variable" mode="join-gnaml">
  <xsl:param name="doc2" as="element()?" />
  <xsl:copy>
    <xsl:attribute name="id" select="@id" />
    <xsl:variable name="doc1" as="element()" select="." />
    <xsl:copy-of select="if (exists(gnaml:zero-parameter))
                         then (gnaml:zero-parameter)
                         else ($doc2/gnaml:zero-parameter)" />
    <xsl:copy-of select="if (exists(gnaml:box-parameter))
                         then (gnaml:box-parameter)
                         else ($doc2/gnaml:box-parameter)" />
    <xsl:variable name="threshold-parameters-ids" as="xs:string*"
                  select="(.|$doc2)/gnaml:list-of-threshold-parameters/gnaml:threshold-parameter/@id" />
    <xsl:if test="exists($threshold-parameters-ids)">
      <list-of-threshold-parameters xmlns="http://www-gna.inrialpes.fr/gnaml/version1">
        <xsl:copy-of select="for $id in distinct-values($threshold-parameters-ids)
                             return if (exists($doc1/gnaml:list-of-threshold-parameters
                                                /gnaml:threshold-parameter[@id = $id]))
                                    then $doc1/gnaml:list-of-threshold-parameters
                                          /gnaml:threshold-parameter[@id = $id]
                                    else $doc2/gnaml:list-of-threshold-parameters
                                          /gnaml:threshold-parameter[@id = $id]" />
      </list-of-threshold-parameters>
    </xsl:if>
    <xsl:variable name="synthesis-parameters-ids" as="xs:string*"
                  select="(.|$doc2)/gnaml:list-of-synthesis-parameters/gnaml:synthesis-parameter/@id" />
    <xsl:if test="exists($synthesis-parameters-ids)">
      <list-of-synthesis-parameters xmlns="http://www-gna.inrialpes.fr/gnaml/version1">
        <xsl:copy-of select="for $id in distinct-values($synthesis-parameters-ids)
                             return if (exists($doc1/gnaml:list-of-synthesis-parameters
                                                /gnaml:synthesis-parameter[@id = $id]))
                                    then $doc1/gnaml:list-of-synthesis-parameters
                                          /gnaml:synthesis-parameter[@id = $id]
                                    else $doc2/gnaml:list-of-synthesis-parameters
                                          /gnaml:synthesis-parameter[@id = $id]" />
      </list-of-synthesis-parameters>
    </xsl:if>
    <xsl:variable name="degradation-parameters-ids" as="xs:string*"
                  select="(.|$doc2)/gnaml:list-of-degradation-parameters
                            /gnaml:degradation-parameter/@id" />
    <xsl:if test="exists($degradation-parameters-ids)">
      <list-of-degradation-parameters xmlns="http://www-gna.inrialpes.fr/gnaml/version1">
        <xsl:copy-of select="for $id in distinct-values($degradation-parameters-ids)
                             return if (exists($doc1/gnaml:list-of-degradation-parameters
                                                /gnaml:degradation-parameter[@id = $id]))
                                    then $doc1/gnaml:list-of-degradation-parameters
                                          /gnaml:degradation-parameter[@id = $id]
                                    else $doc2/gnaml:list-of-degradation-parameters
                                          /gnaml:degradation-parameter[@id = $id]" />
      </list-of-degradation-parameters>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="$doc1/gnaml:state-equation">
        <xsl:copy-of select="$doc1/gnaml:state-equation" />
      </xsl:when>
      <xsl:when test="$doc2/gnaml:state-equation">
        <xsl:copy-of select="$doc2/gnaml:state-equation" />
      </xsl:when>
    </xsl:choose>
    <xsl:choose>
      <xsl:when test="$doc1/gnaml:parameter-inequalities">
        <xsl:copy-of select="$doc1/gnaml:parameter-inequalities" />
      </xsl:when>
      <xsl:when test="$doc2/gnaml:parameter-inequalities">
        <xsl:copy-of select="$doc2/gnaml:parameter-inequalities" />
      </xsl:when>
    </xsl:choose>
  </xsl:copy>
</xsl:template>

</xsl:stylesheet>