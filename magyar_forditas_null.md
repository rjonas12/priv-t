# SRM Beta Quant — Közös tudásalap (Shared Knowledge Baseline)

> **Fordítói megjegyzés.** Ez a `SRM_BETA_QUANT_SHARED_KNOWLEDGE_BASELINE_KB0.md` magyar fordítása. A kódneveket, azonosítókat, fájlneveket, YAML-mezőket és API-mezőneveket szándékosan eredeti alakjukban hagytam. A kulcsfogalmak angol megfelelője első előfordulásukkor zárójelben szerepel. Hivatkozási alap továbbra is az angol eredeti.

**Tudásalap:** `KB-0`
**Dokumentum státusza:** Tudásalap-jelölt kollégai átnézésre; még nincs a repositoryban
**Elkészült:** 2026-09-21
**A repositoryból vett evidencia határa:** a `de4532c` commit (`feat(srm-beta): AMENDMENT-SE SE-P1 governance bootstrap (C1)`)
**A leírt, commitolt projektállapot dátuma:** 2026-09-18
**Munkanyelv:** angol
**Hatáskör:** Kizárólag navigációs szintézis. A dokumentum nem írja felül a chartert, elfogadott döntési rekordot, befagyasztott registryt, elfogadott munkacsomagot, lezárási rekordot vagy az API-architektúrát.

> **Figyelmeztetés párhuzamos munkáról.** Az előkészítéskor a repository munkakönyvtárában aktív,
> nem commitolt Catalog Factory-munka volt a `de4532c` utáni állapoton túl. Ezeket a változásokat
> az alábbi ténybeli alapállapot szándékosan nem tartalmazza. Ahol releváns, a dokumentum jelzi, hogy
> a katalógus utódmunkája folyamatban van, de nem commitolt termékeket nem ír le készként vagy
> elfogadottként. Mielőtt a KB-0 bekerül a repositoryba, egyeztetni kell a végső, pusholt állapottal.

---

## 1. Vezetői összefoglaló és tájolás

Az SRM Beta Quant projekt a **Rendszerkockázati Térkép (Systemic Risk Map, SRM)** első konkrét,
tesztelhető kvantitatív megvalósítását építi egyetlen, szándékosan szűk és idővel befagyasztandó
szűrőkontextusra (filter context). A béta célja nem az, hogy egyszerre megoldja a teljes
termékrácsot. Megbízható, végponttól végpontig tartó utat akar kialakítani: a governált piaci
objektumoktól és point-in-time adatoktól explicit kvantitatív becsülendő mennyiségeken (estimand)
és tesztelt Python-modelleken át a válaszséma szerinti kimenetekig, amelyeket a backend el tud
tárolni és ki tud szolgálni.

A projekt két nagy alapot már elkészített.

Először: a piaci univerzumot kiválasztották és tizenkét típusos piaci kockázati doménként
befagyasztották. Ez egy korábbi, kizárólag részvényiparági koncepciót váltott fel. A béta most
globális piaci proxykat fed le részvényszektorokon, hitelpiacon, kamatokon, devizán és
nyersanyag-érzékeny doméneken keresztül, miközben megtartja a magyar szakpolitikai és a jövőbeli
transzmissziós nézőpontot (lens). A proxy-tagság és a kontextuális szerepek a `proxy_registry_v1`
registryben vannak befagyasztva.

Másodszor: a Sandbox Data Foundationt (homokozó adatalap) megvalósították, ellenőrizték és ember
jóváhagyta. Le tudja kérni a registry Yahoo-alapú részhalmazát, megváltoztathatatlan nyers
pillanatképeket (snapshot) őriz meg, modellfüggő imputálás nélkül kanonizálja a megfigyeléseket,
auditálja az adatminőséget, tanúsítja a termékeket, és az aláírt snapshotot bájtra azonosan vissza
tudja játszani. Ez egy governált, megfigyelt adatokra épülő alap, nem kitöltött modellmátrix.

A projekt egy heterogén, tizenkét objektumos Know Your Instrument (KYI, „ismerd az eszközödet”)
pilotot is lezárt. A pilot megmutatta, hogy komoly kvantitatív felhasználáshoz a tiszta idősorok
önmagukban nem elegendők. Számít az eszköz azonossága, a gazdasági kitettség, a benchmark- és
módszertantörténet, a mérték szemantikája, a publikálási konvenciók, a piaci szereplőkre vonatkozó
állítások, az evidencia érettsége, a származtatott idősorok definíciója és a modellbe-engedési
státusz is. Ennek a tudásnak a nagy léptékű megőrzésére típusos Catalog Factory (katalógusgyár)
épül. A commitolt evidencia határán a Gate 2 (2. kapu) elfogadott és lezárt; a későbbi Catalog
Factory-munka még folyamatban van, és nem része ennek az alapállapotnak a lezárt ténybeli körében.

Ami nyitott, az maga a kvantitatív kérdés. A szűrőkontextus még nincs befagyasztva. A bétának
különösen a következőket kell rendeznie: a kezdeti döntési horizontot, az első felhasználó felé
megjelenő kockázati célt (risk target), az aggregált csomópont gazdasági jelentését, a point-in-time
bemeneti szemantikát, a megengedett becslési ablakokat, a futásidejű szűrők és a modellkonfiguráció
viszonyát, valamint a kontextus azonosítóját. Csomópontkockázati vagy transzmissziós modellt még
nem fogadtak el.

Az első kvantitatív vertikális szelet (vertical slice) a csomópont- és doménkockázati alappal
indul, nem a transzmisszióval. Kezdetben determinisztikus szintetikus bemeneteken fejlesztik, egy
típusos bemeneti szerződés (input contract) mögött. A kvantitatív kód bemenetként kapja az adatot;
nem tölt le adatot, és nem ír közvetlenül a production adatbázisba. A transzmissziós élek, láncok,
makrotranszmisszió, riasztások, hírek és a generált értelmezés későbbi függőségi sávok maradnak.

### Egyperces állapot

| Terület | Állapot az evidencia határán |
|---|---|
| A béta hatóköre és munkaarchitektúrája | Döntött, az élő charterben |
| Tizenkét doménes piaci univerzum | Jóváhagyott és befagyasztott |
| `proxy_registry_v1` | Befagyasztott; változtatáshoz új verzió és döntési rekord kell |
| Sandbox Data Foundation | Kész, ellenőrzött, ember által jóváhagyott |
| Aláírt sandbox snapshot | `20260828T131353Z_proxy_registry_v1_9158801f391e` |
| Registry-lefedettség | 94 objektum: 83 Yahoo-alapú megfigyelt idősor és 11 csak metaadatos vagy nem Yahoo-objektum |
| KYI pilot | 12/12 objektumról ember döntött |
| KYI-koncepció és gépi szerződések | Verziózott és governált; a korábbi generációk megőrizve |
| Catalog Factory | Gate 2 elfogadva; utódmunka folyamatban; nincs teljes publikált katalógus |
| A katalógus hátralévő feltöltése | 82 objektum; az evidencia határán korlátlan feltöltésre nincs engedély |
| Szűrőkontextus | Részben döntött; nincs befagyasztva |
| Kvantitatív modell | Még nincs megvalósítva vagy elfogadva |
| Első tervezett modellképesség | Alap- (underlying) és aggregált csomópontok kockázati alapja |
| Transzmissziós modellezés | Kifejezetten halasztva, amíg nincsenek elfogadott csomóponti idősorok |
| Production Data Layer-integráció | Egy későbbi Quant Data Readiness Gate-re (kvantitatív adatkészültségi kapu) halasztva |

---

## 2. A KB-0 célja, közönsége és hatóköre

A KB-0 a közös belépési pont azoknak a kollégáknak, akik csatlakoznak a kvantitatív sávhoz (track)
vagy átnézik azt. Kvantitatív kutatóknak, matematikusoknak, adatmérnököknek, backend-mérnököknek,
bírálóknak és projektgazdáknak szól. Célja, hogy minden olvasó ugyanarról a fogalmi és ténybeli
kiindulópontról induljon, anélkül hogy több száz implementációs és governance-fájlból kellene
rekonstruálnia a projektet.

A KB-0 elolvasása után egy kollégának érteni kell:

- mit próbál bizonyítani a béta;
- mely piaci univerzum és adatalapok rögzítettek már;
- miért kezelik külön governance alatt az eszközökről szóló tudást és a numerikus adatot;
- mit jelent ebben a projektben a szűrőkontextus;
- mely kvantitatív döntések nyitottak még;
- miért igényelnek az alap- és az aggregált csomópontok rokon, de nem szükségszerűen azonos becslőket;
- hogyan korlátozza a modellezést a point-in-time információ, a vintage (adatváltozat) és a
  publikálás időzítése;
- miért indul a projekt szintetikus adattal és típusos bemeneti szerződéssel;
- hogyan határozzák meg a UI-kötelezettségek (obligation) a szállítási sorrendet anélkül, hogy
  előírnák a matematikát;
- mi van kifejezetten a hatókörön kívül vagy tiltva a jelenlegi szakaszban.

A KB-0 nem helyettesíti a mérvadó forrásokat. Nem definiál új Catalog Factory-szerződést, nem
ismétli meg az API-séma minden mezőjét, nem formalizál végleges modellt, nem ad engedélyt
implementációra, és nem változtat befagyasztott döntésen. Szerepe az, hogy a mérvadó anyagokat
koherens tudásállapottá kösse össze, és láthatóvá tegye a nyitott kérdéseket.

---

## 3. Hatáskör, evidencia és döntési státusz

Ha a források ellentmondanak egymásnak, a béta az `srm_beta_quant/BETA_CHARTER.md` szerinti
hatásköri sorrendet követi:

1. a charterben és döntési naplójában rögzített elfogadott döntések;
2. a `systemic-risk-api-architecture.md` a frontend felé irányuló kötelezettségekre és a JSON-válaszok
   alakjára;
3. a bétán belül létrehozott, kötelezettség-specifikus kutatás, formalizálás, tesztek és aláírt
   döntések;
4. a tágabb `QCP_quant` keretrendszer referenciaanyagként, nem automatikusan kötelező eszköztárként.

