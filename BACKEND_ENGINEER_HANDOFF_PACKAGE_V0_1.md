# Backend engineer handoff — Node Risk Index, `GET /api/v1/nodes/{nodeId}/risk-index`

- **Package id**: `D5-BACKEND-HANDOFF-V0_1`
- **Context**: `srm-beta-market-stress-daily-v1`
- **Accepted model**: `cell-08` — `technology-aggregate-a1-v1` over `u2-dual-memory-downside-v1`
- **Status**: **synthetic-ready. Not production-ready.**

## What this is

This package gives you a **deterministic, schema-valid `NodeRiskIndexResponse` on disk**, plus the
provenance needed to say exactly which model produced it. You can feed it to your endpoint
implementation, fixture your tests against it, or diff it against what your service returns.

**It does not run a server.** Nothing here starts, calls, deploys or configures a service, and
nothing touches a database, a network or a scheduler. Exercising the endpoint is your step.

## One exact command

```bash
cd /path/to/QCP_quant/srm_beta_quant

./scripts/run_node_risk_synthetic.sh \
  --output-root handoff_runs \
  --run-id d5-handoff-empty-cache-v0-1 \
  --fit-cache-dir handoff_runs/u2_fit_cache \
  --seed 20260928
```

Add `--example-bundle-dir <dir>` to also emit the small cache-free bundle described below, and
`--with-challenger-sidecar` to additionally emit the cell-12 diagnostic (never the payload).
`--python <path>` selects the interpreter; by default the script uses the repository `.venv` and
falls back to `python3`.

### Prerequisites

- Python **3.11+**. The repository `.venv` is used automatically if present.
- The package installed: `pip install -e .` from `srm_beta_quant/`, plus the dev extra for
  `jsonschema` (`pip install -e '.[dev]'`) if you want to re-validate the payload yourself.
- **No network access is required or used.** The synthetic fixture is generated locally from the
  pinned parameter and scenario manifests.
- Disk: about 40 MB for a full run, most of it the fit cache.

### Runtime — measured, not estimated

| run | fit cache | wall clock | fits |
|---|---|---|---|
| cold (cache path did not exist) | `hits 0, misses 408, writes 408` | **41 min 22 s** | 408 |
| warm (same cache path, new run id) | `hits 408, misses 0, writes 0` | **2 min 19 s** | 0 |

Essentially all cold-run time is stage 3, the U2 GJR-t optimizer fits. Stages 4, 5 and 6 perform
**zero** fits, because stage 3's panel is serialized and reloaded rather than recomputed.

Point a second run at the **same** `--fit-cache-dir` with a **different** `--run-id` to get the
warm path. Nothing is deleted between runs — see *Output and deletion guarantee* below.

## The six stages

`generate → adapt → estimate → aggregate → project → validate/export`. Each is one
`python -m srm_beta_quant.cli <stage>` invocation; the shell contains no quantitative formula.

| # | stage | CLI stage | does |
|---|---|---|---|
| 1 | generate | `generate-synthetic` | the declared synthetic fixture `tech-validation-s1-v1` |
| 2 | adapt | `prepare-quant-input` | the validated quant-input panel |
| 3 | estimate | `estimate-underlying-u2` | **the expensive stage.** U2 GJR-t, one profile, serialized |
| 4 | aggregate | `estimate-aggregate-a1` | A1 over the **reloaded** U2 artifact → `cell-08` |
| 5 | project | `project-api` | the public payload, the receipt and the preview |
| 6 | validate/export | `validate-run` | independent re-validation from the published bytes |

## Artifact tree

```
handoff_runs/
  u2_fit_cache/                              <- content-addressed; read and appended to only
  d5-handoff-empty-cache-v0-1/               <- the published run
    public/node_risk_index_response.json     <- THE PAYLOAD
    receipt/handoff_receipt.json             <- provenance sidecar
    receipt/stage_chain.json
    preview/risk_index_preview.png           <- watermarked SYNTHETIC
    preview/chart_render_check.md            <- text render check, always emitted
  d5-handoff-empty-cache-v0-1.stages/        <- stage intermediates
    01-generate/  02-adapt/
    03-estimate/<run-id>/underlying_u2_estimate.json
    04-aggregate/<run-id>/aggregate_a1_estimate.json
    06-validate/<run-id>/validation_receipt.json
```

