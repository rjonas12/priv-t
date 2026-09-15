**Egy LLM anatómiája – Application to our system**

## 0. Mit vetítünk le, és mi az alaptézis

A Theory tizenkét szerkezeti gátat sorol, az Experimental study hét kísérletben hetet
közülük meg is mért. Ez a dokumentum azt nézi meg, mit jelentenek ezek a QCP-re:
az Epicre, a Model Manufaktúrára, a Model Poolra, a Katalógus sémára és az
agent-orkesztrációra.

Az alaptézis végig ugyanaz: **egyik gát sem szűnik meg promptolással, mert mind
egy konkrét szerkezeti elemből következik.** Amit a rendszertervezés tehet, az nem
a gát megszüntetése, hanem az, hogy a gátat olyan helyre tereli, ahol olcsó, és
olyan helyről kitiltja, ahol drága. A QCP még a modellezési fázisban van, ezért az
alábbiak jórészt tervezési kérdések és javaslatok, nem megállapítások a meglévő
rendszerről.

Egy keret, ami a többit rendezi. A mérések három csoportba esnek:

- **Kapacitás** (E1, E2): mennyi fér be, mennyibe kerül, hány agent futhat egyszerre.
- **Megbízhatóság** (E3, E5, E7): mit hisz el a modell, mit talál ki, mit nem vesz észre.
- **Elszámoltathatóság** (E4, E6): mit tudunk utólag bizonyítani arról, ami történt.

Jegybanki környezetben a harmadik csoport a legkevésbé alkudható.

---

## 1. A nyelvi határ

**Mérési alap:** E1. A magyar szorzó 1,86–3,01 azonos tartalomra; a `tok/kar` érték
angolon gyakorlatilag konstans (0,180–0,193), magyaron 0,350–0,534.

Eldőlt, hogy a rendszer angolul működik, a promptok angolok lesznek — magyar
forrásdokumentumok viszont biztosan lesznek. Ez a döntés **kevesebbet változtat a
token-ökonómián, mint amennyit sugall.** Egy hívás bemenetének 80–90%-a a behúzott
dokumentumokban van, nem a promptban; ha azok magyarul maradnak, a szorzó a domináns
tagon marad rajta.

Az igazi tervezési kérdés tehát nem a prompt nyelve, hanem hogy **hol fordul a magyar
dokumentum, ha fordul**:

| Változat | Token-költség | Modell-megértés | Auditálhatóság |
|---|---|---|---|
| Beömléskor egyszer fordul | egyszeri, indexeléskor | jobb (G12) | gyenge — a lánc a fordítást látja |
| Magyarul marad az indexben | lekérdezésenként fizetve | gyengébb | erős — az eredetire mutat |
| Mindkettő tárolva | egyszeri + tárhely | jobb | erős |

A harmadik változat mellett két érv szól, és mindkettő a Theory-ból jön:

**G8 az indexben.** Egy félrefordított jogszabályi vagy jegybanki szakkifejezés nem
egy válaszban jelenik meg, hanem beleég az indexbe, és onnantól minden rá épülő
válaszban ott van. A rossz prompt egy választ ront el; a rossz fordítás az összeset.
Az E7 megmutatta, hogy a modell a hibás premisszát nem felismeri, hanem
racionalizálja — ha az index hordozza a hibát, a lánc végig fog rá építeni.

**Auditálhatóság.** Egy MNB-válasznak a magyar eredetire kell visszamutatnia, nem
annak gépi fordítására. Ha a lánc csak a fordítást látta, a hivatkozás forrása egy
olyan szöveg, amit soha senki nem hagyott jóvá.

**Javaslat:** angol fordítás a retrievalhez és a következtetéshez, a magyar eredeti
megőrizve és hivatkozva mint forrás. Ez tárhelybe kerül, nem tokenbe. A fordítási
lépés maga viszont **validálandó komponens**, nem infrastruktúra: jegybanki
terminológiai szótár, és emberi jóváhagyás azokra a kifejezésekre, amik a
Katalógus sémában is szerepelnek.

Egy szám, amit érdemes megmérni, mielőtt ez eldől: az E1 cellája kész, csak a
korpuszt kell kicserélni egy valódi MNB-dokumentumra. A 631 karakteren mért
szorzó iránya biztos, a második tizedesjegye nem.