Ez a munkamegosztás alapvető. Az API-szerződés azt határozza meg, **mit kell visszaadni**.
Önmagában nem dönti el, mit jelent egy kockázati mennyiség, és hogyan kell becsülni. Egy
`systemic-risk-score` nevű példamező, egy példaként szereplő egyhónapos becslési ablak vagy egy
példa-transzmissziós szabály nem bizonyíték arra, hogy a megfelelő kvantitatív fogalmat
kiválasztották.

A KB-0 a következő státusznyelvet használja:

| Státusz | Jelentés |
|---|---|
| **Döntött (Decided)** | Ember elfogadta, és a tulajdonos repository-hatóságnál rögzítették |
| **Kész (Complete)** | Megvalósítva, és a szükséges technikai és emberi evidenciával lezárva |
| **Konvergáló (Converging)** | Erős tervezési irány a jelenlegi kvantitatív egyeztetésből, a repositoryban még nem ratifikálva |
| **Jelölt (Candidate)** | Összehasonlításra javasolt módszer, értelmezés vagy termék |
| **Nyitott (Open)** | Döntés, amely még szükséges ahhoz, hogy a tőle függő munka lezárulhasson |
| **Halasztott (Deferred)** | Szándékosan elhalasztva, amíg előfeltételei nem léteznek |
| **Felváltott (Superseded)** | Nyomon követhetőség miatt megőrzött korábbi döntés, amelyet egy későbbi elfogadott döntés váltott fel |

A lényeges matematikai, piaci és architekturális tanulságoknak nyomon követhetőnek kell maradniuk.
Egy vonzó ötlet nem válik döntéssé csak azért, mert hihetőnek tűnik, vagy mert egy modell hasznos
ábrát ad. A tartós döntésekhez kell egy tulajdonos termék, forrás- vagy evidencia-feljegyzés,
explicit következmények és a megfelelő emberi jóváhagyás.

---

## 4. Hogyan jutott el a projekt a jelenlegi állapotáig

### 4.1 A piaci univerzumról szóló döntés

A béta először részvényiparági felosztásban gondolkodott. A kutatás kimutatta, hogy ez kihagyná a
piaci stressz fő csatornáit (hitel, szuverén kamatok, finanszírozás, deviza és nyersanyagok), és
arra késztetné a terméket, hogy egymástól eltérő objektumokat „iparágnak” nevezzen. Az elfogadott
csere a `typed_market_risk_domains_v1`: tizenkét típusos piaci kockázati domén, amelyeket egy
befagyasztott, szerepeket ismerő proxy-registry reprezentál.

A projekt ebből következő állítása szándékosan korlátozott: ez egy **globális piaci rendszerkockázati
proxy-béta magyar transzmissziós nézőponttal**. A globális piaci információ és a magyar szakpolitikai
nézőpont különböző dimenziók. Az első kvantitatív szelet a csomópont- és doménkockázatot méri; a
magyar transzmissziót vagy az oksági rendszerszintű hozzájárulást még nem becsüli.

### 4.2 Sandbox Data Foundation

A `WP-DF-001` munkacsomag megvalósította a megfigyelt adatok alapját, és emberi jóváhagyással
lezárult. Az aláírt snapshotot commitolt kód állította elő tiszta munkakönyvtárból. Mind a 83
Yahoo-alapú registry-idősort lekérte, nem volt blokkoló megállapítás, átment a strict-JSON- és a
tanúsítási hash-ellenőrzéseken, és bájtra azonosan visszajátszható volt.

Ez a mérföldkő igazolta, hogy a projekt meg tudja őrizni azt, amit a forrás szolgáltatott.
Szándékosan nem döntött a hozamokról, a skálázásról, az imputálásról, az aggregálásról vagy a
kockázati becslőről. Ezek a döntések a döntési horizonttól, a kockázati céltól, az eszköz típusától
és a point-in-time elfogadhatóságtól függenek.

### 4.3 Tizenkét objektumos KYI pilot

A KYI pilot tizenkét objektumot választott három egymást követő tételben (batch):

| Tétel | Objektumok | A tesztelt fő heterogenitás |
|---|---|---|
| A | `IXC`, `RSPT`, `ICLN`, `IYR` | széles, egyenlő súlyú, tematikus és ingatlanpiaci részvénycsomagolások (wrapper) |
| B | `CL=F`, `^TNX`, `TLT`, `^VIX` | folytonos határidős ügyletek, hozamindexek, kötvény-ETF-ek és nem befektethető implikált volatilitás |
| C | `HYG`, `drv-hy-vs-ig`, `EURHUF=X`, `ecb-ciss` | hitel, származtatott objektumok, deviza és hivatalos összetett indikátorok |

Tíz pilotobjektumhoz volt sandbox-adat; kettő csak metaadatos volt. A pilotot azért választották,
hogy felszínre hozza a sémahibákat, nem azért, hogy előre kiválassza a jövőbeli modellezési
halmazt. Megmutatta, hogy a jogi azonosságnak, a gazdasági kitettségnek, a mérték definíciójának,
a piaci szereplőkre vonatkozó evidenciának, a publikálás időzítésének, a revíziós szabályoknak, a
módszertani rezsimeknek és az adatelérhetőségnek külön kell maradnia.

Mind a tizenkét pilotobjektumról ember döntött. Az ebből adódó minőségi mérce annyi strukturált és
narratív evidenciát követel meg, hogy egy elfogadott eszközkártya offline, új lényeges modellállítás
nélkül rekonstruálható legyen.

### 4.4 Katalógusszerződések és a Factory

A katalógusarchitektúra három governált állapotot választ szét:

1. **Tudásállapot (knowledge state):** megfelelően dokumentált-e az azonosság, a működési mechanika,
   a szereplők, a rezsimek, az evidencia és a csapdák.
2. **Numerikus reprezentáció állapota (numerical representation state):** az objektum lekért
   megfigyelt, hivatalos-de-le-nem-kért, származtatott-de-nem-számított, kiszámított származtatott,
   nem elérhető vagy kivezetett.
3. **Modellbe-engedési állapot (model-admission state):** az objektum nem értékelt, jelölt, egy
   megnevezett profilhoz engedélyezett, korlátozott, halasztott vagy kizárt.

Ezeket az állapotokat nem szabad összemosni. Egy kiváló minőségű tudásrekord nem bizonyítja a
numerikus adat elérhetőségét, a numerikus elérhetőség pedig nem jelent engedélyt arra, hogy az
objektumot modellben használjuk.

A repository evidencia-határán a Gate 2-t elfogadták és lezárták. A futásidejű katalógushatóság az
elfogadott v7 generáción maradt. Az `AMENDMENT-SE` elindult, és a governance-bootstrap C1 commitja
létezett, de a módosítást és a v8 utódmunkát itt nem tekintjük teljesen megvalósítottnak vagy
lezártnak. A CP-3 és a későbbi kódolási ellenőrzőpontok (checkpoint) a commitolt navigációs
állapotban még nem kezdődtek el; teljes katalógust governált publikálási értelemben nem publikáltak.

### 4.5 Visszatérés a kvantitatív tervezéshez

A kvantitatív sáv most csak olvasási módban konszolidálhatja a kontextusdöntéseit, amíg a Catalog
Factory az aktív író. A formális repository-változtatásoknak, a modellimplementációnak és a
kontextusazonosító kiadásának (minting) meg kell várnia egy explicit átadást (handoff), a tiszta
munkakönyvtárat és az emberi engedélyt. Így a master ágon egy író marad, a tervezési haladás pedig
nem vész el.

---

## 5. A befagyasztott piaci univerzum

Az univerzum alábbi mezői döntöttek:

```yaml
partitionRule: typed_market_risk_domains_v1
marketUniverseScope: global_market_proxies
policyLens: hungary
frequency: daily
measurementCurrencyPolicy: native_quote_returns
membershipPolicy: frozen_versioned_proxy_registry
proxyRegistryVersion: proxy_registry_v1
provisionalCommonStart: 2008-01-02
sandboxSource: yahoo_via_yfinance
productionSource: unresolved
```

### 5.1 Tizenkét aggregált domén

| Csomópont-azonosító | Domén | Alapértelmezés |
|---|---|---|
| `agg-energy` | Energiapiacok | Tőzsdén jegyzett energia-részpiacok; a fizikai nyersanyagok típusos driverként külön kezelve |
| `agg-utilities-infra` | Közművek és kritikus infrastruktúra | Globális közmű- és infrastruktúra-kitettségek |
| `agg-materials` | Alapanyagok és nyersanyagok | Tőzsdén jegyzett alapanyag- és bányászati kitettségek; a nyersanyag-driverek elkülönítve |
| `agg-industrials` | Ipar és szállítás | Globális ipari, szállítási, repülőgépipari és védelmi kitettségek |
| `agg-technology` | Technológia és digitális gazdaság | Globális technológia, félvezetők, szoftver és kommunikáció |
| `agg-consumer` | Fogyasztói gazdaság | Nem alapvető és alapvető fogyasztási cikkek, kiskereskedelem, lakáspiac és szabadidő részpiacai |
| `agg-healthcare` | Egészségügy és élettudományok | Globális egészségügy, biotechnológia, orvostechnikai eszközök és szolgáltatók |
| `agg-financials` | Pénzügyi közvetítők | Globális pénzügyi szektor, regionális bankok és biztosítók |
| `agg-real-estate` | Ingatlan | Tőzsdén jegyzett amerikai, Egyesült Államokon kívüli és jelzálog-ingatlan kitettségek |
| `agg-credit-funding` | Hitel és finanszírozás | Governált relatív hitelmértékek és fix kamatozású bemenetek |
| `agg-rates` | Szuverén kamatok és duráció | Hozamgörbe-pontok és durációérzékeny fix kamatozású proxyk |
| `agg-fx` | Deviza | Globális devizapiaci helyzet; a magyar nézőpont horgonya az EUR/HUF |

A keresztmetszeti validációs idősorok, például a VIX, a MOVE, az ECB CISS, a Hungary CLIFS, az
OFR FSI, a SPY és az ACWI szándékosan nem gyökérdomének.

### 5.2 Kontextuális szerepek

| Szerep | Jelentése a bétában |
|---|---|
| `anchor` (horgony) | A domén széles referencia-reprezentációja |
| `child_candidate` (gyerekjelölt) | Alapcsomópont-jelölt, miután a kockázati cél és a befogadási szabályok rögzültek |
| `driver` (hajtótényező) | Gazdaságilag releváns bemenet vagy magyarázó változó; nem automatikusan része a csomópont pontszámának |
| `validation` (validáció) | Modellen kívüli összehasonlító, szélességi (breadth) ellenőrzés vagy alternatív reprezentáció |
| `supplemental` (kiegészítő) | Kezdetben kizárva a történeti hossz, a redundancia vagy más dokumentált korlát miatt |

