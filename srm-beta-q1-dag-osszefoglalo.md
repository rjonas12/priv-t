# SRM Beta Quant – Q1 DAG és Obligation Map v2 összefoglaló (magyar)

> Források: Iván `DEPENDENCY_DAG_AND_BACKLOG_V1.md` és `OBLIGATION_MAP_V2.md` (mindkettő 2026-09-22). Gépi forrás: `dependency_graph_v1.yaml`, tesztek: `tests/obligations/test_dependency_graph.py`. Irányadó munkacsomag: `WP-QUANT-001`.
> Feldolgozva: 2026-09-22. A KB-0 összefoglalóra épül (`srm-beta-kb0-osszefoglalo.md`), itt csak az új vagy változott elemek szerepelnek.

## Egy percben
- **Q0 kész:** a kontextus be van fagyasztva: `srm-beta-market-stress-daily-v1`. A KB-0-ban ez még nyitott volt.
- **Q1 elfogadva (Human Stop Q1, 2026-09-22):** elkészült a függőségi gráf és a 23 UI-kötelezettség sorrendje.
- **Következik a Q2:** az 1. kötelezettség, a `node-risk-index` specifikációja. Ez a Q-fázis neve, nem „a 2. UI elem”.
- **Napi munkarend:** egyszerre egy kötelezettséget nyitunk meg, végigvisszük a 9 lépéses körön, backend-átadással zárjuk, és csak utána lépünk a következőre. A DAG és a hullámok háttér- és biztonsági bizonyítékként szolgálnak, a napi munkát nem ezek vezérlik.
- **A Q1 nem választ módszert.** EWMA, GARCH, PCA, EVT stb., valamint a pilot domén, az ablakok és a küszöbök mind Q2-es vagy későbbi döntések.

## Mit jelentenek a Q-fázisok (a `WP-QUANT-001` szakaszai)
| Fázis | Jelentés | Állapot |
|---|---|---|
| Q0 | A kérdés rögzítése: egy kontextus, azonos információs-idő szabályok | Kész |
| Q1 | Biztonságos sorrend: minden UI/API kötelezettség, valódi előfeltételei, sorrend | Kész, elfogadva |
| Q2 | Az 1. kötelezettség specifikálása: üzleti kérdés, estimand, API-kimenet, befogadott bemenetek, jelölt módszerek, tesztek. Még **modellkód nélkül** | Következik |
| Q3 | Csak a Q2-ben jóváhagyott jelöltek implementálása, előre rögzített tesztek, kvantitatív elfogadás | – |
| Q4 | Leképezés az API-szerződésre, vékony futtatható átadás a backendnek | – |

Q4 után a többi kötelezettség ugyanezt a kört járja be: specifikálás → implementálás vagy újrafelhasználás → validálás → leképezés → átadás.

## A fő elméleti újdonság: négy különböző kapcsolat
„A UI-függőségi gráf” valójában négy különböző kérdés, és ezek nem cserélhetők fel egymással:

1. **Kemény függés (hard dependency).** `A → B`, ha B nem számolható, nem validálható vagy nem szolgálható ki igazmondóan elfogadott A nélkül. Ezek az élek körmentesek, és ezek adják a topologikus szinteket. 140 ilyen él van.
2. **Minimális teljesítés (minimum fulfillment).** A legkisebb *becsületes* válasz ahhoz szükséges elemei. Ez egyben kemény függés is, de nem jelenti azt, hogy a válasz később nem bővülhet. 36 link.
   - Példa: a `NodeRiskIndexResponse`-hoz elég a kockázati idősor és a delta.
3. **Bővítés (enrichment).** Később jövő képesség, amely mezőket ad egy már használható válaszhoz, de **nem blokkolja** a minimumot. 14 link.
   - Példák: transzmissziós élek a node-only risk-mapen; a legerősebb élek a node hoveren; a volatilitás-, persistence- és tail-oszlopok a child táblában.
4. **Újrafelhasználás (reuse).** Egy implementáció vagy eredmény több fogyasztót szolgál ki, szerződés- és befogadási ellenőrzés után. **Nem hoz létre függőséget** pusztán azért, mert lehetséges.
   - Példa: egy jóváhagyott node-risk eredmény öt vagy több vetületet táplál.

