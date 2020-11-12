echo 'Transform ' $1 ' to ' $2
python3 pyCovidRebuid.py $1 > covid19-tmp.xml
java -jar saxon9he.jar -xsl:covid-eu-enrichment.xsl -s:covid19-tmp.xml > $2
rm covid19-tmp.xml