A registrybeli szerep nem modellbe-engedési döntés. Egy horgony egy adott mértékhez vagy
modellprofilhoz még lehet nem elfogadható. Validációs objektum nem kerülhet csendben a tanítóadatba,
és egy drivert sem szabad pusztán azért beleátlagolni a domén pontszámába, mert gazdaságilag
releváns.

### 5.3 Befagyasztott invariánsok

- Egy idősornak egy befagyasztott kontextusban legfeljebb egy pontozott „otthona” van.
- A másodlagos előfordulásokat kifejezetten driver- vagy validációs felhasználásként kell típusozni.
- Az ETF-hozamokat, határidős ügyleteket, hozamokat, hitelproxykat és devizát nem átlagoljuk nyers
  mértékegységben.
- A kiegészítő idősorok nem rövidíthetik meg csendben a modellezési mintát.
- A proxy-tagság változásához új registry-verzió és döntési rekord kell.
- A Yahoo által kezelt összetevőket a sandboxban elfogadjuk; a vállalati összetevők point-in-time
  rekonstrukciója nem történik meg.
- Natív jegyzési devizájú hozamokat (native quote returns) használunk, ahelyett hogy mechanikusan
  forintkockázatot vinnénk minden doménbe.
- Az árakat nem töltjük előre (forward-fill) mesterséges nullhozamokká.
- A Yahoo sandbox-beszerzési forrás, nem hiteles production forrás.

---

## 6. A Sandbox Data Foundation

A Data Foundation nulladik terméke egy validált, megfigyelt adatokból álló snapshot. Megőrzi a
forrásmegfigyeléseket, az eredetet (provenance) és a minőségi evidenciát, anélkül hogy úgy tenne,
mintha tudná, hogyan kell majd helyesen kezelnie ezeket a későbbi modellnek.

### 6.1 Mit biztosít

- a registry validálását és a beszerzési halmaz levezetését;
- izolált szolgáltatói adaptert típusos hibákkal és újrapróbálkozással;
- megváltoztathatatlan nyers snapshotokat és eredet-manifeszteket (provenance manifest);
- céltól független auditokat az azonosságra, a sémára, a duplikátumokra, a lefedettségre, a
  hézagokra, az elavultságra (staleness), az időzónára és az értékek alapvető épségére;
- kanonikus, hosszú formátumú megfigyeléseket csomópont- és szerep-metaadatokkal;
- minőség-ellenőrzési (QC) riportokat és átnézésre szánt ábrákat;
- strict JSON-t és megváltoztathatatlan tanúsítási manifeszteket;
- offline visszajátszást és hash-ellenőrzést;
- atomi mutatót (pointer) a legutóbbi érvényes tanúsított snapshotra.

Az aláírt alap-snapshot:

```text
20260828T131353Z_proxy_registry_v1_9158801f391e
```

Az ezt előállító commit:

```text
30f4fa1363468cf77ca8d76443a06867f41e6b31
```

### 6.2 Mit nem biztosít szándékosan

- interpolációt, simítást vagy imputálást;
- szintetikus visszatöltést (backfilling);
- hozam- vagy spread-képzést;
- skálázást, winsorizálást vagy normalizálást;
- célspecifikus időbeli illesztést (alignment);
- jellemzőképzést (feature engineering);
- csomópont-aggregálást;
- modellválasztást;
- production licencelést;
- ORM- vagy PostgreSQL-írást;
- API-kiszolgálást vagy lekérés idejű adatbeszerzést;
- production minőségű, folytonos határidős görgetett (roll) idősort.

Ez a határ nem mulasztás. Megakadályozza, hogy modellfeltevések rejtőzzenek el a megfigyelt adatok
rétegében.

### 6.3 Rétegzett adatfolyam

A kialakuló architektúra hasonlít a medallion-felépítéshez, de a projekt színcímkék helyett
felelősségi neveket használ:

```text
L0 — megváltoztathatatlan nyers szolgáltatói payloadok
     A pontosan beszerzett tartalom és a lekérés eredete.

L1 — kanonikus megfigyelt adat
     Governált azonosság, mező, mértékegység, deviza, naptár, időbélyeg,
     hiányzás, elavultsági jelölt és snapshot-leszármazás (lineage).

L2 — verziózott, modellkész QuantInputContract
     Célspecifikus hozamok, változások, spreadek, származtatott mértékek,
     illesztés, megengedett imputálás és annak maszkja, jellemző-leszármazás.

L3 — típusos kvantitatív eredmények
     Becslések, diagnosztika, bizonytalanság, hiba-/tartózkodási (abstention) állapot,
     kontextus-/modell-/futásazonosság és átnézési termékek.

L4 — perzisztencia és API-adapter
     Az adatarchitekt felelősségébe tartozó adatbázis-betöltés és szerződés szerinti kiszolgálás.
```

Az L0 és az L1 a Sandbox Data Foundation részeként létezik. Az L2 és az L3 a kvantitatív sáv munkája
marad. Az L4 egy későbbi integrációs határ.

---

## 7. Mivel járul hozzá az eszközkatalógus a modellezéshez

A katalógus nem díszítő szószedet. Megvédi a kvantitatív munkát attól, hogy egy tiszta, de
félreértett idősort használjon.

A pilot példái megmutatják, miért:

- Egy szektor-ETF egy tőzsdei csomagolást és benchmark-kitettséget reprezentál, nem feltétlenül a
  széles csomópontcímke által megnevezett teljes fizikai vagy gazdasági szektort.
- Egy tematikus ETF megtarthatja ugyanazt a tickert lényeges indexmódszertani változásokon át is.
- Egy szolgáltatói folytonos határidős ticker elrejtheti a kontraktusválasztást, a görgetést, az
  összefűzést (splice), a korrekciót és a revíziós döntéseket.
- Egy hozamindex, egy kötvényár, egy teljeshozam-index (total-return index) és egy durációs
  kitettség különböző mértékek.
- Az azonnali (spot) VIX, az implikált variancia, a realizált variancia, a volatilitási
  kockázati prémium, a VIX-határidős ügyletek és a VIX ETP-k hozamai különböző objektumok.
- Egy high yield ETF hozama egyszerre tartalmazza az amerikai állampapír-durációt, a hitelkockázatot,
  a likviditást, a carryt, a visszahívásokat (call), a csődöket, a benchmark forgását és az ETF-es
  közvetítést; nem OAS és nem csődvalószínűség.
- A `HYG / LQD` kifejezés-karakterlánc, nem engedélyezett származtatott megfigyelés.
- Egy adatszolgáltatói EUR/HUF záróár, egy végrehajtható jegyzés, egy MNB-fixing és egy EKB
  referencia-árfolyam időzítése, hozzájárulói, naptára és felhasználási jogai eltérnek.
- Egy hivatalos összetett mutató, például a CISS, hasznos validációs evidencia lehet, de nem
  független valós igazság (ground truth), ha átfed a modell komponenseivel.

A kvantitatív következmény: minden befogadott bemenetnek egy típusos `measure_id`-hoz kell kötődnie,
nem csupán egy tickerhez. A származtatott mértékekhez verziózott formula-objektum kell,
komponens-élekkel, iránnyal, mértékegységgel, naptárral, hiányzási szabállyal, a vállalati
események / pénzáramlások kezelésével, időbélyeg-konvencióval és snapshot-leszármazással. A
modellbe-engedés profilspecifikus marad.

---

## 8. Mit jelent a szűrőkontextus

A szűrőkontextus azt a döntési szempontból releváns kérdést azonosítja, amelyre választ adunk. Nem
lehet becslőnevek zsákja. A béta négy réteget különböztet meg.

### 8.1 A réteg — rögzített döntési kontextus

Ez a réteg definiálja a kérdést és a piaci objektumokat, és egy production jelölt elfogadása előtt
befagyasztják. Része az univerzum, a taxonómia, a szakpolitikai nézőpont, a döntési horizont, a
kockázati cél és az aggregált csomópontok gazdasági jelentése.

### 8.2 B réteg — futásidejű választók

A futásidejű választók már definiált és eltárolt válaszok közül választanak. Példák: `asOf`,
`riskIndex`, `estimationWindow`, `deltaWindow`, `regionScope` és `expandedNodeId`. Egy futásidejű
választás nem hoz létre automatikusan új modellt vagy új üzleti kérdést. A `deltaWindow` például az
összehasonlításhoz használt korábbi jóváhagyott becslést választja ki; nem definiálja a kockázati
becslőt. Statisztikai értelmezését később a külön delta-elemzési kötelezettség kezeli.

### 8.3 C réteg — kondicionált modellbeállítások

Ez a réteg határozza meg, hogyan használja az információt egy elfogadott modell: transzformációk,
hiányzóadat-szabály, jellemzőablakok, lecsengés (decay), regularizáció, farokvalószínűség,
küszöbölés és más paraméterek. Ezek a beállítások egy verziózott modellprofilhoz tartoznak, hacsak a
terméknek nincs valódi oka arra, hogy valamelyiket felhasználói választásként kínálja.

### 8.4 D réteg — kutatási jelölt-konfiguráció

A jelöltazonosítók, módszercsaládok, kísérleti paraméterek és összehasonlító futások kutatási
manifesztekbe tartoznak. Alapértelmezés szerint nem kerülnek a felhasználó felé megjelenő
szűrőkontextusba.

Az irányadó promóciós teszt:

- Ugyanaz a cél és értelmezés, alternatív becslő: összehasonlítás, kiválasztás vagy ensemble; nem
  kerül új szűrőérték.
- Eltérő cél vagy döntési értelmezés: külön riskIndex-érték vagy későbbi kontextus lehet indokolt.
- Ugyanaz a képesség különböző elfogadható rezsimekben: belső útválasztás governált szabályok
  szerint.
- Paraméter- vagy érzékenységi változat: a modell-/futáskonfigurációban marad, hacsak egy
  felhasználói döntés valóban nem kívánja meg a megjelenítését.

---

## 9. A szűrőkontextus jelenlegi döntési állapota

