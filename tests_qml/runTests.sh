#/bin/bash

rm -rf *.xml

qmltestrunner -platform offscreen -o qmlresults.xml,xml

