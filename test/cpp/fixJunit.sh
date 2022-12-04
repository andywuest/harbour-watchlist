#/bin/bash

# workaround for not properly generated junit xml files by qt test
sed -i -e 's/<\/testsuite>/<\/testsuite><\/testsuites>/g' junit.xml
sed -i -e 's/<testsuite /<testsuites name="workaround" time="0.0"><testsuite time="0.0" /g' junit.xml
cat *.xml