### Exact response location

```
handoff_runs/d5-handoff-empty-cache-v0-1/public/node_risk_index_response.json
```

A committed-in-tree copy, cache-free and small, is also provided for convenience:

```
fixtures/node_risk/d5/handoff_example/node_risk_index_response.json
```

> Note on status: the example bundle is **versionable but currently uncommitted**. It exists in the
> working tree of this delivery and has not been committed or pushed.

## Mapping onto the endpoint

The payload is the complete `NodeRiskIndexResponse` body for:

```
GET /api/v1/nodes/agg-technology/risk-index
```

- `nodeId` is the path parameter, and this context projects exactly one node, `agg-technology`.
- **`filterContext` is not modelled by D5.** The endpoint's input schema requires it; this payload
  is what the endpoint returns for a single filter selection. Mapping `filterContext` onto the
  quantitative layer is out of scope here and is an open item.
- Authentication, pagination and caching headers are backend concerns and are untouched.

The body validates against the frozen
`contracts/node_risk_index_response_v1.schema.json`
(`$id: https://qcp.local/srm-beta/node-risk-index-response/1.0.0`). That schema is **authority**,
not output: it predates this delivery and was implemented, not authored, by it.

### Shape, and what is deliberately absent

Top level is exactly `nodeId`, `riskIndexChart`, `latest` — `additionalProperties: false`.

```
riskIndexChart.format              "multi_columnar_time_series"
riskIndexChart.version             "1.0"
riskIndexChart.chart.title          "Technology market stress intensity"
riskIndexChart.chart.xAxis          {label: "Date", type: "date"}
riskIndexChart.chart.yAxis          {label: "Market stress intensity"}
riskIndexChart.series[0]            id "market_stress_intensity", number, left  axis, "0.00"
riskIndexChart.series[1]            id "risk_state_numeric",      integer, right axis, "0"
riskIndexChart.series[].index       each series carries its OWN date index
riskIndexChart.meta.order           "ascending"
riskIndexChart.meta.missingValuePolicy "gap"
riskIndexChart.meta.stateValueMap   {low:1, watch:2, elevated:3, critical:4}
latest.value                        number in [0,1], NON-nullable
latest.deltaDirection               "up" | "down" | "flat" | "not_available"
```

**There is no model id, digest, run id or `SYNTHETIC` marker in the payload.** The API authority
admits three members and the schema enforces it, so all provenance lives in the receipt sidecar.
If you need to surface "this is synthetic" in a UI, take it from the sidecar or the directory —
not by adding a field.

### Semantics you will want to know

- **States.** `low [0,0.5)`, `watch [0.5,0.75)`, `elevated [0.75,0.9)`, `critical [0.9,1]`.
  Exact thresholds map **upward**: `0.5` is `watch`, `0.75` is `elevated`, `0.9` is `critical`.
- **Delta.** Current score against the score **5 scored observations earlier**, with a closed
  `±0.02` deadband **in score units**: `0.52` against `0.50` is `flat`. Fewer than 6 scored
  observations gives `not_available`.
- **History.** `full_scored_history`, read literally: the series runs from the first valid scored
  observation to the last. **No leading warm-up nulls and no trailing ones**; `null` appears only
  between two scored observations, and a `null` is a gap, never a dropped date. Both series are
  positionally aligned and each carries its own ascending date index.
- **`latest` is the last scored observation**, which is therefore the last chart point.

### What this particular example does and does not exercise

The canonical run is a realistic example, **not** a state-coverage fixture. Measured on it:

| | |
|---|---|
| score range | `0.06722247408000441` … `0.8583480627849669` |
| `risk_state_numeric` counts | `low` (1): **626**, `watch` (2): **130**, `elevated` (3): **7** |
| `critical` (4) | **does not occur on this path** |

