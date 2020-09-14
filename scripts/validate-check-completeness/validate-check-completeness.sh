
echo "Downloading Saxon 9"
if [[ ! -e bin/saxon9.jar ]];
then
  mkdir bin
  touch bin/saxon9.jar
  curl -L -q http://central.maven.org/maven2/net/sf/saxon/Saxon-HE/9.9.1-2/Saxon-HE-9.9.1-2.jar > bin/saxon9.jar
fi

echo "Downloading Oxygen"
if [[ ! -e bin/oxygen.tar.gz ]];
then
  mkdir bin
  touch bin/oxygen.tar.gz
  curl -L -q https://mirror.oxygenxml.com/InstData/Editor/All/oxygen.tar.gz > bin/oxygen.tar.gz
  tar xzf bin/oxygen.tar.gz -C bin/
  
  
fi

cp -rf scripts/validate-check-completeness/scriptinglicensekey.txt  bin/oxygen/scriptinglicensekey.txt

rm -rf bin/tmp-vcc/
mkdir -p bin/tmp-vcc/

echo "Validate and check for completeness"

sh bin/oxygen/validateCheckDITA.sh -i source/markdown-dita/garage.ditamap -s scripts/validate-check-completeness/validate-check-completeness.xml -r bin/tmp-vcc/vcc-result.xml

echo "--RESULT--"
cat bin/tmp-vcc/vcc-result.xml

echo "Convert to Sonar"
java -cp bin/saxon9.jar net.sf.saxon.Transform -s:bin/tmp-vcc/vcc-result.xml -xsl:scripts/validate-check-completeness/validatation-results-to-sonar.xsl > bin/tmp-vcc/vcc-result-sonar.json


echo "--CONVERTED--"
cat bin/tmp-vcc/vcc-result-sonar.json
