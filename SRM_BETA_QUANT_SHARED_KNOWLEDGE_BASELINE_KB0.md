# SRM Beta Quant — Shared Knowledge Baseline

**Knowledge baseline:** `KB-0`  
**Document status:** Baseline candidate for colleague review; not yet landed in the repository  
**Prepared:** 2026-09-21  
**Repository evidence cutoff:** commit `de4532c` (`feat(srm-beta): AMENDMENT-SE SE-P1 governance bootstrap (C1)`)  
**Committed project state described through:** 2026-09-18  
**Working language:** English  
**Authority:** Navigational synthesis only; this document does not override the charter, an accepted decision record, a frozen registry, an accepted work package, a completion record, or the API architecture

> **Concurrent-work notice.** At preparation time the repository working tree contained active,
> uncommitted Catalog Factory work beyond `de4532c`. Those changes are deliberately excluded from
> the factual baseline below. Where relevant, this document says that successor catalog work is in
> progress, but it does not describe uncommitted artifacts as complete or accepted. Before KB-0 is
> landed in the repository, it must be reconciled against the final pushed state.

---

## 1. Executive orientation

The SRM Beta Quant project is building the first concrete, testable quantitative implementation of
the **Systemic Risk Map (SRM)** for one deliberately narrow and eventually frozen filter context.
The beta is not intended to solve the complete product lattice at once. Its purpose is to establish
a trustworthy end-to-end path from governed market objects and point-in-time data, through explicit
quantitative estimands and tested Python models, to response-shaped outputs that the backend can
persist and serve.

The project has already completed two major foundations.

First, the market universe has been selected and frozen as twelve typed market-risk domains. This
replaced an earlier equity-industry-only concept. The beta now covers global market proxies across
equity sectors, credit, rates, foreign exchange and commodity-sensitive domains, while retaining a
Hungarian policy and future transmission lens. Proxy membership and contextual roles are frozen in
`proxy_registry_v1`.

Second, the Sandbox Data Foundation has been implemented, verified and human-signed-off. It can
retrieve the Yahoo-backed subset of the registry, preserve immutable raw snapshots, canonicalize
observations without model-dependent imputation, audit data quality, certify artifacts, and replay
the signed snapshot byte-identically. It is a governed observed-data foundation, not a filled model
matrix.

The project has also completed a heterogeneous twelve-object Know Your Instrument (KYI) pilot. The
pilot demonstrated that clean time series alone are insufficient for serious quantitative use:
instrument identity, economic exposure, benchmark and methodology history, measure semantics,
publication conventions, participant claims, evidence maturity, derived-series definitions and
model-admission status all matter. A typed Catalog Factory is being built to preserve this knowledge
at scale. At the committed evidence cutoff, Gate 2 is accepted and closed; later Catalog Factory
work is still in progress and is not part of this baseline's closed factual state.

What remains open is the quantitative question itself. The filter context is not yet frozen. In
particular, the beta must settle the initial decision horizon, the first user-facing risk target,
the economic meaning of an aggregate node, point-in-time input semantics, admissible estimation
windows, the relationship between runtime filters and model configuration, and the context identity.
No node-risk model or transmission model has yet been accepted.

The first quantitative vertical slice will start with the node- and domain-risk foundation, not
with transmission. It will be developed initially against deterministic synthetic inputs, behind a
typed input contract. Quantitative code will receive data as input; it will not fetch data and will
not write directly to the production database. Transmission edges, chains, macro transmission,
alerts, news and generated interpretation remain later dependency bands.

### One-minute status

| Area | Status at the evidence cutoff |
|---|---|
| Beta scope and working architecture | Decided in the living charter |
| Twelve-domain market universe | Approved and frozen |
| `proxy_registry_v1` | Frozen; changes require a new version and decision record |
| Sandbox Data Foundation | Complete, verified and human-signed-off |
| Signed sandbox snapshot | `20260828T131353Z_proxy_registry_v1_9158801f391e` |
| Registry coverage | 94 objects: 83 Yahoo-backed observed series and 11 metadata-only or non-Yahoo objects |
| KYI pilot | 12/12 objects human-decided |
| KYI concept and machine contracts | Versioned and governed; historical generations preserved |
| Catalog Factory | Gate 2 accepted; successor work in progress; no full published catalog |
| Remaining catalog population | 82 objects; not authorized for unrestricted population at the evidence cutoff |
| Filter context | Partially decided; not frozen |
| Quantitative model | Not yet implemented or accepted |
| First planned model capability | Underlying- and aggregate-node risk foundation |
| Transmission modelling | Explicitly deferred until accepted node series exist |
| Production Data Layer integration | Deferred to a later Quant Data Readiness Gate |

---

## 2. Purpose, audience and scope of KB-0

KB-0 is the shared entry point for colleagues joining or reviewing the quantitative track. It is
written for quantitative researchers, mathematicians, data engineers, backend engineers, reviewers
and project owners. It aims to give each reader the same conceptual and factual starting point
without requiring them to reconstruct the project from hundreds of implementation and governance
files.

After reading KB-0, a colleague should understand:

- what the beta is trying to prove;
- which market universe and data foundations are already fixed;
- why instrument knowledge and numerical data are governed separately;
- what a filter context means in this project;
- which quantitative choices remain open;
- why underlying and aggregate nodes require related but not necessarily identical estimators;
- how point-in-time information, vintage and publication timing constrain modelling;
- why the project starts with synthetic data and a typed input contract;
- how UI obligations determine the delivery order without dictating the mathematics;
- what is explicitly out of scope or prohibited at the current stage.

KB-0 is not a replacement for the authoritative sources. It does not define a new Catalog Factory
contract, restate every API schema field, formalize a final model, authorize implementation, or
change a frozen decision. Its role is to connect the authoritative materials into a coherent
knowledge state and make open questions visible.

---

## 3. Authority, evidence and decision status

When sources conflict, the beta follows the authority order in `srm_beta_quant/BETA_CHARTER.md`:

1. accepted decisions recorded in the charter and its decision log;
2. `systemic-risk-api-architecture.md` for frontend-facing obligations and JSON response shapes;
3. obligation-specific research, formalization, tests and signed decisions created inside the beta;
4. the wider `QCP_quant` framework as reference material, not automatically binding machinery.

This division is essential. The API contract specifies **what must be returned**. It does not, by
itself, decide what a risk quantity means or how it should be estimated. An example field named
`systemic-risk-score`, an example one-month estimation window, or an example transmission rule is
not evidence that the corresponding quantitative concept has been selected.

