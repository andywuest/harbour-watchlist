#/bin/bash

# execute with workaround with tap - because junit cannot be generated directly with the used version

find . -name "*.o" -exec rm  {} \;
find . -name "*.tap" -exec rm  {} \;
find . -name "moc_*" -exec rm  {} \;
find . -name "Makefile" -exec rm  {} \;

qmake -o Makefile harbour-watchlist-tests.pro
make
env LC_ALL=de_DE.UTF-8 LC_NUMERIC=de_DE.utf8 ./IngDibaBackendTest -junitxml -o junit.xml