Mellé jön a **végrehajtási sorrend**: a függőség szempontjából biztonságos lépések közül mi legyen előbb, figyelembe véve a bizonytalanságot, a ráfordítást, az újrafelhasználási értéket és a stratégiát.

Tanulságok:
- Attól, hogy valami újrafelhasználható, még nem univerzálisan érvényes.
- Egy technikailag könnyű UI mögött is lehet nehéz kutatás.
- Egy bővítés soha nem blokkolhatja a korábbi minimumot.
- Ami topologikusan már lehetséges (pl. a hírek), az stratégiailag lehet késői.

## Újrafelhasználás: igen, de nem típus nélküli pointerrel
Ez válasz a KB-0-nál felvetett „pointeres pipeline” kérdésre.

Helyes forma:
```
megfigyelt értékek → instrumentum/mérték-specifikus oksági adapter
→ típusos prepared-measure szerződés → model_profile által kiválasztott becslő
→ típusos kockázati eredmény (diagnosztika + lineage) → jóváhagyott, eltárolt eredmény
→ több tiszta (pure) válasz-vetület
```
Hibás forma: `UI shell → tetszőleges függvénypointer → nyers heterogén idősor`.

- **Az endpoint shell** nem választ modellt, nem tölt le adatot, és nem végez rejtett előfeldolgozást. Csak lekér egy elfogadott típusos eredményt, és azt vetíti a válaszszerződésre.
- **A „pointer” a gyakorlatban** egy verziózott registry vagy dependency-injected callable lesz, `model_profile_id` szerint kulcsolva. Több node is mutathat ugyanarra az implementációra.
- **Az újrafelhasználás feltételei** (mindnek teljesülnie kell):
  - azonos a felhasználói estimand;
  - egy típus-specifikus adapter azonos prepared-measure szemantikát állított elő;
  - kompatibilis az egység, a kedvezőtlen irány, a naptár, a hiányzó adat és az elavultság kezelése;
  - a modellprofil explicit befogadja az instrumentum–mérték párt;
  - ugyanazok a viselkedési és no-look-ahead tesztek átmennek;
  - a hiba vagy az abstention explicit marad.
- **Az aggregált becslő külön képesség.** Időben igazított gyerek- és horgonypanelből becsül doménállapotot. A primitíveket (normalizálás, hiányzó adat, eredmény, állapot, vetület) megoszthatja, de nem automatikusan ugyanaz a callable, mint az underlying becslőé.

### Adapter-mátrix (interfésztervként, nem módszerválasztásként)
| Bemenetcsalád | Valószínű prepared measure | Nyitott kérdések | Újrahasználás |
|---|---|---|---|
| Részvény/kötvény ETF | Total vagy adjusted return | Árfolyammező, osztalék, adjusted history, deviza, naptár | Közös underlying becslő, ha a szemantika azonos és a tesztek átmennek |
| Állampapír-hozamindex | Hozamváltozás (vagy indokolt szint/eltérés) | Egység, bp, görbe iránya, negatív vagy nulla közeli értékek | Külön hozam-adapter; nem mehet csendben hozamra épülő becslőbe |
| Származtatott relatív ár | Point-in-time log-arány vagy változás a két lábból | Lábak elérhetősége, igazítás, duplikált számolás, lineage | Csak explicit derived measure után |
| FX spot/index | Irányított hozam, deklarált kedvezőtlen iránnyal | Jegyzési konvenció, policy lens, aszimmetria | Csak rögzített orientáció után |
| Implikált volatilitás index | Szint, változás vagy eltérés, külön szemantikával | Mean reversion, skála, validáció vagy score input szerep | Általában külön adapter és profil |
| Folytonos futures proxy | Halasztva | Roll-módszertan, rések, back adjustment | Nem engedhető be csak azért, mert van adat |
| Aggregált gyerekpanel | Időben igazított típusos gyerek- és horgonyállapot-panel | Súlyozás, közös mozgás vs. kedvezőtlen irány, változó lefedettség | Külön aggregált becslő-interfész; közös eredmény- és vetület-primitívek |

A pilot legyen egy körülhatárolt, közgazdaságilag koherens csoport, amely nem kényszerít egyszerre minden adaptercsaládot. A pilot kiválasztása Q2-es döntés.