Az alábbi táblázat elkülöníti a repositoryban rögzített döntéseket attól a tervezési konvergenciától,
amely a jelenlegi, csak olvasási módú kvantitatív egyeztetés során alakult ki.

| Mező vagy fogalom | Szerep | Státusz | Jelenlegi irány |
|---|---|---|---|
| `partitionRule` | Gyökértaxonómia | **Döntött** | `typed_market_risk_domains_v1` |
| `marketUniverseScope` | A figyelembe vehető információ határa | **Döntött** | `global_market_proxies` |
| `policyLens` | Értelmezési/transzmissziós nézőpont | **Döntött** | `hungary` |
| `nodeTaxonomy` | Aggregált hierarchia | **Döntött** | Tizenkét típusos domén |
| `proxyRegistryVersion` | Befagyasztott objektumok és szerepek | **Döntött** | `proxy_registry_v1` |
| `membershipPolicy` | Hogyan változik a tagság | **Döntött** | Befagyasztott és verziózott |
| `measurementCurrencyPolicy` | A jegyzési deviza kezelése | **Döntött** | Natív jegyzési devizájú hozamok; a deviza explicit |
| `decisionHorizon` | A kockázati állítás időbeli jelentése | **Konvergáló** | Egyidejű (contemporaneous) napi monitoring az első bétához |
| `riskIndex` / `riskTarget` | A felhasználó felé megjelenő estimand | **Konvergáló** | `market-stress-intensity` mint első célkockázat-jelölt |
| `aggregateNodeSemantics` | Egy doméncsomópont gazdasági jelentése | **Konvergáló** | Időben változó közös vagy eloszlásbeli doménstressz |
| `asOfPolicy` | A történeti információ határa | **Konvergáló** | Vintage-biztos, időzóna-explicit point-in-time visszajátszás |
| `estimationWindow` | A becslő számára elérhető történeti időtartam | **Nyitott** | Felhasználó által állítható, de csak elfogadható értékeken keresztül |
| `memoryPolicy` | Súlyozási/felejtési/újramintavételezési struktúra | **Modellprofil-döntés** | Elkülönül a nyers visszatekintési választótól |
| Hiányzóadat-szabály | Modellkész kezelés | **Nyitott** | Explicit maszkok; nincs nullára kényszerítés; módszerspecifikus jelöltek |
| Pontszámskála és kockázati állapotok | UI-értelmezés | **Nyitott** | A történeti átnézés előtt előre rögzíteni kell (precommit) |
| Futásidejű alapértékek | Kezdeti UI-választások | **Halasztott** | Az első kötelezettségek evidenciája után választandó |
| `contextId` | Stabil szemantikai azonosság | **Függőben** | Csak emberi jóváhagyás és repository-átadás után adható ki |
| `transmissionTarget` | Egy irányított él jelentése | **Halasztott** | Az első vertikális szelethez nem szükséges |

A konvergáló bejegyzések szándékosan nincsenek „döntött”-nek jelölve. Rögzíteni, átnézni és
elfogadni kell őket, miután a párhuzamosan dolgozó katalógusíró felszabadítja a repositoryt.

---

## 10. Döntési horizont

A döntési horizont kimondja, hogy egy kockázati becslés a jelenlegi állapotot vagy egy jövőbeli
időszakot ír le, és hogy a döntéshozónak milyen időintervallumra kell értelmeznie.

Az első béta vezető jelöltje:

```yaml
decisionHorizon:
  targetTiming: contemporaneous
  forecastHorizon: null
  evaluationFrequency: daily
  decisionUse: short_term_monitoring
```

Ez azt jelenti, hogy minden napi kiértékelés csak az `asOf` határig elérhető információt használja a
jelenlegi piaci kockázati vagy stresszállapot becslésére. Nem állítja, hogy előre jelzi a következő
havi veszteséget. Az eredmény segítheti a rövid távú monitoringot vagy a fedezési (hedging)
egyeztetést, de matematikai célja egyidejű.

Ez azért alkalmas első bétának, mert elkerüli az egyhónapos modell többletterheit: a célcímkéket és
az előrejelzés validálását. A volatilitási állapot, a farokesemények bekövetkezése, a tartósság és a
szélesség oksági (csak a múltat használó) történeti információval vizsgálható, viselkedésük pedig
nyugodt és stresszes időszakokon át is átnézhető.

Egy későbbi, előretekintő kontextus ehelyett ezt deklarálhatná:

```yaml
decisionHorizon:
  targetTiming: forward
  forecastHorizon: 1m
  evaluationFrequency: daily
```

Ez lényegesen eltérő cél lenne. Előretekintő címkéket, előrejelzés-pontozást, az átfedő horizontok
kezelését, erősebb mintán kívüli (out-of-sample) tervezést és egy egyhónapos döntés explicit
értelmezését igényelné.

---

## 11. Kockázati célok és kockázatimérték-családok

Az első béta nincs örökre egyetlen kockázati mértékre korlátozva. Az API `riskIndex` választója
idővel több, a felhasználó számára releváns estimandot is kínálhat, feltéve, hogy mindegyik jól
definiált, elfogadható a kiválasztott horizonthoz, tesztelt, eltárolt és jóváhagyott.

A jelölt családok:

| Kockázati fogalom | Megválaszolt kérdés | Példa becslők vagy konstrukciók |
|---|---|---|
| Piaci stresszintenzitás | Mennyire rendellenes és kedvezőtlen a jelenlegi piaci állapot? | Összetett vagy látens állapotú jelöltek |
| Volatilitási szint/rezsim | Mennyire változékony a mérték, és melyik volatilitási állapot érvényes? | Realizált volatilitás, EWMA, GARCH, rezsimmodellek |
| Value at Risk (kockáztatott érték) | Milyen veszteségkvantilis érvényes egy megadott horizonton és kitettségi konvenció mellett? | Historikus, parametrikus, szűrt historikus szimuláció |
| Expected Shortfall (várható hiány) | Mekkora a várható veszteség a kiválasztott VaR-kvantilisen túl? | Empirikus, parametrikus, EVT-alapú jelöltek |
| Farok-súlyosság | Mennyire vastag vagy súlyos a kedvezőtlen farok? | Farokindex, küszöbtúllépési és EVT-módszerek |
| Stresszbe lépési valószínűség | Mekkora a valószínűsége, hogy egy jövőbeli stresszállapotba lépünk? | Osztályozási, Markov-/rezsim- vagy hazard-jelöltek |
| Tartósság (persistence) | Mennyire tartós egy megfigyelt stresszállapot? | Időtartam-, autokorrelációs vagy rezsimtartóssági mértékek |
| Szélesség (breadth) | Hány befogadott gyerek van egyszerre stresszben? | Küszöbölt vagy folytonos keresztmetszeti összegzések |
| Többváltozós rendellenesség | Mennyire szokatlan az együttes konfiguráció? | Robusztus Mahalanobis-jellegű mértékek |
| Közösfaktor-stressz | Mennyire erős és stresszes a közös doménkomponens? | PCA- vagy dinamikus faktoros jelöltek |
| Rendszerszintű hozzájárulás | Mennyivel járul hozzá egy objektum a rendszerkockázathoz? | Későbbi módszerek, amelyekhez definiált rendszer és erősebb függőségek kellenek |

Az EWMA, a GARCH, a PCA, a dinamikus faktormodellek és az EVT nem automatikusan riskIndex
szűrőértékek. Becslőcsaládok, hacsak nem egy lényegesen eltérő felhasználói kérdésre válaszolnak.

A vezető első célnév a `market-stress-intensity`. A korábbi munkanevet, a „nowcast”-ot erre az
általános használatra elvetették, mert hagyományosan egy még nem megfigyelt, aktuális időszaki
változó vegyes frekvenciás becslésére utal. Az időbeli jelentést ehelyett a döntési horizont
metaadataiban kell explicitté tenni.

Egy olyan mérték, mint a volatilitás, a farokkockázat, a tartósság vagy a szélesség, később több
szerep egyikét töltheti be:

- felső szintű, választható `riskIndex`;
- egy összetett piaci stresszindex komponense;
- lefúrható (drill-through) diagnosztika;
- modellen kívüli validációs metrika.

Ezt a szerepet el kell dönteni, nem a metrika nevéből kikövetkeztetni.

---

## 12. A heterogén eszközök típusos mértékeket igényelnek

Ugyanaz a felhasználó felé megjelenő kockázati fogalom vonatkozhat részvényre, kötvényre,
devizaárfolyamra vagy aggregált doménre, de nem feltételezhető, hogy ugyanazt a nyers mezőt vagy
transzformációt használja.

| Objektumtípus | Jelölt modellezési mérték | Fő szemantikai kockázat |
|---|---|---|
| Részvény vagy részvény-ETF | Ár-/teljes hozam, lefelé irányuló hozam, realizált volatilitás | Vállalati események, kifizetések, benchmark- és csomagolási kitettség |
| Kötvény vagy kötvény-ETF | Teljes hozam, többlethozam, hozam-/spread-változás | Duráció, konvexitás, carry, benchmark, valamint NAV- és árkülönbségek |
| Állampapírhozam-index | Szint, változás vagy görbemozgás | A hozam (yield) nem kötvényhozam (return); a kedvezőtlen irány a kérdéstől függ |
| Hitelobjektum | OAS-/spread-változás vagy governált proxy | Kamat-, likviditási és csomagolási szennyeződés |
| Azonnali devizaárfolyam | Kanonikusan irányított hozam vagy szintváltozás | Bázis-/ellendeviza iránya, fixing időpontja és szakpolitikai nézőpont |
| Határidős proxy | Governált folytonos hozam | Kontraktusválasztás, görgetés, összefűzés, korrekció és revíziós kétértelműség |
| Volatilitási index | Szint, változás, variancia- vagy prémiummérték | Nem befektethető; összetéveszthető a derivatívák hozamaival |
| Származtatott objektum | Egy jóváhagyott formula-objektum kimenete | A kifejezés-metaadat önmagában nem definiál megfigyelést |

A jövőbeli QuantInputContractnak ezért többre van szüksége, mint `series_id` és `value`. Legalább a
következőket kell tudnia hordozni:

```text
series_id
measure_id
node_id
role
instrument_type
timestamp
as_of
published_at / available_at, ahol ismert
vintage_id
publication_lag
unit
currency
calendar_id
hiányzási állapot és maszk
elavultsági állapot
transformation_id
snapshot- és leszármazási azonosítók
```

