<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2"
    xmlns:sqf="http://www.schematron-quickfix.com/validator/process"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:template match="node() | @*" mode="copyExceptPrefix">
        <xsl:copy copy-namespaces="no">
            <xsl:apply-templates select="node() | @* except @class" mode="copy"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="node() | @*" mode="copy">
        <xsl:copy copy-namespaces="no">
            <xsl:apply-templates select="node() | @* except @class" mode="copy"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="node()[position()=1][self::text()]" mode="copyExceptPrefix">
        <xsl:param name="prefix" select="''"/>
        <xsl:value-of select="substring-after(., $prefix)"/>
    </xsl:template>

    <xsl:template match="node() | @*" mode="fixLinks">
        <xsl:copy copy-namespaces="no">
            <xsl:apply-templates select="node() | @* except @class" mode="fixLinks"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="node()[self::text()]" mode="fixLinks">
        <xsl:analyze-string select="." regex="\[.*\]\(.*\)" flags="s">
            <xsl:matching-substring>
                <xsl:element name="xref">
                    <xsl:attribute name="format">html</xsl:attribute>
                    <xsl:attribute name="scope">external</xsl:attribute>
                    <xsl:attribute name="href" select="substring-before(substring-after(., '('), ')')"/>
                    <xsl:value-of select="substring-before(substring-after(., '['), ']')"/>
                </xsl:element>
            </xsl:matching-substring>
            <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
    <xsl:template match="node() | @*" mode="fixImages">
        <xsl:copy copy-namespaces="no">
            <xsl:apply-templates select="node() | @* except @class" mode="fixImages"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="node()[self::text()]" mode="fixImages">
        <xsl:analyze-string select="." regex="!\[.*\]\(.*\)" flags="s">
            <xsl:matching-substring>
                <xsl:variable name="q">"</xsl:variable>
                <xsl:variable name="ref" select="substring-before(substring-after(., '('), ')')"/>
                <xsl:variable name="href" select="if (contains($ref, $q)) then substring-before($ref, $q) else $ref"/>
                <xsl:variable name="title" select="if (contains($ref, $q)) then substring-before(substring-after($ref, $q), $q) else ''"/>
                <xsl:variable name="image">
                    <xsl:element name="image">
                        <xsl:attribute name="href" select="normalize-space($href)"/>
                        <xsl:element name="alt">
                            <xsl:value-of select="substring-before(substring-after(., '['), ']')"/>
                        </xsl:element>
                    </xsl:element>
                </xsl:variable>
                <xsl:choose>
                    <xsl:when test="$title!=''">
                        <xsl:element name="fig">
                            <xsl:element name="title"><xsl:value-of select="$title"/></xsl:element>
                            <xsl:copy-of select="$image"/>
                        </xsl:element>
                    </xsl:when>
                    <xsl:otherwise><xsl:copy-of select="$image"/></xsl:otherwise>
                </xsl:choose>
            </xsl:matching-substring>
            <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
    <xsl:template match="node() | @*" mode="fixQuickLinks">
        <xsl:copy copy-namespaces="no">
            <xsl:apply-templates select="node() | @* except @class" mode="fixQuickLinks"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="node()[self::text()]" mode="fixQuickLinks">
        <xsl:analyze-string select="." regex="&lt;http(s?)://.*>">
            <xsl:matching-substring>
                <xsl:element name="xref">
                    <xsl:attribute name="format">html</xsl:attribute>
                    <xsl:attribute name="scope">external</xsl:attribute>
                    <xsl:attribute name="href" select="substring-before(substring-after(., '&lt;'), '>')"/>
                </xsl:element>
            </xsl:matching-substring>
            <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
    <xsl:template match="node() | @*" mode="fixInlineCode">
        <xsl:copy copy-namespaces="no">
            <xsl:apply-templates select="node() | @* except @class" mode="fixInlineCode"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="node()[self::text()]" mode="fixInlineCode">
        <xsl:analyze-string select="." regex="`..*`" flags="s">
            <xsl:matching-substring>
                <xsl:element name="codeph">
                    <xsl:value-of select="substring-before(substring-after(., '`'), '`')"/>
                </xsl:element>
            </xsl:matching-substring>
            <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>


    <xsl:template match="p" mode="tableHead">
        <thead>
            <row>
               <xsl:analyze-string select="." regex="\|" flags="s">
                    <xsl:matching-substring/>
                    <xsl:non-matching-substring>
                        <entry><xsl:value-of select="."/></entry>
                    </xsl:non-matching-substring>
                </xsl:analyze-string>                 
            </row>
        </thead>
    </xsl:template>
    
    <xsl:template match="p" mode="tableRow">
        <row>
           <xsl:analyze-string select="." regex="\|" flags="s">
                <xsl:matching-substring/>
                <xsl:non-matching-substring>
                    <entry><xsl:value-of select="."/></entry>
                </xsl:non-matching-substring>
            </xsl:analyze-string>                 
        </row>
        <xsl:apply-templates select="following-sibling::*[1][self::p][starts-with(., '|')]" mode="tableRow"/>
    </xsl:template>
    
    <xsl:template match="p" mode="createTable">
        <xsl:variable name="cols" select="string-length(.) - string-length(translate(., '|', '')) - 1"/>
        <table>
            <tgroup cols="{$cols}">
                <xsl:analyze-string select="." regex="\|" flags="s">
                    <xsl:matching-substring>
                        <xsl:if test="position()!=last()">
                            <colspec colname="col{(position()+1) div 2}"/>
                        </xsl:if>
                    </xsl:matching-substring>
                    <xsl:non-matching-substring/>
                </xsl:analyze-string>
                <xsl:apply-templates select="preceding-sibling::*[1][self::p][starts-with(., '|')]"
                    mode="tableHead"/>
                <tbody>
                    <xsl:apply-templates select="following-sibling::*[1][self::p][starts-with(., '|')]" mode="tableRow"/>
                </tbody>
            </tgroup>
        </table>
    </xsl:template>

    <sch:pattern id="lists-codeblocks-quotes">
        <sch:rule context="p">
            <sch:let name="this" value="."/>
            <sch:let name="text" value="node()[1][self::text()]/normalize-space()"/>
            <sch:let name="prefix" value="substring($text, 1, 2)"/>
            
            <!-- Convert Markdown list items to DITA unordered list items -->
            <sch:report test="(starts-with($text, '* ') or starts-with($text, '- '))
                and not(preceding-sibling::*[1][self::p[starts-with(., $prefix)]])" role="info" 
                sqf:fix="createListFromParagraph addItemToList">
                List items should be marked with a list item (li) element and added to a list (ul) element.
            </sch:report>
            <sqf:fix id="createListFromParagraph" use-when="not(preceding-sibling::*[1][self::ul])">
                <sqf:description>
                    <sqf:title>Create a list</sqf:title>
                </sqf:description>
                <sqf:add position="after">
                    <ul>
                        <xsl:for-each-group select="$this|following-sibling::*" group-adjacent="self::p and starts-with(., $prefix)">
                            <xsl:if test="current-group()=$this">
                                <xsl:for-each select="current-group()">
                                    <li>
                                        <xsl:apply-templates mode="copyExceptPrefix">
                                            <xsl:with-param name="prefix" select="$prefix"/>
                                        </xsl:apply-templates>
                                    </li>
                                </xsl:for-each>
                            </xsl:if>
                        </xsl:for-each-group>
                    </ul>
                </sqf:add>
                <sqf:delete match="following-sibling::p[starts-with(., $prefix)][
                    preceding-sibling::*[not(starts-with(., $prefix))][1]/following-sibling::*=$this
                    or not(preceding-sibling::*[not(starts-with(., $prefix))][1])
                    ]"/>
                <sqf:delete/>
            </sqf:fix>
            <sqf:fix id="addItemToList" use-when="preceding-sibling::*[1][self::ul]">
                <sqf:description>
                    <sqf:title>Add this as an item to the preceding list</sqf:title>
                </sqf:description>
                
                <sqf:add match="preceding-sibling::*[1][self::ul]" position="last-child">
                    <li>
                    <xsl:apply-templates mode="copyExceptPrefix" select="following-sibling::*[1]/node()">
                        <xsl:with-param name="prefix" select="$prefix"/>
                    </xsl:apply-templates>
                    </li>
                </sqf:add>
                <sqf:delete/>
            </sqf:fix>
            
            <!-- Convert a Markdown numbered list item to a DITA ordered list with one item -->
            <sch:report test="matches($text, '^\d(\d)*\.') and not(preceding-sibling::*[1][self::p[matches(., '^\d(\d)*\.')]])" role="info" sqf:fix="createOrderedListFromParagraph">
                Ordered list items should be marked with a list item (li) element and added to an ordered list (ol) element.
            </sch:report>
            <sqf:fix id="createOrderedListFromParagraph">
                <sqf:description>
                    <sqf:title>Create an ordered list</sqf:title>
                </sqf:description>
                <sqf:add position="after">
                    <ol>
                        <xsl:for-each select=". | following-sibling::p[matches(., '^\d(\d)*\.')][
                                preceding-sibling::*[not(matches(., '^\d(\d)*\.'))][1]/following-sibling::*=$this
                                or not(preceding-sibling::*[not(matches(., '^\d(\d)*\.'))])
                                ]">
                            <li>
                                <xsl:apply-templates mode="copyExceptPrefix">
                                    <xsl:with-param name="prefix" select="concat(substring-before(., '.'), '.')"/>
                                </xsl:apply-templates>
                            </li>
                        </xsl:for-each>
                    </ol>
                </sqf:add>
                <sqf:delete match="following-sibling::p[matches(., '^\d(\d)*\.')][
                    preceding-sibling::*[not(matches(., '^\d(\d)*\.'))][1]/following-sibling::*=$this
                    or not(preceding-sibling::*[not(matches(., '^\d(\d)*\.'))])
                    ]"/>
                <sqf:delete/>
            </sqf:fix>
            
            <!-- Convert Markdown code to DITA codeblocks -->
            <sch:report test="starts-with($text, '```')" role="info" 
                sqf:fix="createCodeblockFromParagraph createCodeblockFromParagraphs">
                Code fragments should be placed within a "codeblock" element.
            </sch:report>
            <sqf:fix id="createCodeblockFromParagraph" use-when="not(following-sibling::p[.='```'])">
                <sqf:description>
                    <sqf:title>Create a code block from the current paragraph</sqf:title>
                </sqf:description>
                <sqf:add position="after">
                    <codeblock>
                        <xsl:apply-templates mode="copyExceptPrefix">
                            <xsl:with-param name="prefix" select="'```'"/>
                        </xsl:apply-templates>
                    </codeblock>
                </sqf:add>
                <sqf:delete/>
            </sqf:fix>
            <sqf:fix id="createCodeblockFromParagraphs" use-when="following-sibling::p[.='```']">
                <sqf:description>
                    <sqf:title>Create a code block from multiple paragraphs</sqf:title>
                </sqf:description>
                <sqf:add position="after">
                    <xsl:element name="codeblock">
                        <xsl:for-each select="following-sibling::p[.='```'][1]/preceding-sibling::p[$this &lt;&lt; .]">
                            <xsl:copy-of select="node()"/>
                            <xsl:if test="position()!=last()">
                                <xsl:text>&#10;</xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:element>
                </sqf:add>
                <sqf:delete match="following-sibling::p[.='```'][1]/(preceding-sibling::p[$this &lt;&lt; .], self::p)"/>
                <sqf:delete/>
            </sqf:fix>
            
            <!-- Convert Markdown quotes to DITA long quotes -->
            <sch:report test="starts-with($text, '> ') and not(preceding-sibling::*[1][self::p[starts-with(., '> ')]])" role="info" 
                sqf:fix="createQuoteFromParagraph">
                Quotes should be marked with a long quote (lq) element.
            </sch:report>
            <sqf:fix id="createQuoteFromParagraph">
                <sqf:description>
                    <sqf:title>Create a quote</sqf:title>
                </sqf:description>
                <sqf:add position="after">
                    <lq>
                        <xsl:for-each-group select="$this|following-sibling::*" group-adjacent="self::p and starts-with(., '>')">
                            <xsl:if test="current-group()=$this">
                                <xsl:for-each select="current-group()">
                                    <p>
                                        <xsl:apply-templates mode="copyExceptPrefix">
                                            <xsl:with-param name="prefix" select="$prefix"/>
                                        </xsl:apply-templates>
                                    </p>
                                </xsl:for-each>
                            </xsl:if>
                        </xsl:for-each-group>
                    </lq>
                </sqf:add>
                <sqf:delete match="following-sibling::p[starts-with(., '> ')][
                    preceding-sibling::*[not(starts-with(., '> '))][1]/following-sibling::*=$this
                    or not(preceding-sibling::*[not(starts-with(., '> '))][1])
                    ]"/>
                <sqf:delete/>
            </sqf:fix>
        </sch:rule>
    </sch:pattern>

    <sch:pattern id="links-images">
        <sch:rule context="p[matches(., '!\[.*\]\(.*\)', 's')]|li[not(descendant-or-self::p)][matches(., '!\[.*\]\(.*\)', 's')]">
            <!-- Convert Markdown images to DITA image or figure -->
            <sch:report test="true()" role="info" sqf:fix="convertMarkdownImages2DITA">
                Paragraph contains image references in Markdown format! These should be converted to 
                DITA image or, in case we have a title, a DITA figure.
            </sch:report>
            <sqf:fix id="convertMarkdownImages2DITA">
                <sqf:description>
                    <sqf:title>Create images references</sqf:title>
                </sqf:description>
                <sqf:add position="after">
                    <xsl:apply-templates mode="fixImages" select="."/>
                </sqf:add>
                <sqf:delete/>
            </sqf:fix>
        </sch:rule>
        
        <sch:rule context="p|li[not(descendant-or-self::p)]">
            <!-- Convert Markdown links to DITA cross referernces -->
            <sch:report test="matches(., '\[.*\]\(.*\)', 's')" role="info" sqf:fix="convertMarkdownLinks2XReferences">
                Paragraph contains links in Markdown format! These should be converted to 
                DITA cross references.
            </sch:report>
            <sqf:fix id="convertMarkdownLinks2XReferences">
                <sqf:description>
                    <sqf:title>Transform Markdown links to DITA cross references</sqf:title>
                </sqf:description>
                <sqf:add position="after">
                    <xsl:apply-templates mode="fixLinks" select="."/>
                </sqf:add>
                <sqf:delete/>
            </sqf:fix>            
        </sch:rule>
    </sch:pattern>
    
    <sch:pattern id="quickLinks">
        <sch:rule context="p|li[not(descendant-or-self::p)]">
            <!-- Convert Markdown quick links to DITA cross referernces -->
            <sch:report test="matches(., '&lt;http(s?)://.*>')" role="info" sqf:fix="convertMarkdownQuickLinks2XReferences">
                Paragraph contains links in Markdown format! These should be converted to 
                DITA cross references.
            </sch:report>
            <sqf:fix id="convertMarkdownQuickLinks2XReferences">
                <sqf:description>
                    <sqf:title>Transform Markdown quick links to DITA cross references</sqf:title>
                </sqf:description>
                <sqf:add position="after">
                    <xsl:apply-templates mode="fixQuickLinks" select="."/>
                </sqf:add>
                <sqf:delete/>
            </sqf:fix>
        </sch:rule>
    </sch:pattern>
    
    <sch:pattern id="codephrase">
        <sch:rule context="p|li[not(descendant-or-self::p)]">
            <!-- Convert inline code to codeph -->
            <sch:report test="matches(., '`.[^`].*`', 's')" role="info" sqf:fix="convertMarkdowncode2Codeph">
                Paragraph contains inline code fragments! These should be converted to 
                DITA code phase (codeph) elements.
            </sch:report>
            <sqf:fix id="convertMarkdowncode2Codeph">
                <sqf:description>
                    <sqf:title>Transform Markdown inline code to DITA code phrases</sqf:title>
                </sqf:description>
                <sqf:add position="after">
                    <xsl:apply-templates mode="fixInlineCode" select="."/>
                </sqf:add>
                <sqf:delete/>
            </sqf:fix>
        </sch:rule>
    </sch:pattern>

    <sch:pattern id="topics">
        <sch:rule context="body[not(preceding-sibling::title)]/*[1][self::p]">
            <sch:let name="this" value="."/>
            <sch:let name="text" value="node()[1][self::text()]/normalize-space()"/>
            <sch:let name="prefix" value="substring($text, 1, 2)"/>
            <sch:report test="starts-with(., '# ')" role="info" sqf:fix="createTitle">
                Topic titles should be marked with a title element.
            </sch:report>
            <sqf:fix id="createTitle">
                <sqf:description>
                    <sqf:title>Transform into title</sqf:title>
                </sqf:description>
                <sqf:add match="parent::body/parent::*" position="first-child">
                    <title>
                        <xsl:apply-templates mode="copyExceptPrefix" select="$this/node()">
                            <xsl:with-param name="prefix" select="$prefix"/>
                        </xsl:apply-templates>
                    </title>
                </sqf:add>
                <sqf:delete/>
            </sqf:fix>
        </sch:rule>
        
        <sch:rule context="body/p[last()]">
            <sch:let name="this" value="."/>
            <sch:let name="text" value="node()[1][self::text()]/normalize-space()"/>
            <sch:let name="prefix" value="substring($text, 1, 2)"/>
            <!-- Convert to topics -->
            <sch:report test="starts-with($text, '# ')" 
                role="info" sqf:fix="createSiblingTopic createInnerTopic">
                Topic titles should be marked with a title element and placed within a topic.
            </sch:report>
            
            <sqf:fix id="createInnerTopic">
                <sqf:description>
                    <sqf:title>Create inner topic with this title</sqf:title>
                </sqf:description>
                <sch:let name="topic" value="local-name(/*)"/>
                <sqf:add match="parent::body" position="after">
                    <xsl:element name="{$topic}">
                        <xsl:attribute name="id" select="concat('topic_', 
                            translate(string(current-dateTime()),translate(string(current-dateTime()),'012345679', ''),'')
                            )"/>
                        <title>
                            <xsl:apply-templates select="p[last()]/node()" mode="copyExceptPrefix">
                                <xsl:with-param name="prefix" select="$prefix"/>
                            </xsl:apply-templates>
                        </title>
                        <body><p></p></body>
                    </xsl:element>
                </sqf:add>
                <sqf:delete/>
            </sqf:fix>
            
            <sqf:fix id="createSiblingTopic" use-when="ancestor::topic[parent::topic]">
                <sqf:description>
                    <sqf:title>Create sibling topic with this title</sqf:title>
                </sqf:description>
                <sch:let name="topic" value="local-name(/*)"/>
                <sqf:add match="ancestor::topic[1]" position="after">
                    <xsl:element name="{$topic}">
                        <xsl:attribute name="id" select="concat('topic_', 
                            translate(string(current-dateTime()),translate(string(current-dateTime()),'012345679', ''),'')
                            )"/>
                        <title>
                            <xsl:apply-templates select="body/p[last()]/node()" mode="copyExceptPrefix">
                                <xsl:with-param name="prefix" select="$prefix"/>
                            </xsl:apply-templates>
                        </title>
                        <body><p></p></body>
                    </xsl:element>
                </sqf:add>
                <sqf:delete/>
            </sqf:fix>
        </sch:rule>
    </sch:pattern>
    
    <sch:pattern id="sections">
        <sch:rule context="body/p">
            <sch:let name="this" value="."/>
            <sch:let name="text" value="node()[1][self::text()]/normalize-space()"/>
            <sch:let name="prefix" value="substring($text, 1, 3)"/>
            <!-- Convert to section -->
            <sch:report test="starts-with($text, '## ')" 
                role="info" sqf:fix="createSection">
                Section titles should be marked with a title element and placed within a section.
            </sch:report>
            
            <sqf:fix id="createSection">
                <sqf:description>
                    <sqf:title>Create a new section with this title</sqf:title>
                </sqf:description>
                
                <sqf:add position="after">
                    <section>
                        <title>
                            <xsl:apply-templates mode="copyExceptPrefix">
                                <xsl:with-param name="prefix" select="$prefix"/>
                            </xsl:apply-templates>
                        </title>
                        <p></p>
                    </section>
                </sqf:add>
                <sqf:delete/>
            </sqf:fix>
        </sch:rule>
        
        <sch:rule context="section/*[last()][self::p]">
            <sch:let name="this" value="."/>
            <sch:let name="text" value="node()[1][self::text()]/normalize-space()"/>
            <sch:let name="prefix" value="substring($text, 1, 3)"/>
            <!-- Create section after -->
            <sch:report test="starts-with(., '## ')" 
                role="info" sqf:fix="createSectionAfter">
                Section titles should be marked with a title element and placed within a section.
            </sch:report>
            
            <sqf:fix id="createSectionAfter">
                <sqf:description>
                    <sqf:title>Create a new section with this title after the current section</sqf:title>
                </sqf:description>
                
                <sqf:add match=".." position="after">
                    <section>
                        <title>
                            <xsl:apply-templates select="*[last()]/node()" mode="copyExceptPrefix">
                                <xsl:with-param name="prefix" select="$prefix"/>
                            </xsl:apply-templates>
                        </title>
                        <p></p>
                    </section>
                </sqf:add>
                <sqf:delete/>
            </sqf:fix>
        </sch:rule>
    </sch:pattern>

    <sch:pattern id="tables">
        <sch:rule context="p[starts-with(., '|-')]">
            <sch:let name="this" value="."/>
            <!-- Convert to table -->
            <sch:report test="matches(., '|\-(\-*)(|\-(\-*))*|', 's')" 
                role="info" sqf:fix="createTable createSimpleTable">
                Tables should be marked with a table element.
            </sch:report>
            
            <sqf:fix id="createTable" use-when="preceding-sibling::*[1][self::p][starts-with(., '|')]">
                <sqf:description>
                    <sqf:title>Create a table</sqf:title>
                </sqf:description>
                <sqf:add position="after">
                    <xsl:apply-templates select="." mode="createTable"/>
                </sqf:add>
                <sqf:delete match="following-sibling::p[starts-with(., '|')][
                    preceding-sibling::*[not(starts-with(., '|'))][1]/following-sibling::*=$this
                    or not(preceding-sibling::*[not(starts-with(., '|'))])
                    ]"/>
                <sqf:delete match="preceding-sibling::*[1][self::p][starts-with(., '|')]"/>
                <!-- this actually deletes the current p -->
                <sqf:delete match="preceding-sibling::p[1]"/>
            </sqf:fix>
            
            <sqf:fix id="createSimpleTable" use-when="not(preceding-sibling::*[1][self::p][starts-with(., '|')])">
                <sqf:description>
                    <sqf:title>Create a table</sqf:title>
                </sqf:description>
                <sqf:add position="after">
                    <xsl:apply-templates select="." mode="createTable"/>
                </sqf:add>
                <sqf:delete match="following-sibling::p[starts-with(., '|')][
                    preceding-sibling::*[not(starts-with(., '|'))][1]/following-sibling::*=$this
                    or not(preceding-sibling::*[not(starts-with(., '|'))])
                    ]"/>
                <sqf:delete/>
            </sqf:fix>
        </sch:rule>
    </sch:pattern>
</sch:schema>