So if you are building a UI that renders a `critical` band, this payload will not drive it — do not
infer from its absence that the state is unreachable or that the mapping is untested. The
score-to-state mapping onto **all four declared states** is covered by unit tests — across the
**three internal thresholds** `0.5`, `0.75` and `0.9` (four states need only three cut points) plus
the **closed endpoints** `0.0` and `1.0`, each asserted from both sides. `T-PRJ-001` covers the
boundaries; `P-PRJ-001` covers totality, disjointness, monotonicity and contiguity of each state's
preimage. A boundary is asserted directly there; a simulation can only hope to wander onto one.

To exercise a `critical` band in a UI, either craft a fixture payload by editing a copy of this
response, or generate one of the declared S2 presentation variants
(`tech-presentation-critical-v1`) via `--fixture-profile`.

## Validation receipt

Stage 6 re-reads the published bytes — it does not re-check the objects stage 5 held in memory —
re-validates against the frozen schema and re-hashes against the receipt:

```
handoff_runs/d5-handoff-empty-cache-v0-1.stages/06-validate/d5-handoff-empty-cache-v0-1/validation_receipt.json
```

```json
{"result": "pass",
 "checks": ["public_response_schema_valid", "response_digest_matches_receipt",
            "accepted_cell_is_cell_08", "no_ensemble_no_fallback",
            "scored_history_trimmed_to_scored_endpoints", "series_index_ascending"]}
```

## Provenance sidecar

`receipt/handoff_receipt.json`, validated against the additive
`contracts/node_risk_index_handoff_receipt_v1.schema.json`. From the executed run:

| field | value |
|---|---|
| `accepted_cell.cell_id` | `cell-08` |
| `accepted_cell.aggregate_profile_id` | `technology-aggregate-a1-v1` |
| `accepted_cell.underlying_profile_id` / `input_panel_id` | `u2-dual-memory-downside-v1` |
| `accepted_cell.node_id` | `agg-technology` |
| `ensemble` / `fallback_permitted` | `false` / `false` |
| `generated_from` | `synthetic` |
| `scored_history` | 763 points, 763 scored, 0 interior gaps, 0 leading nulls, 0 trailing nulls |
| first / last scored date | `2023-08-14` / `2026-08-27` |
| `latest` | value `0.0728219305561878`, state `low`, delta `down` |
| `response_sha256` | `007306ecd84618d428b842d9842d9b2140b3658effd938acb3bc12006348fcb1` |
| `upstream_identity.child_result_bundle_hash` | `2c6ed36bfe4ad69577f9ae40a0f110adef2ab3a24e26ba0e9f1b964ffd7ebbf7` |
| `upstream_identity.underlying_artifact_sha256` | `678d7777ba064e88030f1504b33c2345513421f0e5ed7943f95a27ce2fed21b6` |
| `upstream_identity.aggregate_artifact_sha256` | `645b5c04456deb706af3519077876db652b702ba7e703f385826cf0da6e70519` |
| `upstream_identity.code_identity` | `srm-beta-node-risk-ch6` |
| `upstream_identity.projection_code_identity` | `srm-beta-node-risk-d5` |

### Two different digests — do not confuse them

- `response_sha256` = `007306ec…48fcb1` is the digest of the **canonical JSON object**. It is what
  the receipt carries and what the determinism check compares, because it is invariant to
  formatting.
- `299a0483e0a025ea6105691449833902c79371878b293369a44ace5ed6029a90` is the sha256 of the
  **file bytes** as written. That is what `shasum -a 256` on the file reports, and what
  `hashes.txt` in the example bundle lists.

Both are correct; they digest different things.

### Example bundle digests (file bytes)

```
d12714f14f8d7f6d75cfd2d096f5195e7f55a9595667504c2bd980715b3e593b  chart_render_check.md
d9b703b895995c05daa61528140edc12d2e86339fddbbcc49a311b022d4671ca  handoff_receipt.json
299a0483e0a025ea6105691449833902c79371878b293369a44ace5ed6029a90  node_risk_index_response.json
a93a980da212905876be69f12fff11ce44e4833cfceade38520aeabc2377dbca  risk_index_preview.png
```

