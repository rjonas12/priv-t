**Egy LLM anatómiája – Application to our system**

## Alaptézis

A Theory tizenkét szerkezeti gátat sorol; az Experimental study nyolc kísérletben
hetet közülük megmért. Egyik gát sem szűnik meg promptolással. Amit a
rendszertervezés tehet: a gátat olyan helyre tereli, ahol olcsó, és kitiltja onnan,
ahol drága.

A mérések három csoportba esnek — **kapacitás** (E1, E2), **megbízhatóság**
(E3, E5, E7), **elszámoltathatóság** (E4, E6). Jegybanki környezetben a harmadik a
legkevésbé alkudható.

A QCP a modellezési fázisban van, ezért az alábbiak tervezési javaslatok, nem
megállapítások a meglévő rendszerről.

---

## 1. A nyelvi határ

**Mérés:** a magyar szorzó 1,86–3,01 azonos tartalomra; a `tok/kar` angolon
gyakorlatilag konstans (0,180–0,193), magyaron 0,350–0,534.

A rendszer angolul működik, de magyar forrásdokumentumok lesznek. Ez kevesebbet
változtat a token-ökonómián, mint amennyit sugall: **a bemenet 80–90%-a a behúzott
dokumentumokban van, nem a promptban.** Ha azok magyarul maradnak, a szorzó a
domináns tagon marad rajta.

A kérdés tehát nem a prompt nyelve, hanem hogy hol fordul a dokumentum:

| Változat | Token-költség | Modell-megértés | Auditálhatóság |
|---|---|---|---|
| Beömléskor egyszer | egyszeri | jobb | gyenge — a lánc a fordítást látja |
| Magyarul marad | lekérdezésenként | gyengébb | erős |
| Mindkettő tárolva | egyszeri + tárhely | jobb | erős |

**Javaslat: a harmadik.** Angol fordítás a retrievalhez, magyar eredeti megőrizve és
hivatkozva mint forrás — ez tárhelybe kerül, nem tokenbe. Két ok:

- **G8 az indexben.** Egy félrefordított szakkifejezés nem egy választ ront el,
  hanem beleég az indexbe, és minden rá épülő válaszba. Az E7 megmutatta, hogy a
  modell a hibás premisszát nem felismeri, hanem racionalizálja.
- **Auditálhatóság.** Egy MNB-válasznak a magyar eredetire kell visszamutatnia, nem
  annak gépi fordítására.

A fordítási lépés ezért **validálandó komponens**, nem infrastruktúra: jegybanki
terminológiai szótár, és emberi jóváhagyás azokra a kifejezésekre, amik a Katalógus
sémában is szerepelnek.

---

## 2. Az Epic — a kérdésfordítás

**Mérés:** E7 (racionalizálás), E5 (kalibráció), E4 (a döntés helye nem függ a
nehézségtől).

