SCHEMATRON_DIR=bin/xspec/src/schematron/iso-schematron/
DITA_CATALOG=bin/dita-ot-3.3.3/catalog-dita.xml

echo "Downloading Saxon 9"
if [[ ! -e bin/saxon9.jar ]];
then
  mkdir bin
  touch bin/saxon9.jar
  curl -L -q https://repo1.maven.org/maven2/net/sf/saxon/Saxon-HE/9.9.1-2/Saxon-HE-9.9.1-2.jar > bin/saxon9.jar
fi

echo "Downloading Apache catalog Resolver"
if [[ ! -e bin/xml-resolver.jar ]];
then
  mkdir bin
  touch bin/xml-resolver.jar
  curl -L -q https://repo1.maven.org/maven2/xml-resolver/xml-resolver/1.2/xml-resolver-1.2.jar > bin/xml-resolver.jar
fi


echo "Downloading the Oxygen framework"
if [[ ! -e bin/xspec ]];
then
  mkdir bin
  touch bin/frameworks.zip
  curl -q https://www.oxygenxml.com/maven/com/oxygenxml/frameworks/21.0.0.0/frameworks-21.0.0.0.zip > bin/frameworks.zip
  unzip -q bin/frameworks.zip -d bin/
fi

echo "Downloading DITA-OT"
if [[ ! -e bin/dita-ot.zip ]];
then
  mkdir bin
  
  curl -q -L https://github.com/dita-ot/dita-ot/releases/download/3.3.3/dita-ot-3.3.3.zip --output bin/dita-ot.zip
  
  ls -l bin/dita-ot.zip
  
  unzip -q bin/dita-ot.zip -d bin/
fi



echo "Downloading the SVRL to SONAR conversion tool"
if [[ ! -e bin/svrl-to-sonar.jar ]];
then
  mkdir bin
  touch bin/svrl-to-sonar.jar
  curl -qL https://github.com/AlexJitianu/svrl-to-sonar/releases/download/0.1.1/svrl-to-sonar-0.1.1.jar > bin/svrl-to-sonar.jar
fi



rm -rf bin/tmp/
mkdir -p bin/tmp/

echo "Validating with schematron"

echo "Expand Schematron"
java -jar bin/saxon9.jar scripts/schematron-validation/rulesAdvanced.sch $SCHEMATRON_DIR/iso_dsdl_include.xsl > bin/tmp/paper-includes.sch
java -jar bin/saxon9.jar bin/tmp/paper-includes.sch $SCHEMATRON_DIR/iso_abstract_expand.xsl > bin/tmp/paper-expanded.sch
java -jar bin/saxon9.jar bin/tmp/paper-expanded.sch $SCHEMATRON_DIR/iso_svrl_for_xslt2.xsl > bin/tmp/paper-validate.xsl

echo "Apply  Schematron"
java -cp bin/xml-resolver.jar:bin/saxon9.jar net.sf.saxon.Transform -catalog:$DITA_CATALOG -s:source/rule_based_validation_samples.dita -xsl:bin/tmp/paper-validate.xsl > bin/tmp/paper.svrl

echo "--RESULT--"
cat bin/tmp/paper.svrl

echo "Convert SVRL to SONAR"
java -jar bin/svrl-to-sonar.jar bin/tmp/paper.svrl > bin/tmp/sonar-schematron.json

echo "--CONVERTED--"
cat bin/tmp/sonar-schematron.json