## Kvantitatív képesség-DAG (a node- és szektorkockázati alap)
```
Frozen context + Universe → QuantInputContract v1
Observed data + Instrument admission + QIC → Typed measure preparation
QIC → Synthetic fixtures;  Admission + QIC → Risk model profile → Score/state/abstention policy
Preparation + Fixtures + Profile + Policy → Underlying-node risk series
Underlying + Universe + Profile + Policy → Aggregate-domain risk series
Underlying + Aggregate → Persisted typed history → Point-in-time delta → Child ranking
Underlying + Aggregate → Contribution contract → Contribution/allocation
History → Attribution estimand → Driver attribution + confidence
Admission + Preparation + Fixtures → Sector-metric profiles → Volatility | Persistence | Tail → Sector-metric deltas
```
Három szándékos következmény:
1. **Az aggregált érték alapból nem súlyozott átlag.** Elfogadott gyerekállapot-jelekre épül, de saját estimand és becslő kell hozzá, amelyről Q2/Q3 döntés születik.
2. **A volatilitás-rezsim, a persistence és a tail testvérek.** Közös bemenetből dolgoznak, de nem függenek egymástól és az aggregált indextől sem, ezért párhuzamosan kutathatók.
3. **A hozzájárulás/koncentráció nem ingyen melléktermék.** Külön elfogadott allokációs szabály kell hozzá.

## Transzmisszió: lejjebb a gráfban
Elfogadott node-histories + QuantInput időszerződés → igazított node-panel → (transzmissziós estimand + identifikáció) → irányított hálózat. Ebből jönnek:
- élek története, deltája és rangsora, valamint belső/külső határosztályok → él-vetületek (map, táblák, kártyák, hover);
- útvonal-jogosultság és rangsorolási szabály → láncok → láncválasztás;
- magyar makrohatás.

Ez **projektsorrendi** függés. Nem azt jelenti, hogy a transzmisszió a 0–1-es kijelzett score-t fogja használni. A későbbi transzmissziós specifikáció választhat gazdagabb node-jelet ugyanabból a modelleredményből, de a node-kockázatot nem definiálhatja át csendben.

## VS-001: az első vertikális szelet
Hat kötelezettség, egyenként és sorban (a 8. fejezet 1–6. sora), mindegyiknek saját leképezéssel, átadással és review-val:
1. `GET /nodes/{nodeId}/risk-index`
2. `GET /nodes/{nodeId}/selected-summary`
3. `GET /nodes/{nodeId}/child-nodes-summary` (minimum: kockázat + mozgás)
4. `GET /risk-map` (csak csomópontok, gyökér)
5. `GET /risk-map?expandedNodeId=...` (csak csomópontok, kibontva)
6. `GET /filter-options` (csak ténylegesen alátámasztott választási lehetőségekkel)

**Szükséges képességek:** QuantInputContract v1; típusos oksági előkészítés és maszkok; determinisztikus fixture-ök előre rögzített viselkedéssel; underlying és aggregált kockázati eredmény; állapot/küszöb/abstention szabály; eredmény-identitás és eltárolt history; point-in-time delta; child top-N szabály; approved-result selector index; típusos chart/table/JSON vetületek.

**Kizárva:** transzmissziós élek és strongest-edge mezők; láncok kiemelése; koncentráció (külön allokációs review nélkül); volatilitás-, persistence- és tail-oszlopok (egyedi elfogadás nélkül); hírek, riasztások, watchpointok, makro, generált insightok.

> Kulcselv: node-only risk-mapen az üres `edges[]` és a null láncválasztás becsületes, a kitalált placeholder élek nem. A dinamikus sémák (child tábla oszlopai, nullable hover-mezők) éppen azt teszik lehetővé, hogy ne legyen „előbb minden kvant problémát meg kell oldani” típusú monolitikus függés. Kötelező mezőt kihagyni vagy default értéket kitalálni viszont nem szabad.

## A 23 kötelezettség sorrendje (8. fejezet, ez a futtatási sor)
Skálák: 1 = alacsony, 5 = nagyon magas. **Vet.** = vetület-ráfordítás (a shell bonyolultsága), **Biz.** = kutatási bizonytalanság.

