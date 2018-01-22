#!/usr/bin/env bash

# Command arguments
# $1 = xQuery file
# $2 = Output file
# $3 = Solr `type` (for deleting only one type of record)
# $4 = Solr address for indexing
# $5 = Optional mode:
#           Append 'force' to disable checking for data issues and push to Solr without prompting
#           Append 'noindex' to generate the files and do the checking but not push to Solr

echo

if [ $# -lt 4 ]; then
    echo "Too few command line arguments."
    exit 1;
fi

# Change directory to the location of this script
cd "${0%/*}"

# Create subfolder to keep generated files out of GitHub
if [ ! -d "solr" ]; then
    mkdir solr
fi

# Start log file
LOGFILE="solr/$3.log"
echo "Processing TEI files in collections folder using $1 on $(date +"%Y-%m-%d %H:%M:%S") to be sent to $4 for re-indexing." > $LOGFILE

# Run XQuery to build Solr XML index files
echo "Generating Solr XML file containing $3 records..."
java -Xmx1G -Xms1G -cp "saxon/saxon9he.jar" net.sf.saxon.Query -xi:on -q:$1 1> solr/$2 2>> $LOGFILE
if [ $? -gt 0 ]; then
    echo "XQuery failed. Re-indexing of $3 records cancelled. Please raise an issue on GitHub, attaching $LOGFILE"
    exit 1;
fi

# Clean up log file (because XQuery/Saxon appends some junk to the end of each line)
# Doesn't work in git-bash which lacks the rev command
if hash rev 2>/dev/null; then
    rev $LOGFILE | cut -f 2- | rev > $LOGFILE.tmp && mv $LOGFILE.tmp $LOGFILE
fi

# Check what's been logged
errors=$(grep -ic "^error" $LOGFILE)
if [ $errors -gt 0 ]; then
    echo "There are $errors error messages in $LOGFILE so re-indexing of $3 records cannot proceed."
    exit 1;
fi
warnings=$(grep -ic "^warn" $LOGFILE)
infos=$(grep -ic "^info" $LOGFILE)
if [ $warnings -gt 0 ] || [ $infos -gt 0 ]; then
    echo "There are $warnings warning and $infos info messages in $LOGFILE"
    if [ ! "$5" == "force" ] && [ ! "$5" == "noindex" ]; then
        while true; do
            read -p "Do you wish to rebuild the $3 index? [Yes|No|Quit|View] " answer
            case $answer in
                [Yy]|YES|Yes|yes ) break;;
                [Nn]|NO|No|no ) echo "Re-indexing of $3 records cancelled. Proceeding to next index."; exit 0;;
                [Qq]|QUIT|Quit|quit ) echo "Re-indexing of $3 records cancelled. Abandoning all further indexing."; exit 1;;
                [Vv]|VIEW|View|view ) less $LOGFILE; echo;;
                * ) echo;;
            esac
        done
    fi
fi

if [ ! "$5" == "noindex" ]; then

    # Emptying index on Solr. Doing so for both place and organization will result in only one of them 
    # being indexed; so if we're indexing organizations, then, skip the empty step.
    if [ ! $1 == "organizations.xquery" ]; then
        echo "Emptying Solr of $3 records..."
        curl -fsS "http://${4}:8983/solr/hebrew-mss/update?stream.body=<delete><query>type:${3}</query></delete>&commit=true" 1>> $LOGFILE 2>> $LOGFILE
    fi

    # Upload generated XML to Solr
    if [ $? -gt 0 ]; then
        echo "Emptying Solr failed. The indexes cannot be updated. Please try again later. If problem persists, raise an issue on GitHub, attaching $LOGFILE"
        exit 1;
    else
        echo "Sending new $3 records to Solr..."
        curl -fsS "http://${4}:8983/solr/hebrew-mss/update?commit=true" --data-binary @solr/$2 -H "Content-Type: text/xml" 1>> $LOGFILE 2>> $LOGFILE
        if [ $? -eq 0 ]; then
            echo "Re-indexing of $3 records finished. Please check the web site for expected changes."
            exit 0;
        else
            echo "Re-indexing of $3 records failed. The web site will have no $3s. If this is on production, raise an urgent issue on GitHub, attaching $LOGFILE"
            exit 1;
        fi
    fi
else
    echo "Re-indexing skipped in $5 mode."
    exit 0;
fi


