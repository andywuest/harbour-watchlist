#/bin/bash

export CLANG_VERSION=14

cd src
clang-format-$CLANG_VERSION --sort-includes -i **/*.cpp **/*.h --verbose
cd ..
cd test
cd cpp
clang-format-$CLANG_VERSION --sort-includes -i *.cpp *.h --verbose
cd ..
cd ..

