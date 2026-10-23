---
tags: [content, names]
updated: 2026-10-20
---
# Gamertag Bank

Natural-sounding gamer tags, the way real pros are named: short, odd, lowercase, a digit swapped in, weird capitals. Think of how real tags like donk, s1mple, ZywOo, ropz, apEX or karrigan *feel*, then make **original** ones. Used by [[Player Generator]].

> **Never use real pro tags.** Keep a block list of real pro tags (top players across CS2, Valorant, LoL, Dota 2, Fortnite, Apex, fighting games, sim racing). Block exact matches and near matches (one letter different for tags of 5 letters or fewer). The tags below are invented; still run them through the block list before shipping.

## What makes a tag feel "real"
| Style | Real-world feel (for reference) | Rule | Share |
|---|---|---|---|
| **Short nonsense word** | donk, ropz | 3–5 letters, lowercase, sounds like a noise or a nickname | 30% |
| **Digit swap** | s1mple, m0NESY | Swap one letter: o→0, i→1, e→3, a→4, s→5 (only one swap) | 15% |
| **Odd capitals** | ZywOo, apEX | Capitalize 1–3 letters in odd places | 10% |
| **Name-based** | karrigan, olofmeister | First name + ending (-z, -y, -o, -ster, -inho, -ski) | 15% |
| **Everyday word** | device, chopper | Plain object or animal word, lowercase | 15% |
| **Letters + number** | Xyp9x, b1t | Consonant cluster + 1 digit | 10% |
| **Joke tag** (Common only) | — | Silly tags like `xX_n00b_Xx` | 5% |

Rarity shifts the mix: Common uses more joke and number tags; Epic+ uses more short words and odd capitals, which feel more "pro".

## Generator rules
```lua
-- 1) Build a base
--    Short word:  onset + vowel + coda, e.g. "pl" + "o" + "nk" → "plonk"
--    Name-based:  firstName:lower() + ending, e.g. "tobias" → "tobsen"
--    Everyday:    pick from WordList
-- 2) Apply at most ONE transform
--    digitSwap (o→0, i→1, e→3, a→4), oddCaps, doubleLetter ("kk", "zz"), trailingZ/X/S
-- 3) Reject if: < 3 or > 10 chars, in RealProBlockList (exact or 1-edit if ≤ 5 chars), in BadWordList, or already used on this server
Onsets = {"b","bl","br","d","dr","f","fl","fr","g","gl","gr","j","k","kl","kr","l","m","n","p","pl","pr","r","s","sk","sl","sn","sp","st","t","tr","v","w","z"}
Vowels = {"a","e","i","o","u","oo","ee","y"}
Codas  = {"","b","k","nk","nz","p","ps","rk","s","x","z","zz","ck","ff","m","mp","sh","t","v"}
```

## Bank (original tags)

### Short nonsense (donk-style)
plok · vrez · mipz · krab · dulo · zemi · frix · gorp · wizk · blim · yuni · kroz · spud · nobe · vinz · peko · drov · lumi · bazz · toki · rukk · flim · zarp · jexo · hux · pilo · bren · quib · mozz · glub · vesk · nilo · zugg · kaji · bimo · wex · prax · fizk · rezz · tamo · gekk · plonk · snoo · brik · tazz · yopo · kemz · drib · voxx · muup

### Digit swap (s1mple-style)
b0lt · sn4p · k1ra · m4ze · d4sh · r1ft · t0ast · w1zz · j3t · f1nn · h4wk · l0gik · p1xl · cr4ne · dr1ft · sh4de · m0th · kr1sp · g0ose · fl1p · r0cko · t1dal · b3ns · sl1ck · v0ss

### Odd capitals (ZywOo-style)
ZeKKo · miRRo · KoBu · raViN · VeXu · toRRi · OxyN · kaZuu · LeVo · PuNKz · NoXxi · TeMPo · zAki · RiKu · GhOsTy · mOOka · BiXo · kRuSt · YeTi · ZooMa

### Name-based (karrigan-style)
tobsen · jakeyy · ericpls · samwiz · lukmeister · tomtom · benkk · ollie9 · markusz · teddo · jonasx · rafinho · pellis · ivanko · kenji7 · aleksz · mattie · danyo · hugoz · emilski · leoni · sashka · ruiz0 · timbo · fabsen

Filter example: a generated `nik0` or `s1mpel` must be rejected; it's one edit away from a real pro tag.

### Everyday words (device-style)
kettle · pebble · latch · gravel · marble · cobalt · socket · nickel · thimble · cinder · wrench · quartz · ferret · badger · gecko · otter · biscuit · lantern · pickle · waffle · teacup · noodle · pretzel · button · zipper · sprout · walnut · domino · tumble · haiku

### Letters + number (Xyp9x-style)
kz9 · jex7 · mo2x · v3x · rk1 · tox4 · zen5 · lum8 · dex3 · qx2 · brr4 · fyn6 · yz0 · pk7 · zzt1

### Joke tags (Common only)
xX_n00b_Xx · LagLord · MomSaysBedtime · NoScopeNana · AFKenny · 404skill · ButterFingers · WifiWarrior · SnackBreak · OopsAllMisses

## Nicknames from tags (for casters)
Casters ([[Caster & Commentary]]) shorten or play with tags for flavor:
- Long tags get short forms: `lukmeister` → "Luk", `rafinho` → "Rafa".
- Repeat-letter tags get stretched when hype: `ZeKKo` → "ZEKKOOO!"
- Stored as `ShortName` in the card (generated from the tag).

## Tag origin stories (bio flavor)
The bio line can explain the tag, like real pros' fun name stories:
- "Got the name from a typo in their first account."
- "Named after their cat."
- "It's the sound their old mouse made."
- "Their little brother made it up."
- "It's their name backwards, sort of."
- "Picked it at age 9 and never changed it."
- "From a meme only their friends understand."

## Key players & stars
- Hand-made [[Key Players]] can keep their character names (Rusty, Wraith) or get a natural tag + nickname (e.g. tag `ruzt`, called "Rusty" by casters).
- Named stars in [[Pro Player References]] use tags that copy the **style** of their real counterpart (thud ← donk, cl3an ← s1mple, VyxEe ← ZywOo) but are different words. The near-match block list still applies to them.
