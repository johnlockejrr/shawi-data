<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:rna="http://relaxng.org/ns/compatibility/annotations/1.0" xmlns:rng="http://relaxng.org/ns/structure/1.0" xmlns:saxon="http://saxon.sf.net/" xmlns:sch="http://purl.oclc.org/dsdl/schematron" xmlns:sch1x="http://www.ascc.net/xml/schematron" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsd="http://www.w3.org/2001/XMLSchema" version="2.0"><!--Implementers: please note that overriding process-prolog or process-root is 
    the preferred method for meta-stylesheets to use where possible. -->
   <xsl:param name="archiveDirParameter"/>
   <xsl:param name="archiveNameParameter"/>
   <xsl:param name="fileNameParameter"/>
   <xsl:param name="fileDirParameter"/>
   <xsl:variable name="document-uri">
      <xsl:value-of select="document-uri(/)"/>
   </xsl:variable>
   <!--PHASES-->
   <!--PROLOG-->
   <xsl:output xmlns:svrl="http://purl.oclc.org/dsdl/svrl" method="xml" omit-xml-declaration="no" standalone="yes" indent="yes"/>
   <!--XSD TYPES FOR XSLT2-->
   <!--KEYS AND FUNCTIONS-->
   <!--DEFAULT RULES-->
   <!--MODE: SCHEMATRON-SELECT-FULL-PATH-->
   <!--This mode can be used to generate an ugly though full XPath for locators-->
   <xsl:template match="*" mode="schematron-select-full-path">
      <xsl:apply-templates select="." mode="schematron-get-full-path"/>
   </xsl:template>
   <!--MODE: SCHEMATRON-FULL-PATH-->
   <!--This mode can be used to generate an ugly though full XPath for locators-->
   <xsl:template match="*" mode="schematron-get-full-path">
      <xsl:apply-templates select="parent::*" mode="schematron-get-full-path"/>
      <xsl:text>/</xsl:text>
      <xsl:choose>
         <xsl:when test="namespace-uri()=''">
            <xsl:value-of select="name()"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>*:</xsl:text>
            <xsl:value-of select="local-name()"/>
            <xsl:text>[namespace-uri()='</xsl:text>
            <xsl:value-of select="namespace-uri()"/>
            <xsl:text>']</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:variable name="preceding" select="count(preceding-sibling::*[local-name()=local-name(current())                                   and namespace-uri() = namespace-uri(current())])"/>
      <xsl:text>[</xsl:text>
      <xsl:value-of select="1+ $preceding"/>
      <xsl:text>]</xsl:text>
   </xsl:template>
   <xsl:template match="@*" mode="schematron-get-full-path">
      <xsl:apply-templates select="parent::*" mode="schematron-get-full-path"/>
      <xsl:text>/</xsl:text>
      <xsl:choose>
         <xsl:when test="namespace-uri()=''">@<xsl:value-of select="name()"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>@*[local-name()='</xsl:text>
            <xsl:value-of select="local-name()"/>
            <xsl:text>' and namespace-uri()='</xsl:text>
            <xsl:value-of select="namespace-uri()"/>
            <xsl:text>']</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <!--MODE: SCHEMATRON-FULL-PATH-2-->
   <!--This mode can be used to generate prefixed XPath for humans-->
   <xsl:template match="node() | @*" mode="schematron-get-full-path-2">
      <xsl:for-each select="ancestor-or-self::*">
         <xsl:text>/</xsl:text>
         <xsl:value-of select="name(.)"/>
         <xsl:if test="preceding-sibling::*[name(.)=name(current())]">
            <xsl:text>[</xsl:text>
            <xsl:value-of select="count(preceding-sibling::*[name(.)=name(current())])+1"/>
            <xsl:text>]</xsl:text>
         </xsl:if>
      </xsl:for-each>
      <xsl:if test="not(self::*)">
         <xsl:text/>/@<xsl:value-of select="name(.)"/>
      </xsl:if>
   </xsl:template>
   <!--MODE: SCHEMATRON-FULL-PATH-3-->
   <!--This mode can be used to generate prefixed XPath for humans 
	(Top-level element has index)-->
   <xsl:template match="node() | @*" mode="schematron-get-full-path-3">
      <xsl:for-each select="ancestor-or-self::*">
         <xsl:text>/</xsl:text>
         <xsl:value-of select="name(.)"/>
         <xsl:if test="parent::*">
            <xsl:text>[</xsl:text>
            <xsl:value-of select="count(preceding-sibling::*[name(.)=name(current())])+1"/>
            <xsl:text>]</xsl:text>
         </xsl:if>
      </xsl:for-each>
      <xsl:if test="not(self::*)">
         <xsl:text/>/@<xsl:value-of select="name(.)"/>
      </xsl:if>
   </xsl:template>
   <!--MODE: GENERATE-ID-FROM-PATH -->
   <xsl:template match="/" mode="generate-id-from-path"/>
   <xsl:template match="text()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.text-', 1+count(preceding-sibling::text()), '-')"/>
   </xsl:template>
   <xsl:template match="comment()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.comment-', 1+count(preceding-sibling::comment()), '-')"/>
   </xsl:template>
   <xsl:template match="processing-instruction()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.processing-instruction-', 1+count(preceding-sibling::processing-instruction()), '-')"/>
   </xsl:template>
   <xsl:template match="@*" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.@', name())"/>
   </xsl:template>
   <xsl:template match="*" mode="generate-id-from-path" priority="-0.5">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:text>.</xsl:text>
      <xsl:value-of select="concat('.',name(),'-',1+count(preceding-sibling::*[name()=name(current())]),'-')"/>
   </xsl:template>
   <!--MODE: GENERATE-ID-2 -->
   <xsl:template match="/" mode="generate-id-2">U</xsl:template>
   <xsl:template match="*" mode="generate-id-2" priority="2">
      <xsl:text>U</xsl:text>
      <xsl:number level="multiple" count="*"/>
   </xsl:template>
   <xsl:template match="node()" mode="generate-id-2">
      <xsl:text>U.</xsl:text>
      <xsl:number level="multiple" count="*"/>
      <xsl:text>n</xsl:text>
      <xsl:number count="node()"/>
   </xsl:template>
   <xsl:template match="@*" mode="generate-id-2">
      <xsl:text>U.</xsl:text>
      <xsl:number level="multiple" count="*"/>
      <xsl:text>_</xsl:text>
      <xsl:value-of select="string-length(local-name(.))"/>
      <xsl:text>_</xsl:text>
      <xsl:value-of select="translate(name(),':','.')"/>
   </xsl:template>
   <!--Strip characters-->
   <xsl:template match="text()" priority="-1"/>
   <!--SCHEMA SETUP-->
   <xsl:template match="/">
      <svrl:schematron-output xmlns:svrl="http://purl.oclc.org/dsdl/svrl" title="" schemaVersion="">
         <xsl:comment>
            <xsl:value-of select="$archiveDirParameter"/>   
		 <xsl:value-of select="$archiveNameParameter"/>  
		 <xsl:value-of select="$fileNameParameter"/>  
		 <xsl:value-of select="$fileDirParameter"/>
         </xsl:comment>
         <svrl:ns-prefix-in-attribute-values uri="http://www.tei-c.org/ns/1.0" prefix="tei"/>
         <svrl:ns-prefix-in-attribute-values uri="http://www.w3.org/2001/XMLSchema" prefix="xs"/>
         <svrl:ns-prefix-in-attribute-values uri="http://relaxng.org/ns/structure/1.0" prefix="rng"/>
         <svrl:ns-prefix-in-attribute-values uri="http://relaxng.org/ns/compatibility/annotations/1.0" prefix="rna"/>
         <svrl:ns-prefix-in-attribute-values uri="http://purl.oclc.org/dsdl/schematron" prefix="sch"/>
         <svrl:ns-prefix-in-attribute-values uri="http://www.ascc.net/xml/schematron" prefix="sch1x"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">vicav_corpus-att.cmc-generatedBy-CMC_generatedBy_within_post-constraint-rule-1</xsl:attribute>
            <xsl:attribute name="name">vicav_corpus-att.cmc-generatedBy-CMC_generatedBy_within_post-constraint-rule-1</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M6"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">vicav_corpus-att.datable.w3c-att-datable-w3c-when-constraint-rule-2</xsl:attribute>
            <xsl:attribute name="name">vicav_corpus-att.datable.w3c-att-datable-w3c-when-constraint-rule-2</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M7"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">vicav_corpus-att.datable.w3c-att-datable-w3c-from-constraint-rule-3</xsl:attribute>
            <xsl:attribute name="name">vicav_corpus-att.datable.w3c-att-datable-w3c-from-constraint-rule-3</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M8"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">vicav_corpus-att.datable.w3c-att-datable-w3c-to-constraint-rule-4</xsl:attribute>
            <xsl:attribute name="name">vicav_corpus-att.datable.w3c-att-datable-w3c-to-constraint-rule-4</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M9"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">vicav_corpus-att.global.source-source-only_1_ODD_source-constraint-rule-5</xsl:attribute>
            <xsl:attribute name="name">vicav_corpus-att.global.source-source-only_1_ODD_source-constraint-rule-5</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M10"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">vicav_corpus-att.pointing-targetLang-targetLang-constraint-rule-6</xsl:attribute>
            <xsl:attribute name="name">vicav_corpus-att.pointing-targetLang-targetLang-constraint-rule-6</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M11"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">vicav_corpus-att.styleDef-schemeVersion-schemeVersionRequiresScheme-constraint-rule-7</xsl:attribute>
            <xsl:attribute name="name">vicav_corpus-att.styleDef-schemeVersion-schemeVersionRequiresScheme-constraint-rule-7</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M12"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">vicav_corpus-att.typed-subtypeTyped-constraint-rule-8</xsl:attribute>
            <xsl:attribute name="name">vicav_corpus-att.typed-subtypeTyped-constraint-rule-8</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M13"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">vicav_corpus-att.calendarSystem-calendar-calendar_attr_on_empty_element-constraint-rule-9</xsl:attribute>
            <xsl:attribute name="name">vicav_corpus-att.calendarSystem-calendar-calendar_attr_on_empty_element-constraint-rule-9</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M14"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">vicav_corpus-p-abstractModel-structure-p-in-ab-or-p-constraint-rule-10</xsl:attribute>
            <xsl:attribute name="name">vicav_corpus-p-abstractModel-structure-p-in-ab-or-p-constraint-rule-10</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M15"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">vicav_corpus-p-abstractModel-structure-p-in-l-constraint-rule-11</xsl:attribute>
            <xsl:attribute name="name">vicav_corpus-p-abstractModel-structure-p-in-l-constraint-rule-11</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M16"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">vicav_corpus-desc-deprecationInfo-only-in-deprecated-constraint-rule-12</xsl:attribute>
            <xsl:attribute name="name">vicav_corpus-desc-deprecationInfo-only-in-deprecated-constraint-rule-12</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M17"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">vicav_corpus-ref-refAtts-constraint-rule-13</xsl:attribute>
            <xsl:attribute name="name">vicav_corpus-ref-refAtts-constraint-rule-13</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M18"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">vicav_corpus-resp-uniqueRespValues-constraint-rule-14</xsl:attribute>
            <xsl:attribute name="name">vicav_corpus-resp-uniqueRespValues-constraint-rule-14</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M19"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">vicav_corpus-fileDesc-rec-person-twice-constraint-rule-15</xsl:attribute>
            <xsl:attribute name="name">vicav_corpus-fileDesc-rec-person-twice-constraint-rule-15</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M20"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">vicav_corpus-funder-funderIdnoType-constraint-rule-16</xsl:attribute>
            <xsl:attribute name="name">vicav_corpus-funder-funderIdnoType-constraint-rule-16</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M21"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">vicav_corpus-publicationStmt-publStmtIdnoType-constraint-rule-17</xsl:attribute>
            <xsl:attribute name="name">vicav_corpus-publicationStmt-publStmtIdnoType-constraint-rule-17</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M22"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">vicav_corpus-div-abstractModel-structure-div-in-l-constraint-rule-18</xsl:attribute>
            <xsl:attribute name="name">vicav_corpus-div-abstractModel-structure-div-in-l-constraint-rule-18</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M23"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">vicav_corpus-div-abstractModel-structure-div-in-ab-or-p-constraint-rule-19</xsl:attribute>
            <xsl:attribute name="name">vicav_corpus-div-abstractModel-structure-div-in-ab-or-p-constraint-rule-19</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M24"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">vicav_corpus-w-msd-spec-constraint-rule-20</xsl:attribute>
            <xsl:attribute name="name">vicav_corpus-w-msd-spec-constraint-rule-20</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M25"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">vicav_corpus-w-lemmaRef-spec-constraint-rule-21</xsl:attribute>
            <xsl:attribute name="name">vicav_corpus-w-lemmaRef-spec-constraint-rule-21</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M26"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">vicav_corpus-span-span-target-check-constraint-rule-22</xsl:attribute>
            <xsl:attribute name="name">vicav_corpus-span-span-target-check-constraint-rule-22</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M27"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">vicav_corpus-span-target-from-constraint-rule-23</xsl:attribute>
            <xsl:attribute name="name">vicav_corpus-span-target-from-constraint-rule-23</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M28"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">vicav_corpus-span-targetto-constraint-rule-24</xsl:attribute>
            <xsl:attribute name="name">vicav_corpus-span-targetto-constraint-rule-24</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M29"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">vicav_corpus-span-tonotfrom-constraint-rule-25</xsl:attribute>
            <xsl:attribute name="name">vicav_corpus-span-tonotfrom-constraint-rule-25</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M30"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">vicav_corpus-span-tofrom-constraint-rule-26</xsl:attribute>
            <xsl:attribute name="name">vicav_corpus-span-tofrom-constraint-rule-26</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M31"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">vicav_corpus-shift-shiftNew-constraint-rule-27</xsl:attribute>
            <xsl:attribute name="name">vicav_corpus-shift-shiftNew-constraint-rule-27</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M32"/>
      </svrl:schematron-output>
   </xsl:template>
   <!--SCHEMATRON PATTERNS-->
   <!--PATTERN vicav_corpus-att.cmc-generatedBy-CMC_generatedBy_within_post-constraint-rule-1-->
   <!--RULE -->
   <xsl:template match="tei:*[@generatedBy]" priority="1000" mode="M6">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="tei:*[@generatedBy]"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="ancestor-or-self::tei:post"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="ancestor-or-self::tei:post">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>The @generatedBy attribute is for use within a &lt;post&gt; element.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M6"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M6"/>
   <xsl:template match="@*|node()" priority="-2" mode="M6">
      <xsl:apply-templates select="*" mode="M6"/>
   </xsl:template>
   <!--PATTERN vicav_corpus-att.datable.w3c-att-datable-w3c-when-constraint-rule-2-->
   <!--RULE -->
   <xsl:template match="tei:*[@when]" priority="1000" mode="M7">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="tei:*[@when]"/>
      <!--REPORT nonfatal-->
      <xsl:if test="@notBefore|@notAfter|@from|@to">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@notBefore|@notAfter|@from|@to">
            <xsl:attribute name="role">nonfatal</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>The @when attribute cannot be used with any other att.datable.w3c attributes.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M7"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M7"/>
   <xsl:template match="@*|node()" priority="-2" mode="M7">
      <xsl:apply-templates select="*" mode="M7"/>
   </xsl:template>
   <!--PATTERN vicav_corpus-att.datable.w3c-att-datable-w3c-from-constraint-rule-3-->
   <!--RULE -->
   <xsl:template match="tei:*[@from]" priority="1000" mode="M8">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="tei:*[@from]"/>
      <!--REPORT nonfatal-->
      <xsl:if test="@notBefore">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@notBefore">
            <xsl:attribute name="role">nonfatal</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>The @from and @notBefore attributes cannot be used together.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M8"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M8"/>
   <xsl:template match="@*|node()" priority="-2" mode="M8">
      <xsl:apply-templates select="*" mode="M8"/>
   </xsl:template>
   <!--PATTERN vicav_corpus-att.datable.w3c-att-datable-w3c-to-constraint-rule-4-->
   <!--RULE -->
   <xsl:template match="tei:*[@to]" priority="1000" mode="M9">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="tei:*[@to]"/>
      <!--REPORT nonfatal-->
      <xsl:if test="@notAfter">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@notAfter">
            <xsl:attribute name="role">nonfatal</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>The @to and @notAfter attributes cannot be used together.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M9"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M9"/>
   <xsl:template match="@*|node()" priority="-2" mode="M9">
      <xsl:apply-templates select="*" mode="M9"/>
   </xsl:template>
   <!--PATTERN vicav_corpus-att.global.source-source-only_1_ODD_source-constraint-rule-5-->
   <!--RULE -->
   <xsl:template match="tei:*[@source]" priority="1000" mode="M10">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="tei:*[@source]"/>
      <xsl:variable name="srcs" select="tokenize( normalize-space(@source),' ')"/>
      <!--REPORT -->
      <xsl:if test="(   self::tei:classRef                                 | self::tei:dataRef                                 | self::tei:elementRef                                 | self::tei:macroRef                                 | self::tei:moduleRef                                 | self::tei:schemaSpec )                                   and                                   $srcs[2]">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="( self::tei:classRef | self::tei:dataRef | self::tei:elementRef | self::tei:macroRef | self::tei:moduleRef | self::tei:schemaSpec ) and $srcs[2]">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
              When used on a schema description element (like
              <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/>), the @source attribute
              should have only 1 value. (This one has <xsl:text/>
               <xsl:value-of select="count($srcs)"/>
               <xsl:text/>.)
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M10"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M10"/>
   <xsl:template match="@*|node()" priority="-2" mode="M10">
      <xsl:apply-templates select="*" mode="M10"/>
   </xsl:template>
   <!--PATTERN vicav_corpus-att.pointing-targetLang-targetLang-constraint-rule-6-->
   <!--RULE -->
   <xsl:template match="tei:*[not(self::tei:schemaSpec)][@targetLang]" priority="1000" mode="M11">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="tei:*[not(self::tei:schemaSpec)][@targetLang]"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="@target"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@target">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>@targetLang should only be used on <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> if @target is specified.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M11"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M11"/>
   <xsl:template match="@*|node()" priority="-2" mode="M11">
      <xsl:apply-templates select="*" mode="M11"/>
   </xsl:template>
   <!--PATTERN vicav_corpus-att.styleDef-schemeVersion-schemeVersionRequiresScheme-constraint-rule-7-->
   <!--RULE -->
   <xsl:template match="tei:*[@schemeVersion]" priority="1000" mode="M12">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="tei:*[@schemeVersion]"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="@scheme and not(@scheme = 'free')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@scheme and not(@scheme = 'free')">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
              @schemeVersion can only be used if @scheme is specified.
            </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M12"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M12"/>
   <xsl:template match="@*|node()" priority="-2" mode="M12">
      <xsl:apply-templates select="*" mode="M12"/>
   </xsl:template>
   <!--PATTERN vicav_corpus-att.typed-subtypeTyped-constraint-rule-8-->
   <!--RULE -->
   <xsl:template match="tei:*[@subtype]" priority="1000" mode="M13">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="tei:*[@subtype]"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="@type"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@type">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>The <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> element should not be categorized in detail with @subtype unless also categorized in general with @type</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M13"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M13"/>
   <xsl:template match="@*|node()" priority="-2" mode="M13">
      <xsl:apply-templates select="*" mode="M13"/>
   </xsl:template>
   <!--PATTERN vicav_corpus-att.calendarSystem-calendar-calendar_attr_on_empty_element-constraint-rule-9-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M14">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="tei:*[@calendar]"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length( normalize-space(.) ) gt 0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="string-length( normalize-space(.) ) gt 0">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> @calendar indicates one or more
              systems or calendars to which the date represented by the content of this element belongs,
              but this <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> element has no textual content.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M14"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M14"/>
   <xsl:template match="@*|node()" priority="-2" mode="M14">
      <xsl:apply-templates select="*" mode="M14"/>
   </xsl:template>
   <!--PATTERN vicav_corpus-p-abstractModel-structure-p-in-ab-or-p-constraint-rule-10-->
   <!--RULE -->
   <xsl:template match="tei:p" priority="1000" mode="M15">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="tei:p"/>
      <!--REPORT -->
      <xsl:if test="(ancestor::tei:ab or ancestor::tei:p) and                        not( ancestor::tei:floatingText                           | parent::tei:exemplum                           | parent::tei:item                           | parent::tei:note                           | parent::tei:q                           | parent::tei:quote                           | parent::tei:remarks                           | parent::tei:said                           | parent::tei:sp                           | parent::tei:stage                           | parent::tei:cell                           | parent::tei:figure )">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(ancestor::tei:ab or ancestor::tei:p) and not( ancestor::tei:floatingText | parent::tei:exemplum | parent::tei:item | parent::tei:note | parent::tei:q | parent::tei:quote | parent::tei:remarks | parent::tei:said | parent::tei:sp | parent::tei:stage | parent::tei:cell | parent::tei:figure )">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
          Abstract model violation: Paragraphs may not occur inside other paragraphs or ab elements.
        </svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M15"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M15"/>
   <xsl:template match="@*|node()" priority="-2" mode="M15">
      <xsl:apply-templates select="*" mode="M15"/>
   </xsl:template>
   <!--PATTERN vicav_corpus-p-abstractModel-structure-p-in-l-constraint-rule-11-->
   <!--RULE -->
   <xsl:template match="tei:l//tei:p" priority="1000" mode="M16">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="tei:l//tei:p"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="ancestor::tei:floatingText | parent::tei:figure | parent::tei:note"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="ancestor::tei:floatingText | parent::tei:figure | parent::tei:note">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
          Abstract model violation: Metrical lines may not contain higher-level structural elements such as div, p, or ab, unless p is a child of figure or note, or is a descendant of floatingText.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M16"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M16"/>
   <xsl:template match="@*|node()" priority="-2" mode="M16">
      <xsl:apply-templates select="*" mode="M16"/>
   </xsl:template>
   <!--PATTERN vicav_corpus-desc-deprecationInfo-only-in-deprecated-constraint-rule-12-->
   <!--RULE -->
   <xsl:template match="tei:desc[ @type eq 'deprecationInfo']" priority="1000" mode="M17">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="tei:desc[ @type eq 'deprecationInfo']"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="../@validUntil"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="../@validUntil">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Information about a
        deprecation should only be present in a specification element
        that is being deprecated: that is, only an element that has a
        @validUntil attribute should have a child &lt;desc
        type="deprecationInfo"&gt;.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M17"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M17"/>
   <xsl:template match="@*|node()" priority="-2" mode="M17">
      <xsl:apply-templates select="*" mode="M17"/>
   </xsl:template>
   <!--PATTERN vicav_corpus-ref-refAtts-constraint-rule-13-->
   <!--RULE -->
   <xsl:template match="tei:ref" priority="1000" mode="M18">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="tei:ref"/>
      <!--REPORT -->
      <xsl:if test="@target and @cRef">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@target and @cRef">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Only one of the attributes @target and @cRef may be supplied on <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/>.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M18"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M18"/>
   <xsl:template match="@*|node()" priority="-2" mode="M18">
      <xsl:apply-templates select="*" mode="M18"/>
   </xsl:template>
   <!--PATTERN vicav_corpus-resp-uniqueRespValues-constraint-rule-14-->
   <!--RULE -->
   <xsl:template match="tei:respStmt" priority="1000" mode="M19">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="tei:respStmt"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(tei:resp[. != 'recording' and . != 'transcription check' and . != 'contributor' and . = preceding::tei:resp])"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(tei:resp[. != 'recording' and . != 'transcription check' and . != 'contributor' and . = preceding::tei:resp])">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Each value inside 'respStmt' must be unique, except for 'recording', 'transcription check' and 'contributor'</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M19"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M19"/>
   <xsl:template match="@*|node()" priority="-2" mode="M19">
      <xsl:apply-templates select="*" mode="M19"/>
   </xsl:template>
   <!--PATTERN vicav_corpus-fileDesc-rec-person-twice-constraint-rule-15-->
   <!--RULE -->
   <xsl:template match="tei:respStmt" priority="1000" mode="M20">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="tei:respStmt"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="count(//tei:resp[text() = 'recording']) = 2"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(//tei:resp[text() = 'recording']) = 2">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>The role 'recording' should appear exactly twice across all respStmt elements</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M20"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M20"/>
   <xsl:template match="@*|node()" priority="-2" mode="M20">
      <xsl:apply-templates select="*" mode="M20"/>
   </xsl:template>
   <!--PATTERN vicav_corpus-funder-funderIdnoType-constraint-rule-16-->
   <!--RULE -->
   <xsl:template match="tei:funder/tei:idno" priority="1000" mode="M21">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="tei:funder/tei:idno"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="@type='projectNumber'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@type='projectNumber'">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Only the type "projectNumber" is permitted for idno inside funder</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M21"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M21"/>
   <xsl:template match="@*|node()" priority="-2" mode="M21">
      <xsl:apply-templates select="*" mode="M21"/>
   </xsl:template>
   <!--PATTERN vicav_corpus-publicationStmt-publStmtIdnoType-constraint-rule-17-->
   <!--RULE -->
   <xsl:template match="tei:publicationStmt/tei:idno" priority="1000" mode="M22">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="tei:publicationStmt/tei:idno"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="@type='SHAWICorpusID'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@type='SHAWICorpusID'">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Only the type "SHAWICorpusID" is permitted for idno inside publicationStmt</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M22"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M22"/>
   <xsl:template match="@*|node()" priority="-2" mode="M22">
      <xsl:apply-templates select="*" mode="M22"/>
   </xsl:template>
   <!--PATTERN vicav_corpus-div-abstractModel-structure-div-in-l-constraint-rule-18-->
   <!--RULE -->
   <xsl:template match="tei:l//tei:div" priority="1000" mode="M23">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="tei:l//tei:div"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="ancestor::tei:floatingText"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="ancestor::tei:floatingText">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
          Abstract model violation: Metrical lines may not contain higher-level structural elements such as div, unless div is a descendant of floatingText.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M23"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M23"/>
   <xsl:template match="@*|node()" priority="-2" mode="M23">
      <xsl:apply-templates select="*" mode="M23"/>
   </xsl:template>
   <!--PATTERN vicav_corpus-div-abstractModel-structure-div-in-ab-or-p-constraint-rule-19-->
   <!--RULE -->
   <xsl:template match="tei:div" priority="1000" mode="M24">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="tei:div"/>
      <!--REPORT -->
      <xsl:if test="(ancestor::tei:p or ancestor::tei:ab) and not(ancestor::tei:floatingText)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(ancestor::tei:p or ancestor::tei:ab) and not(ancestor::tei:floatingText)">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
          Abstract model violation: p and ab may not contain higher-level structural elements such as div, unless div is a descendant of floatingText.
        </svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M24"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M24"/>
   <xsl:template match="@*|node()" priority="-2" mode="M24">
      <xsl:apply-templates select="*" mode="M24"/>
   </xsl:template>
   <!--PATTERN vicav_corpus-w-msd-spec-constraint-rule-20-->
   <!--RULE -->
   <xsl:template match="tei:w[@msd]" priority="1000" mode="M25">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="tei:w[@msd]"/>
      <xsl:variable name="fLibFile" select="'../../010_manannot/fLib.xml'"/>
      <xsl:variable name="msd_values" select="doc($fLibFile)//tei:fvLib[@n='Morpho-syntactic annotations']/tei:fs/@xml:id"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="@msd = $msd_values"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@msd = $msd_values">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>MSD: '<xsl:text/>
                  <xsl:value-of select="@msd"/>
                  <xsl:text/>' is not in list of msd values (<xsl:text/>
                  <xsl:value-of select="$msd_values"/>
                  <xsl:text/>)</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M25"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M25"/>
   <xsl:template match="@*|node()" priority="-2" mode="M25">
      <xsl:apply-templates select="*" mode="M25"/>
   </xsl:template>
   <!--PATTERN vicav_corpus-w-lemmaRef-spec-constraint-rule-21-->
   <!--RULE -->
   <xsl:template match="tei:w[@xml:lang='ar-acm-x-shawi-vicav']" priority="1000" mode="M26">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="tei:w[@xml:lang='ar-acm-x-shawi-vicav']"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="@lemmaRef"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@lemmaRef">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>@lemmaRef is required when xml:lang is 'ar-acm-x-shawi-vicav'</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:variable name="dict" select="'../../vicav_dicts/dc_shawi_eng_2025_05_14T12_08_57.xml'"/>
      <xsl:variable name="entryIDs" select="doc($dict)//tei:entry/@xml:id"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(@lemmaRef) or substring-after(@lemmaRef, 'dict:') = $entryIDs"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(@lemmaRef) or substring-after(@lemmaRef, 'dict:') = $entryIDs">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>There is no entry in the dictionary for the current w element: '<xsl:text/>
                  <xsl:value-of select="@lemmaRef"/>
                  <xsl:text/>'</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M26"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M26"/>
   <xsl:template match="@*|node()" priority="-2" mode="M26">
      <xsl:apply-templates select="*" mode="M26"/>
   </xsl:template>
   <!--PATTERN vicav_corpus-span-span-target-check-constraint-rule-22-->
   <!--RULE -->
   <xsl:template match="tei:span" priority="1000" mode="M27">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="tei:span"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="parent::tei:spanGrp/parent::tei:annotationBlock/@xml:id = substring-after(@target, '#')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="parent::tei:spanGrp/parent::tei:annotationBlock/@xml:id = substring-after(@target, '#')">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>target of span should point at xml:id of parent annotationBlock element</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M27"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M27"/>
   <xsl:template match="@*|node()" priority="-2" mode="M27">
      <xsl:apply-templates select="*" mode="M27"/>
   </xsl:template>
   <!--PATTERN vicav_corpus-span-target-from-constraint-rule-23-->
   <!--RULE -->
   <xsl:template match="tei:span" priority="1000" mode="M28">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="tei:span"/>
      <!--REPORT -->
      <xsl:if test="@from and @target">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@from and @target">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
          Only one of the attributes @target and @from may be supplied on <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M28"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M28"/>
   <xsl:template match="@*|node()" priority="-2" mode="M28">
      <xsl:apply-templates select="*" mode="M28"/>
   </xsl:template>
   <!--PATTERN vicav_corpus-span-targetto-constraint-rule-24-->
   <!--RULE -->
   <xsl:template match="tei:span" priority="1000" mode="M29">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="tei:span"/>
      <!--REPORT -->
      <xsl:if test="@to and @target">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@to and @target">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
          Only one of the attributes @target and @to may be supplied on <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M29"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M29"/>
   <xsl:template match="@*|node()" priority="-2" mode="M29">
      <xsl:apply-templates select="*" mode="M29"/>
   </xsl:template>
   <!--PATTERN vicav_corpus-span-tonotfrom-constraint-rule-25-->
   <!--RULE -->
   <xsl:template match="tei:span" priority="1000" mode="M30">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="tei:span"/>
      <!--REPORT -->
      <xsl:if test="@to and not(@from)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@to and not(@from)">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
          If @to is supplied on <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/>, @from must be supplied as well
        </svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M30"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M30"/>
   <xsl:template match="@*|node()" priority="-2" mode="M30">
      <xsl:apply-templates select="*" mode="M30"/>
   </xsl:template>
   <!--PATTERN vicav_corpus-span-tofrom-constraint-rule-26-->
   <!--RULE -->
   <xsl:template match="tei:span" priority="1000" mode="M31">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="tei:span"/>
      <!--REPORT -->
      <xsl:if test="contains(normalize-space(@to),' ') or contains(normalize-space(@from),' ')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="contains(normalize-space(@to),' ') or contains(normalize-space(@from),' ')">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
          The attributes @to and @from on <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> may each contain only a single value
        </svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M31"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M31"/>
   <xsl:template match="@*|node()" priority="-2" mode="M31">
      <xsl:apply-templates select="*" mode="M31"/>
   </xsl:template>
   <!--PATTERN vicav_corpus-shift-shiftNew-constraint-rule-27-->
   <!--RULE -->
   <xsl:template match="tei:shift" priority="1000" mode="M32">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="tei:shift"/>
      <!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="@new"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@new">
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>              
          The @new attribute should always be supplied; use the special value
          "normal" to indicate that the feature concerned ceases to be
          remarkable at this point.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M32"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M32"/>
   <xsl:template match="@*|node()" priority="-2" mode="M32">
      <xsl:apply-templates select="*" mode="M32"/>
   </xsl:template>
</xsl:stylesheet>