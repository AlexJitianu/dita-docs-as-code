DITA_OT=bin/dita-ot-3.3.3

echo "Downloading DITA-OT"
if [[ ! -e bin/dita-ot.zip ]];
then
  mkdir bin
  
  curl -q -L https://github.com/dita-ot/dita-ot/releases/download/3.3.3/dita-ot-3.3.3.zip --output bin/dita-ot.zip
  
  ls -l bin/dita-ot.zip
  
  unzip -q bin/dita-ot.zip -d bin/
fi

echo "====================================="
echo "download WebHelp plugin"
echo "====================================="

curl -q -L https://mirror.oxygenxml.com/InstData/WebHelp/oxygen-webhelp-dot-3.x.zip  --output bin/oxygen-webhelp-dot-2.x.zip


echo "====================================="
echo "extract WebHelp to DITA-OT"
echo "====================================="
unzip -q bin/oxygen-webhelp-dot-2.x.zip -d bin/

cp -R bin/com.oxygenxml.* $DITA_OT/plugins/

pwd

cp scripts/publishing/licensekey.txt $DITA_OT/plugins/com.oxygenxml.webhelp.responsive/licensekey.txt

echo "====================================="
echo "Add Edit Link to DITA-OT"
echo "====================================="

echo "Using REPOSITORY_URL $REPOSITORY_URL" 
SLUG=`echo $REPOSITORY_URL | sed 's/git@github.com://' | sed 's/https:\/\/.*github.com\///'`
echo "Slug: $SLUG"
USERNAME=`echo $SLUG | cut -d '/' -f 1`
REPONAME=`echo $SLUG | cut -d '/' -f 2`

mkdir bin/plugins
# Add the editlink plugin
git clone https://github.com/oxygenxml/dita-reviewer-links bin/plugins/
cp -R bin/plugins/com.oxygenxml.editlink $DITA_OT/plugins/

# Send some parameters to the "editlink" plugin as system properties
export ANT_OPTS="$ANT_OPTS -Deditlink.remote.ditamap.url=github://getFileContent/$USERNAME/$REPONAME/$BRANCH/source/markdown-dita/garage.ditamap -Deditlink.web.author.url=https://www.oxygenxml.com/oxygen-xml-web-author/"
# Send parameters for the Webhelp styling.
export ANT_OPTS="$ANT_OPTS -Dwebhelp.fragment.welcome='$WELCOME'"



echo "====================================="
echo "integrate plugins"
echo "====================================="
cd $DITA_OT
bin/ant -f integrator.xml
cd ../..

pwd

sh $DITA_OT/bin/dita \
    --format=webhelp-responsive \
    --input=source/markdown-dita/garage.ditamap \
    --output=bin/out