| # | Kötelezettség | Típus | Minimum-szolgáltató | Későbbi bővítés | Vet. | Biz. | Hullám |
|---:|---|---|---|---|---:|---:|---:|
| 1 | Node risk index | kvant + vetület | Eltárolt risk history + delta | Bizonytalansági sáv, ha a szerződés engedi | 2 | 2 | W4 |
| 2 | Selected-node summary | vetület | Aktuális kockázat/állapot + delta + node metaadat | Gazdagabb, aláírt narratíva | 1 | 2 | W4 |
| 3 | Child-node summary | kvant + vetület | Gyerek-kockázat + delta + top-N | Szektormetrikák, hozzájárulás, spillover | 2 | 2 | W4 |
| 4 | Root risk-map nodes | vetület | Aggregált kockázat + delta + topológia | Élek + kiemelt láncok | 3 | 2 | W4 |
| 5 | Expanded risk-map nodes | vetület | Aggregált + gyerek-kockázat + delta + topológia | Élek + kiemelt láncok | 3 | 2 | W4 |
| 6 | Filter options | vetület | Fagyasztott kontextus + approved result index | Új targetek/ablakok csak befogadás után | 2 | 2 | W4 |
| 7 | Node hover | interakció + vetület | Risk history + delta | Legerősebb élek + értelmezés | 2 | 2 | W5 |
| 8 | Delta analysis | kvant + vetület | Összehasonlítható point-in-time becslések | Összehasonlítási bizonytalanság | 2 | 3 | W6 |
| 9 | Sector summary | kvant + vetület | Volatilitás-rezsim + persistence + tail estimandok | További risk targetek | 2 | 4 | W6 |
| 10 | Risk concentration | kvant + vetület + narratíva | Aggregált allokáció/hozzájárulás + governált leírás | Érzékenység, bizonytalanság | 2 | 5 | W7 |
| 11 | Node interpretation | kvant + narratíva | Driver-attribúció + kalibrált konfidencia | Transzmisszió, külső evidencia | 3 | 5 | W7 |
| 12 | Spillover strength | kvant + vetület | Él-history, rangsor, delta | Alternatív élmetrikák | 2 | 3 | W10 |
| 13 | Edge hover | interakció + vetület | Él-összegzés + aktivitás-history | Csatorna-narratíva | 2 | 3 | W10 |
| 14 | Internal transmission | kvant + vetület + narratíva | Él-history + határon belüli osztály + narratíva | Alternatív élmetrikák, diagnosztika | 3 | 4 | W10 |
| 15 | External transmission | kvant + vetület + narratíva | Él-history + határon átnyúló osztály + narratíva | Alternatív élmetrikák, diagnosztika | 3 | 4 | W10 |
| 16 | Risk chains | kvant + vetület | Irányított háló + útkeresés/rangsor | Szcenárió-specifikus rangsor | 3 | 5 | W11 |
| 17 | Selected-chain label | interakció + vetület | Elfogadott lánchalmaz | – | 1 | 1 | W11 |
| 18 | Key triggers & alerts | kvant + vetület | Elfogadott metrika + esemény/küszöb/dwell szabály | Lánc-specifikus triggerek | 3 | 4 | W12 |
| 19 | Watchpoints | narratíva | Trigger események + monitoring logika | Lánc/hír kontextus | 3 | 4 | W12 |
| 20 | Sector news | külső integráció + vetület | Governált hírforrás + node-kapcsolás | Kvantitatív relevancia-rangsor | 2 | 4 | W13 |
| 21 | News implication | külső integráció + narratíva | Hírforrás + implikációs/kapcsolási szabály | Lánc-kontextus | 3 | 4 | W13 |
| 22 | Hungarian macro impact | kvant + vetület | Transzmissziós háló + point-in-time makro target/adat | Szcenárió-kondicionálás | 3 | 5 | W14 |
| 23 | Quantitative insights | narratíva | Elfogadott kimenetek + IT-szerződés + review policy | Transzmisszió/hír/makro | 4 | 5 | W15 |

Mintázat: az 1–7. sor alacsony bizonytalanságú, és egyetlen eredményt hasznosít újra (node-risk). A 9–11. sor új estimand-családokat nyit meg. A 12–17. sor a transzmisszióra épül. A 18–23. sor governance- és külső forrás-kérdés.