Ez a lánc legkockázatosabb pontja, a G8 miatt: ami itt eldől, azt semmi nem vonja
vissza. Az E7 három érvényes esetében a modell egyszer sem ismerte fel, hogy hibás
premisszán dolgozik — ehelyett alátámasztotta. A 100 °F-hez például egy **második
hamis állítást gyártott** („or 0 degrees Celsius"), hogy az első konzisztens legyen.

Agent-láncban: **ha az Epic félreérti a kérdést, a lánc többi tagja hibátlan munkát
végez a rossz kérdésen.** A minőség végig magas marad, tehát semmi nem jelzi a hibát.

Három következmény:

1. **A legerősebb kapu a lánc elejére**, pedig az Epic a legolcsóbb lépés. A későbbi
   lépések nem javítják a korábbi hibát, hanem ráépítenek.
2. **Az Epic adja vissza, hogyan értette a kérdést** — milyen szabadságfokokat
   rögzített, melyeket hagyott nyitva —, és ezt ember hagyja jóvá, mielőtt a lánc
   elindul. Ez az egyetlen pont, ahol a hiba még olcsó.
3. **A visszakérdezés nem bízható a modell magabiztosságára.** Az E5-ben a kitalált
   jegybankról p = 0,782-vel és 1,73 bit entrópiával nyilatkozott — magabiztosabban,
   mint Párizsról (0,275; 4,51 bit). A token-entrópia a **formátum**
   megjósolhatóságát méri, nem a tényét. Egy „kérdezz vissza, ha bizonytalan vagy"
   szabály pont ott néma, ahol kellene. Szerkezetileg kell kikényszeríteni.

---

## 3. Model Manufaktúra — validáció

**Mérés:** E7 negyedik esete, E5.

A modell a beinjektált „Europe is the largest continent" premisszát ellenőrzendő
állítássá fordította, és **helyesen „False"-ra jutott** — de kétszer sorolta fel
Észak-Amerikát, kihagyta Ausztráliát, és az indoklása („Europe is located in the
western part of the world") a méretről semmit nem mond. A helyes válasz egyetlen
memorizált tényből jött, nem az elemzésből.

**Helyes következtetés, érvénytelen levezetés.** Ebből:

- **Az oracle és a numerikus teszt nem helyettesíthető judge-dzsal.** Ahol van
  determinisztikus ellenőrzés (pylab, séma-validálás), annak meg kell **előznie** a
  modellalapú értékelést, nem kiegészítenie.
- **A judge a láncot értékelje, ne a konklúziót.** Ha a judge prompt úgy szól, hogy
  „helyes-e a válasz", akkor az érvénytelen levezetésű helyes válasz átmegy — és
  vele a sablon, ami legközelebb rosszat fog adni.
- **A judge ne ugyanaz a modell legyen** (G11): a preferenciahangolás egyetértésre
  hajlít, az önértékelés torzítás, nem független ellenőrzés.
- **A kiírt levezetés nem ellenőrzés.** A Theory a G4-hez „levezetés kiíratását"
  javasolja; ez több számítást enged tokenekben, de a látható gondolatmenet a
  formátum renderelése. Ellenőrzés az, ha a lépéseket determinisztikus eszköz
  újraszámolja.

---

## 4. Model Pool és Katalógus séma

**Mérés:** E5 (kitalált intézmény), E2.

A G3 szerint a súlyok fagyottak, a G10 szerint a tudás nem lokalizálható. Ebből:

**Minden, aminek igaznak kell lennie, a hálón kívül él.** A modell dolga a
kiválasztás, nem a tárolás.

**A modell által „ismert" tény nem forrás.** Az E5-ben a nem létező Zarbonia
jegybankjáról a modell kifogástalan szakmai regiszterben közölt egy kitalált
inflációs célt. A 3% azért hihető, mert a modell a valódi jegybankok eloszlásából
mintavételez — **nem tényt idéz fel, hanem generál, és az eredmény pont ezért
hihető.** Cseréld „Zarboniát" „Hungary"-re: ugyanezt kapod, és semmi nem jelzi.

Gyakorlati szabály: **a láncban keletkező minden szám, dátum és intézménynév vagy a
Katalógus sémából jön, vagy determinisztikus eszköz számolta, vagy megjelölendő mint
nem hitelesített.** Harmadik lehetőség nincs.

**Az auditálhatóság a hálón kívül épül.** A modell auditálható felülete a be- és
kimenet: a behúzott dokumentumok, az eszközhívások naplója, a Katalógusból vett
értékek, és a tárolt válasz.

---

## 5. Agentek és kapacitás

**Mérés:** E2, E4.

**A cache-költség önálló tengely.** A KV cache tokenenkénti mérete
`2 · L · H_kv · d_head`, és nem korrelál a paraméterszámmal: a Gemma-2-2B
104 kB/token, a háromszor nagyobb Qwen2.5-7B csak 56. Modellválasztásnál ez a
paraméterszámmal **egyenrangú** kritérium — és a modellkártyák nem írják ki.

Párhuzamos láncok (felső becslés, bf16, aktivációk nélkül; valósban 60–80%):

| Modell | 24 GB / 8k | 24 GB / 32k | 80 GB / 8k | 80 GB / 32k |
|---|---|---|---|---|
| Qwen2.5-0.5B | 234 | 58 | 803 | 200 |
| Llama-3.2-1B | 82 | 20 | 295 | 73 |
| Gemma-2-2B | 22 | 5 | 87 | 21 |
| Qwen2.5-7B | 19 | 4 | 141 | 35 |

**Egy félreértés, amit előre tisztázni kell.** A cache lineáris az **összes rezidens
tokenben**. Négy darab 8k-s atomic agent ugyanannyit eszik, mint egy 32k-s lánc — a
felbontás önmagában nem spórol. A nyereség abból jön, hogy egy atomic agentnek
**nem kell** az egész előzmény. Ha mindegyik megkapja a teljes kontextust, a
felbontásból nulla memória-előny származik.

**A G4 költségoldala.** Az E4 szerint mindkét prompt ugyanannyi réteget futott, és
ugyanabban a 22. rétegben dőlt el — a döntési pont architekturális. A modell nem tud
többet gondolkodni a nehezebb kérdésen, csak gyengébb választ ad. „Több gondolkodás"
kizárólag több tokenként létezik, az pedig növeli a rezidens tokenek számát, tehát
**csökkenti a párhuzamosságot.** A kapacitásterv nem a modell méretéből, hanem a
kontextus-higiéniából jön ki.

---

## 6. Reprodukálhatóság

**Mérés:** E6.

Egyszálas CPU-n a logitok **bitre azonosak** batch-összeállítástól függetlenül.
T4 GPU-n **0,018–0,043 logitkülönbség** jelenik meg pusztán attól, hány másik
szekvencia van a batchben — és ez 183 pozíción **egy argmax-váltást** okozott
(0,55%). Az eltérés nem monoton a batch-mérettel, tehát **nincs „biztonságos"
batchméret.** G8-cal együtt: egyetlen átfordult token az egész további választ
átírja.

A Theory G7-es megkerülési oszlopa három dolgot sorol — rögzített modellverzió,
rögzített dekódolási paraméterek, teljes hívásnapló. **Ezek nem egyenrangúak:** az
első kettő adott volt, és mégis átfordult egy token. Batchelt kiszolgálásban nem mi
választjuk a batch-szomszédainkat, tehát a bitre reprodukálhatóság **szerkezetileg
nem elérhető.**

- Auditálható nyom csak a **tárolt válasz**. A „futtasd újra és nézd meg" nem válasz
  egy felügyeleti kérdésre.
- A dekódolási paramétereket akkor is rögzíteni kell: az E5 szerint `top_p = 0,9`
  önmagában semmit nem korlátoz (T = 1,0-nál 25 token a nucleus, T = 1,5-nél 4 692).
- Ahol bitre azonos újrajátszás kell, ott **dedikált, batch=1 futtatás** — drága,
  tehát nem alapeset, de legyen rá út.
- A célhardveren **mérni kell**, nem feltételezni.

---

## 7. Amit nem mértünk

- **G9 (prompt injection)** — nem mértük, pedig agent-rendszernél a legmagasabb tétű.
  A tervezési elv enélkül is áll (nem megbízható forrásból jövő szöveg soha ne kapjon
  eszközjogot; eszközhívás-fehérlista), de mérni kell, nagyobb modellel.
- **G3, G5, G10** — érveléssel állnak, nem méréssel.
- **Minden mérés 0,5B-s modellen.** A mechanizmusok architekturálisak, tehát nem
  tűnnek el a mérettel; ami méretfüggő, az a hibák gyakorisága.
- **Az E6 flip-gyakorisága egyetlen eseményből jön** (95%-os CI kb. 0,01%–3,0%).

---

## Gát → komponens

| Gát | Hol csap le | Mit kell tenni |
|---|---|---|
| G1 tokenizáció | kapacitásterv | szorzó mérése valódi MNB-anyagon |
| G2 véges ablak | orkesztráció | kontextus-higiénia; cache/token mint modellválasztási kritérium |
| G3 fagyott súlyok | Katalógus, Pool | minden állapot a hálón kívül |
| G4 fix mélység | orkesztráció költsége | a „több gondolkodás" párhuzamosság-tétel is |
| G5 nincs végrehajtó | Manufaktúra, pylab | a modell válassza ki a műveletet, ne végezze el |
| G6 nincs „nem tudom" | Epic, validáció | szerkezeti visszakérdezés; oracle a judge előtt |
| G7 batch-függő numerika | kiszolgálás, audit | a tárolt válasz az egyetlen bizonyíték |
| G8 nincs revízió | lánc eleje | legerősebb kapu előre; validált fordítási lépés |
| G9 utasítás/adat | retrieval, eszközök | eszközjog forrás szerint; **még mérendő** |
| G10 nem lokalizálható | magyarázhatóság | a magyarázat a hálón kívül épül |
| G11 preferenciahangolás | LLM-as-a-judge | más modell legyen a judge |
| G12 előtanítási eloszlás | magyar domain | domain-anyag retrievalbe; magyar kiértékelő készlet |

---

## Felmerülő kérdések

1. Hol fordul a magyar dokumentum, és **ki validálja** a fordítást?
2. Mit hagy jóvá ember, mielőtt a lánc elindul? Az Epic kérdésértelmezése igen — és
   mi még?
3. A judge a **konklúziót** értékeli vagy a **láncot**? (Ez a következő téma magja.)
4. Van-e **batch=1 út** vitatott döntések rekonstrukciójára, és mennyibe kerül?
5. Mennyi **rezidens tokent** kap egy atomic agent, és mi a kompaktálás fázishatára?
   Ebből jön ki a párhuzamosság.
6. Mikor és milyen modellen mérjük a **G9-et**?
7. Melyik modellcsalád jön szóba, és ismerjük-e a **cache/token** értékét — nem csak
   a paraméterszámát?
8. A magyar szorzót **valódi MNB-dokumentumon** mikor mérjük újra?
