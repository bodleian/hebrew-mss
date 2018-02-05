import module namespace bod = "http://www.bodleian.ox.ac.uk/bdlss" at "https://raw.githubusercontent.com/bodleian/consolidated-tei-schema/master/msdesc2solr.xquery";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare option saxon:output "indent=yes";

<add>
{
    let $doc := doc("../authority/places_master.xml")
    let $places := $doc//tei:place

    for $place in $places
    
        let $id := $place/@xml:id/string()
        let $name := normalize-space($place//tei:placeName[@type = 'index' or (@type = 'variant' and not(preceding-sibling::tei:placeName))][1]/string())

        return 
        <doc>
            <field name="type">place</field>
            <field name="pk">{ $id }</field>
            <field name="id">{ $id }</field>
            <field name="title">{ $name }</field>
            <field name="alpha_title">{  bod:alphabetize($name) }</field>
            <field name="pl_name_s">{ $name }</field>
            {
            for $ref in $place/tei:ref
                order by $ref
                return <field name="link_manuscripts_smni">{ $ref/text() }</field>
            }
        </doc>
}

</add>
