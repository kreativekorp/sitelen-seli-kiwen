#!/usr/bin/env bash

# Find FontForge
if command -v fontforge >/dev/null 2>&1; then
	FONTFORGE="fontforge"
elif test -f /Applications/FontForge.app/Contents/Resources/opt/local/bin/fontforge; then
	FONTFORGE="/Applications/FontForge.app/Contents/Resources/opt/local/bin/fontforge"
else
	echo "Could not find FontForge."
	exit 1
fi

# Find fonttools
if command -v fonttools >/dev/null 2>&1; then
	FONTTOOLS="fonttools"
else
	echo "Could not find fonttools."
	exit 1
fi

# Find Bits'n'Picas
if command -v bitsnpicas >/dev/null 2>&1; then
	BITSNPICAS="bitsnpicas"
elif test -f BitsNPicas.jar; then
	BITSNPICAS="java -jar BitsNPicas.jar"
elif test -f ../BitsNPicas/BitsNPicas.jar; then
	BITSNPICAS="java -jar ../BitsNPicas/BitsNPicas.jar"
elif test -f ../Workspace/BitsNPicas/BitsNPicas.jar; then
	BITSNPICAS="java -jar ../Workspace/BitsNPicas/BitsNPicas.jar"
elif test -f ../../BitsNPicas/BitsNPicas.jar; then
	BITSNPICAS="java -jar ../../BitsNPicas/BitsNPicas.jar"
elif test -f ../../Workspace/BitsNPicas/BitsNPicas.jar; then
	BITSNPICAS="java -jar ../../Workspace/BitsNPicas/BitsNPicas.jar"
elif test -f ../../../BitsNPicas/BitsNPicas.jar; then
	BITSNPICAS="java -jar ../../../BitsNPicas/BitsNPicas.jar"
elif test -f ../../../Workspace/BitsNPicas/BitsNPicas.jar; then
	BITSNPICAS="java -jar ../../../Workspace/BitsNPicas/BitsNPicas.jar"
elif test -f ../../../../BitsNPicas/BitsNPicas.jar; then
	BITSNPICAS="java -jar ../../../../BitsNPicas/BitsNPicas.jar"
elif test -f ../../../../Workspace/BitsNPicas/BitsNPicas.jar; then
	BITSNPICAS="java -jar ../../../../Workspace/BitsNPicas/BitsNPicas.jar"
else
	echo "Could not find BitsNPicas."
	exit 1
fi

# Find ttf2eot
if command -v ttf2eot >/dev/null 2>&1; then
	TTF2EOT="ttf2eot"
else
	echo "Could not find ttf2eot."
	exit 1
fi

# Clean
rm -f *.sfd-* *_base.* *.ttf *.eot *.zip

# Make patched versions
python sfdpatch/sfdpatch.py sitelenselikiwen.sfd sfdpatch/asuki.txt > sitelenselikiwenasuki_base.sfd
python sfdpatch/sfdpatch.py sitelenselikiwen.sfd sfdpatch/atuki.txt > sitelenselikiwenatuki_base.sfd
python sfdpatch/sfdpatch.py sitelenselikiwen.sfd sfdpatch/juniko.txt > sitelenselikiwenjuniko_base.sfd
python sfdpatch/sfdpatch.py sitelenselikiwenmono.sfd sfdpatch/monoasuki.txt > sitelenselikiwenmonoasuki_base.sfd
python sfdpatch/sfdpatch.py sitelenselikiwenmono.sfd sfdpatch/monoatuki.txt > sitelenselikiwenmonoatuki_base.sfd
python sfdpatch/sfdpatch.py sitelenselikiwenmono.sfd sfdpatch/monojuniko.txt > sitelenselikiwenmonojuniko_base.sfd

