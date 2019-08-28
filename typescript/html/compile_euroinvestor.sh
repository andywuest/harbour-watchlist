#!/bin/bash

set -x

cd backend/euroinvestor
tsc -m none --alwaysStrict Euroinvestor.ts --out euroinvestor.js
cp euroinvestor.js ../../../../qml/js
#cd ..
#cd ..