## Synthetic label — where it lives

- in the receipt: `generated_from: "synthetic"` and a `synthetic_label` sentence;
- in the preview PNG: a `SYNTHETIC / NOT FOR PRODUCTION` watermark across the plot;
- in `chart_render_check.md`: a bold label above the table;
- in the run directory name and this document.

**Not in the payload**, because the API authority does not admit such a field.

## Render / preview artifact

- `preview/risk_index_preview.png` — both series on their declared axes (score left `0..1`, state
  right `1..4`), the three threshold lines annotated, watermarked. Written with matplotlib; if no
  plotting backend is importable it is simply absent and the run still succeeds.
- `preview/chart_render_check.md` — **always** emitted. First and last ten points with date, score
  and state, plus the summary counts. Use this to eyeball alignment without opening an image.

## Exit behaviour

The shell returns the CLI's declared stage exit classes:

| code | meaning |
|---|---|
| 0 | success |
| 2 | invalid configuration / manifest / schema / hash identity |
| 3 | synthetic generation failure |
| 4 | adapter failure |
| 5 | estimator failure |
| 6 | export validation failure |
| **7** | **output conflict — the destination already exists** |

Code `1` is deliberately unassigned, so an unhandled interpreter crash stays distinguishable from
a typed refusal.

A refusal prints `[<ErrorType>] <message>` and writes nothing.

## Output and deletion guarantee

**No caller-owned path is ever deleted, overwritten, pruned or truncated.** An existing run
directory, stage directory or example bundle is a refusal (exit 7), never a merge — verified: a
re-run against an existing destination exited 7 and left the payload byte-identical. A
`--fit-cache-dir` you supply is read and appended to; it is never pruned or rewritten. The shell
script itself contains no deletion of any kind.

**The one internal exception, stated so the guarantee is not overclaimed.** Each stage publishes
atomically: the CLI writes into a temporary staging directory it created itself and renames it
into place, clearing that temporary directory in a `finally`. So a stage that fails part-way
removes **its own scratch space**, publishing nothing and leaving no orphaned partial. No path
you named is touched by that cleanup.

**This is per stage, not per run — plan your reruns accordingly.** If the shell fails at, say,
stage 4, stages 1–3 have already published under that run id and those directories stay, on
purpose, as evidence of what happened. Re-running the whole command with the same `--run-id` will
refuse at the first already-published stage (exit 7). To retry, use a **new `--run-id`**, or
deliberately remove the previous run's directories yourself. Nothing in this tooling reclaims a
partially published run for you.

## Non-goals — explicit

- Does **not** start, call, deploy, configure or health-check a server.
- **No** production Data Layer integration, database, network or market data. Synthetic only.
- **No** scheduler, cron entry or daemon.
- **No** git action, no commit, no push.
- **No** production admission. This is **not production-ready**.
- **No** ensembling of `cell-08` and `cell-12`, and **no fallback**: if the accepted cell is
  unavailable the run refuses rather than publishing A0, A1-over-U1 (which is `cell-07`) or A2.
- Does **not** model `filterContext`, multiple nodes, node expansion or drill-through.
- Does **not** calibrate the delta deadband; `±0.02` is provisional and its sensitivity grid is
  diagnostic only.

## Known: a repository-wide `pytest` is not green, for an unrelated inherited reason

If you run the whole test suite you will see failures. They are **not** from this handoff and
**not** in the Node Risk code. Flagged here so you do not spend time on them.

`srm_beta_quant/LEARNING_REGISTRY.md` is a Tier-B (hash-verified) frozen input of the KYI Catalog
Factory closure manifests, and its bytes disagree with the hash those manifests expect:

| | |
|---|---|
| `LEARNING_REGISTRY.md`, working tree **and** HEAD `21113ae` | `f9a6f389…daf3bec7` |
| expected by `catalog/frozen_inputs/pilot-12_closure*.yaml` | `07e811e3…e50b47f92` |

