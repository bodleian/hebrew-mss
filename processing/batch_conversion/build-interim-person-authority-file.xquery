declare namespace tei="http://www.tei-c.org/ns/1.0";
declare option saxon:output "indent=yes";


declare function local:logging($level, $msg, $values)
{
    (: Trick XQuery into doing trace() to output message to STDERR but not insert it into the XML :)
    substring(trace('', concat(upper-case($level), '	', $msg, '	', string-join($values, '	'), '	')), 0, 0)
};

<TEI xmlns="http://www.tei-c.org/ns/1.0">
    <teiHeader>
        <fileDesc>
            <titleStmt>
                <title>Title</title>
            </titleStmt>
            <publicationStmt>
                <p>Publication Information</p>
            </publicationStmt>
            <sourceDesc>
                <p>Information about the source</p>
            </sourceDesc>
        </fileDesc>
    </teiHeader>
    <text>
        <body>
            <listPerson>
{

    let $skipids := ()
    
    (: First build an in-memory nodeset temporarily storing titles, IDs and the files they come from. :)
    let $hebrewpeople := (
        for $x in collection('../../collections/?select=*.xml;recurse=yes')//tei:persName[not(ancestor::tei:revisionDesc or ancestor::tei:respStmt)]
            return
            if ($x eq $skipids) then
                ( (: This @key is in one of the manually-maintained authority files, so don't include it in the generated list :) )
            else
                <person>
                    <name>{ normalize-space(string-join($x//text(), ' ')) }</name>
                    <file>{ base-uri($x) }</file>
                    <ref>/catalog/{ $x/ancestor::tei:TEI/@xml:id/data() }|{ ($x/ancestor::tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msIdentifier/tei:idno)[1]/text() }</ref>
                </person>
    )
    
    (: NOTE: In the Hebrew catalogue, persName when used inside author marks up a translated variant of the same name. :)
    let $hebrewauthors := (
        for $x in collection('../../collections/?select=*.xml;recurse=yes')//tei:author
            return
            if ($x eq $skipids) then
                ( (: This @key is in one of the manually-maintained authority files, so don't include it in the generated list :) )
            else
                <person>
                    <name>{ normalize-space(string-join($x//text()[not(ancestor::persName)], ' ')) }</name>
                    <file>{ base-uri($x) }</file>
                    <ref>/catalog/{ $x/ancestor::tei:TEI/@xml:id/data() }|{ ($x/ancestor::tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msIdentifier/tei:idno)[1]/text() }</ref>
                </person>
    )
    
    let $genizahpeople := (
        for $x in collection('../../../genizah-mss/collections/?select=*.xml;recurse=yes')//tei:persName[not(ancestor::tei:revisionDesc or ancestor::tei:respStmt)]
            return
            if ($x eq $skipids) then
                ( (: This @key is in one of the manually-maintained authority files, so don't include it in the generated list :) )
            else
                <person>
                    <name>{ normalize-space(string-join($x//text(), ' ')) }</name>
                    <file>{ base-uri($x) }</file>
                    <ref>/catalog/{ $x/ancestor::tei:TEI/@xml:id/data() }|{ ($x/ancestor::tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msIdentifier/tei:idno)[1]/text() }</ref>
                </person>
    )
    
    let $allpeople := ($hebrewpeople, $hebrewauthors, $genizahpeople)
    (: NOTE: No author TEI elements used in Genizah :)

    let $dedupedpeople := (
        for $t at $pos in distinct-values($allpeople/name/text())
            order by $t
            return
            <person xml:id="{ concat('person_', $pos) }">
                <persName type="display">{ $t }</persName>
                {
                for $s in distinct-values($allpeople[name = $t]/ref/text())
                    order by $s
                    return
                    <ref>{ $s }</ref>
                }
            </person>
    
    )
    
    return $dedupedpeople       

}
            </listPerson>
        </body>
    </text>
</TEI>




        
