#!/usr/bin/env bash
mkdir -p safespace
cp sitelenselikiwen.sfd safespace/sitelenselikiwen.bak
cp sitelenselikiwenmono.sfd safespace/sitelenselikiwenmono.bak
SFDPATCH="python openrelay-tools/tools/sfdpatch.py"
$SFDPATCH safespace/sitelenselikiwen.bak -spr -s > sitelenselikiwen.sfd
$SFDPATCH safespace/sitelenselikiwenmono.bak -spr -s > sitelenselikiwenmono.sfd