KB-0 uses the following status language:

| Status | Meaning |
|---|---|
| **Decided** | Human-accepted and recorded in an owning repository authority |
| **Complete** | Implemented and closed with the required technical and human evidence |
| **Converging** | Strong design direction from the current quantitative discussion, not yet repository-ratified |
| **Candidate** | A method, interpretation or artifact proposed for comparison |
| **Open** | A decision still required before dependent work can close |
| **Deferred** | Intentionally postponed until its prerequisites exist |
| **Superseded** | Historical decision retained for traceability but replaced by a later accepted decision |

Material mathematical, market and architectural learning must remain traceable. An attractive idea
does not become a decision merely because it appears plausible or because a model produces a useful
chart. Durable decisions require an owning artifact, source or evidence note, explicit implications,
and the appropriate human sign-off.

---

## 4. How the project reached its current state

### 4.1 Market-universe decision

The beta first considered an equity-industry partition. Research showed that this would omit major
channels of market stress—credit, sovereign rates, funding, foreign exchange and commodities—and
would encourage the product to call unlike objects “industries.” The accepted replacement is
`typed_market_risk_domains_v1`: twelve typed market-risk domains represented by a frozen,
role-aware proxy registry.

The resulting project claim is deliberately bounded: this is a **global market-systemic-risk proxy
beta with a Hungarian transmission lens**. Global market information and the Hungarian policy lens
are different dimensions. The first quantitative slice will measure node/domain risk; it will not
yet estimate Hungarian transmission or causal systemic contribution.

### 4.2 Sandbox Data Foundation

`WP-DF-001` implemented the observed-data foundation and closed with human sign-off. The signed
snapshot was produced by committed code with a clean worktree, retrieved all 83 Yahoo-backed
registry series, had zero blocking findings, passed strict-JSON and certification-hash checks, and
replayed byte-identically.

This milestone established that the project can preserve what the source supplied. It deliberately
did not decide returns, scaling, imputation, aggregation or a risk estimator. Those choices depend
on the decision horizon, risk target, instrument type and point-in-time admissibility.

### 4.3 Twelve-object KYI pilot

The KYI pilot selected twelve objects in three sequential batches:

| Batch | Objects | Main heterogeneity tested |
|---|---|---|
| A | `IXC`, `RSPT`, `ICLN`, `IYR` | broad, equal-weight, thematic and real-estate equity wrappers |
| B | `CL=F`, `^TNX`, `TLT`, `^VIX` | continuous futures, yield indices, bond ETFs and non-investable implied volatility |
| C | `HYG`, `drv-hy-vs-ig`, `EURHUF=X`, `ecb-ciss` | credit, derived objects, FX and official composite indicators |

Ten pilot objects had acquired sandbox data; two were metadata-only. The pilot was chosen to expose
schema failures, not to preselect the future modelling set. It demonstrated that legal identity,
economic exposure, measure definition, participant evidence, publication timing, revision policy,
methodology regimes and data availability must remain distinct.

All twelve pilot objects received human decisions. The resulting quality benchmark requires enough
structured and narrative evidence to reconstruct an accepted instrument card offline without new
material model claims.

### 4.4 Catalog contracts and Factory

The catalog architecture separates three governed states:

1. **Knowledge state:** whether identity, mechanics, participants, regimes, evidence and traps are
   documented adequately.
2. **Numerical representation state:** whether the object is acquired observed,
   official-not-acquired, derived-not-computed, computed-derived, unavailable or retired.
3. **Model-admission state:** whether the object is not evaluated, a candidate, admitted for a named
   profile, restricted, deferred or excluded.

These states must not be collapsed. A high-quality knowledge record does not prove numerical data
availability, and numerical availability does not imply permission to use an object in a model.

At the repository evidence cutoff, Gate 2 had been accepted and closed. Runtime catalog authority
remained on the accepted v7 generation. `AMENDMENT-SE` had begun and its governance-bootstrap C1
commit existed, but the amendment and v8 successor work were not treated here as fully implemented
or closed. CP-3 and later encoding checkpoints had not begun in the committed navigation state; no
full catalog was published in the governed publication sense.

### 4.5 Re-entry into quantitative design

The quantitative track can now consolidate its context decisions in read-only form while the
Catalog Factory remains the active writer. Formal repository changes, model implementation and
context minting must wait for an explicit handoff, a clean tree and human authorization. This keeps
one writer on the master branch without losing design progress.

---

## 5. The frozen market universe

The following universe fields are decided:

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

### 5.1 Twelve aggregate domains

| Node ID | Domain | Core interpretation |
|---|---|---|
| `agg-energy` | Energy markets | Listed energy sub-markets, with physical commodities kept as typed drivers |
| `agg-utilities-infra` | Utilities and critical infrastructure | Global utilities and infrastructure exposures |
| `agg-materials` | Materials and commodities | Listed materials/mining exposures with commodity drivers separated |
| `agg-industrials` | Industrials and transport | Global industrial, transport and aerospace/defence exposures |
| `agg-technology` | Technology and digital economy | Global technology, semiconductors, software and communications |
| `agg-consumer` | Consumer economy | Discretionary, staples, retail, housing and leisure sub-markets |
| `agg-healthcare` | Healthcare and life sciences | Global healthcare, biotechnology, devices and providers |
| `agg-financials` | Financial intermediaries | Global financials, regional banks and insurance |
| `agg-real-estate` | Real estate | Listed US, ex-US and mortgage real-estate exposures |
| `agg-credit-funding` | Credit and funding | Governed relative-credit measures and fixed-income inputs |
| `agg-rates` | Sovereign rates and duration | Yield-curve points and duration-sensitive fixed-income proxies |
| `agg-fx` | Foreign exchange | Global FX conditions with EUR/HUF as the Hungarian-lens anchor |

Cross-cutting validation series such as VIX, MOVE, ECB CISS, Hungary CLIFS, OFR FSI, SPY and ACWI
are deliberately not root domains.

### 5.2 Contextual roles

| Role | Meaning in the beta |
|---|---|
| `anchor` | Broad reference representation of a domain |
| `child_candidate` | Candidate underlying node after the risk target and admission rules are fixed |
| `driver` | Economically relevant input or explanatory variable; not automatically part of a node score |
| `validation` | Out-of-model comparator, breadth check or alternative representation |
| `supplemental` | Initially excluded because of history, redundancy or another documented limitation |

