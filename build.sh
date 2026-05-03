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
TTFHACK="python openrelay-tools/tools/ttfhack.py"

# Clean
rm -f *.sfd-* *_base.* *.ttf *.eot *.zip
rm -f BoundsHack/*.ttf

# Make patched versions
$SFDPATCH sitelenselikiwen.sfd sfdpatch/asuki.txt > sitelenselikiwenasuki_base.sfd
$SFDPATCH sitelenselikiwen.sfd sfdpatch/atuki.txt > sitelenselikiwenatuki_base.sfd
$SFDPATCH sitelenselikiwen.sfd sfdpatch/juniko.txt > sitelenselikiwenjuniko_base.sfd
$SFDPATCH sitelenselikiwenjuniko_base.sfd sfdpatch/nocjk.txt > sitelenselikiwenjuniko_nocjk_base.sfd
$SFDPATCH sitelenselikiwenmono.sfd sfdpatch/monoasuki.txt > sitelenselikiwenmonoasuki_base.sfd
$SFDPATCH sitelenselikiwenmono.sfd sfdpatch/monoatuki.txt > sitelenselikiwenmonoatuki_base.sfd
$SFDPATCH sitelenselikiwenmono.sfd sfdpatch/monojuniko.txt > sitelenselikiwenmonojuniko_base.sfd
$SFDPATCH sitelenselikiwenmonojuniko_base.sfd sfdpatch/nocjk.txt > sitelenselikiwenmonojuniko_nocjk_base.sfd

# Generate fea
cd features
grep -E -v "uni(30|4E|51|FF)" sitelenpona.txt > sitelenpona-nocjk.txt
$SITELENPANA -f ../sitelenselikiwenjuniko_nocjk_base.sfd -i sitelenpona-nocjk.txt -a /dev/null -o spnocjk.fea
$SITELENPANA -f ../sitelenselikiwenasuki_base.sfd -i sitelenpona.txt -a spascii.fea -o spbase.fea -g ../glyphs.html -e sitelenselikiwenjuniko.eot -t sitelenselikiwenjuniko.ttf
$SITELENPANA -f ../sitelenselikiwenatuki_base.sfd -i titipula.txt -a tpascii.fea -o /dev/null
$SITELENPANA -f ../sitelenselikiwenmonojuniko_nocjk_base.sfd -i sitelenpona-nocjk.txt -a /dev/null -o spmononocjk.fea
$SITELENPANA -f ../sitelenselikiwenmonoasuki_base.sfd -i sitelenpona.txt -a /dev/null -o spmono.fea -g ../glyphsmono.html -e sitelenselikiwenmonojuniko.eot -t sitelenselikiwenmonojuniko.ttf
$SITELENPANA -f ../sitelenselikiwenmonoatuki_base.sfd -i titipula.txt -a /dev/null -o /dev/null
cd ..

# Generate ttf
$FONTFORGE -lang=ff -c 'i = 1; while (i < $argc); Open($argv[i]); Generate($argv[i]:r + ".ttf", "", 0); i = i+1; endloop' \
	sitelenselikiwenasuki_base.sfd sitelenselikiwenatuki_base.sfd \
	sitelenselikiwenjuniko_base.sfd sitelenselikiwenjuniko_nocjk_base.sfd \
	sitelenselikiwenmonoasuki_base.sfd sitelenselikiwenmonoatuki_base.sfd \
	sitelenselikiwenmonojuniko_base.sfd sitelenselikiwenmonojuniko_nocjk_base.sfd

# Add OpenType features
$FONTTOOLS feaLib -o sitelenselikiwenasuki.ttf features/asuki.fea sitelenselikiwenasuki_base.ttf
$FONTTOOLS feaLib -o sitelenselikiwenatuki.ttf features/atuki.fea sitelenselikiwenatuki_base.ttf
$FONTTOOLS feaLib -o sitelenselikiwenjuniko.ttf features/juniko.fea sitelenselikiwenjuniko_base.ttf
$FONTTOOLS feaLib -o sitelenselikiwenjuniko-nocjk.ttf features/nocjk.fea sitelenselikiwenjuniko_nocjk_base.ttf
$FONTTOOLS feaLib -o sitelenselikiwenmonoasuki.ttf features/monoasuki.fea sitelenselikiwenmonoasuki_base.ttf
$FONTTOOLS feaLib -o sitelenselikiwenmonoatuki.ttf features/monoatuki.fea sitelenselikiwenmonoatuki_base.ttf
$FONTTOOLS feaLib -o sitelenselikiwenmonojuniko.ttf features/monojuniko.fea sitelenselikiwenmonojuniko_base.ttf
$FONTTOOLS feaLib -o sitelenselikiwenmonojuniko-nocjk.ttf features/mononocjk.fea sitelenselikiwenmonojuniko_nocjk_base.ttf

# Clean up
rm *_base.sfd
rm features/sitelenpona-nocjk.txt
rm features/spascii.fea
rm features/spbase.fea
rm features/spmono.fea
rm features/spmononocjk.fea
rm features/spnocjk.fea
rm features/tpascii.fea
rm *_base.ttf

# Inject PUAA table
PUAAFLAGS="ktt --mathematical-symbols-appendix --modifier-tone-letter-presentation-forms"
$BLOCKS $PUAAFLAGS > Blocks.txt
$UNIDATA $PUAAFLAGS > UnicodeData.txt
$PUAABOOK -D Blocks.txt UnicodeData.txt -I sitelenselikiwenjuniko.ttf -O pua.html
$PYPUAA compile -D Blocks.txt UnicodeData.txt \
	-I sitelenselikiwenasuki.ttf sitelenselikiwenatuki.ttf \
	-I sitelenselikiwenjuniko.ttf sitelenselikiwenjuniko-nocjk.ttf \
	-I sitelenselikiwenmonoasuki.ttf sitelenselikiwenmonoatuki.ttf \
	-I sitelenselikiwenmonojuniko.ttf sitelenselikiwenmonojuniko-nocjk.ttf
rm Blocks.txt UnicodeData.txt

# Convert to eot
$TTF2EOT < sitelenselikiwenasuki.ttf > sitelenselikiwenasuki.eot
$TTF2EOT < sitelenselikiwenatuki.ttf > sitelenselikiwenatuki.eot
$TTF2EOT < sitelenselikiwenjuniko.ttf > sitelenselikiwenjuniko.eot
$TTF2EOT < sitelenselikiwenjuniko-nocjk.ttf > sitelenselikiwenjuniko-nocjk.eot
$TTF2EOT < sitelenselikiwenmonoasuki.ttf > sitelenselikiwenmonoasuki.eot
$TTF2EOT < sitelenselikiwenmonoatuki.ttf > sitelenselikiwenmonoatuki.eot
$TTF2EOT < sitelenselikiwenmonojuniko.ttf > sitelenselikiwenmonojuniko.eot
$TTF2EOT < sitelenselikiwenmonojuniko-nocjk.ttf > sitelenselikiwenmonojuniko-nocjk.eot

# Create bounds hacked version
$TTFHACK if=sitelenselikiwenasuki.ttf yMax=1150 of=BoundsHack/sitelenselikiwenasuki.ttf
$TTFHACK if=sitelenselikiwenatuki.ttf yMax=1150 of=BoundsHack/sitelenselikiwenatuki.ttf
$TTFHACK if=sitelenselikiwenjuniko.ttf yMax=1150 of=BoundsHack/sitelenselikiwenjuniko.ttf
$TTFHACK if=sitelenselikiwenjuniko-nocjk.ttf yMax=1150 of=BoundsHack/sitelenselikiwenjuniko-nocjk.ttf
$TTFHACK if=sitelenselikiwenmonoasuki.ttf yMax=1150 of=BoundsHack/sitelenselikiwenmonoasuki.ttf
$TTFHACK if=sitelenselikiwenmonoatuki.ttf yMax=1150 of=BoundsHack/sitelenselikiwenmonoatuki.ttf
$TTFHACK if=sitelenselikiwenmonojuniko.ttf yMax=1150 of=BoundsHack/sitelenselikiwenmonojuniko.ttf
$TTFHACK if=sitelenselikiwenmonojuniko-nocjk.ttf yMax=1150 of=BoundsHack/sitelenselikiwenmonojuniko-nocjk.ttf

# Update HTML documentation
sed '/<!-- START GLYPH LIST -->/q' sitelenselikiwen.html > sitelenselikiwen_tmp.html
sed '/<!-- START GLYPH LIST -->/q' sitelenselikiwenmono.html > sitelenselikiwenmono_tmp.html
sed '1,/<body>/d;/<\/body>/,$d' glyphs.html >> sitelenselikiwen_tmp.html
sed '1,/<body>/d;/<\/body>/,$d' glyphsmono.html >> sitelenselikiwenmono_tmp.html
sed -n '/<!-- END GLYPH LIST -->/,$p' sitelenselikiwen.html >> sitelenselikiwen_tmp.html
sed -n '/<!-- END GLYPH LIST -->/,$p' sitelenselikiwenmono.html >> sitelenselikiwenmono_tmp.html
mv sitelenselikiwen_tmp.html sitelenselikiwen.html
mv sitelenselikiwenmono_tmp.html sitelenselikiwenmono.html
rm glyphs.html glyphsmono.html

# Create zip
zip sitelenselikiwen.zip OFL.txt \
	sitelenselikiwen.html sitelenselikiwenmono.html \
	sitelenselikiwenasuki.ttf sitelenselikiwenasuki.eot \
	sitelenselikiwenatuki.ttf sitelenselikiwenatuki.eot \
	sitelenselikiwenjuniko.ttf sitelenselikiwenjuniko.eot \
	sitelenselikiwenjuniko-nocjk.ttf sitelenselikiwenjuniko-nocjk.eot \
	sitelenselikiwenmonoasuki.ttf sitelenselikiwenmonoasuki.eot \
	sitelenselikiwenmonoatuki.ttf sitelenselikiwenmonoatuki.eot \
	sitelenselikiwenmonojuniko.ttf sitelenselikiwenmonojuniko.eot \
	sitelenselikiwenmonojuniko-nocjk.ttf sitelenselikiwenmonojuniko-nocjk.eot \
	BoundsHack/* pua.html
