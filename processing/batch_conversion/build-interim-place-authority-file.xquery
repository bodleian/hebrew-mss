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
            <listPlace>
{

    (:
    TODO:
        Pick up on @role attributes, if any
        Batch convert the TEI to add @key to all persNames then use that here (blow away existing ones - there's only about a dozen, and they contain spaces)
    :)

    let $skipids := ()  (: TODO:)
    
    (: First build an in-memory nodeset temporarily storing titles, IDs and the files they come from. :)
    let $hebrewplaces := (
        for $x in collection('../../collections/?select=*.xml;recurse=yes')//tei:placeName
            return
            if ($x eq $skipids) then
                ( (: This @key is in one of the manually-maintained authority files, so don't include it in the generated list :) )
            else
                <place>
                    <name>{ normalize-space(string-join($x//text(), ' ')) }</name>
                    <file>{ base-uri($x) }</file>
                    <ref>/catalog/{ $x/ancestor::tei:TEI/@xml:id/data() }|{ ($x/ancestor::tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msIdentifier/tei:idno)[1]/text() }</ref>
                    <scheme>{ ($x/ancestor::keywords/@scheme/data(), 'bodl')[1] }</scheme>
                </place>
    )
   
    let $genizahplaces := (
        for $x in collection('../../../genizah-mss/collections/?select=*.xml;recurse=yes')//tei:placeName
            return
            if ($x eq $skipids) then
                ( (: This @key is in one of the manually-maintained authority files, so don't include it in the generated list :) )
            else
                <place>
                    <name>{ normalize-space(string-join($x//text(), ' ')) }</name>
                    <file>{ base-uri($x) }</file>
                    <ref>/catalog/{ $x/ancestor::tei:TEI/@xml:id/data() }|{ ($x/ancestor::tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msIdentifier/tei:idno)[1]/text() }</ref>
                    <scheme>{ ($x/ancestor::keywords/@scheme/data(), 'bodl')[1] }</scheme>
                </place>
    )
    
    let $allplaces := ($hebrewplaces, $genizahplaces)

    let $dedupedplaces := (
        for $t at $pos in distinct-values($allplaces/name/text())
            order by $t
            return
            <place xml:id="{ concat('place_', $pos) }">
                <placeName type="index" source="{ string-join(distinct-values($allplaces[name = $t]/scheme/text()), ' ') }">{ $t }</placeName>
                {
                for $s in distinct-values($allplaces[name = $t]/ref/text())
                    order by $s
                    return
                    <ref>{ $s }</ref>
                }
            </place>
    )
    
    return $dedupedplaces      

}
            </listPlace>
        </body>
    </text>
</TEI>




        