The registry role is not a model-admission decision. An anchor can still be inadmissible for a
particular measure or model profile. A validation object must not silently enter training, and a
driver must not be averaged into a domain score merely because it is economically relevant.

### 5.3 Frozen invariants

- A series has at most one scored home in a frozen context.
- Secondary appearances must be explicitly typed as driver or validation use.
- ETF returns, futures, yields, credit proxies and FX are not averaged in raw units.
- Supplemental series cannot silently shorten the modelling sample.
- Proxy membership changes require a new registry version and decision record.
- Yahoo provider-managed constituents are accepted for the sandbox; point-in-time company
  constituents are not reconstructed.
- Native quote returns are used instead of mechanically injecting HUF risk into every domain.
- Prices are not forward-filled into artificial zero returns.
- Yahoo is a sandbox acquisition source, not a production source of record.

---

## 6. The Sandbox Data Foundation

The Data Foundation's zero-th product is a validated observed-data snapshot. It preserves source
observations, provenance and quality evidence without pretending to know the later model's correct
treatment.

### 6.1 What it provides

- registry validation and acquisition-set derivation;
- an isolated provider adapter with typed failures and retries;
- immutable raw snapshots and provenance manifests;
- target-independent audits for identity, schema, duplicates, coverage, gaps, staleness, timezone
  and basic value sanity;
- canonical long-form observations with node and role metadata;
- QC reports and review plots;
- strict JSON and immutable certification manifests;
- offline replay and hash verification;
- an atomic pointer to the latest valid certified snapshot.

The signed foundation snapshot is:

```text
20260828T131353Z_proxy_registry_v1_9158801f391e
```

It was produced by commit:

```text
30f4fa1363468cf77ca8d76443a06867f41e6b31
```

### 6.2 What it intentionally does not provide

- interpolation, smoothing or imputation;
- synthetic backfilling;
- return or spread construction;
- scaling, winsorization or normalization;
- target-specific alignment;
- feature engineering;
- node aggregation;
- model selection;
- production licensing;
- ORM or PostgreSQL writes;
- API serving or request-time acquisition;
- a production-quality continuous-futures roll series.

This boundary is not an omission. It prevents model assumptions from being hidden inside the
observed-data layer.

### 6.3 Layered data flow

The emerging architecture is similar to a medallion design, but the project uses responsibility
names rather than relying on color labels:

```text
L0 — immutable raw provider payloads
     Exact acquired content and retrieval provenance.

L1 — canonical observed data
     Governed identity, field, unit, currency, calendar, timestamp,
     missingness, staleness candidate and snapshot lineage.

L2 — versioned model-ready QuantInputContract
     Target-specific returns, changes, spreads, derived measures,
     alignment, allowed imputation and its mask, and feature lineage.

L3 — typed quantitative results
     Estimates, diagnostics, uncertainty, failure/abstention state,
     context/model/run identity and review artifacts.

L4 — persistence and API adapter
     Data-architect-owned database loading and contract-shaped serving.
```

L0 and L1 exist for the Sandbox Data Foundation. L2 and L3 remain quantitative-track work. L4 is
a later integration boundary.

---

## 7. What the instrument catalog contributes to modelling

The catalog is not a decorative glossary. It protects quantitative work from using a clean but
misunderstood series.

Examples from the pilot illustrate why:

- A sector ETF represents a listed wrapper and benchmark exposure, not necessarily the whole
  physical or economic sector named by a broad node label.
- A thematic ETF can retain one ticker across material index-methodology changes.
- A provider continuous-futures ticker can hide contract selection, roll, splice, adjustment and
  revision choices.
- A yield index, a bond price, a total-return index and a duration exposure are different measures.
- Spot VIX, implied variance, realized variance, the volatility risk premium, VIX futures and VIX
  ETP returns are distinct objects.
- A high-yield ETF return combines Treasury duration, credit, liquidity, carry, calls, defaults,
  benchmark turnover and ETF intermediation; it is not an OAS or default probability.
- `HYG / LQD` is an expression string, not an authorized derived observation.
- A vendor EUR/HUF close, an executable quote, an MNB fixing and an ECB reference rate have
  different timing, contributors, calendars and rights.
- An official composite such as CISS can be useful validation evidence without being independent
  ground truth when it overlaps the model's components.

The quantitative implication is that every admitted input must bind to a typed `measure_id`, not
merely a ticker. Derived measures require a versioned formula object, component edges, direction,
unit, calendar, missingness policy, action/cash-flow treatment, timestamp convention and snapshot
lineage. Model admission remains profile-specific.

---

## 8. What a filter context means

A filter context identifies the decision-relevant question being answered. It must not be a bag of
estimator names. The beta distinguishes four layers.

### 8.1 Layer A — fixed decision context

This layer defines the question and market objects and is frozen before a production candidate is
accepted. It includes the universe, taxonomy, policy lens, decision horizon, risk target and the
economic meaning of aggregate nodes.

### 8.2 Layer B — runtime selectors

Runtime selectors choose among already-defined and persisted answers. Examples are `asOf`,
`riskIndex`, `estimationWindow`, `deltaWindow`, `regionScope` and `expandedNodeId`. A runtime choice
does not automatically create a new model or a new business question. `deltaWindow`, for example,
selects the earlier approved estimate used for comparison; it does not define the risk estimator.
Its statistical interpretation is handled later by the dedicated delta-analysis obligation.

### 8.3 Layer C — conditioned model settings

This layer defines how an accepted model uses information: transformations, missing-data policy,
feature windows, decay, regularization, tail probability, thresholding and other parameters. These
settings belong to a versioned model profile unless the product has a genuine reason to expose one
as a user choice.

### 8.4 Layer D — research candidate configuration

Candidate IDs, method families, experimental parameters and comparison runs belong to research
manifests. They do not enter the user-facing filter context by default.

The governing promotion test is:

- Same target and interpretation, alternative estimator: compare, select or ensemble; do not add a
  filter value.
- Different target or decision interpretation: a separate risk-index value or later context may be
  justified.
- Same capability in different admissible regimes: route internally under governed rules.
- Parameter or sensitivity variant: retain in model/run configuration unless a user decision
  genuinely requires exposure.

---

## 9. Current filter-context decision state

The following table distinguishes repository decisions from the design convergence reached during
the current read-only quantitative discussion.

