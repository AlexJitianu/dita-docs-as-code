<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    xmlns:r="http://www.oxygenxml.com/ns/report"
    xmlns:f="ns:functions"
    version="3.0">
    
    <xsl:output omit-xml-declaration="true"/>
    
    <xsl:variable name="severity" as="map(xs:string, xs:string)">
        <xsl:map>
            <xsl:map-entry key="'FATAL'" select="'BLOCKER'"/>
            <xsl:map-entry key="'ERROR'" select="'CRITICAL'"/>
            <xsl:map-entry key="'WARN'" select="'MINOR'"/>
            <xsl:map-entry key="'WARNING'" select="'MINOR'"/>
            <xsl:map-entry key="'CAUTION'" select="'MINOR'"/>
            <xsl:map-entry key="'INFO'" select="'MINOR'"/>
            <xsl:map-entry key="'HINT'" select="'MINOR'"/>
            <xsl:map-entry key="'TRACE'" select="'MINOR'"/>
            <xsl:map-entry key="'DEBUG'" select="'MINOR'"/>
        </xsl:map>
    </xsl:variable>
    

    <xsl:template match="r:report" >
        {
        "issues": [
          <xsl:apply-templates/>
        ]
        }
    </xsl:template> 
    <xsl:template match="r:incident">
        <xsl:if test="preceding-sibling::r:incident">,</xsl:if>
        <xsl:variable name="sev" select="upper-case(r:severity/text())"/>
        <xsl:message select="$sev"></xsl:message>
        {
            "engineId": "VCC",
            "type": "CODE_SMELL",
            "effortMinutes": 5,
            "severity": "<xsl:value-of select="$severity($sev)"/>",
            "ruleId": "<xsl:value-of select="r:type/text()"/>",
            "primaryLocation": {
                "message": "<xsl:value-of select="replace(replace(replace(r:description/text(), '\\', '/'), '\n', '\\n'), '&quot;', '\\&quot;')"/>",
                "filePath": "<xsl:value-of select="replace(r:systemID/text(), '\\', '/')"/>",
                "textRange": {
                    "startLine": <xsl:value-of select="r:location/r:start/r:line/text()"/>,
                    "startColumn": <xsl:value-of select="xs:integer(r:location/r:start/r:column/text()) - 1"/>,
                    "endLine": <xsl:value-of select="r:location/r:end/r:line/text()"/>,
                    "endColumn": <xsl:value-of select="xs:integer(r:location/r:end/r:column/text()) - 1"/>
                }
            }
        }
    </xsl:template>
    
    <xsl:function name="f:getSeverity">
        
    </xsl:function>
</xsl:stylesheet>