#!/usr/bin/env bash
# Thin executable handoff shell for the SRM beta Node Risk Index (wave D5).
#
# Exactly six conceptual stages, in order, and nothing else:
#
#   1 generate          -> generate-synthetic
#   2 adapt             -> prepare-quant-input
#   3 estimate          -> estimate-underlying-u2   (the one expensive stage)
#   4 aggregate         -> estimate-aggregate-a1    (over the reloaded U2 artifact)
#   5 project           -> project-api
#   6 validate/export   -> validate-run
#
# Every quantitative decision lives in Python. This file contains no formula, no threshold,
# no epsilon, no window length and no state literal: the profile identifiers it passes are
# names, not numbers. It exists so a backend engineer has one command.
#
# What this script deliberately does NOT do:
#   * no network of any kind, and no package installation
#   * no database client
#   * no service control, container control or process signalling
#   * no scheduler registration
#   * no git invocation
#   * no deletion or overwrite of anything the caller owns. This script itself contains no
#     deletion at all. An existing run directory, stage directory or example bundle is a
#     refusal (exit 7), never a merge or a replacement. A caller may point --fit-cache-dir at
#     a content-addressed cache; this run reads it, appends to it and records its counters,
#     and never prunes, rewrites or removes it.
#
#     The precise internal exception, stated so the guarantee is not overclaimed: the Python
#     CLI publishes each stage atomically by writing into a temporary staging directory it
#     created itself and then renaming it into place, and it clears that temporary directory
#     in a `finally`. So a stage that fails part-way removes its own scratch space -- which is
#     what stops a failed run from leaving a half-written directory that blocks the next
#     attempt. Nothing a caller named is ever touched.
#   * no server is started, called or configured. This prepares a deterministic payload; it
#     does not exercise the endpoint.
#
# Human Stop Q3 accepted cell-08 (technology-aggregate-a1-v1 over u2-dual-memory-downside-v1)
# as the single primary beta API profile. cell-12 is a challenger diagnostic only, produced
# only under --with-challenger-sidecar, never as the public payload and never blended into it.
#
# Synthetic only. Not production-ready. No production Data Layer integration.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BETA_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
REPO_ROOT="$(cd "${BETA_ROOT}/.." && pwd)"

PYTHON="${REPO_ROOT}/.venv/bin/python"
if [[ ! -x "${PYTHON}" ]]; then
    PYTHON="$(command -v python3 || true)"
fi

OUTPUT_ROOT=""
RUN_ID="d5-handoff-v0-1"
SEED="20260928"
# The declared S1 integrated validation fixture: 3024 observations, 1520 scored, and a scored path
# that visits calm, an isolated shock, a broad crash, a persistent bear phase, a recovery and a
# favorable rally.
#
# That describes the *driver* path, not the published state path, and the two are not the same
# thing. On the canonical seed the A1 score reaches 0.858, so the published chart occupies low,
# watch and elevated but never critical. This fixture is a realistic example, not a state-coverage
# fixture -- the score-to-state mapping onto all four declared states, across all three internal
# thresholds and both closed endpoints, is covered by unit tests (T-PRJ-001 and P-PRJ-001), where a
# boundary can be asserted directly instead of being hoped for from a simulation.
FIXTURE_PROFILE="tech-validation-s1-v1"
FIT_CACHE_DIR=""
EXAMPLE_BUNDLE_DIR=""
WITH_CHALLENGER_SIDECAR="no"

ACCEPTED_UNDERLYING_PROFILE_ID="u2-dual-memory-downside-v1"
ACCEPTED_AGGREGATE_PROFILE_ID="technology-aggregate-a1-v1"