| Field or concept | Role | Status | Current direction |
|---|---|---|---|
| `partitionRule` | Root taxonomy | **Decided** | `typed_market_risk_domains_v1` |
| `marketUniverseScope` | Eligible information boundary | **Decided** | `global_market_proxies` |
| `policyLens` | Interpretation/transmission perspective | **Decided** | `hungary` |
| `nodeTaxonomy` | Aggregate hierarchy | **Decided** | Twelve typed domains |
| `proxyRegistryVersion` | Frozen objects and roles | **Decided** | `proxy_registry_v1` |
| `membershipPolicy` | How membership changes | **Decided** | Frozen and versioned |
| `measurementCurrencyPolicy` | Quote-currency treatment | **Decided** | Native quote returns; FX explicit |
| `decisionHorizon` | Temporal meaning of the risk statement | **Converging** | Contemporaneous daily monitoring for the first beta |
| `riskIndex` / `riskTarget` | User-facing estimand | **Converging** | `market-stress-intensity` as the first candidate target |
| `aggregateNodeSemantics` | Economic meaning of a domain node | **Converging** | Time-varying common or distributional domain stress |
| `asOfPolicy` | Historical information cutoff | **Converging** | Vintage-safe, timezone-explicit point-in-time replay |
| `estimationWindow` | Historical span available to an estimator | **Open** | User-configurable only through admissible values |
| `memoryPolicy` | Weighting/forgetting/resampling structure | **Model-profile decision** | Separate from the raw lookback selector |
| Missing-data policy | Model-ready treatment | **Open** | Explicit masks; no zero coercion; method-specific candidates |
| Score scale and risk states | UI interpretation | **Open** | Must be precommitted before historical review |
| Runtime defaults | Initial UI selections | **Deferred** | Choose after evidence from the first obligations |
| `contextId` | Stable semantic identity | **Pending** | Mint only after human sign-off and repository handoff |
| `transmissionTarget` | Meaning of a directed edge | **Deferred** | Not required for the first vertical slice |

The converging entries are intentionally not labelled “decided.” They must be persisted, reviewed
and accepted after the concurrent catalog writer releases the repository.

---

## 10. Decision horizon

The decision horizon states whether a risk estimate describes the current state or a future period,
and over what interval the decision-maker should interpret it.

The leading first-beta candidate is:

```yaml
decisionHorizon:
  targetTiming: contemporaneous
  forecastHorizon: null
  evaluationFrequency: daily
  decisionUse: short_term_monitoring
```

This means that each daily evaluation uses only information available by its `asOf` cutoff to
estimate the current market-risk or stress state. It does not claim to forecast next month's loss.
The result can inform short-term monitoring or hedging discussion, but its mathematical target is
contemporaneous.

This is a suitable first beta because it avoids the additional target-label and forecast-validation
burden of a one-month model. Volatility state, tail realization, persistence and breadth can be
investigated using causal historical information, and their behavior can be reviewed across calm
and stressed periods.

A later forward context could instead declare:

```yaml
decisionHorizon:
  targetTiming: forward
  forecastHorizon: 1m
  evaluationFrequency: daily
```

That would be a materially different target. It would require forward labels, forecast scoring,
overlapping-horizon treatment, stronger out-of-sample design and an explicit interpretation of a
one-month decision.

---

## 11. Risk targets and risk-measure families

The first beta is not restricted forever to one risk measure. The API's `riskIndex` selector can
eventually expose several user-relevant estimands, provided each is well-defined, admissible for
the selected horizon, tested, persisted and signed off.

Candidate families include:

| Risk concept | Question answered | Example estimators or constructions |
|---|---|---|
| Market-stress intensity | How abnormal and adverse is the current market state? | Composite or latent-state candidates |
| Volatility level/regime | How variable is the measure, and which volatility state applies? | Realized volatility, EWMA, GARCH, regime models |
| Value at Risk | What loss quantile applies over a stated horizon and exposure convention? | Historical, parametric, filtered historical simulation |
| Expected Shortfall | What is the expected loss beyond the selected VaR quantile? | Empirical, parametric, EVT-based candidates |
| Tail severity | How heavy or severe is the adverse tail? | Tail index, exceedance and EVT methods |
| Stress-entry probability | What is the probability of entering a future stress state? | Classification, Markov/regime or hazard candidates |
| Persistence | How durable is an observed stress state? | Duration, autocorrelation or regime persistence measures |
| Breadth | How many admitted children are simultaneously stressed? | Thresholded or continuous cross-sectional summaries |
| Multivariate abnormality | How unusual is the joint configuration? | Robust Mahalanobis-type measures |
| Common-factor stress | How strong and stressed is the common domain component? | PCA or dynamic factor candidates |
| Systemic contribution | How much does an object contribute to system risk? | Later methods requiring a defined system and stronger dependencies |

EWMA, GARCH, PCA, dynamic factor models and EVT are not automatically risk-index filter values.
They are estimator families unless they answer a materially different user question.

The leading first target name is `market-stress-intensity`. The earlier working word “nowcast” has
been rejected for this generic use because it conventionally suggests mixed-frequency estimation
of a not-yet-observed current-period variable. Temporal meaning should instead be explicit in the
decision-horizon metadata.

A measure such as volatility, tail risk, persistence or breadth may later occupy one of several
roles:

- a top-level selectable `riskIndex`;
- a component of a composite market-stress index;
- a drill-through diagnostic;
- an out-of-model validation metric.

That role must be decided rather than inferred from the metric's name.

---

## 12. Heterogeneous instruments require typed measures

The same user-facing risk concept can apply to an equity, a bond, an FX rate or an aggregate domain,
but it cannot be assumed to consume the same raw field or transformation.

| Object type | Candidate modelling measure | Main semantic risk |
|---|---|---|
| Equity or equity ETF | Price/total return, downside return, realized volatility | Corporate actions, distributions, benchmark and wrapper exposure |
| Bond or bond ETF | Total return, excess return, yield/spread change | Duration, convexity, carry, benchmark and NAV/price differences |
| Government-yield index | Level, change or curve movement | A yield is not a bond return; adverse direction depends on the question |
| Credit object | OAS/spread change or governed proxy | Rate, liquidity and wrapper contamination |
| FX spot | Canonically oriented return or level change | Base/counter direction, fixing time and policy lens |
| Futures proxy | Governed continuous return | Contract selection, roll, splice, adjustment and revision ambiguity |
| Volatility index | Level, change, variance or premium measure | Non-investability and confusion with derivatives returns |
| Derived object | Output of an approved formula object | Expression metadata alone does not define an observation |

