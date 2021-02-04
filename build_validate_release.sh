#!/bin/bash

# set -x

# define some variables
export PROJECT="harbour-watchlist"
export RPM_VALIDATOR="sdk-harbour-rpmvalidator"

# remove old rpms
cd RPMS
rm -f *.rpm
cd ..

# determine supported target version string
export TARGET=$(ssh -p 2222 -i ~/SailfishOS/vmshare/ssh/private_keys/engine/mersdk mersdk@localhost sdk-assistant list | grep "^Sailfish")

# build new rpm
# find path more dynamically - not hardcoded
ssh -p 2222 -i ~/SailfishOS/vmshare/ssh/private_keys/engine/mersdk mersdk@localhost << EOF
  set -x
  cd /home/src1/projects/sailfishos/github/$PROJECT
  rm *.o
  mb2 --no-snapshot -t $TARGET-armv7hl build
EOF

# checkout rpm validator if not yet here
if [ ! -d "$RPM_VALIDATOR" ]; then
  git clone https://github.com/sailfishos/$RPM_VALIDATOR.git
fi

# go to validator, update it, and run it
cd $RPM_VALIDATOR
git pull
./rpmvalidation.sh ../RPMS/$PROJECT*.rpm

cd ..
rm -rf $RPM_VALIDATOR
