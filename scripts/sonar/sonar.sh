echo "Downloading sonar"

if [[ ! -e bin/sonar ]];
then
  mkdir bin
  touch bin/sonar.zip 
  curl -q https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-3.3.0.1492-linux.zip > bin/sonar.zip
  unzip -q bin/sonar.zip -d bin/
  mv bin/sonar-scanner* bin/sonar
fi

echo "Running validation" 
bash scripts/schematron-validation/validate.sh

echo "Running validate and check for completeness" 
bash scripts/validate-check-completeness/validate-check-completeness.sh

echo "Running sonar"
bin/sonar/bin/sonar-scanner -X \
    -Dproject.settings=scripts/sonar/sonar.properties
	
echo "report"



for file in /opt/build/repo/.scannerwork/scanner-report/*
do
    if [[ -f $file ]]; then
        echo "$file"
    fi
done



   