The future QuantInputContract therefore needs more than `series_id` and `value`. At minimum it must
be able to carry:

```text
series_id
measure_id
node_id
role
instrument_type
timestamp
as_of
published_at / available_at where known
vintage_id
publication_lag
unit
currency
calendar_id
missingness state and mask
staleness state
transformation_id
snapshot and lineage identifiers
```

If an estimator is not admissible for an input type, it must abstain or fail with a typed reason.
It must not silently apply an equity-return algorithm to a yield level or turn an unsupported input
into zero.

Initial quantitative development will use deterministic synthetic fixtures. Those fixtures should
represent several input families—equity returns, yield/spread changes, FX, aggregate child panels,
missing and stale observations, and explicitly unsupported inputs—even if the first accepted model
supports only a bounded subset.

---

## 13. Underlying and aggregate nodes

An underlying node represents an admitted instrument, sub-market or typed measure. An aggregate
node represents a domain-level mathematical object constructed from admitted information. They can
share a user-facing risk concept, but they need not share one estimator implementation.

The proposed context-level semantics are:

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

This entry would state what the aggregate node means without prematurely selecting a method.

Candidate methods answer partly different questions:

- A robust cross-sectional median or trimmed mean estimates typical admitted-child stress.
- Rolling PCA or a dynamic factor model can estimate a common component, subject to loading,
  sign, rotation and stability controls.
- The largest eigenvalue or its share of total variation primarily measures synchronization or
  commonality; high commonality is not necessarily high stress.
- A Mahalanobis-type distance measures joint abnormality; without directional design it can flag a
  benign rally as strongly as an adverse shock.
- Breadth measures how widespread stress is, not its average severity.
- A portfolio-weighted risk measure requires a defensible exposure and weight definition.

Consequently, “commonality,” “abnormality,” “average stress,” “tail loss,” “breadth” and “systemic
contribution” must not be treated as synonyms. Research must first classify the target, then compare
estimators that genuinely address that target.

---

## 14. Point-in-time information, `asOf` and vintage

The purpose of `asOf` is to replay the information state that a decision-maker could actually have
used. It is not merely a filter on observation dates.

For a decision cutoff (t), the admissible information set is conceptually:

\[
\mathcal I_t = \{x_{i,s,v}: available\_at_{i,s,v} \leq t\}.
\]

In words: an observation is eligible only if the relevant vintage was available by the decision
cutoff. A historical result must not be recomputed using a correction or revision first published
after that historical decision date.

The temporal fields answer different questions:

| Field | Question |
|---|---|
| `timestamp` | When was the market/economic quantity observed or valued? |
| `published_at` | When did the source first publish that value? |
| `available_at` | When could the quantitative system first use it under the governed pipeline? |
| `retrieved_at` | When did this system acquire the payload? |
| `vintage_id` | Which immutable source/snapshot version does the value belong to? |
| `source_revision_at` | When did a later source correction or revision occur? |
| `publication_lag` | What delay separates observation and publication/availability? |
| `as_of` | What decision-time cutoff governs the result? |

The first beta can use a conservative daily decision cycle. One candidate is to interpret a public
`asOf` date as a fixed Europe/Budapest morning cutoff and use only fully closed and processed market
sessions available before that time. The exact clock time remains to be ratified. The invariant is
that timezone and cutoff are explicit and reproducible.

When exact publication timestamps are unavailable, a conservative measure-specific availability
policy may be used and labelled as such. An assumed lag must not be presented as observed source
metadata. For revised official series, vintage-aware selection is mandatory. For market prices,
later source corrections still create a new vintage rather than silently rewriting an earlier
replay.

The public API may continue to display a date. Internally, that date must resolve to an approved
result and a precise knowledge cutoff. The historical selector should offer persisted, reproducible
result dates; it should not accept an arbitrary date and rebuild history from today's latest
vintages without disclosure.

---

## 15. Missingness, staleness and model-ready preparation

Missingness and staleness are information, not values to be erased.

The observed foundation distinguishes at least:

- structural absence before inception or after termination;
- different trading and publication calendars;
- provider or source failure;
- an isolated missing print;
- an unchanged observation that may or may not be stale;
- a malformed or economically impossible value;
- asynchronous market closes.

The quantitative layer must preserve the original missingness state and any later imputation mask.
It must not coerce missing values to zero, forward-fill prices into zero returns, or silently drop an
instrument and renormalize the remaining weights unless an accepted policy explicitly allows that
behavior.

Three questions remain separate:

1. What did the source actually observe?
2. How was that observation canonicalized without changing its meaning?
3. What target-specific preparation did the model apply?

Later candidate policies may include complete-case rules, causal filtering, state-space methods,
expectation-maximization or multiple imputation. Any accepted method must be point-in-time safe,
expose its mask, report uncertainty where appropriate, and be sensitivity-tested against a
non-imputed baseline. If minimum coverage is not met, the honest output is unavailable or abstained,
not a fabricated score.

---

## 16. Decision horizon, estimation window and memory policy

These concepts are related but not interchangeable.

| Concept | Meaning |
|---|---|
| `decisionHorizon` | The present or future period to which the risk statement applies |
| `estimationWindow` | The historical span of observations made available to an estimator |
| `memoryPolicy` | How observations within that information history are weighted, forgotten, resampled or routed |

For example:

```yaml
decisionHorizon:
  targetTiming: contemporaneous
  forecastHorizon: null

estimationWindow: 5y

memoryPolicy:
  type: exponentially_weighted
  halfLife: 60bd
```

The estimator may see five years of observations while giving much greater weight to recent data.
That is not the same as a sixty-day rolling window.

The current design direction is to retain `estimationWindow` as a possible long-term user selector,
but not as arbitrary free text. The backend should return only values admissible for the selected
risk target, decision horizon and accepted model profile. An EVT tail estimator may require far more
effective tail observations than a short UI window supplies; a volatility model may support a
different set. Incompatible combinations should fail explicitly.

Changing the estimation window normally selects an estimator sensitivity rather than a new business
estimand. It need not change the semantic context ID, but it must be part of request, cache, result
and run identity. Every exposed combination requires tests and a persisted approved result. A user
request must not trigger live full retraining or a data download.

The concrete window whitelist, default and memory policy remain open until the first risk target and
candidate methods are compared.

---

## 17. Identity and provenance

The beta needs several separate identities because they answer different questions.