## A 9 lépéses kör egy kötelezettségen belül
1. UI-komponens és API-specifikáció megnyitása.
2. Az üzleti kérdés újra levezetése és megkérdőjelezése; javasolt kérdés és pontos válaszmezők.
3. Új estimand, egy elfogadott eredmény vetülete, vagy a kettő keveréke?
4. Módszerek összehasonlítása, vagy egy meglévő típusos képesség formális újrafelhasználása.
5. Elvárt viselkedés, minimális formalizáció, I/O szerződés, determinisztikus tesztek.
6. A tiszta kvant mag implementálása vagy újrafelhasználása, diagnosztika review-ja.
7. Leképezés az API-válaszra rejtett újraszámolás nélkül.
8. Átadás a backendnek: vékony `.sh` belépési pont, hívási dokumentáció, típusos példák, exit/hiba-viselkedés, verziózott Python belépési pont.
9. Emberi jóváhagyás, és csak utána jöhet a következő sor.

Szabályok:
- **A backlog üzleti kérdés-megfogalmazása ideiglenes**, a kötelezettség megnyitásakor pontosítható. Aláírás után viszont csak verziózott módosítással vagy formálisan újranyitott specifikációval változhat.
- **Kontextusváltozásnak számít**, ha egy változás érintené a döntési horizontot, a risk targetet, az objektumkört vagy az információs-idő szabályokat. Ezt nem szabad csendben elnyelni.
- **A `.sh` csak szállítási és reprodukálhatósági határ.** Nincs benne kvant logika, nem tölt le adatot, és nem ír a production DB-be. (Ez megerősíti a KB-0-os „shell file = csak indító” értelmezést.)
- **A mappastruktúra csak akkor bővül, amikor kell.** Csak azt a fájlt hozzuk létre, ami ténylegesen kell. Az első egy-két kör után lehet sablont elfogadni. Közös modult csak a második valódi felhasználónál emelünk ki, nem azért, mert a DAG jósolja.

## Háttér-hullámok (W0–W15) és kapuk
Prioritási szabályok, ebben a sorrendben:
1. kemény függés soha nem sérülhet;
2. a node-risk szelet zárjon a transzmisszió előtt;
3. nagy újrafelhasználás és alacsony bizonytalanság előnyben;
4. minden új estimand-család vagy nagy mérlegelést igénylő integráció előtt human stop.

| Hullám | Tartalom | Kapu |
|---|---|---|
| W0 | Q1 gráf + backlog | Human Stop Q1 ✔ |
| W1 | Underlying és aggregált estimand, `QuantInputContract v1` | Human Stop Q2 |
| W2 | Típusos adapterek, oksági maszkok, fixture-ök, profilszerződések | Automatikus szerződés- és fixture-ellenőrzés |
| W3 | Underlying jelöltek, majd aggregált jelöltek összehasonlítása | Kvantitatív elfogadás Q3 |
| W4 | VS-001 (6 válasz) | Backend handoff Q4 |
| W5 | Node hover | Viselkedés-review |
| W6 | Delta tábla + szektormetrikák (párhuzamosan) | Estimandonkénti elfogadás |
| W7 | Koncentráció + driver-értelmezés | Attribúció/konfidencia review |
| W8–W9 | Transzmisszió specifikálása, majd implementálása | Specifikációs és kvant sign-off |
| W10 | Spillover tábla, belső/külső kártyák, edge hover, térképélek | Él-vetület és narratíva review |
| W11 | Láncok + kiválasztás | Lánc-szemantika review |
| W12 | Triggerek, riasztások, watchpointok | Monitoring review |
| W13 | Hírek | Külső forrás review |
| W14 | Magyar makro | Makro módszer/adat sign-off |
| W15 | Kvantitatív insightok | IT-szerződés + tartalom review |

## Topologikus szintek (0–11), röviden
Szint = csak kemény függésekből adódó rétegzés; minden él szigorúan feljebb lép. **A szint nem prioritás.** Példa: a hírek UI-ja már a 3. szinten „technikailag lehetséges”, mégis a W13-ba került (forrás-, licenc- és governance-bizonytalanság miatt).
- 0: alapok;
- 1: szerződések és policy-k;
- 2: modellkész szerződések;
- 3: score/state szabály;
- 4: underlying kockázat és szektorprimitívek;
- 5: aggregált kockázat;
- 6: eltárolt history;
- 7: index, delta, hozzájárulás, igazított panel;
- 8: child rangsor, attribúció, transzmissziós háló, első szelet vetületei;
- 9–11: élek, láncok, makro, narratívák.