# Generate ttf
$FONTFORGE -lang=ff -c 'i = 1; while (i < $argc); Open($argv[i]); Generate($argv[i]:r + ".ttf", "", 0); i = i+1; endloop' \
	sitelenselikiwenasuki_base.sfd sitelenselikiwenatuki_base.sfd sitelenselikiwenjuniko_base.sfd \
	sitelenselikiwenmonoasuki_base.sfd sitelenselikiwenmonoatuki_base.sfd sitelenselikiwenmonojuniko_base.sfd

rm *_base.sfd

# Add OpenType features (FontForge completely fouls this up on its own)
cd features
python build.py
cat languages.fea sequences.fea joiners.fea asuki.fea variants.fea extendable.fea extensions.fea > ../sitelenselikiwenasuki_base.fea
cat languages.fea sequences.fea joiners.fea atuki.fea variants.fea extendable.fea extensions.fea > ../sitelenselikiwenatuki_base.fea
cat languages.fea sequences.fea joiners.fea variants.fea extendable.fea extensions.fea > ../sitelenselikiwenjuniko_base.fea
cd ..

$FONTTOOLS feaLib -o sitelenselikiwenasuki.ttf sitelenselikiwenasuki_base.fea sitelenselikiwenasuki_base.ttf
$FONTTOOLS feaLib -o sitelenselikiwenatuki.ttf sitelenselikiwenatuki_base.fea sitelenselikiwenatuki_base.ttf
$FONTTOOLS feaLib -o sitelenselikiwenjuniko.ttf sitelenselikiwenjuniko_base.fea sitelenselikiwenjuniko_base.ttf
$FONTTOOLS feaLib -o sitelenselikiwenmonoasuki.ttf sitelenselikiwenasuki_base.fea sitelenselikiwenmonoasuki_base.ttf
$FONTTOOLS feaLib -o sitelenselikiwenmonoatuki.ttf sitelenselikiwenatuki_base.fea sitelenselikiwenmonoatuki_base.ttf
$FONTTOOLS feaLib -o sitelenselikiwenmonojuniko.ttf sitelenselikiwenjuniko_base.fea sitelenselikiwenmonojuniko_base.ttf

rm *_base.fea
rm *_base.ttf

# Inject PUAA table
$BITSNPICAS injectpuaa \
	-D unidata/Blocks.txt unidata/UnicodeData.txt \
	-I sitelenselikiwenasuki.ttf sitelenselikiwenatuki.ttf sitelenselikiwenjuniko.ttf \
	-I sitelenselikiwenmonoasuki.ttf sitelenselikiwenmonoatuki.ttf sitelenselikiwenmonojuniko.ttf

# Convert to eot
$TTF2EOT < sitelenselikiwenasuki.ttf > sitelenselikiwenasuki.eot
$TTF2EOT < sitelenselikiwenatuki.ttf > sitelenselikiwenatuki.eot
$TTF2EOT < sitelenselikiwenjuniko.ttf > sitelenselikiwenjuniko.eot
$TTF2EOT < sitelenselikiwenmonoasuki.ttf > sitelenselikiwenmonoasuki.eot
$TTF2EOT < sitelenselikiwenmonoatuki.ttf > sitelenselikiwenmonoatuki.eot
$TTF2EOT < sitelenselikiwenmonojuniko.ttf > sitelenselikiwenmonojuniko.eot

# Create zip
zip sitelenselikiwen.zip OFL.txt \
	sitelenselikiwen.html sitelenselikiwenmono.html \
	sitelenselikiwenasuki.ttf sitelenselikiwenasuki.eot \
	sitelenselikiwenatuki.ttf sitelenselikiwenatuki.eot \
	sitelenselikiwenjuniko.ttf sitelenselikiwenjuniko.eot \
	sitelenselikiwenmonoasuki.ttf sitelenselikiwenmonoasuki.eot \
	sitelenselikiwenmonoatuki.ttf sitelenselikiwenmonoatuki.eot \
	sitelenselikiwenmonojuniko.ttf sitelenselikiwenmonojuniko.eot