Ha egy becslő nem elfogadható egy bemenettípushoz, tartózkodnia kell (abstain), vagy típusos okkal
hibára kell futnia. Nem alkalmazhat csendben részvényhozam-algoritmust egy hozamszintre, és nem
alakíthat nullává egy nem támogatott bemenetet.

A kezdeti kvantitatív fejlesztés determinisztikus szintetikus fixture-öket (tesztadat-készleteket)
használ. Ezeknek több bemeneti családot kell reprezentálniuk (részvényhozamok, hozam-/spread-változások,
deviza, aggregált gyerekpanelek, hiányzó és elavult megfigyelések, kifejezetten nem támogatott
bemenetek), még akkor is, ha az első elfogadott modell csak egy korlátozott részhalmazt támogat.

---

## 13. Alap- és aggregált csomópontok

Egy alapcsomópont (underlying node) befogadott eszközt, részpiacot vagy típusos mértéket reprezentál.
Egy aggregált csomópont a befogadott információból felépített, domén-szintű matematikai objektum.
Osztozhatnak egy felhasználó felé megjelenő kockázati fogalmon, de nem kell ugyanazt a
becslő-implementációt használniuk.

A javasolt kontextus-szintű szemantika:

```yaml
aggregateNodeSemantics:
  target: domain_common_stress
  interpretation: domain_level_latent_or_distributional_state
  compositionBasis: admitted_anchor_and_child_measures
  timeVarying: true
  explicitlyNot:
    - investable_portfolio_loss
    - causal_systemic_contribution
```

Ez a bejegyzés kimondaná, mit jelent az aggregált csomópont, anélkül hogy idő előtt módszert
választana.

A jelölt módszerek részben eltérő kérdésekre felelnek:

- A robusztus keresztmetszeti medián vagy nyesett átlag a befogadott gyerekek tipikus stresszét
  becsli.
- A gördülő PCA vagy a dinamikus faktormodell közös komponenst becsülhet, a súlyok (loading), az
  előjel, a rotáció és a stabilitás kontrollja mellett.
- A legnagyobb sajátérték vagy a teljes variációból való részesedése elsősorban a szinkronizációt vagy
  a közösséget méri; a magas közösség nem feltétlenül magas stressz.
- Egy Mahalanobis-jellegű távolság az együttes rendellenességet méri; irányított kialakítás nélkül egy
  ártalmatlan emelkedő piacot (rally) ugyanolyan erősen jelezhet, mint egy kedvezőtlen sokkot.
- A szélesség azt méri, mennyire kiterjedt a stressz, nem az átlagos súlyosságát.
- Egy portfólió-súlyozott kockázati mértékhez védhető kitettség- és súlydefiníció kell.

Következésképpen a „közösség”, a „rendellenesség”, az „átlagos stressz”, a „farokveszteség”, a
„szélesség” és a „rendszerszintű hozzájárulás” nem kezelhető szinonimaként. A kutatásnak először a
célt kell besorolnia, azután olyan becslőket összehasonlítania, amelyek valóban arra a célra
válaszolnak.

---

## 14. Point-in-time információ, `asOf` és vintage

Az `asOf` célja azoknak az információknak a visszajátszása, amelyeket a döntéshozó ténylegesen
használhatott. Nem csupán szűrő a megfigyelési dátumokra.

Egy (t) döntési határidőpontra az elfogadható információhalmaz fogalmilag:

\[
\mathcal I_t = \{x_{i,s,v}: available\_at_{i,s,v} \leq t\}.
\]

Szavakkal: egy megfigyelés csak akkor használható, ha a releváns vintage (adatváltozat) a döntési
határidőpontig elérhető volt. Egy történeti eredményt nem szabad olyan korrekcióval vagy
revízióval újraszámolni, amelyet először az adott történeti döntési dátum után publikáltak.

Az időbeli mezők különböző kérdésekre felelnek:

| Mező | Kérdés |
|---|---|
| `timestamp` | Mikor figyelték meg vagy értékelték a piaci/gazdasági mennyiséget? |
| `published_at` | Mikor publikálta a forrás először az értéket? |
| `available_at` | Mikor használhatta először a kvantitatív rendszer a governált pipeline-on keresztül? |
| `retrieved_at` | Mikor szerezte be a rendszer a payloadot? |
| `vintage_id` | Melyik megváltoztathatatlan forrás-/snapshot-változathoz tartozik az érték? |
| `source_revision_at` | Mikor történt egy későbbi forrásoldali korrekció vagy revízió? |
| `publication_lag` | Mekkora késés választja el a megfigyelést a publikálástól/elérhetőségtől? |
| `as_of` | Melyik döntési időpontbeli határ irányadó az eredményre? |

Az első béta konzervatív napi döntési ciklust használhat. Az egyik jelölt az, hogy egy nyilvános
`asOf` dátumot egy rögzített Europe/Budapest reggeli határidőpontként értelmezünk, és csak azokat a
teljesen lezárt és feldolgozott tőzsdei kereskedési napokat használjuk, amelyek ez előtt elérhetők
voltak. A pontos időpont ratifikálása még hátravan. Az invariáns az, hogy az időzóna és a
határidőpont explicit és reprodukálható.

Ha pontos publikálási időbélyegek nem érhetők el, konzervatív, mértékspecifikus elérhetőségi szabály
használható, amelyet ennek megfelelően jelölni kell. Feltételezett késést nem szabad megfigyelt
forrásmetaadatként feltüntetni. Revideált hivatalos idősoroknál kötelező a vintage-tudatos
kiválasztás. Piaci áraknál a későbbi forrásoldali korrekciók is új vintage-et hoznak létre, és nem
írják át csendben egy korábbi visszajátszás eredményét.

A nyilvános API továbbra is dátumot jeleníthet meg. Belül ennek a dátumnak egy jóváhagyott
eredményre és egy pontos tudáshatárra kell feloldódnia. A történeti választónak eltárolt,
reprodukálható eredménydátumokat kell kínálnia; nem fogadhat el tetszőleges dátumot úgy, hogy a
múltat a mai legfrissebb vintage-ekből építi újra, ezt jelezve sem.

---

## 15. Hiányzás, elavultság és modellkész előkészítés

A hiányzás és az elavultság információ, nem kitörlendő érték.

A megfigyelt adatok alapja legalább a következőket különbözteti meg:

- strukturális hiány a bevezetés előtt vagy a megszűnés után;
- eltérő kereskedési és publikálási naptárak;
- szolgáltatói vagy forrásoldali hiba;
- egy elszigetelt hiányzó jegyzés;
- változatlan megfigyelés, amely elavult is lehet, meg nem is;
- hibás formátumú vagy gazdaságilag lehetetlen érték;
- aszinkron piaczárások.

A kvantitatív rétegnek meg kell őriznie az eredeti hiányzási állapotot és a későbbi imputálási
maszkot. Nem kényszerítheti nullára a hiányzó értékeket, nem töltheti előre az árakat nullhozamokká,
és nem hagyhat ki csendben egy eszközt úgy, hogy a maradék súlyokat újranormálja, hacsak egy
elfogadott szabály ezt kifejezetten meg nem engedi.

Három kérdés marad elkülönítve:

1. Mit figyelt meg ténylegesen a forrás?
2. Hogyan kanonizálták ezt a megfigyelést a jelentése megváltoztatása nélkül?
3. Milyen célspecifikus előkészítést alkalmazott a modell?

A későbbi jelölt szabályok között lehetnek teljes eseten alapuló (complete-case) szabályok, oksági
szűrés, állapottér-módszerek, EM-algoritmus (expectation-maximization) vagy többszörös imputálás.
Minden elfogadott módszernek point-in-time biztosnak kell lennie, meg kell mutatnia a maszkját,
ahol indokolt, bizonytalanságot kell jelentenie, és érzékenységvizsgálatot kell végezni rajta egy
imputálás nélküli alapesethez képest. Ha a minimális lefedettség nem teljesül, az őszinte kimenet a
„nem elérhető” vagy a tartózkodás, nem egy kitalált pontszám.

---

## 16. Döntési horizont, becslési ablak és memóriaszabály

Ezek a fogalmak összefüggenek, de nem felcserélhetők.

| Fogalom | Jelentés |
|---|---|
| `decisionHorizon` | A jelen vagy jövőbeli időszak, amelyre a kockázati állítás vonatkozik |
| `estimationWindow` | A becslő számára elérhetővé tett megfigyelések történeti időtartama |
| `memoryPolicy` | Hogyan súlyozzák, felejtik, mintavételezik újra vagy irányítják az ezen az információs történeten belüli megfigyeléseket |

Például:

```yaml
decisionHorizon:
  targetTiming: contemporaneous
  forecastHorizon: null

estimationWindow: 5y

memoryPolicy:
  type: exponentially_weighted
  halfLife: 60bd
```

A becslő öt év megfigyelését láthatja, miközben sokkal nagyobb súlyt ad a friss adatoknak. Ez nem
ugyanaz, mint egy hatvannapos gördülő ablak.

A jelenlegi tervezési irány az, hogy az `estimationWindow` hosszú távon lehetséges felhasználói
választó maradjon, de ne tetszőleges szabad szöveg. A backendnek csak a kiválasztott kockázati
célhoz, döntési horizonthoz és elfogadott modellprofilhoz elfogadható értékeket kell visszaadnia. Egy
EVT-alapú farokbecslő sokkal több effektív farokmegfigyelést igényelhet, mint amennyit egy rövid
UI-ablak biztosít; egy volatilitásmodell más értékkészletet támogathat. A nem kompatibilis
kombinációknak explicit hibára kell futniuk.

A becslési ablak megváltoztatása általában egy becslő-érzékenységi változatot választ ki, nem új
üzleti estimandot. Nem kell, hogy megváltoztassa a szemantikai kontextusazonosítót, de része kell
legyen a kérés-, cache-, eredmény- és futásazonosságnak. Minden megjelenített kombinációhoz tesztek
és eltárolt, jóváhagyott eredmény kell. Egy felhasználói kérés nem indíthat élő, teljes
újratanítást vagy adatletöltést.

A konkrét ablak-engedélylista (whitelist), az alapérték és a memóriaszabály nyitott marad, amíg az
első kockázati célt és a jelölt módszereket össze nem hasonlítják.

