# SRM Beta Quant — Obligation Map v2

**Status:** Human Stop Q1 accepted; Q2 `node-risk-index` specification is next.

**Predecessor:** [`OBLIGATION_MAP.md`](OBLIGATION_MAP.md), frozen as Catalog/KYI evidence

**Last updated:** 2026-09-22

## 1. Identity rule

The API's `Comp.ID` identifies the rendered component. The beta's framed obligation is:

```text
API component id x frozen context id
```

The first frozen context ID is `srm-beta-market-stress-daily-v1`. Stable obligation IDs may now be
minted from each API component ID crossed with that context. The slugs below remain planning handles
under the canonical mapping accepted at Human Stop Q1.

The accepted detailed graph and authoritative UI-by-UI execution sequence are in
[`obligations/DEPENDENCY_DAG_AND_BACKLOG_V1.md`](obligations/DEPENDENCY_DAG_AND_BACKLOG_V1.md).
Its machine-readable graph is
[`obligations/dependency_graph_v1.yaml`](obligations/dependency_graph_v1.yaml). It separates hard
dependencies, minimum UI fulfillment, later enrichment, implementation/result reuse and strategic
delivery order. The grouped bands below remain the compact inventory view.

An API component is not always an independent quantitative model. It may be:

- **quantitative:** requires its own estimand or substantial calculation;
- **projection:** reshapes already-computed quantitative results;
- **interaction:** serves hover, selection, or highlighting over existing results;
- **narrative/integration:** combines quantitative results with news, interpretation, or generated content.

## 2. Prerequisite workstreams

These are not UI obligations, but they feed every obligation:

| Workstream | Deliverable | Status |
|---|---|---|
| `foundation-context` | Frozen `context.yaml` with its identifier and interpretation | COMPLETE — `srm-beta-market-stress-daily-v1` |
| `foundation-universe` | Typed market-risk domains, frozen role-aware proxy registry, and inclusion rationale | DECIDED |
| `foundation-sandbox-data` | Registry-driven downloader, immutable raw data, provenance, observed-data canonicalization, QC, tests, and plots | COMPLETE — `WP-DF-001` |
| `foundation-instrument-review` | Evidence-backed Know Your Instrument pilot, observed-data profiles, participant/use-case map, generated review document, and human admissibility decisions | COMPLETE for the 12-object pilot; full catalog remains separately governed |
| `foundation-contract-adapter` | Typed result objects, JSON serialization, contract-shape tests, and thin executable entry point | PLANNED |

The shared `GET /api/v1/filter-options` endpoint belongs to `foundation-context`; it is a
control-plane contract rather than an independent quantitative obligation in the single-context
beta. Its first response may expose only `market-stress-intensity` and model-admissible selector
values. Illustrative API values are not quantitative authority.

## 3. Component inventory and dependency bands

The bands express dependency order, not a promise that every row becomes a separate implementation folder.

### Band R1 - Node and sector risk foundation

| Planning slug | Source component ID | Endpoint | Kind | Main dependency |
|---|---|---|---|---|
| `node-risk-index` | `Comp.ID:SRM.P02.risk-index` | `GET /nodes/{nodeId}/risk-index` | quantitative | Curated underlying time series; node risk estimand |
| `selected-node-summary` | `Comp.ID:SRM.P02.selected-aggr-summary` | `GET /nodes/{nodeId}/selected-summary` | projection | Current node risk result |
| `underlying-node-summary` | `Comp.ID:SRM.P02.top-underlying-nodes` | `GET /nodes/{nodeId}/child-nodes-summary` | quantitative + projection | Underlying-node risk results and diagnostics |
| `sector-risk-summary` | `Comp.ID:SRM.P01.sector-summary-table` | `GET /sector-summary-table` | quantitative | Sector/node risk results plus volatility, persistence, and tail-risk definitions |
| `node-risk-concentration` | `Comp.ID:SRM.P02.risk-concentration` | `GET /nodes/{nodeId}/risk-concentration` | quantitative | Accepted aggregation and contribution/allocation rule |
| `delta-analysis` | `Comp.ID:SRM.P01.Delta-analysis` | `GET /delta-analysis` | quantitative | Point-in-time node risk estimates at current and comparison dates |

### Band R2 - Risk-map node views and interactions