| Identifier | What it identifies |
|---|---|
| `context_id` | The decision question: universe, lens, horizon, target semantics and aggregate-node meaning |
| `risk_target_id` | The precise user-facing estimand |
| `model_profile_id` | The accepted transformations, estimator, memory policy, parameters and admissibility rules |
| `run_id` | One concrete execution against a specified input snapshot and code version |
| `snapshot_id` | The immutable observed-data snapshot |
| `quant_input_contract_version` | The schema and semantic version of model-ready inputs |

A new context ID is justified when the universe, policy lens, decision horizon, risk target or
economic interpretation changes. It is not normally required for a different `asOf`, a UI default,
a bug fix, a new run, or an alternative estimator of the same target. Those differences remain
visible through the other identities.

The context ID is also operationally useful. It prevents results answering different questions
from being mixed in storage, cache, API responses or review artifacts. The obligation identity in
the beta is conceptually:

```text
API component ID × frozen context ID
```

The exact first context ID must be minted only after the semantic fields receive human sign-off.

---

## 18. Per-obligation quantitative workflow

Each UI obligation follows a research-to-handoff loop. The loop is lightweight enough to support
iteration but strict enough to preserve meaning and evidence.

1. **Explore.** Brainstorm the business question, possible estimands, expected behavior and failure
   modes without prematurely selecting one technique.
2. **Research.** Conduct targeted source-led research for the mathematical, market and data issues
   that can change the result.
3. **Compare.** Retain multiple methods when they answer genuinely different questions or provide
   useful benchmarks.
4. **Specify.** Record the selected estimand, assumptions, inputs, outputs, units and API fields.
5. **Pre-commit expected behavior.** State calm, stress, direction, missingness and regime
   expectations before viewing historical result figures.
6. **Formalize.** Write the minimum sufficient mathematics for serious implementation candidates.
7. **Contract.** Freeze a versioned QuantInputContract and typed result contract.
8. **Synthesize.** Build deterministic synthetic data and named test cases, including failure and
   unsupported-input cases.
9. **Implement.** Write a pure, typed Python model core with no acquisition or database writes.
10. **Verify.** Run unit, property, failure, regime, reproducibility and no-look-ahead tests.
11. **Render.** Produce reviewable tables, figures and diagnostics by run without silent overwrite.
12. **Map.** Map the accepted result fields to the relevant API response contract.
13. **Judge.** Human review accepts, revises, rejects or defers the candidate.
14. **Package.** Expose the accepted result through a thin executable or adapter.

Not every brainstormed idea receives full formalization or implementation. Formalization begins
when a candidate is selected for deliberate comparison or implementation.

---

## 19. Dependency-safe obligation roadmap

The API architecture lists frontend components; quantitative delivery must also represent the
non-visible prerequisites on which those components depend.

### 19.1 Shared prerequisites

```text
shared knowledge baseline
→ semantic filter-context freeze
→ point-in-time temporal contract
→ typed measure and admissibility rules
→ QuantInputContract
→ deterministic synthetic fixture families
→ primitive risk-measure capabilities
```

### 19.2 R1 — node and domain-risk foundation

| Planning capability | API destination | Main prerequisite |
|---|---|---|
| Node risk index | `GET /nodes/{nodeId}/risk-index` | Accepted node-risk estimand and model-ready series |
| Selected-node summary | `GET /nodes/{nodeId}/selected-summary` | Current node-risk result |
| Child-node summary | `GET /nodes/{nodeId}/child-nodes-summary` | Underlying-node results and diagnostics |
| Sector/domain summary | `GET /sector-summary-table` | Aggregate and underlying metrics such as volatility, persistence and tail risk |
| Delta analysis | `GET /delta-analysis` | Point-in-time estimates at current and comparison dates |
| Risk concentration | `GET /nodes/{nodeId}/risk-concentration` | Separately justified contribution/allocation rule |

### 19.3 R2 — node-only graph projections

The aggregate and expanded risk-map nodes, node hover and drill-through interactions can initially be
projections of accepted node results. Transmission edges need not exist for the first node-only map.

### 19.4 T1 and T2 — transmission, chains and macro impact

Transmission starts only after accepted node series exist. It requires its own target, direction,
identification rule, uncertainty and validation. Edge projections depend on that core; risk chains
depend on directed edges; Hungarian macro impact adds mixed-frequency market-to-macro methodology.

### 19.5 N1 — alerts, narratives and external information

Alerts, watch points, interpretations, news and generated insights depend on accepted quantitative
outputs and additional editorial or external-source rules. They are not substitutes for the risk
foundation.

This structure is a directed acyclic graph, not necessarily one long serial list. Independent
primitive metrics may occupy the same dependency layer and can later be compared without violating
prerequisites.

---

## 20. First quantitative vertical slice

The first vertical slice, `VS-001`, should exercise the complete workflow without transmission.

Its intended scope is:

1. freeze one semantic context;
2. choose one aggregate domain with a small admitted child set;
3. use deterministic synthetic inputs first;
4. compute historical risk-index series for the underlying nodes;
5. construct one time-varying aggregate/domain series under an explicit semantic target;
6. generate figures and diagnostic tables for both levels;
7. produce contract-shaped response examples;
8. package the run behind a thin executable handoff.

Minimum response-shaped outputs are:

- `NodeRiskIndexResponse`;
- `NodeSelectedSummaryResponse`;
- `ChildNodesSummaryResponse`;
- the node-only subset of `RiskMapResponse`.

`SectorSummaryTableResponse` is a natural early extension because the API explicitly expects
volatility regime, trend persistence and tail-risk fields. `NodeRiskConcentrationResponse` should
remain a follow-on until contribution and allocation semantics are independently justified.

Transmission edges, chains, macro transmission, news, alerts and generated quantitative insights
are explicitly excluded from `VS-001`.

The pilot domain has not been signed off. A convenient domain is not automatically the correct
choice: selection should balance understandable stress behavior, clean type semantics, sufficient
history, manageable child count and relevance to the eventual API demonstration.

---

## 21. Quantitative, Data Layer and backend boundaries

### 21.1 Quantitative responsibility

The quant package owns:

- the estimand and formalization;
- the typed model-ready input contract;
- deterministic synthetic fixtures;
- transformations explicitly assigned to the model profile;
- the pure model calculation;
- uncertainty, diagnostics and abstention state;
- typed Python result objects;
- context/model/run lineage;
- API response-field mapping and golden examples.

### 21.2 Data Layer responsibility

The later production Data Layer owns:

- licensed or approved source acquisition;
- raw payload retention;
- source-specific adapters;
- operational scheduling and monitoring;
- production snapshot availability;
- persistence and database loading under the agreed handoff.

The accepted operating direction is one scheduled refresh per day, although the exact scheduler
time, monitoring and operational ownership remain open.

The quantitative interface is designed now to support fields such as `series_id`, `measure_id`,
`node_id`, `timestamp`, `as_of`, vintage, publication lag, unit, currency, calendar, missingness and
staleness. Production integration waits for the Quant Data Readiness Gate.

### 21.3 Backend responsibility

The backend owns authentication, request handling, ORM/PostgreSQL serving, endpoint implementation
and API operational behavior. User API calls consume approved persisted results; they do not call
Yahoo or execute a full research pipeline synchronously.

### 21.4 Thin handoff

```text
validated QuantInputContract
→ pure Python quantitative callable
→ typed result
→ contract adapter / JSON serialization
→ data-architect-owned persistence and serving
```

A shell file, if required for operational handoff, should only invoke Python entry points. It must
not contain hidden quantitative logic.

---

## 22. Validation philosophy

The beta separates several kinds of correctness:

- **Unit correctness:** functions do what their local contracts state.
- **Data correctness:** identities, units, calendars, vintages and missingness are consistent.
- **Pipeline correctness:** the intended input reaches the intended calculation and output field.
- **Quantitative behavior:** the estimator behaves sensibly on known constructions and regimes.
- **Point-in-time correctness:** no future observation, publication or revision enters an earlier
  result.
- **Failure correctness:** unsupported or insufficient inputs fail or abstain explicitly.
- **Reproducibility:** the same governed inputs, code and profile reproduce the same artifacts.
- **Human admissibility:** the output is fit for the stated decision use and does not overclaim.

A green test suite proves only the assertions encoded by the tests. It does not prove economic
validity, causal interpretation or decision usefulness. Historical validation should include calm
and stressed periods, but expected qualitative behavior must be written before result figures are
reviewed. Missing or inadmissible values remain explicit rather than being converted to zero.

---

## 23. What the beta does not yet claim

At KB-0, the project does **not** claim:

- a general solution across the full filter lattice;
- a frozen first filter context;
- an accepted node-risk estimator;
- a production-ready or licensed market-data source;
- a completed QuantInputContract;
- a production database or ORM integration;
- a causal transmission network;
- a systemic-contribution estimate;
- a validated risk-chain methodology;
- Hungarian macro-transmission estimates;
- company-level point-in-time constituent reconstruction;
- that an ETF price equals its underlying economic market;
- that all 94 registry objects have acquired numerical histories;
- that all 94 catalog records are encoded and published;
- that the API's illustrative risk scores or filter values are accepted quantitative decisions;
- that a clean historical chart proves stable semantics;
- that an official composite is independent ground truth for a model using overlapping components.

These limitations are design boundaries, not hidden shortcomings. They prevent the first beta from
making claims that its data and methods cannot support.

---

## 24. Open decisions and human gates

The following decisions are required before or during the first quantitative vertical slice.

| Decision | Why it matters | What depends on it | Closure evidence |
|---|---|---|---|
| Final first-beta decision horizon | Defines present versus future target semantics | Labels, validation and admissible model families | Human-accepted context decision |
| First risk target | Defines what the node score means | Formalization, inputs, tests and API labels | Signed estimand specification |
| Primitive versus top-level metrics | Prevents diagnostics from being mistaken for separate products | Risk-index filter and sector-summary fields | Risk-measure catalog decision |
| Aggregate-node semantic target | Distinguishes common stress, abnormality, breadth and portfolio loss | Aggregate model candidates | Human-accepted semantic definition |
| Admitted measure set | Prevents ticker-level or cross-type ambiguity | QuantInputContract and fixtures | Typed admission record/profile |
| Missingness and minimum coverage | Determines when a result exists | Aggregation and failure behavior | Precommitted policy and tests |
| Estimation-window whitelist | Prevents inadmissible UI combinations | Filter metadata and persisted runs | Target/profile compatibility matrix |
| Memory policy | Determines historical weighting and effective sample | Candidate estimators | Accepted model profile |
| Score scale and state thresholds | Gives meaning to 0–1 scores and UI states | Risk map and summaries | Precommitted threshold specification |
| Runtime defaults | Sets initial UI state without redefining the model | Filter-options endpoint | Backend/quant configuration sign-off |
| Pilot domain and children | Defines the first bounded data problem | `VS-001` implementation | Explicit work-package selection |
| Context ID | Creates stable obligation and result identity | All response-ready artifacts | Frozen context manifest and hash |
| Backend handoff contract | Clarifies files, CLI, JSON and ownership | Integration testing | Jointly reviewed interface record |

Human sign-off remains necessary where the charter assigns meaning, admissibility or decision use
to the owner. An agent or test suite cannot silently promote a candidate to a decision.

---

## 25. Collaboration and repository rules

- Only one task writes to the master branch at a time.
- Read-only inspection and design discussion may proceed while another track writes, but no file is
  modified until the owner explicitly transfers write authority.
- A clean worktree alone is not authorization; the handoff must be explicit.
- Commit and push require separate permission.
- Frozen Catalog Factory and KYI contracts are outside the quantitative track's mutation scope.
- Changes to `proxy_registry_v1` require a new registry version and decision record.
- Generated review artifacts are stored by run and are not silently overwritten.
- Exactly one active design track should own unresolved convergence points.
- Material mathematical, market, architectural and workflow learning must leave a durable source or
  repository note and be indexed in `LEARNING_REGISTRY.md` where appropriate.
- Colleague-facing summaries never override owning authorities.

---

## 26. Recommended reading path

### Fifteen-minute orientation

Read:

1. Sections 1–3 of KB-0;
2. Section 5, “The frozen market universe”;
3. Section 9, “Current filter-context decision state”;
4. Sections 19–20, “Roadmap” and “First vertical slice”;
5. Section 23, “What the beta does not yet claim.”

### One-hour quantitative onboarding

Add:

1. Sections 6–7 on data and instrument knowledge;
2. Sections 10–17 on horizon, targets, typed measures, aggregate nodes and point-in-time identity;
3. Sections 18 and 22 on workflow and validation.

### Deep repository onboarding

Follow the source map in Section 28 and then read only the work package and completion evidence for
the task being undertaken. Do not treat the full repository as an undifferentiated instruction set.

---

## 27. Glossary