---

## 2. Az Epic — a kérdésfordítás

**Mérési alap:** E7 (a hibás premissza racionalizálása), E5 (kalibráció), E4
(a döntés helye nem függ a nehézségtől).

Az Epic fordítja a vezetői kérdést kvantitatív problémává, és kezeli a
szabadságfokokat. A mérések szerint ez **a lánc legkockázatosabb pontja**, és nem
azért, mert nehéz, hanem a G8 miatt: ami itt eldől, azt semmi nem vonja vissza.

Az E7 három érvényes esetében a modell egyszer sem ismerte fel, hogy hibás
premisszán dolgozik. Ehelyett **alátámasztotta**: Berlinről igaz állításokat
sorolt fel, hogy a hamis mondat hitelesnek látsszon; a „kamatemelés csökkenő
infláció miatt" állításhoz indoklást talált ki kifogástalan jegybanki
regiszterben; a 100 °F-hez pedig egy második hamis állítást gyártott
(„or 0 degrees Celsius"), hogy az első konzisztens legyen.

Agent-láncban lefordítva: **ha az Epic félreérti a kérdést, a lánc többi tagja
hibátlan munkát fog végezni a rossz kérdésen.** A Manufaktúra jó modellt fog
összeállítani, a Model Pool jó futtatást ad, a végén jó minőségű válasz születik —
egy olyan kérdésre, amit senki nem tett fel. És mivel a minőség végig magas, semmi
nem fogja jelezni a hibát.

Ebből három tervezési következmény jön:

**A legerősebb kapu a lánc elejére.** Ez nem költséghatékony, mert az Epic a
legolcsóbb lépés, és mégis oda kell a legtöbb ellenőrzés. De az E7 szerint a
későbbi lépések nem javítják a korábbi hibát, hanem ráépítenek.

**Visszakérdezés a kérdésértelmezésnél, nem a válaszadásnál.** Az Epicnek explicit
módon vissza kell adnia, hogyan értette a kérdést, milyen szabadságfokokat rögzített
és melyeket hagyott nyitva — és ezt embernek kell jóváhagynia, mielőtt a lánc
elindul. Ez nem udvariassági kör: ez az egyetlen pont, ahol a hiba még olcsó.

**A visszakérdezés nem bízható a modell magabiztosságára.** Az E5 megmutatta,
miért: a kitalált jegybankról a modell p = 0,782-vel és 1,73 bit entrópiával
nyilatkozott — magabiztosabban, mint Párizsról (p = 0,275; 4,51 bit). A
token-entrópia a **formátum** megjósolhatóságát méri, nem a tényét. Egy „kérdezz
vissza, ha bizonytalan vagy" szabály tehát pont ott nem fog megszólalni, ahol
kellene. A visszakérdezést szerkezetileg kell kikényszeríteni (minden kérdés
értelmezése megy jóváhagyásra), nem bizonytalansági küszöbbel.

---

## 3. Model Manufaktúra — összeállítás és validáció

**Mérési alap:** E7 (helyes következtetés érvénytelen levezetéssel), E5
(hallucináció szakmai regiszterben), G5, G11.

Az E7 negyedik esete a Manufaktúra szempontjából a legfontosabb eredmény az egész
notebookban. A modell a beinjektált „Europe is the largest continent" premisszát
ellenőrzendő állítássá fordította, és **helyesen „False"-ra jutott** — de:

- kétszer sorolta fel Észak-Amerikát, és kihagyta Ausztráliát,
- az indoklása („Europe is located in the western part of the world") a méretről
  semmit nem mond,
- a helyes válasz egyetlen memorizált tényből jött („The largest continent is
  Asia"), nem az elemzésből.

**Helyes következtetés, érvénytelen levezetés.** Egy értékelő, ami a következtetést
nézi, ezt átengedi. Egy értékelő, ami a láncot nézi, elbuktatja. És ugyanez a
sablon, más memorizált ténnyel vagy anélkül, ugyanilyen tekintélyesen kinéző
lépésekkel magabiztosan rossz következtetésre jutna.

Ez közvetlenül érinti a validációs piramist:

**Az oracle és a numerikus teszt nem helyettesíthető judge-dzsal.** A judge a
kimenetet látja, és a kimenet — ahogy az E5 és E7 mutatja — fluens akkor is, ha a
tartalom hamis. Ahol van determinisztikus ellenőrzés (pylab, séma-validálás,
numerikus egyezés), ott annak **meg kell előznie** a modellalapú értékelést, nem
kiegészítenie.

**A judge a láncot értékelje, ne a konklúziót.** Az E7 negyedik esete pontosan azt
mutatja, hogy a kettő szétválhat. Ha a judge prompt úgy szól, hogy „helyes-e a
válasz", akkor az érvénytelen levezetésű helyes válasz átmegy — és vele átmegy a
sablon, ami legközelebb rosszat fog adni.

**A judge ne ugyanaz a modell legyen, ami a választ adta** (G11). A
preferenciahangolás egyetértésre hajlít; az önértékelés rendszeres torzítás, nem
független ellenőrzés.

**A G4 megkerülése felülvizsgálandó.** A Theory a G4-hez azt írja: „levezetés
kiíratása, lépésekre bontás". Az E7 megmutatta, hogy a **kiírt levezetés nem
bizonyítéka a valódi levezetésnek** — a látható gondolatmenet a formátum
renderelése. Ez nem teszi értéktelenné a chain-of-thought-ot (a lépésekre bontás
tényleg több számítást enged tokenekben), de azt jelenti, hogy **a levezetés
olvashatósága nem ellenőrzés.** Az ellenőrzés az, ha a levezetés lépéseit
determinisztikus eszköz újraszámolja.

---

## 4. Model Pool és Katalógus séma — az állapot a hálón kívül

**Mérési alap:** G3, G10, E2 (tied embedding, elosztott reprezentáció), E5
(kitalált intézmény).

A Theory G3-as gátja szerint a súlyok fagyottak: nincs perzisztens emlékezet, a
tudás veszteséges tömörítés, nem lekérdezhető adatbázis. A G10 ezt kiegészíti: a
tudás **nem lokalizálható** — nem mutatható meg, hol van egy tény, és nem javítható
sebészi pontossággal.

Ez a Katalógus séma és a Model Pool létjogosultsága, és egyben a határaik kijelölése:

**Minden, aminek igaznak kell lennie, a hálón kívül él.** Modellverziók,
paraméterek, adatdefiníciók, terminológia, a futtatások eredményei. A modell dolga
a **kiválasztás**, nem a tárolás.

**A modell által „ismert" tény nem forrás.** Az E5 a legélesebb példa: a nem létező
Zarbonia jegybankjáról a modell kifogástalan szakmai regiszterben közölt egy
kitalált inflációs célt („set its inflation target at 3%"). A 3% azért hihető, mert
a modell a valódi jegybankok eloszlásából mintavételez — nem tényt idéz fel, hanem
**eloszlásból generál, és az eredmény pont ezért hihető.** Cseréld „Zarboniát"
„Hungary"-re és az évszámot a tudáshatáron túlira: ugyanezt a mondatot kapod,
ugyanilyen magabiztosan, és semmi nem jelzi, hogy kitalált.

Gyakorlati szabály ebből: **a láncban keletkező minden szám, dátum és intézménynév
vagy a Katalógus sémából jön, vagy determinisztikus eszköz számolta, vagy
megjelölendő mint nem hitelesített.** Harmadik lehetőség nincs. Ha egy agent
kimenetében olyan érték szerepel, aminek nincs forrása a Poolban vagy a Katalógusban,
az önmagában hiba, függetlenül attól, hogy helyesnek látszik-e.

**Az auditálhatóság a hálón kívül épül.** A G10 miatt a „miért ezt válaszolta" nem
olvasható ki a súlyokból. Ami kiolvasható: a behúzott dokumentumok, az eszközhívások
naplója, a Katalógusból vett értékek, és a tárolt válasz. A modell auditálható
felülete a be- és kimenet, nem a belseje.

---

## 5. Agentek és orkesztráció — a kapacitáskorlát

**Mérési alap:** E2 (KV cache, párhuzamos láncok), E4 (fix mélység), G2, G4.

Az E2 két olyan számot adott, ami közvetlenül orkesztrációs tervezési paraméter.

**A cache-költség önálló tengely.** A KV cache tokenenkénti mérete
`2 · L · H_kv · d_head`, és **nem korrelál a paraméterszámmal**: a Gemma-2-2B
104 kB/token, a háromszor nagyobb Qwen2.5-7B csak 56. Aki „kisebb modellt választok,
hogy több agent férjen el" alapon dönt, könnyen kevesebbet kap. Modellválasztásnál
a cache/token a paraméterszámmal **egyenrangú** kritérium, és a modellkártyák nem
írják ki.

**A párhuzamosság kiszámítható, és szűkebb, mint várnánk:**

| Modell | 24 GB / 8k | 24 GB / 32k | 80 GB / 8k | 80 GB / 32k |
|---|---|---|---|---|
| Qwen2.5-0.5B | 234 | 58 | 803 | 200 |
| Llama-3.2-1B | 82 | 20 | 295 | 73 |
| Gemma-2-2B | 22 | 5 | 87 | 21 |
| Qwen2.5-7B | 19 | 4 | 141 | 35 |

(Felső becslés, aktivációk nélkül; valósban 60–80%.) A kontextushossz **pontosan
fordítottan arányos** a láncszámmal: 8k → 32k negyedeli.

**Egy félreértés, amit előre tisztázni kell.** A cache lineáris az **összes rezidens
tokenben**. Négy darab 8k-s atomic agent ugyanannyi memóriát eszik, mint egy 32k-s
lánc — a felbontás önmagában nem spórol. A nyereség abból jön, hogy egy atomic
agentnek **nem kell** az egész előzmény: pointer-alapú memóriával, fázishatáron
végzett kompaktálással jóval kevesebbet tart bent. Vagyis nem a darabolás olcsó,
hanem az, hogy a darabolás lehetővé teszi a kevesebb rezidens tokent. Ha az atomic
agentek mindegyike megkapja a teljes kontextust, a felbontásból nulla memória-előny
származik.

**A G4 költségoldala.** Az E4 megmutatta, hogy mindkét prompt pontosan ugyanannyi
réteget futott, és ugyanabban a 22. rétegben dőlt el — a döntési pont
architekturális, nem a kérdés nehézségétől függ. A modell **nem tud többet
gondolkodni** a nehezebb kérdésen; csak gyengébb választ ad. „Több gondolkodás"
kizárólag több tokenként létezik: levezetés kiíratása, lépésekre bontás, több körös
orkesztráció — és mindegyik token-, idő- és költségtétel, plusz mindegyik növeli a
rezidens tokenek számát, tehát csökkenti a párhuzamosságot.

Ez konkrét trade-off: a fenti tábla azt mondja, hogy egy 32k-s, sok lépéses
gondolkodó lánc négyszer kevesebb példányban fut, mint ugyanaz 8k-val. Egy
agent-rendszer kapacitásterve nem a modell méretéből, hanem a **kontextus-higiénéből**
jön ki.

---

## 6. Kiszolgálás és reprodukálhatóság

**Mérési alap:** E6 (CPU vs GPU), E5 (dekódolási paraméterek), G7.

Az E6 a legfontosabb eredmény jegybanki szempontból, mert **auditkérdést érint**.

Ugyanaz a prompt, ugyanaz a modell, ugyanazok a dekódolási paraméterek. Egyszálas
CPU-n a logitok **bitre azonosak** batch-összeállítástól függetlenül. T4 GPU-n
viszont **0,018–0,043 logitkülönbség** jelenik meg pusztán attól, hány másik
szekvencia van a batchben. És ez nem elméleti: 183 pozíción **egy argmax-váltás**
következett be (0,55%); a rés-eloszlás 1%-os kvantilise 0,044, vagyis a pozíciók
kb. 1%-ánál a döntési rés a zaj alatt van.

Az eltérés **nem monoton** a batch-mérettel (0,035 → 0,043 → 0,027), ami
kernel-stratégiaváltásra utal, nem hibahalmozódásra. Tehát **nincs „biztonságos"
batchméret**, amivel a hibát korlátozni lehetne.

G8-cal együtt: **egyetlen átfordult token az egész további választ átírja.**

Ebből a Theory G7-es megkerülési oszlopának átértékelése jön. Az három dolgot
sorol — rögzített modellverzió, rögzített dekódolási paraméterek, teljes hívásnapló
—, és a mérés megmutatta, hogy **ezek nem egyenrangúak.** Az első kettő adott volt,
és mégis átfordult egy token. Batchelt kiszolgálásban nem mi választjuk a
batch-szomszédainkat, tehát a bitre reprodukálhatóság **szerkezetileg nem
elérhető.**

**Következmények:**

- Auditálható nyom csak a **tárolt válasz**. A „futtasd újra és nézd meg" nem
  válasz egy felügyeleti kérdésre. A hívásnapló nem kiegészítő, hanem az egyetlen
  bizonyíték.
- A dekódolási paramétereket akkor is rögzíteni kell, ha nem adnak
  reprodukálhatóságot — az E5 megmutatta, hogy `top_p = 0,9` **önmagában semmit
  nem korlátoz**: T = 1,0-nál 25 token a nucleus, T = 1,5-nél 4 692, T = 2,0-nál
  41 555, vagyis a teljes szótár ~3%-a. A temperature és a top-p csak együtt
  értelmes.
- Ahol bitre azonos újrajátszásra van szükség (pl. egy vitatott döntés
  rekonstrukciója), ott **dedikált, batch=1 futtatás** kell, saját hardveren.
  Ez drága, tehát nem lehet alapeset — de kell, hogy legyen rá út.
- A célhardveren **mérni kell**, nem feltételezni. Az E6 cellái ehhez készek;
  más GPU, más kernelverzió, más kiszolgáló (vLLM vs HF) más eredményt adhat.

---

## 7. Nyelvi és adateloszlási kockázat

**Mérési alap:** E1, E4 (a gyenge tény küszöb alatt marad), G12.

A G12 szerint a kompetencia a tanítóadat lefedettségét követi — és ez **nem azonos
a tudáshatárral**. A határon *belül* is egyenetlen: a magyar makrogazdasági és
jegybanki korpusz vékony az angol pénzügyihez képest.

Az E4 megmutatta, hogyan néz ki ez működés közben. A ritka tény (Ouagadougou)
**ott volt** a modellben — a 24. rétegben az 5. helyen, p = 0,042 —, de a kimenet
mégis egy szintaktikai kitérő lett (`' located'`), mert az valószínűbb volt. Nem
azért, mert a modell hezitált: nincs mivel. A gyenge tényt egyszerűen legyőzte a
sablonos folytatás.

Jegybanki kontextusra fordítva: **a hazai intézményi tudás pont az a fajta gyenge
tény, ami küszöb alatt marad.** A modell nem fogja jelezni, hogy bizonytalan —
folyékonyan ír valami mást. Ezért a hazai domain-anyag helye a **retrievalben van,
nem a promptban**, és nem a modell „ismereteire" hagyatkozva.

Két mérés, ami ezt számmá tenné, és amit érdemes megcsinálni a rendszer beélesítése
előtt:

- **E1b** (beparkolva): egy magyar dokumentum token-költsége lefordítva vs
  eredetiben, plusz a magyar tulajdonnevek költsége angol szövegben („Monetáris
  Tanács" 6–7 token, „Magyar Nemzeti Bank" 4–8, akármilyen nyelvű a környezet).
  Ez adná a számot az 1. pont három változata közti döntéshez.
- **E9** (opcionális): ugyanaz a tartalom két nyelven, karakterre normált
  (bits-per-character) perplexitás. Ez mérné meg, mennyivel gyengébb a modell
  magyarul — nyers perplexitást nyelvek közt nem lehet összevetni, mert más a
  tokenizálás.

---

## 8. Amit ez a feldolgozás nem mért meg

Fontos, hogy a dokumentum ne állítson többet, mint amit alátámaszt.

**G9 (prompt injection) — nem mértük.** Ez a gát a review során került a Theory-ba,
és agent-rendszernél a legmagasabb tétű: a beolvasott dokumentum, eszközkimenet vagy
retrieval-találat szövege ugyanúgy utasításként hathat, mint a rendszerprompt, mert
**nincs privilegizált csatorna** — minden egyetlen token-folyam. A QCP külső
dokumentumokat és eszközkimeneteket fog beolvasni, tehát ez nem elméleti kockázat.
A tervezési elv enélkül is levezethető: nem megbízható forrásból jövő szöveg soha ne
kapjon eszközjogot; eszközhívás-fehérlista; a jogosultság az agentnél legyen, ne a
promptban. De ezt **mérni kell**, és egy 0,5B-s modellnél nagyobbal.

**G3, G5, G10 — érveléssel állnak, nem méréssel.** A fagyott súlyok definíció
szerint igazak; a szimbolikus végrehajtó hiánya negatív állítás; a szuperpozíció
önálló interpretability-projekt lenne. A notebook ezt kimondja, és ez a dokumentum
sem állít többet.

**Minden mérés egy 0,5B-s modellen készült.** Egy frontier modell jobban kalibrált,
gyakrabban visszakérdez, és ritkábban esik ismétlődő hurokba. De a **mechanizmusok
nem tűnnek el a mérettel**: a fix mélység, a softmax-kényszer, az autoregresszív
visszalépés hiánya és a batch-függő numerika architekturális, nem méretfüggő. Ami
méretfüggő, az a hibák gyakorisága, nem a lehetőségük.

**Az E6 flip-gyakorisága egyetlen eseményből jön.** 1 váltás 183 próbából; a 95%-os
konfidenciaintervallum nagyjából 0,01%–3,0%. A jelenség léte biztos, a gyakorisága
nem. Ha ez felügyeleti dokumentumba megy, több ezer pozíción kell újramérni.

---

## 9. Gát → komponens

| Gát | Hol csap le a QCP-ben | Mit kell tenni |
|---|---|---|
| **G1** subword tokenizáció | kapacitásterv, magyar dokumentumok | a szorzó megmérése valódi MNB-anyagon; karakter- és számműveletek kódba |
| **G2** véges ablak, KV cache | orkesztráció, agent-darabszám | kontextus-higiénia, pointer-memória, fázishatáron kompaktálás; cache/token mint modellválasztási kritérium |
| **G3** fagyott súlyok | Katalógus séma, Model Pool | minden állapot a hálón kívül; újratanítás, nem „megtanítás beszélgetésben" |
| **G4** fix mélység | orkesztráció költsége | a „több gondolkodás" token-, idő- és párhuzamosság-tétel; tervezni kell vele |
| **G5** nincs szimbolikus végrehajtó | Manufaktúra, pylab | a modell a műveletet *válassza ki*, ne végezze el |
| **G6** nincs „nem tudom" | Epic, validációs piramis | szerkezeti visszakérdezés, nem bizonytalansági küszöb; oracle a judge előtt |
| **G7** batch-függő numerika | kiszolgálás, audit | a tárolt válasz az egyetlen bizonyíték; batch=1 út vitatott esetekre |
| **G8** nincs revízió | Epic, lánc eleje | a legerősebb kapu előre; a fordítási lépés validált komponens |
| **G9** utasítás/adat nincs elválasztva | retrieval, eszközhasználat | eszközjog forrás szerint; fehérlista; **még mérendő** |
| **G10** nem lokalizálható tudás | magyarázhatóság, audit | a magyarázat a hálón kívül épül: forrás, eszköznapló, levezetés |
| **G11** preferenciahangolás | LLM-as-a-judge | a judge más modell legyen; numerikus oracle előbb |
| **G12** előtanítási eloszlás | magyar és hazai domain | domain-anyag retrievalbe; magyar kiértékelő készlet |

---

## 10. Nyitott kérdések a következő körre

1. **Hol fordul a magyar dokumentum** — és ki validálja a fordítást? (1. pont)
2. **Mit hagy jóvá ember, mielőtt a lánc elindul** — az Epic kérdésértelmezése
   igen; és mi még? (2. pont)
3. **A judge mit értékel** — konklúziót vagy láncot? Ez a következő téma
   (LLM-as-a-judge) magja. (3. pont)
4. **Van-e batch=1 út** vitatott döntések rekonstrukciójára, és mennyibe kerül?
   (6. pont)
5. **A G9 mérése** — nagyobb modellen, valódi dokumentum-beolvasási úton. (8. pont)
6. **Kontextus-költségvetés agentenként** — mennyi rezidens tokent kap egy atomic
   agent, és mi a kompaktálás fázishatára? Ebből jön ki a párhuzamosság. (5. pont)
