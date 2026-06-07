# Widget v1.1 — License + Likeness Audit (Phase 0 hard gate)

**Generated:** 2026-06-07 · **Pattern (d)** bundled-data widget · source = Musicians BFF (`musicians.jazzlore.com`), read-only.

**Candidate pool: 48** — 13 hand-curated core + 35 deterministic sample from `/api/musicians/polished-ids` (146 ids; sampled by SHA-256(id) ascending, first 35 after de-duping the core).

## Summary: 27 CLEAR · 20 NEEDS-REVIEW · 1 EXCLUDE  (of 48)

- **CLEAR** = public-domain / CC0 / CC-BY (attribution satisfiable on the tap destination) **and** deceased (no living-likeness concern) **and** portrait URL reachable.
- **NEEDS-REVIEW** = CC-BY-SA / GFDL / ambiguous license (share-alike or strict attribution), **or** living / unverified-death musician (commercial-likeness sensitivity on a home-screen surface, even where the license permits editorial use).
- **EXCLUDE** = non-commercial / no-derivatives / all-rights-reserved license, no portrait, or unreachable source URL.

> Attribution model for Pattern (d): the widget face shows **no** inline caption (no room on 2×2). Each portrait's `license` + `attribution` ships in `musicians.json`, and tapping the widget opens the in-app musician page which renders the full attribution caption (the app's existing legal-caption component). CLEAR ratings assume that tap-destination attribution satisfies CC-BY; **CC-BY-SA/GFDL need your explicit confirmation that this is sufficient** (share-alike has stricter obligations) — hence NEEDS-REVIEW, not auto-CLEAR.

## ✅ RESOLVED — Approved pool: 39 musicians (Aurélien, 2026-06-07)

Decisions: **(1)** CC-BY-SA with tap-to-attribution = acceptable → share-alike deceased move to CLEAR. **(2)** Living removed (Herbie Hancock, E Street Band). **(3)** Non-jazz removed (7). **(4)** Bobby Timmons excluded (no portrait in node) — curated-core gap noted for a future sourced image/fallback.

**Removed (9):** Bobby Timmons (no portrait), Herbie Hancock (living), E Street Band (band/living/non-jazz), Jerry Garcia, Billy Preston, Henry Mancini, Bobbie Nelson, Jim Gordon, Q77060 (all non-jazz).

**Curated core (11):** Art Blakey, Bill Evans, Cannonball Adderley, Charles Mingus, John Coltrane, John Lewis, Miles Davis, Sonny Rollins, Thelonious Monk, Wayne Shorter, Wes Montgomery

**Polished surprise (28):** Anthony Jackson, Art Pepper, Art Tatum, Bud Powell, Carla Bley, Cecil Taylor, Earl Hines, Elvin Jones, Freddie Hubbard, Grover Washington, Jr., Jaki Byard, James Booker, Joe Henderson, Lee Konitz, Lee Morse, Michael Brecker, Michael Jones, Natalie Cole, Niels-Henning Ørsted Pedersen, Paul Weston, Ramsey Lewis, Ray Noble, Stan Getz, Tony Williams, Toots Thielemans, Vagif Mustafazadeh, Yusef Lateef, Ziad Rahbani

Machine-readable pool: `docs/widget-pool.json` (consumed by `generate-widget-content.mjs` in Phase 1).

## Decisions needed from Aurélien

1. **CC-BY-SA / GFDL pool** (the bulk of NEEDS-REVIEW): confirm whether tap-to-attribution on the in-app page satisfies share-alike for a home-screen widget, OR restrict the bundled pool to PD/CC0/CC-BY only. This single call resolves most NEEDS-REVIEW rows.
2. **Living musicians** in the sample: keep (editorial/educational use, license permitting) or exclude for likeness caution? (Listed in their own table below.)
3. **Editorial relevance**: the `polished-ids` filter guarantees bio+photo, NOT jazz-fame. Flagged oddities (a band, unresolved-name node, sparse data) are listed under *Editorial flags* — confirm drops.
4. **Final pool composition**: which CLEAR + which approved NEEDS-REVIEW make the shipped rotation pool.