| Term | Meaning in this project |
|---|---|
| **Node** | A graph object for which the system may hold risk results and capabilities |
| **Underlying node** | An admitted instrument, sub-market or typed measure beneath an aggregate domain |
| **Aggregate node** | A domain-level mathematical object built from admitted information |
| **Market-risk domain** | One of the twelve typed root categories in the frozen taxonomy |
| **Risk target / estimand** | The precise quantity the user intends the system to estimate |
| **Estimator** | A mathematical procedure used to estimate a target |
| **Risk index** | The API/user-facing selector for an accepted risk concept; not automatically a method name |
| **Decision horizon** | The present or future period to which the risk statement applies |
| **Estimation window** | The historical span made available to an estimator |
| **Memory policy** | The rule for weighting, forgetting, resampling or routing historical information |
| **`asOf`** | The decision-time cutoff defining what information may be used |
| **Vintage** | An immutable source or snapshot version representing what was available at a point in time |
| **Publication lag** | Delay between an observation and its publication/availability |
| **Missingness** | Typed absence of an observation; never automatically zero |
| **Staleness** | An observation's age relative to its expected calendar and the evaluation cutoff |
| **Measure** | A precisely defined numerical object such as return, yield change, spread or fixing |
| **Model profile** | Versioned transformations, estimator, parameters, memory and admissibility rules |
| **Filter context** | The decision question plus the supported selectors used to obtain an answer |
| **Obligation** | An API component in a frozen context, together with the calculation or projection needed to serve it |
| **Validation series** | An out-of-model comparator; not automatically an input feature |
| **Synthetic fixture** | Deterministic designed data used to prove expected behavior and failures |
| **Persisted approved result** | A validated offline model output suitable for later serving without live recomputation |
| **Abstention** | An explicit statement that an admissible result cannot be produced for the supplied input |

---

## 28. Repository source map

The following paths are relative to the repository root.

### Core authority and navigation

- `srm_beta_quant/BETA_CHARTER.md` — scope, authority, workflow and decision log.
- `srm_beta_quant/CURRENT_STATE_AND_NEXT_STEPS.md` — current re-entry state and dependency-safe roadmap.
- `srm_beta_quant/README.md` — session reading order and navigation.
- `srm_beta_quant/LEARNING_REGISTRY.md` — transferable learning index.

### Market universe

- `srm_beta_quant/MARKET_UNIVERSE_RECOMMENDATION.md` — approved taxonomy and inclusion rationale.
- `srm_beta_quant/registry/proxy_registry_v1.yaml` — frozen machine-readable membership and roles.
- `srm_beta_quant/research/market_universe/` — detailed research and claim/source ledger.

### Data foundation

- `srm_beta_quant/DATA_FOUNDATION_ARCHITECTURE.md` — observed-data boundary and runtime flow.
- `srm_beta_quant/work_packages/WP-DF-001.md` — authorized foundation work.
- `srm_beta_quant/work_packages/WP-DF-001_COMPLETION.md` — implementation, tests, snapshot and sign-off evidence.
- `srm_beta_quant/data/README.md` — generated-artifact and replay documentation.

### Instrument knowledge and Catalog Factory

- `srm_beta_quant/research/instrument_catalog/PILOT_SELECTION.md` — frozen heterogeneous pilot.
- `srm_beta_quant/work_packages/WP-KYI-001_PILOT_PROGRESS.md` — pilot decisions and status.
- `srm_beta_quant/research/instrument_catalog/KYI_QUALITY_BENCHMARK.md` — accepted human-output standard.
- `srm_beta_quant/work_packages/WP-KYI-002_COMPLETION.md` — contract-freeze evidence and Gate E.
- `srm_beta_quant/work_packages/WP-KYI-003.md` — Catalog Factory and migration package.
- `srm_beta_quant/catalog/README.md` — Factory layout, verification and active-generation navigation.
- `srm_beta_quant/work_packages/WP-KYI-003_CP2_8_COMPLETION.md` — CP-2.8 completion and human-stop
  evidence.
- `srm_beta_quant/catalog/contract/decisions/gate_2_closure_record.yaml` — governing Gate 2 decision
  record.
- `srm_beta_quant/work_packages/WP-KYI-003_GATE_2_CLOSURE_PROPAGATION.md` — navigation-propagation
  package; its status must be read together with the governing closure record and committed
  navigation state.
- `srm_beta_quant/work_packages/WP-KYI-003_AMENDMENT_SE.md` — successor work begun at the source cutoff.

### Filter context and obligations

- `srm_beta_quant/FILTER_CONTEXT_SCHEMA.md` — configuration layers and open context sequence.
- `srm_beta_quant/OBLIGATION_MAP.md` — component coverage and dependency bands.
- `systemic-risk-api-architecture.md` — authoritative endpoints and response schemas.

---

## Appendix A — Milestone timeline

| Date | Milestone |
|---|---|
| 2026-08-28 | Typed market-risk domains and `proxy_registry_v1` approved |
| 2026-08-28 | Sandbox Data Foundation closed with clean-provenance signed snapshot |
| 2026-08-28 to 2026-08-31 | Twelve-object KYI pilot completed in three heterogeneous batches |
| 2026-09-02 | KYI v2 concept and machine-contract Gate E accepted |
| 2026-09-03 to 2026-09-07 | Gate 1-H contract resolution, verification, adversarial review and closure |
| 2026-09-11 to 2026-09-18 | Catalog Factory CP-2 implementation and remediation sequence |
| 2026-09-18 | Gate 2 accepted and closed in the committed navigation state |
| 2026-09-18 | AMENDMENT-SE authorized; C1 governance bootstrap later committed as `de4532c` |
| 2026-09-21 | KB-0 candidate prepared outside the repository while successor catalog work continues |

---

## Appendix B — Candidate first-context illustration

The following example is explanatory only. It is not a frozen context and must not be used as
implementation authority.

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

## Appendix C — Baseline change protocol

KB-0 is an evidence-cutoff snapshot. It should not be silently rewritten after distribution.

A later update should state:

1. the previous baseline ID;
2. the new repository evidence cutoff;
3. decisions added, changed or superseded;
4. implementation milestones completed;
5. obligations newly unblocked;
6. new limitations or risks;
7. links to owning decision and completion artifacts.

Minor factual corrections may be issued as an explicitly versioned KB-0 correction. Material
context, model or roadmap changes should produce a new consolidated baseline such as KB-1 while
preserving KB-0 for traceability.