The file is byte-identical to HEAD, so the mismatch is present on pristine `21113ae` and was
inherited from an earlier milestone. Failing tests, all one root cause
(`EvidenceHashMismatch: Tier-B input drifted: LEARNING_REGISTRY.md`):

```
tests/kyi_catalog/test_amendment_f008.py::test_all_four_closure_manifests_verify_against_live_bytes
tests/kyi_catalog/test_frozen_inputs.py::test_every_manifest_entry_exists_and_verifies
tests/kyi_catalog/test_frozen_inputs.py::test_run_all_checks_reports_check_3_when_audited
tests/kyi_catalog/test_frozen_inputs.py::test_run_all_checks_passes_on_the_real_repository
tests/kyi_catalog/test_frozen_inputs.py::test_no_tier_b_file_changes_within_this_package
```

The D5 delivery touches neither `LEARNING_REGISTRY.md` nor any Catalog/KYI manifest — its
learning entries went into `LEARNING_REGISTRY_V2.md`, which no manifest pins — and it is
forbidden from modifying that track, so it is left as found. Resolving it needs an
**owner-approved KYI correction** deciding which side is authoritative.

**To verify the Node Risk work specifically**, run the scope rather than the repository:

```bash
python -m pytest tests/node_risk_d5 -q          # the D5 successor acceptance ids
python -m pytest tests/obligations -q           # the obligation artifacts and contract inventory
```

### The Node Risk scope is not uniformly green either — exact measured results

Stated plainly so you are not surprised. Run per directory, so every remaining failure is
attributable:

| directory | result |
|---|---|
| `tests/obligations` | 34 passed |
| `tests/node_risk_d5` | 16 passed, 2 skipped (the two `slow` full-handoff tests, gated behind `SRM_D5_FULL_HANDOFF=1`) |
| `tests/node_risk` | 208 passed, 3 failed |
| `tests/node_risk_challenger` | 104 passed, 3 skipped, 7 failed |

**`tests/node_risk` — 3 failed.** One was a genuine D5 regression, caught and fixed: a
package-surface guard still asserted `projection.py` must not exist. Extended to its post-Q3 form;
the affected file then re-ran at 92 passed. The remaining two, `B-S1-004` and `S-GJR-002`, are
exactly `challenger_support.PRESERVED_RED_RESULTS` — "the two V0_1 results that stay red" — and
predate this work.

**`tests/node_risk_challenger` — 7 failed, none a D5 regression.** The 3 skips are the retired
`G-NOD5-001…003` guards. `B-S1-003R` is an owner-accepted standing failure. `D-CH-003` and
`K-U2-001…003` / `K-A2-001…002` need the expensive path and are correctly
`not_evidenced_in_this_bundle` in a default run, which does not set `SRM_CHALLENGER_FULL=1`. The
evidenced disposition for that wave remains the existing **D6 challenger review bundle
(103 pass / 1 fail)** and its ledger; the default run recorded here is a weaker configuration and
is **not** claimed to be green.

None of this affects the payload you were handed: it was produced by the executed six-stage run,
validates against the frozen schema, and its identity and digests are in the receipt.

## If you want to re-verify it yourself

```bash
python - <<'PY'
import json, jsonschema, pathlib
root = pathlib.Path('.')
resp = json.loads((root/'handoff_runs/d5-handoff-empty-cache-v0-1/public/node_risk_index_response.json').read_text())
schema = json.loads((root/'obligations/node-risk-index/contexts/srm-beta-market-stress-daily-v1/contracts/node_risk_index_response_v1.schema.json').read_text())
jsonschema.validate(resp, schema)
print('valid;', len(resp['riskIndexChart']['series'][0]['values']), 'points; latest', resp['latest'])
PY
```

## Related records

- `VERSIONED_DECISION_Q3_ACCEPTED_MODEL_V0_1.md` — why `cell-08`, and the three prohibitions
- `D5_STATUS_AND_LIMITATIONS_V0_1.md` — full limitation list and open items
- `TEST_MANIFEST_D5_SUCCESSOR_V0_1.yaml` — the acceptance claims behind this delivery
- `systemic-risk-api-architecture.md` — the public API authority (read-only)