| Planning slug | Source component ID | Endpoint | Kind | Main dependency |
|---|---|---|---|---|
| `aggregate-risk-map-nodes` | `Comp.ID:SRM.P01.risk-map-agr` | `GET /risk-map` | projection initially | Aggregate node risk results; transmission edges may be added later |
| `expanded-risk-map-nodes` | `Comp.ID:SRM.P02.risk-map-agr`, `Comp.ID:SRM.P02.risk-map-underlying` | `GET /risk-map?expandedNodeId=...` | projection initially | Aggregate and underlying-node results; transmission edges later |
| `node-hover` | P01/P02 node-hover component IDs | `GET /nodes/{nodeId}/hover` | interaction + projection | Node risk history and later strongest-edge results |

### Band T1 - Transmission foundation and direct projections

| Planning slug | Source component ID | Endpoint | Kind | Main dependency |
|---|---|---|---|---|
| `transmission-core` | Feeds all edge components | internal quantitative capability | quantitative | Accepted node series, transmission estimand, identification rule, and validation |
| `spillover-strength` | `Comp.ID:SRM.P01.spillover-strenght` | `GET /spillover-strength` | projection | Transmission-core edge estimates and deltas |
| `internal-transmission-summary` | `Comp.ID:SRM.P02.internal-transm-summary` | `GET /nodes/{nodeId}/internal-transmission-summary` | projection | Within-sector/cluster transmission results |
| `external-transmission-summary` | `Comp.ID:SRM.P02.external-transm-summary` | `GET /nodes/{nodeId}/external-transmission-summary` | projection | Cross-boundary transmission results |
| `edge-hover` | All P01/P02 edge-hover component IDs | `GET /edges/{edgeId}/hover` | interaction + projection | Edge estimate and historical activity series |
| `full-risk-map-edges` | P01/P02 risk-map components | `GET /risk-map` | projection | Transmission-core edges plus node results |

### Band T2 - Chains and macro transmission

| Planning slug | Source component ID | Endpoint | Kind | Main dependency |
|---|---|---|---|---|
| `risk-chains` | `Comp.ID:SRM.P01.risk-chains` | `GET /risk-chains` | quantitative | Directed transmission network plus chain-ranking rule |
| `selected-chain-label` | `Comp.ID:SRM.P01.selected-chain` | `GET /risk-chains` | frontend/projection | Risk-chain selection state; no independent quantitative model |
| `hu-macro-transmission-impact` | `Comp.ID:SRM.P01.sector-summary-table.hu-macro-transmission-impact` | `GET /hu-macro-transmission-impact` | quantitative | Market-to-macro mixed-frequency methodology and point-in-time data |

### Band N1 - Alerts, interpretation, and external information

| Planning slug | Source component ID | Endpoint | Kind | Main dependency |
|---|---|---|---|---|
| `key-triggers-alerts` | `Comp.ID:SRM.P01.key-triggers-alerts` | `GET /key-triggers-alerts` | quantitative monitoring | Accepted metrics, thresholds, event/dwell rules, and chain selection |
| `watch-points` | `Comp.ID:SRM.P01.watch-points` | `GET /watch-points` | narrative/integration | Quantitative results plus human-authored monitoring logic |
| `node-interpretation` | `Comp.ID:SRM.P02.interpretation` | `GET /nodes/{nodeId}/interpretation` | narrative/integration | Node and driver results; confidence definition |
| `news-implication` | `Comp.ID:SRM.P01.News-Implication` | `GET /news-implication` | external integration | News source plus selected-chain context |
| `sector-news` | `Comp.ID:SRM.P01.sector-summary-table.sector-news` | `GET /sector-news` | external integration | News source plus sector mapping |
| `quantitative-insights` | `Comp.ID:SRM.P02.quantitative-insights` | `GET /nodes/{nodeId}/quantitative-insights` | narrative/integration | Accepted quantitative outputs; API contract remains provisional |

## 4. First vertical slice - `VS-001` (agreed direction)

The first slice exercises the full workflow without requiring transmission modelling:

1. Use the frozen context and choose one aggregate domain with a small admitted child set.
2. Specify `QuantInputContract` v1 and deterministic synthetic fixture families before using
   observed histories.
3. Precommit underlying and aggregate estimands, expected behavior, failure rules and tests.
4. Implement pure typed model cores and compute risk-index series for underlying nodes.
5. Construct one time-varying aggregate/domain series under the frozen aggregate semantics.
6. Generate human-review figures and diagnostic tables for both levels.
7. Produce at least these contract-shaped examples:
   - `NodeRiskIndexResponse`;
   - `NodeSelectedSummaryResponse`;
   - `ChildNodesSummaryResponse`;
   - the node-only subset of `RiskMapResponse`.
