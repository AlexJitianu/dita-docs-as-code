<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2"
    xmlns:sqf="http://www.schematron-quickfix.com/validator/process">
    
    <sch:pattern>
        <sch:rule context="*[contains(@class, ' topic/topic ')]">
            <sch:assert test="shortdesc" sqf:fix="add">A shortdesc is mandatory.</sch:assert>
            <sqf:fix id="add">
                <sqf:description>
                    <sqf:title>Add shortdesc</sqf:title>
                </sqf:description>
                <sqf:add match="/*/title" position="after">
                        <shortdesc/>
                </sqf:add>
            </sqf:fix>
        </sch:rule>
    </sch:pattern>
    
</sch:schema>