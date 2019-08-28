#!/bin/bash

set -x

cd backend/euroinvestor
tsc -m none --alwaysStrict EuroinvestorBrowserTest.ts --out euroinvestor_nodetestx.js
cat node_prefix.js euroinvestor_nodetestx.js node_suffix.js > euronode.js
cp euronode.js ../..
#cd ..
#cd ..

