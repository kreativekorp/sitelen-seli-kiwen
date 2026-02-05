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

# Find ttf2eot
if command -v ttf2eot >/dev/null 2>&1; then
	TTF2EOT="ttf2eot"
else
	echo "Could not find ttf2eot."
	exit 1
fi

SFDPATCH="python openrelay-tools/tools/sfdpatch.py"
SITELENPANA="python ../openrelay-tools/tools/sitelenpana.py"
BLOCKS="python openrelay-tools/tools/blocks.py"
UNIDATA="python openrelay-tools/tools/unicodedata.py"
PUAABOOK="python openrelay-tools/tools/puaabook.py"
PYPUAA="python openrelay-tools/tools/pypuaa.py"

# Clean
rm -f *.sfd-* *_base.* *.ttf *.eot *.zip

# Make patched versions
$SFDPATCH sitelenselikiwen.sfd sfdpatch/asuki.txt > sitelenselikiwenasuki_base.sfd
$SFDPATCH sitelenselikiwen.sfd sfdpatch/atuki.txt > sitelenselikiwenatuki_base.sfd
$SFDPATCH sitelenselikiwen.sfd sfdpatch/juniko.txt > sitelenselikiwenjuniko_base.sfd
$SFDPATCH sitelenselikiwenmono.sfd sfdpatch/monoasuki.txt > sitelenselikiwenmonoasuki_base.sfd
$SFDPATCH sitelenselikiwenmono.sfd sfdpatch/monoatuki.txt > sitelenselikiwenmonoatuki_base.sfd
$SFDPATCH sitelenselikiwenmono.sfd sfdpatch/monojuniko.txt > sitelenselikiwenmonojuniko_base.sfd

# Generate fea
cd features
$SITELENPANA -f ../sitelenselikiwenasuki_base.sfd -i sitelenpona.txt -a spascii.fea -o spbase.fea
$SITELENPANA -f ../sitelenselikiwenatuki_base.sfd -i titipula.txt -a tpascii.fea -o /dev/null
$SITELENPANA -f ../sitelenselikiwenmonoasuki_base.sfd -i sitelenpona.txt -a /dev/null -o spmono.fea
$SITELENPANA -f ../sitelenselikiwenmonoatuki_base.sfd -i titipula.txt -a /dev/null -o /dev/null
cd ..

# Generate ttf
$FONTFORGE -lang=ff -c 'i = 1; while (i < $argc); Open($argv[i]); Generate($argv[i]:r + ".ttf", "", 0); i = i+1; endloop' \
	sitelenselikiwenasuki_base.sfd sitelenselikiwenatuki_base.sfd sitelenselikiwenjuniko_base.sfd \
	sitelenselikiwenmonoasuki_base.sfd sitelenselikiwenmonoatuki_base.sfd sitelenselikiwenmonojuniko_base.sfd

# Add OpenType features
$FONTTOOLS feaLib -o sitelenselikiwenasuki.ttf features/asuki.fea sitelenselikiwenasuki_base.ttf
$FONTTOOLS feaLib -o sitelenselikiwenatuki.ttf features/atuki.fea sitelenselikiwenatuki_base.ttf
$FONTTOOLS feaLib -o sitelenselikiwenjuniko.ttf features/juniko.fea sitelenselikiwenjuniko_base.ttf
$FONTTOOLS feaLib -o sitelenselikiwenmonoasuki.ttf features/monoasuki.fea sitelenselikiwenmonoasuki_base.ttf
$FONTTOOLS feaLib -o sitelenselikiwenmonoatuki.ttf features/monoatuki.fea sitelenselikiwenmonoatuki_base.ttf
$FONTTOOLS feaLib -o sitelenselikiwenmonojuniko.ttf features/monojuniko.fea sitelenselikiwenmonojuniko_base.ttf

# Clean up
rm *_base.sfd
rm features/spascii.fea
rm features/spbase.fea
rm features/spmono.fea
rm features/tpascii.fea
rm *_base.ttf

# Inject PUAA table
PUAAFLAGS="ktt --mathematical-symbols-appendix --modifier-tone-letter-presentation-forms"
$BLOCKS $PUAAFLAGS > Blocks.txt
$UNIDATA $PUAAFLAGS > UnicodeData.txt
$PUAABOOK -D Blocks.txt UnicodeData.txt -I sitelenselikiwenjuniko.ttf -O pua.html
$PYPUAA compile -D Blocks.txt UnicodeData.txt \
	-I sitelenselikiwenasuki.ttf sitelenselikiwenatuki.ttf sitelenselikiwenjuniko.ttf \
	-I sitelenselikiwenmonoasuki.ttf sitelenselikiwenmonoatuki.ttf sitelenselikiwenmonojuniko.ttf
rm Blocks.txt UnicodeData.txt

# Convert to eot
$TTF2EOT < sitelenselikiwenasuki.ttf > sitelenselikiwenasuki.eot
$TTF2EOT < sitelenselikiwenatuki.ttf > sitelenselikiwenatuki.eot
$TTF2EOT < sitelenselikiwenjuniko.ttf > sitelenselikiwenjuniko.eot
$TTF2EOT < sitelenselikiwenmonoasuki.ttf > sitelenselikiwenmonoasuki.eot
$TTF2EOT < sitelenselikiwenmonoatuki.ttf > sitelenselikiwenmonoatuki.eot
$TTF2EOT < sitelenselikiwenmonojuniko.ttf > sitelenselikiwenmonojuniko.eot

# Create zip
zip sitelenselikiwen.zip OFL.txt pua.html \
	sitelenselikiwen.html sitelenselikiwenmono.html \
	sitelenselikiwenasuki.ttf sitelenselikiwenasuki.eot \
	sitelenselikiwenatuki.ttf sitelenselikiwenatuki.eot \
	sitelenselikiwenjuniko.ttf sitelenselikiwenjuniko.eot \
	sitelenselikiwenmonoasuki.ttf sitelenselikiwenmonoasuki.eot \
	sitelenselikiwenmonoatuki.ttf sitelenselikiwenmonoatuki.eot \
	sitelenselikiwenmonojuniko.ttf sitelenselikiwenmonojuniko.eot
