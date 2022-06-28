#!/usr/bin/env python

import fontforge

uFFA50mx = (50, 528, 40)
uFFA51mx = (35, 418, 38)

f = fontforge.open('sitelenselikiwen.sfd')
for g in f.glyphs():
	if 'uFFA50' in [r[0] for r in g.references]:
		sx = float(g.width + uFFA50mx[0] + uFFA50mx[2]) / float(uFFA50mx[0] + uFFA50mx[1] + uFFA50mx[2])
		tx = sx * uFFA50mx[0] - uFFA50mx[0]
		mx = ('uFFA50', (sx, 0.0, 0.0, 1.0, tx, 0.0))
		refs = tuple(mx if r[0] == 'uFFA50' else r for r in g.references)
		g.references = refs
	if 'uFFA51' in [r[0] for r in g.references]:
		sx = float(g.width + uFFA51mx[0] + uFFA51mx[2]) / float(uFFA51mx[0] + uFFA51mx[1] + uFFA51mx[2])
		tx = sx * uFFA51mx[0] - uFFA51mx[0]
		mx = ('uFFA51', (sx, 0.0, 0.0, 1.0, tx, 0.0))
		refs = tuple(mx if r[0] == 'uFFA51' else r for r in g.references)
		g.references = refs
f.save()