8. Package the accepted run behind a thin executable entry point.

Explicitly deferred from `VS-001`: transmission edges, risk chains, macro transmission, news, alerts, and generated quantitative insights.

`NodeRiskConcentrationResponse` is a likely follow-on rather than an automatic part of `VS-001`, because its contribution/allocation rule must be justified separately from the aggregate index itself.

## 5. Candidate execution order

```text
define and freeze universe
→ build bounded reproducible sandbox-data foundation
→ understand and human-review the registered instruments
→ freeze `srm-beta-market-stress-daily-v1` (complete)
→ build and accept the detailed obligation DAG
→ VS-001: underlying + aggregate risk indices
→ remaining R1 risk-derived components
→ R2 graph node views
→ T1 transmission core and projections
→ T2 chains and macro transmission
→ N1 alerts, news, interpretation, and generated insights
```

The exact UI iteration queue is Section 8 of the linked accepted Q1 document. W0–W15, the
complexity/uncertainty assessment and human gates remain background planning metadata. Later
changes are versioned rather than silently overwritten.

## 6. Complete API component coverage register

Every component ID in the API architecture's two component-mapping tables appears below. This register is the completeness check; the grouped tables above are the work-planning view.

| Source component ID | Planning destination |
|---|---|
| `Comp.ID:SRM.P01.risk-map-agr` | `aggregate-risk-map-nodes`; later `full-risk-map-edges` |
| `Comp.ID:SRM.P01.risk-map-agr.node.hover` | `node-hover` |
| `Comp.ID:SRM.P01.risk-map-agr.edge-agr-agr.hover` | `edge-hover` |
| `Comp.ID:SRM.P01.risk-chains` | `risk-chains` |
| `Comp.ID:SRM.P01.selected-chain` | `selected-chain-label` |
| `Comp.ID:SRM.P01.key-triggers-alerts` | `key-triggers-alerts` |
| `Comp.ID:SRM.P01.News-Implication` | `news-implication` |
| `Comp.ID:SRM.P01.watch-points` | `watch-points` |
| `Comp.ID:SRM.P01.Delta-analysis` | `delta-analysis` |
| `Comp.ID:SRM.P01.spillover-strenght` | `spillover-strength` |
| `Comp.ID:SRM.P01.sector-summary-table` | `sector-risk-summary` |
| `Comp.ID:SRM.P01.sector-summary-table.sector-news` | `sector-news` |
| `Comp.ID:SRM.P01.sector-summary-table.hu-macro-transmission-impact` | `hu-macro-transmission-impact` |
| `Comp.ID:SRM.P02.risk-map-agr` | `expanded-risk-map-nodes`; later `full-risk-map-edges` |
| `Comp.ID:SRM.P02.risk-map-agr.node.hover` | `node-hover` |
| `Comp.ID:SRM.P02.risk-map-agr.edge-agr-agr.hover` | `edge-hover` |
| `Comp.ID:SRM.P02.risk-map-underlying` | `expanded-risk-map-nodes`; later `full-risk-map-edges` |
| `Comp.ID:SRM.P02.risk-map-underlying.node.hover` | `node-hover` |
| `Comp.ID:SRM.P02.risk-map-underlying.edge-underlying-underlying.hover` | `edge-hover` |
| `Comp.ID:SRM.P02.risk-map-underlying.edge-underlying-agr.hover` | `edge-hover` |
| `Comp.ID:SRM.P02.risk-map-underlying.edge-agr-underlying.hover` | `edge-hover` |
| `Comp.ID:SRM.P02.selected-aggr-summary` | `selected-node-summary` |
| `Comp.ID:SRM.P02.risk-index` | `node-risk-index` |
| `Comp.ID:SRM.P02.risk-concentration` | `node-risk-concentration` |
| `Comp.ID:SRM.P02.interpretation` | `node-interpretation` |
| `Comp.ID:SRM.P02.top-underlying-nodes` | `underlying-node-summary` |
| `Comp.ID:SRM.P02.internal-transm-summary` | `internal-transmission-summary` |
| `Comp.ID:SRM.P02.external-transm-summary` | `external-transmission-summary` |
| `Comp.ID:SRM.P02.quantitative-insights` | `quantitative-insights` |