## CLEAR (27)

| Status | Name | Source | ID (wikidata) | Life | License | Attribution | Portrait URL | URL | Notes |
|---|---|---|---|---|---|---|---|---|---|
| CLEAR | Art Blakey | curated | Q311715 | 1919–1990 (deceased) | [CC0](https://creativecommons.org/publicdomain/zero/1.0/) | Fotopersbureau De Boer | [link](https://upload.wikimedia.org/wikipedia/commons/a/ac/Art_Blakey_and_the_Jazz_Messengers_in_the_Kurzaal_Concert_Hall_in_Den_Haag%2C_30.03.1963_-_10.jpg) | 200 |  |
| CLEAR | Cannonball Adderley | curated | Q110477 | 1928–1975 (deceased) | [Public domain](https://creativecommons.org/publicdomain/mark/1.0/) | Unknown photographer | [link](https://upload.wikimedia.org/wikipedia/commons/9/9e/Cannonball_Adderley_press_photo_1966.jpg) | 200 |  |
| CLEAR | John Coltrane | curated | Q7346 | 1926–1967 (deceased) | [CC0](https://creativecommons.org/publicdomain/zero/1.0/) | Gelderen, Hugo van / Anefo | [link](https://upload.wikimedia.org/wikipedia/commons/1/14/John_Coltrane_1963_cropped_ver2.jpg) | 200 |  |
| CLEAR | Miles Davis | curated | Q93341 | 1926–1991 (deceased) | [Public domain](https://creativecommons.org/publicdomain/mark/1.0/) | William P. Gottlieb | [link](https://upload.wikimedia.org/wikipedia/commons/9/94/Miles_Davis_%28Three_Deuces%2C_New_York%2C_N.Y._1947%29.jpg) | 200 |  |
| CLEAR | Thelonious Monk | curated | Q109612 | 1917–1982 (deceased) | [Public domain](https://creativecommons.org/publicdomain/mark/1.0/) | William P. Gottlieb / Adam Cuerden | [link](https://upload.wikimedia.org/wikipedia/commons/9/97/Thelonious_Monk%2C_Minton%27s_Playhouse%2C_New_York%2C_N.Y.%2C_ca._Sept._1947_%28William_P._Gottlieb_06191%29.jpg) | 200 |  |
| CLEAR | Wes Montgomery | curated | Q298601 | 1923–1968 (deceased) | [Public domain](https://creativecommons.org/publicdomain/mark/1.0/) | Verve Records | [link](https://upload.wikimedia.org/wikipedia/commons/a/af/Wes_Montgomery.png) | 200 |  |
| CLEAR | Art Pepper | polished | Q468202 | 1925–1982 (deceased) | [CC BY 2.0](https://creativecommons.org/licenses/by/2.0/) | The original uploader was Mind meal at English W | [link](https://upload.wikimedia.org/wikipedia/commons/9/9e/Art_Pepper.jpg) | 200 |  |
| CLEAR | Art Tatum | polished | Q109053 | 1909–1956 (deceased) | [Public domain](https://creativecommons.org/publicdomain/mark/1.0/) | William P. Gottlieb | [link](https://upload.wikimedia.org/wikipedia/commons/e/ef/Art_Tatum%2C_Vogue_Room_1948_%28Gottlieb%29.jpg) | 206 |  |
| CLEAR | Billy Preston | polished | Q311450 | 1946–2006 (deceased) | [Public domain](https://creativecommons.org/publicdomain/mark/1.0/) | David Hume Kennerly | [link](https://upload.wikimedia.org/wikipedia/commons/8/80/Billy_Preston.jpg) | 206 |  |
| CLEAR | Bobbie Nelson | polished | Q4934650 | 1931–2022 (deceased) | [CC BY 2.0](https://creativecommons.org/licenses/by/2.0/) | Bobbie_Nelson.jpg: ChunkyGlasses
derivative work | [link](https://upload.wikimedia.org/wikipedia/commons/d/d9/Bobbie_Nelson_-_Cropped.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=original) | 206 |  |
| CLEAR | Bud Powell | polished | Q312692 | 1924–1966 (deceased) | [Public domain](https://creativecommons.org/publicdomain/mark/1.0/) | Distributed by the Gale Agency in New York. Phot | [link](https://upload.wikimedia.org/wikipedia/commons/c/c7/Bud_Powell_%281953_publicity_photo_-_cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=original) | 206 |  |
| CLEAR | Carla Bley | polished | Q233721 | 1936–2023 (deceased) | [CC BY 3.0](https://creativecommons.org/licenses/by/3.0/) | Dietmar Liste - http://www.jazzimage.de | [link](https://upload.wikimedia.org/wikipedia/commons/2/21/Carla_Bley_1.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=original) | 200 |  |
| CLEAR | Cecil Taylor | polished | Q363908 | 1929–2018 (deceased) | [CC BY 3.0](https://creativecommons.org/licenses/by/3.0/) | nomo/michael hoefner 

http://www.zwo5.de | [link](https://upload.wikimedia.org/wikipedia/commons/f/f1/Cecil_taylor_E5122329-2.jpg) | 206 |  |
| CLEAR | Earl Hines | polished | Q354883 | 1903–1983 (deceased) | [Public domain](https://creativecommons.org/publicdomain/mark/1.0/) | Unknown authorUnknown author or not provided | [link](https://upload.wikimedia.org/wikipedia/commons/d/d2/%22Earl_%60Father%27_%28Fatha%29_Hines%2C_a_great_swing_musician%2C_is_shown_with_Pvt._Charles_Carpenter%2C_former_manager_of_the_Hines_-_NARA_-_535834.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=original) | 206 |  |
| CLEAR | Henry Mancini | polished | Q185928 | 1924–1994 (deceased) | [Public domain](https://creativecommons.org/publicdomain/mark/1.0/) | RCA Records | [link](https://upload.wikimedia.org/wikipedia/commons/e/ed/Henry_Mancini.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=original) | 200 |  |
| CLEAR | Jerry Garcia | polished | Q312870 | 1942–1995 (deceased) | [CC BY 2.0](https://creativecommons.org/licenses/by/2.0/) | Carl Lender | [link](https://upload.wikimedia.org/wikipedia/commons/c/c0/Jerry-Garcia-01cropped.jpg) | 200 |  |
| CLEAR | Jim Gordon | polished | Q1334162 | 1945–2023 (deceased) | [Public domain](https://creativecommons.org/publicdomain/mark/1.0/) | Atco Records | [link](https://upload.wikimedia.org/wikipedia/commons/7/78/Derek_and_the_Dominos.png) | 206 |  |
| CLEAR | Joe Henderson | polished | Q506006 | 1937–2001 (deceased) | [CC BY 2.0](https://creativecommons.org/licenses/by/2.0/) | Guy MacPherson | [link](https://upload.wikimedia.org/wikipedia/commons/5/5f/Joe_Henderson_2.jpg) | 200 |  |
| CLEAR | Lee Morse | polished | Q3829380 | 1897–1954 (deceased) | [Public domain](https://creativecommons.org/publicdomain/mark/1.0/) | Unknown authorUnknown author | [link](https://upload.wikimedia.org/wikipedia/commons/e/e4/Leemorse_03.jpg) | 206 |  |
| CLEAR | Michael Brecker | polished | Q347023 | 1949–2007 (deceased) | [Public domain](https://creativecommons.org/publicdomain/mark/1.0/) | Sven.petersen | [link](https://upload.wikimedia.org/wikipedia/commons/e/ea/Michael_Brecker_Munich_2001.JPG) | 206 |  |
| CLEAR | Niels-Henning Ørsted Pedersen | polished | Q520796 | 1946–2005 (deceased) | [Public domain](https://creativecommons.org/publicdomain/mark/1.0/) | Björn Milcke | [link](https://upload.wikimedia.org/wikipedia/commons/f/fa/NH%C3%98P.jpg) | 206 |  |
| CLEAR | Paul Weston | polished | Q1765101 | 1912–1996 (deceased) | [Public domain](https://creativecommons.org/publicdomain/mark/1.0/) | Publicity still-Capitol Records. | [link](https://upload.wikimedia.org/wikipedia/commons/d/d6/Paul_weston_capitol_1940s.jpg) | 206 |  |
| CLEAR | Q77060 | polished | Q77060 | 1925–2012 (deceased) | [Public domain](https://creativecommons.org/publicdomain/mark/1.0/) | — | [link](https://upload.wikimedia.org/wikipedia/commons/c/cc/Dietrich_Fischer-Dieskau_-_Buste%2C_face_-_Baryton_allemand_-_btv1b10219465v.jpg) | 206 |  |
| CLEAR | Ramsey Lewis | polished | Q1936300 | 1935–2022 (deceased) | [CC BY 2.0](https://creativecommons.org/licenses/by/2.0/) | Tomas Forgac Bratislava, Slovakia | [link](https://upload.wikimedia.org/wikipedia/commons/0/02/Ramsey_Lewis.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=original) | 206 |  |
| CLEAR | Ray Noble | polished | Q953019 | 1903–1978 (deceased) | [Public domain](https://creativecommons.org/publicdomain/mark/1.0/) | Unknown authorUnknown author | [link](https://upload.wikimedia.org/wikipedia/commons/e/e5/Ray_Noble_1935bw.jpg) | 206 |  |
| CLEAR | Stan Getz | polished | Q30587 | 1927–1991 (deceased) | [CC0](https://creativecommons.org/publicdomain/zero/1.0/) | Geir | [link](https://upload.wikimedia.org/wikipedia/commons/f/ff/Getz%26BakerSandvika1983a.jpg) | 200 |  |
| CLEAR | Toots Thielemans | polished | Q365567 | 1922–2016 (deceased) | [CC BY 2.5](https://creativecommons.org/licenses/by/2.5/) | Ron van der Kolk | [link](https://upload.wikimedia.org/wikipedia/commons/b/ba/Toots_thielemans.jpg) | 200 |  |

## NEEDS-REVIEW (20)

| Status | Name | Source | ID (wikidata) | Life | License | Attribution | Portrait URL | URL | Notes |
|---|---|---|---|---|---|---|---|---|---|
| NEEDS-REVIEW | Bill Evans | curated | Q208205 | 1929–1980 (deceased) | [CC BY-SA 3.0](https://creativecommons.org/licenses/by-sa/3.0/) | Brianmcmillen | [link](https://upload.wikimedia.org/wikipedia/commons/c/c8/Bill_Evans.jpg) | 200 | share-alike / strict-attribution — confirm tap-destination attribution satisfies it |
| NEEDS-REVIEW | Charles Mingus | curated | Q107432 | 1922–1979 (deceased) | [CC BY-SA 2.0](https://creativecommons.org/licenses/by-sa/2.0/) | Tom Marcello Webster, New York, USA | [link](https://upload.wikimedia.org/wikipedia/commons/0/0a/Charles_Mingus_1976.jpg) | 200 | share-alike / strict-attribution — confirm tap-destination attribution satisfies it |
| NEEDS-REVIEW | Herbie Hancock | curated | Q105875 | b. 1940 (no death yr — **verify**) | [CC BY 2.0](https://creativecommons.org/licenses/by/2.0/) | pixgremlin: http://www.aworan.com c/o Pix Gremli | [link](https://upload.wikimedia.org/wikipedia/commons/a/aa/Herbie_Hancock.jpg) | 200 | no deathYear in node — verify living/deceased; living / unverified-death — likeness review for home-screen surface |
| NEEDS-REVIEW | John Lewis | curated | Q353943 | 1920–2001 (deceased) | [CC BY-SA 3.0 nl](https://creativecommons.org/licenses/by-sa/3.0/) | Bert Verhoeff for Anefo | [link](https://upload.wikimedia.org/wikipedia/commons/f/f0/John_Lewis_1977.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=original) | 200 | share-alike / strict-attribution — confirm tap-destination attribution satisfies it |
| NEEDS-REVIEW | Sonny Rollins | curated | Q299208 | 1930–2026 (deceased) | [CC BY-SA 3.0](https://creativecommons.org/licenses/by-sa/3.0/) | Brianmcmillen at English Wikipedia | [link](https://upload.wikimedia.org/wikipedia/commons/8/85/SonnyRollins.jpg) | 200 | share-alike / strict-attribution — confirm tap-destination attribution satisfies it |
| NEEDS-REVIEW | Wayne Shorter | curated | Q317161 | 1933–2023 (deceased) | [CC BY-SA 2.0](https://creativecommons.org/licenses/by-sa/2.0/) | Jean-Luc | [link](https://upload.wikimedia.org/wikipedia/commons/8/82/Weather_Report_%28Wayne_Shorter%29.jpg) | 200 | share-alike / strict-attribution — confirm tap-destination attribution satisfies it |
| NEEDS-REVIEW | Anthony Jackson | polished | Q570001 | 1952–2025 (deceased) | [CC BY-SA 2.0](https://creativecommons.org/licenses/by-sa/2.0/) | Art Bromage from Seattle | [link](https://upload.wikimedia.org/wikipedia/commons/d/dc/Anthony_Jackson.jpg) | 206 | share-alike / strict-attribution — confirm tap-destination attribution satisfies it |
| NEEDS-REVIEW | E Street Band | polished | Q1276681 | **no birth/death data** | [CC BY-SA 2.0](https://creativecommons.org/licenses/by-sa/2.0/) | Manuel Martinez Perez | [link](https://upload.wikimedia.org/wikipedia/commons/6/63/E_Street_Band_2009.jpg) | 206 | NO birth/death data (likely a band/group or sparse node); share-alike / strict-attribution — confirm tap-destination attribution satisfies it; living / unverified-death — likeness review for home-screen surface |
| NEEDS-REVIEW | Elvin Jones | polished | Q357179 | 1927–2004 (deceased) | [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/) | Thomas Huther | [link](https://upload.wikimedia.org/wikipedia/commons/9/91/Elvin_Jones_1979_3.jpg) | 200 | share-alike / strict-attribution — confirm tap-destination attribution satisfies it |
| NEEDS-REVIEW | Freddie Hubbard | polished | Q346762 | 1938–2008 (deceased) | [CC BY-SA 2.0](https://creativecommons.org/licenses/by-sa/2.0/) | Tom Marcello Webster, New York, USA | [link](https://upload.wikimedia.org/wikipedia/commons/7/7c/Freddie_Hubbard_1976.jpg) | 200 | share-alike / strict-attribution — confirm tap-destination attribution satisfies it |
| NEEDS-REVIEW | Grover Washington, Jr. | polished | Q463678 | 1943–1999 (deceased) | [CC BY-SA 2.0](https://creativecommons.org/licenses/by-sa/2.0/) | Kingkongphoto &amp; www.celebrity-photos.com fro | [link](https://upload.wikimedia.org/wikipedia/commons/d/db/Grover_Washington_1995.jpg) | 206 | share-alike / strict-attribution — confirm tap-destination attribution satisfies it |
| NEEDS-REVIEW | Jaki Byard | polished | Q1346401 | 1922–1999 (deceased) | [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/) | Brianmcmillen | [link](https://upload.wikimedia.org/wikipedia/commons/3/39/Jaki_Byard_1979.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=original) | 200 | share-alike / strict-attribution — confirm tap-destination attribution satisfies it |
| NEEDS-REVIEW | James Booker | polished | Q1233935 | 1939–1983 (deceased) | [CC BY-SA 3.0](https://creativecommons.org/licenses/by-sa/3.0/) | Lionel decoster | [link](https://upload.wikimedia.org/wikipedia/commons/6/62/James_Booker.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=original) | 200 | share-alike / strict-attribution — confirm tap-destination attribution satisfies it |
| NEEDS-REVIEW | Lee Konitz | polished | Q453393 | 1927–2020 (deceased) | [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/) | Schorle | [link](https://upload.wikimedia.org/wikipedia/commons/1/1a/Lee_Konitz_Bad_Mergentheim.JPG) | 200 | share-alike / strict-attribution — confirm tap-destination attribution satisfies it |
| NEEDS-REVIEW | Michael Jones | polished | Q2918931 | 1942–2022 (deceased) | [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/) | Brian F Colgate | [link](https://upload.wikimedia.org/wikipedia/commons/8/8a/Michael_Jones_portrait_by_V_Tony_Hauser.png?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=original) | 206 | share-alike / strict-attribution — confirm tap-destination attribution satisfies it |
| NEEDS-REVIEW | Natalie Cole | polished | Q231942 | 1950–2015 (deceased) | [CC BY-SA 2.0](https://creativecommons.org/licenses/by-sa/2.0/) | John Mathew Smith &amp; www.celebrity-photos.com | [link](https://upload.wikimedia.org/wikipedia/commons/1/17/NATALIE_COLE.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=original) | 200 | share-alike / strict-attribution — confirm tap-destination attribution satisfies it |
| NEEDS-REVIEW | Tony Williams | polished | Q453604 | 1945–1997 (deceased) | [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/) | Brianmcmillen | [link](https://upload.wikimedia.org/wikipedia/commons/2/25/Tony_Williams1.jpg) | 200 | share-alike / strict-attribution — confirm tap-destination attribution satisfies it |
| NEEDS-REVIEW | Vagif Mustafazadeh | polished | Q935982 | 1940–1979 (deceased) | [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/) | Eldar Mansurov | [link](https://upload.wikimedia.org/wikipedia/commons/0/01/Vaqif_Mustafazad%C9%99.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=original) | 206 | share-alike / strict-attribution — confirm tap-destination attribution satisfies it |
| NEEDS-REVIEW | Yusef Lateef | polished | Q539832 | 1920–2013 (deceased) | [CC BY-SA 2.0](https://creativecommons.org/licenses/by-sa/2.0/) | Tom Beetz | [link](https://upload.wikimedia.org/wikipedia/commons/f/f9/Yusef_Lateef.jpg) | 200 | share-alike / strict-attribution — confirm tap-destination attribution satisfies it |
| NEEDS-REVIEW | Ziad Rahbani | polished | Q3575465 | 1955–2025 (deceased) | [CC BY-SA 3.0](https://creativecommons.org/licenses/by-sa/3.0/) | Novalib2 | [link](https://upload.wikimedia.org/wikipedia/commons/d/da/Ziad_rahbani_2001.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=original) | 200 | share-alike / strict-attribution — confirm tap-destination attribution satisfies it |

## EXCLUDE (1)

| Status | Name | Source | ID (wikidata) | Life | License | Attribution | Portrait URL | URL | Notes |
|---|---|---|---|---|---|---|---|---|---|
| EXCLUDE | Bobby Timmons | curated | Q132341 | 1935–1974 (deceased) | — | — | — | empty | license string absent/unrecognized; no portrait URL on node |

## Living / unverified-death musicians (likeness sub-decision)

These passed license + URL checks but are flagged NEEDS-REVIEW purely for living-likeness. `no death yr` may also be a data gap on a long-dead figure — verify before excluding.

| Name | ID | Birth | License | Decision (Aurélien) |
|---|---|---|---|---|
| Herbie Hancock | Q105875 | 1940 | CC-BY | _____ |
| E Street Band | Q1276681 | — | CC-BY-SA | _____ |

## Editorial flags (relevance / structural — confirm drops)

Not license/likeness issues — flagged because `polished-ids` is a bio+photo filter, **not** a jazz-fame filter. **7 of 35 sampled candidates have no jazz-family genre** (checked against each node's `genres`: jazz/bebop/bop/swing/fusion/ragtime/dixieland). This is the strongest argument for either (a) adding a jazz-genre guardrail to `generate-widget-content.mjs`, or (b) switching the surprise tier from random-sampled to a hand-picked allowlist (§3.1 decision #3).

| Name | ID | Source | Status | Genres (first 4) | Flag |
|---|---|---|---|---|---|
| Billy Preston | wikidata:Q311450 | polished | CLEAR | gospel music, blues, soul, funk | **no jazz genre** — primarily gospel music, blues, soul |
| Bobbie Nelson | wikidata:Q4934650 | polished | CLEAR | country music, gospel, southern gospel | **no jazz genre** — primarily country music, gospel, southern gospel |
| Henry Mancini | wikidata:Q185928 | polished | CLEAR | comedy, easy listening, lounge music, melodrama | **no jazz genre** — primarily comedy, easy listening, lounge music |
| Jerry Garcia | wikidata:Q312870 | polished | CLEAR | folk rock, bluegrass music, progressive rock, psychedelic rock | **no jazz genre** — primarily folk rock, bluegrass music, progressive rock |
| Jim Gordon | wikidata:Q1334162 | polished | CLEAR | blues, blues rock, hard rock, psychedelic rock | **no jazz genre** — primarily blues, blues rock, hard rock |
| Q77060 | wikidata:Q77060 | polished | CLEAR | baritone, classical, german baritone | name unresolved (renders as raw Q-id); **no jazz genre** — primarily baritone, classical, german baritone |
| E Street Band | wikidata:Q1276681 | polished | NEEDS-REVIEW | rock music, progressive rock, heartland rock, pop rock | no birth/death data (band/group or sparse node); **no jazz genre** — primarily rock music, progressive rock, heartland rock |

## Methodology

- **Pool**: 13 curated ids (`apps/musicians/src/data/curated.ts`) + deterministic SHA-256 sample of 35 from the 146 `polished-ids` (sorted by `sha256(id)` hex ascending, first 35 after removing any that overlap the core). Reproducible: same inputs → same 35.
- **Hydration**: `GET /api/musicians/<id>` per candidate (name, `portrait.{url,license,attribution}`, `birthYear`, `deathYear`, `primaryInstruments`, wikidata/musicbrainz ids). 0 fetch errors across 48.
- **License URL** is derived from the license string (CC deed for the matched type+version); the node stores a license *string* + attribution *string*, not a deed URL or the Wikimedia file-page URL. The **Portrait URL** column is the direct image URL (`portrait.url`) — the canonical attribution page (Wikimedia file page) is not stored in the node.
- **URL liveness**: HTTP HEAD/GET (range) with a descriptive User-Agent. First pass rate-limited (HTTP 429) on 19 Wikimedia URLs — **re-checked politely with spacing**; all 19 returned 200/206 (alive). No URL is actually dead.
- **Living/deceased**: `deathYear` present → deceased; absent → living **or** a data gap (flagged `verify`).

## Sampled ids (reproducibility record)

```
wikidata:Q453393
wikidata:Q1346401
wikidata:Q312870
wikidata:Q233721
wikidata:Q231942
wikidata:Q347023
wikidata:Q311450
wikidata:Q1765101
wikidata:Q2918931
wikidata:Q77060
wikidata:Q463678
wikidata:Q109053
wikidata:Q539832
wikidata:Q3575465
wikidata:Q185928
wikidata:Q570001
wikidata:Q1233935
wikidata:Q4934650
wikidata:Q1936300
wikidata:Q953019
wikidata:Q365567
wikidata:Q3829380
wikidata:Q468202
wikidata:Q354883
wikidata:Q506006
wikidata:Q1276681
wikidata:Q520796
wikidata:Q453604
wikidata:Q363908
wikidata:Q357179
wikidata:Q312692
wikidata:Q30587
wikidata:Q346762
wikidata:Q935982
wikidata:Q1334162
```