---

## 17. Azonosság és eredet

A bétának több külön azonosságra van szüksége, mert ezek különböző kérdésekre felelnek.

| Azonosító | Mit azonosít |
|---|---|
| `context_id` | A döntési kérdést: univerzum, nézőpont, horizont, célszemantika és az aggregált csomópont jelentése |
| `risk_target_id` | A pontos, felhasználó felé megjelenő estimandot |
| `model_profile_id` | Az elfogadott transzformációkat, becslőt, memóriaszabályt, paramétereket és elfogadhatósági szabályokat |
| `run_id` | Egy konkrét futtatást egy megadott bemeneti snapshoton és kódverzión |
| `snapshot_id` | A megváltoztathatatlan megfigyelt-adat snapshotot |
| `quant_input_contract_version` | A modellkész bemenetek séma- és szemantikai verzióját |

Új kontextusazonosító akkor indokolt, ha az univerzum, a szakpolitikai nézőpont, a döntési horizont,
a kockázati cél vagy a gazdasági értelmezés változik. Általában nem szükséges eltérő `asOf`, UI-alapérték,
hibajavítás, új futás vagy ugyanannak a célnak egy alternatív becslője miatt. Ezek a különbségek a
többi azonosságon keresztül láthatók maradnak.

A kontextusazonosító működési szempontból is hasznos. Megakadályozza, hogy a különböző kérdésekre
válaszoló eredmények összekeveredjenek a tárolásban, a cache-ben, az API-válaszokban vagy az
átnézési termékekben. A kötelezettség (obligation) azonossága a bétában fogalmilag:

```text
API-komponens-azonosító × befagyasztott kontextusazonosító
```

A pontos első kontextusazonosítót csak azután szabad kiadni, hogy a szemantikai mezők emberi
jóváhagyást kaptak.

---

## 18. Kötelezettségenkénti kvantitatív munkafolyamat

Minden UI-kötelezettség egy kutatástól átadásig tartó ciklust követ. A ciklus elég könnyű ahhoz, hogy
támogassa az iterációt, de elég szigorú ahhoz, hogy megőrizze a jelentést és az evidenciát.

1. **Feltárás (Explore).** Ötletelés az üzleti kérdésről, a lehetséges estimandokról, a várt
   viselkedésről és a hibamódokról, egy technika idő előtti kiválasztása nélkül.
2. **Kutatás (Research).** Célzott, forrásvezérelt kutatás azokról a matematikai, piaci és
   adatkérdésekről, amelyek megváltoztathatják az eredményt.
3. **Összehasonlítás (Compare).** Több módszer megtartása, ha valóban különböző kérdésekre felelnek,
   vagy hasznos viszonyítási alapot (benchmark) adnak.
4. **Specifikálás (Specify).** A kiválasztott estimand, a feltevések, bemenetek, kimenetek,
   mértékegységek és API-mezők rögzítése.
5. **A várt viselkedés előzetes rögzítése (Pre-commit expected behavior).** A nyugodt és stresszes
   időszakra, az irányra, a hiányzásra és a rezsimekre vonatkozó elvárások kimondása, mielőtt a
   történeti eredményábrákat megnéznénk.
6. **Formalizálás (Formalize).** A komoly implementációs jelöltekhez minimálisan elégséges
   matematika megírása.
7. **Szerződés (Contract).** Egy verziózott QuantInputContract és egy típusos eredményszerződés
   befagyasztása.
8. **Szintézis (Synthesize).** Determinisztikus szintetikus adat és megnevezett tesztesetek
   készítése, beleértve a hiba- és a nem támogatott bemeneti eseteket.
9. **Implementálás (Implement).** Tiszta (pure), típusos Python modellmag írása adatbeszerzés és
   adatbázis-írás nélkül.
10. **Ellenőrzés (Verify).** Egység-, tulajdonság- (property), hiba-, rezsim-, reprodukálhatósági és
    előretekintés-mentességi (no-look-ahead) tesztek futtatása.
11. **Megjelenítés (Render).** Átnézhető táblázatok, ábrák és diagnosztika előállítása futásonként,
    csendes felülírás nélkül.
12. **Leképezés (Map).** Az elfogadott eredménymezők leképezése a releváns API-válaszszerződésre.
13. **Bírálat (Judge).** Emberi átnézés, amely elfogadja, átdolgoztatja, elutasítja vagy elhalasztja
    a jelöltet.
14. **Csomagolás (Package).** Az elfogadott eredmény elérhetővé tétele egy vékony futtatható
    állományon vagy adapteren keresztül.

Nem minden ötletelt gondolat kap teljes formalizálást vagy implementációt. A formalizálás akkor
kezdődik, amikor egy jelöltet tudatos összehasonlításra vagy implementációra kiválasztanak.

---

## 19. Függőségbiztos kötelezettség-ütemterv

Az API-architektúra frontend-komponenseket sorol fel; a kvantitatív szállításnak azokat a nem látható
előfeltételeket is reprezentálnia kell, amelyektől ezek a komponensek függenek.

### 19.1 Közös előfeltételek

```text
közös tudásalap
→ a szemantikai szűrőkontextus befagyasztása
→ point-in-time időbeli szerződés
→ típusos mértékek és elfogadhatósági szabályok
→ QuantInputContract
→ determinisztikus szintetikus fixture-családok
→ primitív kockázatimérték-képességek
```

### 19.2 R1 — csomópont- és doménkockázati alap

| Tervezési képesség | API-cél | Fő előfeltétel |
|---|---|---|
| Csomóponti kockázati index | `GET /nodes/{nodeId}/risk-index` | Elfogadott csomópontkockázati estimand és modellkész idősorok |
| Kiválasztott csomópont összegzése | `GET /nodes/{nodeId}/selected-summary` | Aktuális csomópontkockázati eredmény |
| Gyerekcsomópontok összegzése | `GET /nodes/{nodeId}/child-nodes-summary` | Alapcsomóponti eredmények és diagnosztika |
| Szektor-/doménösszegzés | `GET /sector-summary-table` | Aggregált és alapszintű metrikák, például volatilitás, tartósság és farokkockázat |
| Delta-elemzés | `GET /delta-analysis` | Point-in-time becslések az aktuális és az összehasonlítási dátumra |
| Kockázatkoncentráció | `GET /nodes/{nodeId}/risk-concentration` | Külön megindokolt hozzájárulási/allokációs szabály |

### 19.3 R2 — csak csomópontokat tartalmazó gráfvetületek

Az aggregált és a kibontott kockázati térkép csomópontjai, a csomópontra vitt egér (hover) és a
lefúrási interakciók kezdetben az elfogadott csomóponti eredmények vetületei lehetnek. Az első, csak
csomópontokat tartalmazó térképhez nem kell transzmissziós éleknek létezniük.

### 19.4 T1 és T2 — transzmisszió, láncok és makrohatás

A transzmisszió csak azután kezdődik, hogy léteznek elfogadott csomóponti idősorok. Saját célt,
irányt, identifikációs szabályt, bizonytalanságot és validációt igényel. Az élvetületek ettől a
magtól függenek; a kockázati láncok az irányított élektől; a magyar makrohatás pedig vegyes
frekvenciás, piacról makróra vezető módszertant tesz hozzá.

### 19.5 N1 — riasztások, narratívák és külső információ

A riasztások, figyelési pontok, értelmezések, hírek és generált elemzések az elfogadott kvantitatív
kimenetektől, valamint további szerkesztési vagy külső forrásokra vonatkozó szabályoktól függenek.
Nem helyettesítik a kockázati alapot.

Ez a struktúra irányított körmentes gráf (DAG), nem feltétlenül egyetlen hosszú soros lista. A
független primitív metrikák ugyanabban a függőségi rétegben lehetnek, és később összehasonlíthatók az
előfeltételek megsértése nélkül.

---

## 20. Az első kvantitatív vertikális szelet

Az első vertikális szeletnek, a `VS-001`-nek a teljes munkafolyamatot végig kell járnia transzmisszió
nélkül.

Tervezett hatóköre:

1. egy szemantikai kontextus befagyasztása;
2. egy aggregált domén kiválasztása kis befogadott gyerekhalmazzal;
3. először determinisztikus szintetikus bemenetek használata;
4. történeti kockázatiindex-idősorok számítása az alapcsomópontokra;
5. egy időben változó aggregált/domén-idősor felépítése explicit szemantikai cél mellett;
6. ábrák és diagnosztikai táblázatok előállítása mindkét szintre;
7. szerződés szerinti válaszpéldák előállítása;
8. a futás becsomagolása egy vékony, futtatható átadás mögé.

A minimálisan szükséges, válaszséma szerinti kimenetek:

- `NodeRiskIndexResponse`;
- `NodeSelectedSummaryResponse`;
- `ChildNodesSummaryResponse`;
- a `RiskMapResponse` csak csomópontokat tartalmazó részhalmaza.

A `SectorSummaryTableResponse` természetes korai bővítés, mert az API kifejezetten volatilitási
rezsim, trendtartósság és farokkockázat mezőket vár. A `NodeRiskConcentrationResponse` maradjon
későbbi lépés, amíg a hozzájárulási és allokációs szemantikát függetlenül meg nem indokolják.

A transzmissziós élek, a láncok, a makrotranszmisszió, a hírek, a riasztások és a generált
kvantitatív elemzések kifejezetten ki vannak zárva a `VS-001`-ből.

A pilotdoménről még nem született jóváhagyás. Egy kényelmes domén nem automatikusan a helyes
választás: a kiválasztásnak egyensúlyt kell teremtenie az érthető stresszviselkedés, a tiszta
típusszemantika, az elegendő történeti hossz, a kezelhető gyerekszám és a későbbi API-bemutató
szempontjából vett relevancia között.

---

## 21. A kvantitatív réteg, a Data Layer és a backend határai

### 21.1 Kvantitatív felelősség

A quant csomag felel:

- az estimandért és a formalizálásért;
- a típusos, modellkész bemeneti szerződésért;
- a determinisztikus szintetikus fixture-ökért;
- a modellprofilhoz kifejezetten hozzárendelt transzformációkért;
- a tiszta modellszámításért;
- a bizonytalanságért, a diagnosztikáért és a tartózkodási állapotért;
- a típusos Python eredményobjektumokért;
- a kontextus-/modell-/futás-leszármazásért;
- az API-válaszmezők leképezéséért és a referencia- (golden) példákért.