usage() {
    cat <<'USAGE'
Usage: run_node_risk_synthetic.sh --output-root DIR [options]

Required:
  --output-root DIR           Parent directory for this run. Must not already contain the
                              run id or its stage sibling; an existing destination is a
                              refusal, never an overwrite.

Options:
  --run-id ID                 Run identifier and published directory name.
                              Default: d5-handoff-v0-1
  --python PATH               Python interpreter to invoke. Default: the repository .venv,
                              falling back to python3.
  --seed N                    Synthetic generator master seed. Default: 20260928
  --fixture-profile ID        Declared synthetic fixture profile.
                              Default: tech-validation-s1-v1
  --fit-cache-dir DIR         Content-addressed U2 fit cache. Read and appended to; never
                              pruned, rewritten or removed. Omit for an in-memory cache that
                              does not persist. Point two runs at one path to get an
                              empty-cache run and a warm-cache run without deleting anything.
  --example-bundle-dir DIR    Also write the canonical example bundle (response, receipt,
                              hashes, render evidence; no cache, no stage intermediates).
                              Refuses an existing destination.
  --with-challenger-sidecar   Also write the cell-12 challenger diagnostic. Never the public
                              payload, never ensembled with the accepted cell, and it costs
                              no additional optimizer fit.
  -h, --help                  Print this message.

Exit codes are the CLI's declared stage exit classes:
  0 success
  2 invalid configuration / manifest / schema / hash identity
  3 synthetic failure
  4 adapter failure
  5 estimator failure
  6 export validation failure
  7 output conflict (destination already exists)
USAGE
}

fail() {
    printf 'run_node_risk_synthetic.sh: %s\n' "$1" >&2
    exit 2
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --output-root)          OUTPUT_ROOT="${2:-}"; shift 2 ;;
        --run-id)               RUN_ID="${2:-}"; shift 2 ;;
        --python)               PYTHON="${2:-}"; shift 2 ;;
        --seed)                 SEED="${2:-}"; shift 2 ;;
        --fixture-profile)      FIXTURE_PROFILE="${2:-}"; shift 2 ;;
        --fit-cache-dir)        FIT_CACHE_DIR="${2:-}"; shift 2 ;;
        --example-bundle-dir)   EXAMPLE_BUNDLE_DIR="${2:-}"; shift 2 ;;
        --with-challenger-sidecar) WITH_CHALLENGER_SIDECAR="yes"; shift ;;
        -h|--help)              usage; exit 0 ;;
        *)                      usage >&2; fail "unknown argument: $1" ;;
    esac
done

[[ -n "${OUTPUT_ROOT}" ]] || { usage >&2; fail "--output-root is required"; }
[[ -n "${RUN_ID}" ]] || fail "--run-id must not be empty"
[[ -n "${PYTHON}" && -x "${PYTHON}" ]] || fail "no usable Python interpreter: '${PYTHON}'"

# The published run directory and the stage-intermediate sibling. They are separate because
# stage 5 publishes RUN_DIR atomically and would refuse a destination this script had already
# created to hold stage output.
RUN_DIR="${OUTPUT_ROOT}/${RUN_ID}"
STAGE_ROOT="${OUTPUT_ROOT}/${RUN_ID}.stages"

# Refuse before doing any work. The Python stages each refuse their own destination too; this
# check exists so a collision costs zero seconds instead of one full U2 fit.
[[ -e "${RUN_DIR}" ]] && { printf 'run_node_risk_synthetic.sh: output destination %s already exists; it is never overwritten\n' "${RUN_DIR}" >&2; exit 7; }
[[ -e "${STAGE_ROOT}" ]] && { printf 'run_node_risk_synthetic.sh: stage destination %s already exists; it is never overwritten\n' "${STAGE_ROOT}" >&2; exit 7; }
if [[ -n "${EXAMPLE_BUNDLE_DIR}" && -e "${EXAMPLE_BUNDLE_DIR}" ]]; then
    printf 'run_node_risk_synthetic.sh: example bundle destination %s already exists; it is never overwritten\n' "${EXAMPLE_BUNDLE_DIR}" >&2
    exit 7
fi

mkdir -p "${STAGE_ROOT}"

GENERATE_DIR="${STAGE_ROOT}/01-generate"
ADAPT_DIR="${STAGE_ROOT}/02-adapt"
ESTIMATE_DIR="${STAGE_ROOT}/03-estimate"
AGGREGATE_DIR="${STAGE_ROOT}/04-aggregate"
VALIDATE_DIR="${STAGE_ROOT}/06-validate"

run_stage() {
    local label="$1"
    shift
    printf '[%s] %s\n' "${label}" "$*"
    ( cd "${BETA_ROOT}" && "${PYTHON}" -m srm_beta_quant.cli "$@" )
}

printf 'SYNTHETIC handoff run %s\n' "${RUN_ID}"
printf 'beta root   : %s\n' "${BETA_ROOT}"
printf 'python      : %s\n' "${PYTHON}"
printf 'published to: %s\n' "${RUN_DIR}"
printf 'stages in   : %s\n' "${STAGE_ROOT}"
if [[ -n "${FIT_CACHE_DIR}" ]]; then
    printf 'fit cache   : %s (read and appended to, never pruned)\n' "${FIT_CACHE_DIR}"
