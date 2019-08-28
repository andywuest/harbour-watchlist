#!/bin/bash

set -x

cd backend/euroinvestor
tsc -m none --alwaysStrict EuroinvestorBrowserTest.ts --out euroinvestor_browsertest.js
#cd ..
#cd ..

