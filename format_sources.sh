#/bin/bash
cd src
clang-format-9 --sort-includes -i **/*.cpp **/*.h --verbose
cd ..
