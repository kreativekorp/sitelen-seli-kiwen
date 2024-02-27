#!/usr/bin/env bash
mkdir -p safespace
cp sitelenselikiwen.sfd safespace/sitelenselikiwen.bak
cp sitelenselikiwenmono.sfd safespace/sitelenselikiwenmono.bak
python sfdpatch/sfdpatch.py safespace/sitelenselikiwen.bak -sp -s > sitelenselikiwen.sfd
python sfdpatch/sfdpatch.py safespace/sitelenselikiwenmono.bak -sp -s > sitelenselikiwenmono.sfd