else
    printf 'fit cache   : in-memory only (no --fit-cache-dir given)\n'
fi

# ---------------------------------------------------------------- 1 generate
run_stage "1/6 generate" generate-synthetic \
    --fixture-profile "${FIXTURE_PROFILE}" \
    --seed "${SEED}" \
    --output-dir "${GENERATE_DIR}" \
    --run-id "${RUN_ID}"

# ------------------------------------------------------------------- 2 adapt
run_stage "2/6 adapt" prepare-quant-input \
    --run-directory "${GENERATE_DIR}/${RUN_ID}" \
    --output-dir "${ADAPT_DIR}" \
    --run-id "${RUN_ID}"

# ---------------------------------------------------------------- 3 estimate
# One profile, not four: cell-08 needs only the accepted U2 profile, and this is the stage
# whose cost dominates the run.
ESTIMATE_ARGS=(
    estimate-underlying-u2
    --prepared-directory "${ADAPT_DIR}/${RUN_ID}"
    --profile-id "${ACCEPTED_UNDERLYING_PROFILE_ID}"
    --output-dir "${ESTIMATE_DIR}"
    --run-id "${RUN_ID}"
)
if [[ -n "${FIT_CACHE_DIR}" ]]; then
    ESTIMATE_ARGS+=(--fit-cache-dir "${FIT_CACHE_DIR}")
fi
run_stage "3/6 estimate" "${ESTIMATE_ARGS[@]}"

# --------------------------------------------------------------- 4 aggregate
# The real boundary: the aggregate reloads the serialized U2 artifact instead of recomputing
# an underlying, so this is cell-08 and not cell-07 wearing its name.
run_stage "4/6 aggregate" estimate-aggregate-a1 \
    --prepared-directory "${ADAPT_DIR}/${RUN_ID}" \
    --underlying-directory "${ESTIMATE_DIR}/${RUN_ID}" \
    --input-panel-id "${ACCEPTED_UNDERLYING_PROFILE_ID}" \
    --profile-id "${ACCEPTED_AGGREGATE_PROFILE_ID}" \
    --output-dir "${AGGREGATE_DIR}" \
    --run-id "${RUN_ID}"

# ----------------------------------------------------------------- 5 project
PROJECT_ARGS=(
    project-api
    --aggregate-directory "${AGGREGATE_DIR}/${RUN_ID}"
    --underlying-directory "${ESTIMATE_DIR}/${RUN_ID}"
    --output-dir "${OUTPUT_ROOT}"
    --run-id "${RUN_ID}"
)
if [[ -n "${FIT_CACHE_DIR}" ]]; then
    PROJECT_ARGS+=(--fit-cache-dir "${FIT_CACHE_DIR}")
fi
if [[ "${WITH_CHALLENGER_SIDECAR}" == "yes" ]]; then
    PROJECT_ARGS+=(--with-challenger-sidecar)
fi
run_stage "5/6 project" "${PROJECT_ARGS[@]}"

# -------------------------------------------------------- 6 validate/export
VALIDATE_ARGS=(
    validate-run
    --run-directory "${RUN_DIR}"
    --output-dir "${VALIDATE_DIR}"
    --run-id "${RUN_ID}"
)
if [[ -n "${EXAMPLE_BUNDLE_DIR}" ]]; then
    VALIDATE_ARGS+=(--example-bundle-dir "${EXAMPLE_BUNDLE_DIR}")
fi
run_stage "6/6 validate/export" "${VALIDATE_ARGS[@]}"

printf '\nSYNTHETIC handoff complete.\n'
printf 'response : %s/public/node_risk_index_response.json\n' "${RUN_DIR}"
printf 'receipt  : %s/receipt/handoff_receipt.json\n' "${RUN_DIR}"
printf 'preview  : %s/preview/\n' "${RUN_DIR}"
printf 'validated: %s/%s/validation_receipt.json\n' "${VALIDATE_DIR}" "${RUN_ID}"
if [[ -n "${EXAMPLE_BUNDLE_DIR}" ]]; then
    printf 'example  : %s\n' "${EXAMPLE_BUNDLE_DIR}"
fi
printf 'Synthetic fixture output. Not production-ready; no Data Layer integration.\n'
