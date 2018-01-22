declare namespace tei="http://www.tei-c.org/ns/1.0";
declare option saxon:output "indent=yes";

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
            <listBibl>
{

    let $skipids := ()
    
    (: First build an in-memory nodeset temporarily storing titles, IDs and the files they come from. :)
    let $hebrewworks := (
        for $x in collection('../collections/?select=*.xml;recurse=yes')//tei:msItem[tei:title]/@xml:id
            let $langs := $x/parent::tei:msItem/tei:textLang
            return
            if ($x eq $skipids) then
                ( (: This @key is in one of the manually-maintained authority files, so don't include it in the generated list :) )
            else
                <work id="{ $x }">
                    {
                    for $y in $x/parent::tei:msItem/tei:title
                        let $titletext := normalize-space(string-join($y//text()[not(ancestor::foreign)], ' '))
                        let $foreigntext := normalize-space(string-join($y//text()[ancestor::foreign], ' '))
                        return 
                        if (string-length($titletext) eq 0 and string-length($foreigntext) eq 0) then
                            ()
                        else if (string-length($titletext) gt 0 and string-length($foreigntext) eq 0) then
                            <title lang="{ $y/@xml:lang }">{ $titletext }</title>
                        else if (string-length($titletext) eq 0 and string-length($foreigntext) gt 0) then
                            <title lang="{ $y/foreign/@xml:lang }">{ $foreigntext }</title>
                        else if (string-length($titletext) gt 0 and string-length($foreigntext) gt 0) then
                            (<title lang="{ $y/@xml:lang }">{ $titletext }</title>,
                            <title lang="{ $y/foreign/@xml:lang }">{ $foreigntext }</title>)
                        else
                            <title>{ normalize-space(string-join($y//text(), ' ')) }</title>
                    }
                    { $langs }
                    <file>{ base-uri($x) }</file>
                </work>
    )
    
    let $genizahworks := (
        for $x in collection('../../genizah-mss/collections/?select=*.xml;recurse=yes')//tei:msItem[tei:title and not(tei:msItem)]/@xml:id
            let $langs := $x/parent::tei:msItem/tei:textLang
            return
            if ($x eq $skipids) then
                ( (: This @key is in one of the manually-maintained authority files, so don't include it in the generated list :) )
            else
                <work id="{ $x }">
                    {
                    for $y in $x/parent::tei:msItem/tei:title
                        let $titletext := normalize-space(string-join($y//text()[not(ancestor::foreign)], ' '))
                        let $foreigntext := normalize-space(string-join($y//text()[ancestor::foreign], ' '))
                        return 
                        if (string-length($titletext) eq 0 and string-length($foreigntext) eq 0) then
                            ()
                        else if (string-length($titletext) gt 0 and string-length($foreigntext) eq 0) then
                            <title lang="{ $y/@xml:lang }">{ $titletext }</title>
                        else if (string-length($titletext) eq 0 and string-length($foreigntext) gt 0) then
                            <title lang="{ $y/foreign/@xml:lang }">{ $foreigntext }</title>
                        else if (string-length($titletext) gt 0 and string-length($foreigntext) gt 0) then
                            (<title lang="{ $y/@xml:lang }">{ $titletext }</title>,
                            <title lang="{ $y/foreign/@xml:lang }">{ $foreigntext }</title>)
                        else
                            <title>{ normalize-space(string-join($y//text(), ' ')) }</title>
                    }
                    { $langs }
                    <file>{ base-uri($x) }</file>
                </work>
    )
    
    let $allworks := ($hebrewworks, $genizahworks)

    let $dedupedworks := (
        for $t at $pos in distinct-values($allworks/title[not(preceding-sibling::title)]/text())
            let $variants := (
                for $r in $allworks[title = $t]
                    return
                    for $a in $r/title[not(. = $t)]/text()
                        return $a
            )

            return
            <bibl xml:id="{ concat('work_', $pos) }">
                <title type="uniform">{ $t }</title>
                {
                for $v in distinct-values($variants)
                    return <title type="variant">{ $v }</title>
                }
                {
                for $r in $allworks[title = $t]
                    order by $r/@id
                    return
                    (<ref target="{ $r/@id }"/>, comment{concat(' ../../', string-join(tokenize($r/file, '/')[position() gt last()-3], '/'), '#', $r/@id, ' ')})
                }
                {
                (: This is a bit of a kludge but for indexing it doesn't matter which languages is selected as the "main" one :)
                let $mainlang := (distinct-values($allworks[title = $t]/textLang/@mainLang))[1]
                let $otherlangs := (distinct-values($allworks[title = $t]/textLang/@otherLangs/tokenize(., ' ')))[not(. eq $mainlang)]
                return
                if (count($otherlangs) gt 0) then
                    <textLang mainLang="{ $mainlang }" otherLangs="{ $otherlangs }"/>
                else
                    <textLang mainLang="{ $mainlang }"/>
                }
            </bibl>
    
    )
    
    return $dedupedworks       

}
            </listBibl>
        </body>
    </text>
</TEI>




        
