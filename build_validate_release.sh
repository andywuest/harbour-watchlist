#!/bin/bash

# define some variables
export PROJECT="harbour-watchlist"
export RPM_VALIDATOR="sdk-harbour-rpmvalidator"

# remove old rpms
cd RPMS
rm -f *.rpm
cd ..

# build new rpm
# find path more dynamically - not hardcoded
ssh -p 2222 -i ~/SailfishOS/vmshare/ssh/private_keys/engine/mersdk mersdk@localhost << EOF
  set -x
  cd /home/src1/projects/sailfishos/github/$PROJECT
  mb2 --no-snapshot -t SailfishOS-3.2.1.20-armv7hl build
EOF

# checkout rpm validator if not yet here
if [ ! -d "$RPM_VALIDATOR" ]; then
  git clone https://github.com/sailfishos/$RPM_VALIDATOR.git
fi

# go to validator, update it, and run it
cd $RPM_VALIDATOR
git pull
./rpmvalidation.sh ../RPMS/$PROJECT*.rpm