## Az elfogadott Human Stop Q1 döntések (11)
1. A négy kapcsolattípus külön tipizálva marad.
2. A UI shellek elfogadott típusos eredményt fogyasztanak; a becslő-újrahasználás registry és adapterek mögött történik.
3. A VS-001 = a hat kötelezettség, transzmisszió nélkül.
4. Az underlying megelőzi az aggregáltat, de az aggregáltnak saját becslője és kapuja van.
5. A szektormetrikák párhuzamos testvérek.
6. A koncentráció kívül esik a VS-001-en.
7. A transzmisszió az elfogadott node-idősorok után jön, és nem definiálhatja át a node-kockázatot.
8. A hírek topologikusan korán, stratégiailag későn jönnek.
9. A makro és a generált insightok későn jönnek.
10. A filter-options shell létezhet korán, de csak alátámasztott értékekkel tölthető fel (`asOf`, target, ablak = jóváhagyott eredmények).
11. Kötelezettség-specifikus módszerszerződések kellenek (szektormetrikák, allokáció, attribúció, láncrangsor). Az elfogadott upstream adat vagy score szükséges, de nem elégséges.

## Amit a Q1 NEM enged meg
- becslő kiválasztása (EWMA, GARCH, PCA, dinamikus faktor, EVT, Mahalanobis…);
- pilot domén vagy gyerekhalmaz kiválasztása;
- transzformációk, ablakok, memória, küszöbök, imputálás rögzítése;
- univerzális kockázati függvény nyers heterogén adatra;
- a kontextus, a proxy registry, a Catalog Factory vagy a KYI szerződések módosítása;
- a publikus API-architektúra módosítása;
- transzmisszió vagy generált tartalom implementálása;
- production DB-integráció.

## Gépi validáció (`test_dependency_graph.py`)
A YAML-t teszt ellenőrzi:
- körmentesség, és minden él feljebb lép;
- minden node pontosan egyszer szerepel a topologikus listában;
- UI shell nem függ másik UI shelltől;
- minden kvant képességnek van módszer- vagy estimand-szerződés elődje;
- mind a 29 `Comp.ID` pontosan egyszer van leképezve, mind a 21 endpointnak van kötelezettsége;
- minden minimum-szolgáltató egyben kemény függés is, és egy bővítés sem lett véletlenül kemény függés;
- a VS-001 lezártjában nincs transzmisszió, él vagy lánc;
- a skálák 1–5 közöttiek;
- minden reuse-állításnak vannak feltételei.

A sorrend változása csak verziózott módosítással lehetséges.

## Obligation Map v2 – mi változott a v1-hez képest
- **Identitás:** obligation = `Comp.ID × context_id`. Mivel a kontextus be van fagyasztva, stabil obligation ID-k már generálhatók; a slugok tervezési fogantyúk.
- **Kötelezettség-típusok:** kvantitatív / vetület / interakció / narratíva-integráció. Egy API-komponens nem feltétlenül önálló modell.
- **Előfeltétel-munkafolyamatok:**
  - `foundation-context`: KÉSZ;
  - `foundation-universe`: DÖNTÖTT;
  - `foundation-sandbox-data`: KÉSZ (`WP-DF-001`);
  - `foundation-instrument-review`: KÉSZ a 12-es pilotra;
  - `foundation-contract-adapter` (típusos eredményobjektumok, JSON, séma-tesztek, belépési pont): **TERVEZETT**.
- **Sávok:** R1 (node/szektor), R2 (risk-map node nézetek + hover), T1 (transzmisszió + közvetlen vetületek), T2 (láncok + makro), N1 (riasztás, értelmezés, hírek, insightok).
- **Teljes lefedettség:** 29 `Comp.ID` a regiszterben (a `spillover-strenght` elírás az eredeti API ID része).
- **Részletes sorrend:** a v2 ezt már a DAG-dokumentum 8. fejezetére bízza; a sávok csak kompakt leltárnézetként maradnak.

