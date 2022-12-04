#/bin/bash

rm -rf *.xml

env LC_ALL=de_DE.UTF-8 LC_NUMERIC=de_DE.utf8 qmltestrunner -platform offscreen -junitxml -o junit.xml