### 21.2 A Data Layer felelőssége

A későbbi production Data Layer felel:

- a licencelt vagy jóváhagyott forrásból történő beszerzésért;
- a nyers payloadok megőrzéséért;
- a forrásspecifikus adapterekért;
- az üzemi ütemezésért és monitoringért;
- a production snapshotok elérhetőségéért;
- a perzisztenciáért és az adatbázis-betöltésért az egyeztetett átadás szerint.

Az elfogadott működési irány napi egy ütemezett frissítés, bár a pontos ütemezési időpont, a
monitoring és az üzemeltetési felelősség nyitott marad.

A kvantitatív interfészt már most úgy tervezik, hogy támogassa az olyan mezőket, mint a `series_id`,
`measure_id`, `node_id`, `timestamp`, `as_of`, a vintage, a publikálási késés, a mértékegység, a
deviza, a naptár, a hiányzás és az elavultság. A production integráció a Quant Data Readiness Gate-re
vár.

### 21.3 A backend felelőssége

A backend felel az autentikációért, a kérések kezeléséért, az ORM/PostgreSQL-alapú kiszolgálásért, a
végpontok implementációjáért és az API üzemi viselkedéséért. A felhasználói API-hívások jóváhagyott,
eltárolt eredményeket használnak; nem hívják a Yahoo-t, és nem futtatnak szinkron módon teljes
kutatási pipeline-t.

### 21.4 Vékony átadás

```text
validált QuantInputContract
→ tiszta Python kvantitatív hívható függvény (callable)
→ típusos eredmény
→ szerződésadapter / JSON-szerializálás
→ az adatarchitekt felelősségébe tartozó perzisztencia és kiszolgálás
```

Egy shell fájl, ha az üzemi átadáshoz szükséges, csak Python-belépési pontokat hívhat meg. Nem
tartalmazhat rejtett kvantitatív logikát.

---

## 22. Validációs filozófia

A béta a helyesség több fajtáját különíti el:

- **Egységszintű helyesség:** a függvények azt teszik, amit a helyi szerződésük kimond.
- **Adathelyesség:** az azonosságok, mértékegységek, naptárak, vintage-ek és a hiányzás konzisztens.
- **Pipeline-helyesség:** a szándékolt bemenet eljut a szándékolt számításhoz és kimeneti mezőhöz.
- **Kvantitatív viselkedés:** a becslő ésszerűen viselkedik ismert konstrukciókon és rezsimekben.
- **Point-in-time helyesség:** egyetlen jövőbeli megfigyelés, publikáció vagy revízió sem kerül egy
  korábbi eredménybe.
- **Hibakezelési helyesség:** a nem támogatott vagy elégtelen bemenetek explicit hibára futnak vagy
  explicit tartózkodást eredményeznek.
- **Reprodukálhatóság:** ugyanazok a governált bemenetek, ugyanaz a kód és ugyanaz a profil ugyanazokat
  a termékeket állítja elő.
- **Emberi elfogadhatóság:** a kimenet alkalmas a kimondott döntési felhasználásra, és nem állít
  többet, mint amennyit alátámaszt.

Egy zöld tesztkészlet csak a tesztekbe kódolt állításokat bizonyítja. Nem bizonyítja a gazdasági
érvényességet, az oksági értelmezést vagy a döntési hasznosságot. A történeti validációnak nyugodt és
stresszes időszakokat is tartalmaznia kell, de a várt kvalitatív viselkedést le kell írni, mielőtt az
eredményábrákat átnéznék. A hiányzó vagy nem elfogadható értékek explicitek maradnak, nem alakítjuk
át őket nullává.

---

## 23. Amit a béta még nem állít

A KB-0 állapotában a projekt **nem** állítja:

- hogy általános megoldása van a teljes szűrőrácsra;
- hogy van befagyasztott első szűrőkontextus;
- hogy van elfogadott csomópontkockázati becslő;
- hogy van production-kész vagy licencelt piaci adatforrás;
- hogy kész a QuantInputContract;
- hogy van production adatbázis- vagy ORM-integráció;
- hogy van oksági transzmissziós hálózat;
- hogy van rendszerszintű hozzájárulási becslés;
- hogy van validált kockázatilánc-módszertan;
- hogy vannak magyar makrotranszmissziós becslések;
- hogy megtörtént a vállalati szintű összetevők point-in-time rekonstrukciója;
- hogy egy ETF ára megegyezik a mögötte álló gazdasági piaccal;
- hogy mind a 94 registry-objektumhoz van beszerzett numerikus történet;
- hogy mind a 94 katalógusrekord kódolva és publikálva van;
- hogy az API szemléltető kockázati pontszámai vagy szűrőértékei elfogadott kvantitatív döntések;
- hogy egy tiszta történeti ábra stabil szemantikát bizonyít;
- hogy egy hivatalos összetett mutató független valós igazság egy olyan modell számára, amely
  átfedő komponenseket használ.

Ezek a korlátok tervezési határok, nem rejtett hiányosságok. Megakadályozzák, hogy az első béta
olyan állításokat tegyen, amelyeket az adatai és módszerei nem tudnak alátámasztani.

---

## 24. Nyitott döntések és emberi kapuk

A következő döntésekre az első kvantitatív vertikális szelet előtt vagy közben van szükség.

| Döntés | Miért fontos | Mi függ tőle | Lezárási evidencia |
|---|---|---|---|
| Az első béta végleges döntési horizontja | Meghatározza a jelenre vagy jövőre vonatkozó célszemantikát | Címkék, validáció és elfogadható modellcsaládok | Ember által elfogadott kontextusdöntés |
| Első kockázati cél | Meghatározza, mit jelent a csomóponti pontszám | Formalizálás, bemenetek, tesztek és API-címkék | Aláírt estimand-specifikáció |
| Primitív vagy felső szintű metrikák | Megakadályozza, hogy a diagnosztikát külön terméknek nézzék | A riskIndex-szűrő és a szektorösszegzés mezői | Kockázatimérték-katalógus döntés |
| Az aggregált csomópont szemantikai célja | Elkülöníti a közös stresszt, a rendellenességet, a szélességet és a portfólióveszteséget | Aggregált modelljelöltek | Ember által elfogadott szemantikai definíció |
| A befogadott mértékek halmaza | Megakadályozza a ticker-szintű vagy típusok közötti kétértelműséget | QuantInputContract és fixture-ök | Típusos befogadási rekord/profil |
| Hiányzás és minimális lefedettség | Meghatározza, mikor létezik eredmény | Aggregálás és hibaviselkedés | Előre rögzített szabály és tesztek |
| A becslési ablakok engedélylistája | Megakadályozza a nem elfogadható UI-kombinációkat | Szűrő-metaadatok és eltárolt futások | Cél/profil kompatibilitási mátrix |
| Memóriaszabály | Meghatározza a történeti súlyozást és az effektív mintát | Jelölt becslők | Elfogadott modellprofil |
| Pontszámskála és állapothatárok | Jelentést ad a 0–1 pontszámoknak és a UI-állapotoknak | Kockázati térkép és összegzések | Előre rögzített küszöb-specifikáció |
| Futásidejű alapértékek | Beállítja a kezdeti UI-állapotot a modell újradefiniálása nélkül | A filter-options végpont | Backend/quant konfigurációs jóváhagyás |
| Pilotdomén és gyerekei | Meghatározza az első, korlátozott adatproblémát | A `VS-001` implementációja | Explicit munkacsomag-kiválasztás |
| Kontextusazonosító | Stabil kötelezettség- és eredményazonosságot hoz létre | Minden válaszra kész termék | Befagyasztott kontextus-manifeszt és hash |
| Backend-átadási szerződés | Tisztázza a fájlokat, a CLI-t, a JSON-t és a felelősséget | Integrációs tesztelés | Közösen átnézett interfészrekord |

Emberi jóváhagyás továbbra is szükséges ott, ahol a charter a jelentés, az elfogadhatóság vagy a
döntési felhasználás megállapítását a tulajdonoshoz rendeli. Egy ágens vagy egy tesztkészlet nem
léptethet elő csendben egy jelöltet döntéssé.

---

## 25. Együttműködési és repository-szabályok

- Egyszerre csak egy feladat írhat a master ágra.
- Csak olvasási célú vizsgálat és tervezési egyeztetés folyhat, amíg egy másik sáv ír, de egyetlen
  fájl sem módosul, amíg a tulajdonos kifejezetten át nem adja az írási jogot.
- A tiszta munkakönyvtár önmagában nem engedély; az átadásnak explicitnek kell lennie.
- A commithoz és a pushhoz külön engedély kell.
- A befagyasztott Catalog Factory- és KYI-szerződések kívül esnek a kvantitatív sáv módosítási körén.
- A `proxy_registry_v1` változtatásához új registry-verzió és döntési rekord kell.
- A generált átnézési termékeket futásonként tárolják, és nem írják felül csendben.
- A megoldatlan konvergenciapontokért pontosan egy aktív tervezési sávnak kell felelnie.
- A lényeges matematikai, piaci, architekturális és munkafolyamatbeli tanulságoknak tartós forrás-
  vagy repository-feljegyzést kell hagyniuk, és ahol indokolt, fel kell venni őket a
  `LEARNING_REGISTRY.md`-be.
- A kollégáknak szóló összefoglalók soha nem írják felül a tulajdonos hatóságokat.

---

## 26. Javasolt olvasási útvonal

### Tizenöt perces tájékozódás

Olvasd el:

1. a KB-0 1–3. szakaszát;
2. az 5. szakaszt („A befagyasztott piaci univerzum”);
3. a 9. szakaszt („A szűrőkontextus jelenlegi döntési állapota”);
4. a 19–20. szakaszt (ütemterv és az első vertikális szelet);
5. a 23. szakaszt („Amit a béta még nem állít”).

### Egyórás kvantitatív bevezetés

Ehhez add hozzá:

1. a 6–7. szakaszt az adatokról és az eszközökről szóló tudásról;
2. a 10–17. szakaszt a horizontról, a célokról, a típusos mértékekről, az aggregált csomópontokról és
   a point-in-time azonosságról;
3. a 18. és a 22. szakaszt a munkafolyamatról és a validációról.