## Megfigyelések, apró feszültségek (Ivánnal tisztázható)
1. **Filter-options helye.** A v2 szerint a `filter-options` a `foundation-context` control-plane része, nem önálló kvant kötelezettség. A DAG-ban viszont a 6. UI-kötelezettség a VS-001-ben. Valószínűleg nincs ellentmondás (a shell korán jöhet, a feltöltése a jóváhagyott eredményektől függ), de érdemes megerősíteni.
2. **A VS-001 leírása a két dokumentumban.** A v2 4. fejezete még négy példaválaszt sorol fel (risk-index, selected, child, node-only risk-map), a DAG hatot (plusz a kibontott risk-map és a filter-options). A DAG az irányadó.
3. **Két különböző „delta”.** A delta *primitív* már a VS-001-ben kell (1–5. sor), a *Delta analysis tábla* viszont csak W6-ban jön, mert az összehasonlítás szemantikáját és bizonytalanságát külön review-zni kell. Ezt a kettőt nem szabad összekeverni.
4. **A `foundation-contract-adapter` még csak TERVEZETT**, pedig a VS-001 minden sora típusos eredményre és vetületre épül. Kérdés: része-e a Q2/W2 munkának, és ki felel érte (quant vagy Tamás)?

## Válaszok a KB-0-nál feltett kérdésekre
- **„Shell” jelentése:** a `.sh` csak szállítási határ, logika nélkül. A quant építőkocka a típusos adapter → becslő → eredmény lánc.
- **Pointeres pipeline vs. DAG:** a pointer egy `model_profile_id` szerinti verziózott registry. A DAG a függést és az újrafelhasználást külön relációként kezeli.
- **Hol kapcsolódik be Jónás:** a sor eleje a Q2, vagyis a `node-risk-index` specifikációja (W1), utána fixture-ök és adapterek (W2), majd jelölt-összehasonlítás (W3). A szektorprimitívek (volatilitás, persistence, tail) csak W6-ban jönnek.

## Szószedet
| Angol | Magyar értelmezés |
|---|---|
| obligation | kötelezettség: egy API-komponens × kontextus, amit becsületesen ki kell szolgálni |
| hard dependency | kemény függés: nélküle a válasz nem igaz |
| minimum fulfillment | minimális teljesítés: a legkisebb becsületes válasz |
| enrichment | bővítés: később hozzáadott mezők, nem blokkolnak |
| reuse | újrafelhasználás: több fogyasztó, feltételekhez kötve |
| estimand | a becsülendő mennyiség pontos definíciója (mit mérünk, nem hogyan) |
| prepared measure | típusos, előkészített bemeneti mérték (egység, irány, naptár rögzítve) |
| adapter | instrumentumtípus-specifikus, oksági (no-look-ahead) előkészítő |
| model profile | verziózott módszer- és paramétercsomag, amely befogad instrumentum–mérték párokat |
| abstention | a modell explicit „nem mondok értéket” kimenete |
| projection | vetület: kész eredmény átformálása API-válasszá, új számolás nélkül |
| vertical slice (VS-001) | vertikális szelet: az adatoktól az API-ig végigmenő első szűk megvalósítás |
| wave | háttér-hullám: közös előfeltételek és kapuk csoportja |
| human stop | kötelező emberi jóváhagyási pont |
| lazy-growing | csak igény szerint bővülő (mappák, modulok) |
| point-in-time | csak az adott időpontban már elérhető információt használja |

## Q2 előtt érdemes átgondolni (javasolt kérdések Ivánnak)
1. A Q2 pilot doménjét ki választja ki, és milyen szempontok alapján? (Olyan domén kell, amely nem kényszerít minden adaptercsaládot.)
2. Hány jelölt módszert vár a Q2 specifikáció, és van-e preferált baseline (pl. egyszerű standardizált volatilitás-alapú stressz)?
3. A `foundation-contract-adapter` a quant track része? Ki írja a típusos eredményobjektumokat és a JSON-szerializálást?
4. A szintetikus fixture-családokat (rezsimváltás, hiányzó adat, outlier…) a Q2 rögzíti, vagy csak a W2?
5. Az aggregált estimand specifikációja része a mostani Q2-nek, vagy külön stop lesz az underlying után?
