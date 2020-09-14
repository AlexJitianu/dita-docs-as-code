<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2"
    xmlns:sqf="http://www.schematron-quickfix.com/validator/process">

    <!-- Mandatory header. -->
    <sch:pattern>
        <sch:rule context="body">
            <sch:assert test="*[1][self::hr]">The copyright and lastupdated information must occur
                at the top of the MD file, before attributes are listed. It must be --- surrounded
                by 3 dashes ---</sch:assert>
        </sch:rule>

        <sch:rule context="body/*[1][self::hr]">
            <sch:assert test="following-sibling::hr">The copyright and lastupdated information must
                occur at the top of the MD file, before attributes are listed. It must be ---
                surrounded by 3 dashes ---. The matching --- is missing.</sch:assert>

            <sch:assert
                test="following-sibling::p[normalize-space(string-join(text())) = 'copyright:']">The
                copyright section is missing. Add "copyright:" after the starting ---</sch:assert>

            <sch:assert
                test="following-sibling::p[starts-with(normalize-space(string-join(text())), 'years:')]"
                >Add "years:" after the starting "copyright:" line.</sch:assert>
        </sch:rule>

        <sch:rule context="body/p[starts-with(normalize-space(string-join(text())), 'years:')]">
            <sch:let name="years" value="tokenize(normalize-space(substring-after(text(), 'years:')), ',')"/>
            <sch:assert test="count($years) > 0">No year value was specified.</sch:assert>

            <sch:assert test="count($years) &lt;= 2">Too many years specified. The value years can contain just one year or two
                years separated by a comma, for example, years: 2016, 2017. If the topic was created
                in the current year, provide just one year for the years variable. If you have
                updated the topic over a span of more than the current year, provide the first year
                and the last (current) year, separated by a comma. Don't include the intervening
                years. For example, for a topic created in 2016 and updated until 2017, then list
                the years: 2016, 2017</sch:assert>
            
            <!-- Years with bad format. -->
            <sch:let name="badFormats" value="for $i in $years return if ($i castable as xs:gYear) then () else ($i)"/>
            <sch:assert test="empty($badFormats)">
                Not a year format: <sch:value-of select="$badFormats"/>
            </sch:assert>

        </sch:rule>
    </sch:pattern>
    
</sch:schema>