### Mély repository-bevezetés

Kövesd a 28. szakasz forrástérképét, majd csak az éppen végzett feladat munkacsomagját és lezárási
evidenciáját olvasd el. A teljes repositoryt ne kezeld differenciálatlan utasításhalmazként.

---

## 27. Szószedet

| Fogalom | Jelentése ebben a projektben |
|---|---|
| **Csomópont (node)** | Gráfobjektum, amelyhez a rendszer kockázati eredményeket és képességeket tárolhat |
| **Alapcsomópont (underlying node)** | Egy aggregált domén alatti befogadott eszköz, részpiac vagy típusos mérték |
| **Aggregált csomópont (aggregate node)** | Befogadott információból felépített, domén-szintű matematikai objektum |
| **Piaci kockázati domén (market-risk domain)** | A befagyasztott taxonómia tizenkét típusos gyökérkategóriájának egyike |
| **Kockázati cél / estimand (risk target / estimand)** | Az a pontos mennyiség, amelyet a felhasználó a rendszerrel becsültetni akar |
| **Becslő (estimator)** | A cél becslésére használt matematikai eljárás |
| **Kockázati index (risk index)** | Az API/felhasználói felület választója egy elfogadott kockázati fogalomhoz; nem automatikusan módszernév |
| **Döntési horizont (decision horizon)** | A jelen vagy jövőbeli időszak, amelyre a kockázati állítás vonatkozik |
| **Becslési ablak (estimation window)** | A becslő számára elérhetővé tett történeti időtartam |
| **Memóriaszabály (memory policy)** | A történeti információ súlyozásának, felejtésének, újramintavételezésének vagy irányításának szabálya |
| **`asOf`** | A döntési időpontbeli határ, amely meghatározza, milyen információ használható |
| **Vintage** | Megváltoztathatatlan forrás- vagy snapshot-változat, amely azt reprezentálja, mi volt elérhető egy adott időpontban |
| **Publikálási késés (publication lag)** | Egy megfigyelés és publikálása/elérhetősége közötti késés |
| **Hiányzás (missingness)** | Egy megfigyelés típusos hiánya; soha nem automatikusan nulla |
| **Elavultság (staleness)** | Egy megfigyelés kora a várt naptárához és a kiértékelési határidőponthoz képest |
| **Mérték (measure)** | Pontosan definiált numerikus objektum, például hozam (return), hozamváltozás, spread vagy fixing |
| **Modellprofil (model profile)** | Verziózott transzformációk, becslő, paraméterek, memória- és elfogadhatósági szabályok |
| **Szűrőkontextus (filter context)** | A döntési kérdés és a válasz előállításához támogatott választók |
| **Kötelezettség (obligation)** | Egy API-komponens egy befagyasztott kontextusban, a kiszolgálásához szükséges számítással vagy vetülettel együtt |
| **Validációs idősor (validation series)** | Modellen kívüli összehasonlító; nem automatikusan bemeneti jellemző |
| **Szintetikus fixture (synthetic fixture)** | Determinisztikus, tervezett adat, amellyel a várt viselkedés és a hibák igazolhatók |
| **Eltárolt jóváhagyott eredmény (persisted approved result)** | Validált offline modellkimenet, amely később élő újraszámolás nélkül kiszolgálható |
| **Tartózkodás (abstention)** | Explicit kijelentés, hogy a megadott bemenetből nem állítható elő elfogadható eredmény |

---

## 28. A repository forrástérképe

Az alábbi útvonalak a repository gyökeréhez képest relatívak.

### Alapvető hatósági és navigációs dokumentumok

- `srm_beta_quant/BETA_CHARTER.md` — hatókör, hatáskör, munkafolyamat és döntési napló.
- `srm_beta_quant/CURRENT_STATE_AND_NEXT_STEPS.md` — a jelenlegi visszatérési állapot és a
  függőségbiztos ütemterv.
- `srm_beta_quant/README.md` — munkamenetenkénti olvasási sorrend és navigáció.
- `srm_beta_quant/LEARNING_REGISTRY.md` — az átvihető tanulságok indexe.

### Piaci univerzum

- `srm_beta_quant/MARKET_UNIVERSE_RECOMMENDATION.md` — jóváhagyott taxonómia és a befogadás
  indoklása.
- `srm_beta_quant/registry/proxy_registry_v1.yaml` — befagyasztott, géppel olvasható tagság és
  szerepek.
- `srm_beta_quant/research/market_universe/` — részletes kutatás és állítás-/forrásnyilvántartás.

### Adatalap

- `srm_beta_quant/DATA_FOUNDATION_ARCHITECTURE.md` — a megfigyelt adatok határa és a futásidejű
  folyamat.
- `srm_beta_quant/work_packages/WP-DF-001.md` — az engedélyezett alapozó munka.
- `srm_beta_quant/work_packages/WP-DF-001_COMPLETION.md` — implementációs, teszt-, snapshot- és
  jóváhagyási evidencia.
- `srm_beta_quant/data/README.md` — a generált termékek és a visszajátszás dokumentációja.

### Eszköztudás és Catalog Factory

- `srm_beta_quant/research/instrument_catalog/PILOT_SELECTION.md` — a befagyasztott heterogén pilot.
- `srm_beta_quant/work_packages/WP-KYI-001_PILOT_PROGRESS.md` — a pilot döntései és állapota.
- `srm_beta_quant/research/instrument_catalog/KYI_QUALITY_BENCHMARK.md` — az elfogadott emberi
  kimeneti mérce.
- `srm_beta_quant/work_packages/WP-KYI-002_COMPLETION.md` — a szerződés-befagyasztás evidenciája és a
  Gate E.
- `srm_beta_quant/work_packages/WP-KYI-003.md` — a Catalog Factory és a migrációs csomag.
- `srm_beta_quant/catalog/README.md` — a Factory felépítése, ellenőrzése és az aktív generáció
  navigációja.
- `srm_beta_quant/work_packages/WP-KYI-003_CP2_8_COMPLETION.md` — a CP-2.8 lezárása és az emberi
  megállási pont evidenciája.
- `srm_beta_quant/catalog/contract/decisions/gate_2_closure_record.yaml` — az irányadó Gate 2 döntési
  rekord.
- `srm_beta_quant/work_packages/WP-KYI-003_GATE_2_CLOSURE_PROPAGATION.md` — navigáció-továbbvezetési
  csomag; státuszát az irányadó lezárási rekorddal és a commitolt navigációs állapottal együtt kell
  olvasni.
- `srm_beta_quant/work_packages/WP-KYI-003_AMENDMENT_SE.md` — a forrás-határidőpontkor megkezdett
  utódmunka.

### Szűrőkontextus és kötelezettségek

- `srm_beta_quant/FILTER_CONTEXT_SCHEMA.md` — konfigurációs rétegek és a kontextus nyitott
  döntéseinek sorrendje.
- `srm_beta_quant/OBLIGATION_MAP.md` — komponenslefedettség és függőségi sávok.
- `systemic-risk-api-architecture.md` — a mérvadó végpontok és válaszsémák.

---

## A. függelék — Mérföldkövek idővonala

| Dátum | Mérföldkő |
|---|---|
| 2026-08-28 | A típusos piaci kockázati domének és a `proxy_registry_v1` jóváhagyva |
| 2026-08-28 | A Sandbox Data Foundation lezárva, tiszta eredetű aláírt snapshottal |
| 2026-08-28 – 2026-08-31 | A tizenkét objektumos KYI pilot lezárva három heterogén tételben |
| 2026-09-02 | A KYI v2 koncepció és a gépi szerződések Gate E-je elfogadva |
| 2026-09-03 – 2026-09-07 | A Gate 1-H szerződésrendezés, ellenőrzés, adverzális átnézés és lezárás |
| 2026-09-11 – 2026-09-18 | A Catalog Factory CP-2 implementációs és javítási sorozata |
| 2026-09-18 | A Gate 2 elfogadva és lezárva a commitolt navigációs állapotban |
| 2026-09-18 | Az AMENDMENT-SE engedélyezve; a C1 governance-bootstrap később `de4532c`-ként commitolva |
| 2026-09-21 | A KB-0 jelölt elkészült a repositoryn kívül, miközben a katalógus utódmunkája folytatódik |

---

## B. függelék — Szemléltető példa az első kontextusjelöltre

Az alábbi példa csak magyarázó jellegű. Nem befagyasztott kontextus, és nem használható
implementációs felhatalmazásként.

```yaml
contextId: pending-human-sign-off

universe:
  partitionRule: typed_market_risk_domains_v1
  marketUniverseScope: global_market_proxies
  policyLens: hungary
  proxyRegistryVersion: proxy_registry_v1
  measurementCurrencyPolicy: native_quote_returns

decisionHorizon:
  targetTiming: contemporaneous
  forecastHorizon: null
  evaluationFrequency: daily
  decisionUse: short_term_monitoring

riskTarget:
  riskTargetId: market-stress-intensity-v1
  status: candidate

aggregateNodeSemantics:
  target: domain_common_stress
  interpretation: domain_level_latent_or_distributional_state
  timeVarying: true

asOfPolicy:
  mode: point_in_time
  timezone: Europe/Budapest
  exactCutoff: pending
  vintageSafe: true

estimationWindow:
  status: pending-admissibility-research

memoryPolicy:
  status: model-profile-specific

runtimeDefaults:
  status: deferred-until-first-model-evidence
```

---

## C. függelék — A tudásalap módosítási protokollja

A KB-0 egy evidencia-határhoz kötött pillanatkép. Terjesztése után nem szabad csendben átírni.

Egy későbbi frissítésnek ki kell mondania:

1. az előző tudásalap azonosítóját;
2. az új repository evidencia-határt;
3. a hozzáadott, megváltoztatott vagy felváltott döntéseket;
4. a lezárt implementációs mérföldköveket;
5. az újonnan feloldott kötelezettségeket;
6. az új korlátokat vagy kockázatokat;
7. a hivatkozásokat a tulajdonos döntési és lezárási termékekre.

A kisebb ténybeli javítások kifejezetten verziózott KB-0-javításként adhatók ki. A lényeges kontextus-,
modell- vagy ütemterv-változásoknak új, konszolidált tudásalapot kell eredményezniük (például KB-1),
miközben a KB-0 a nyomon követhetőség érdekében megmarad.
