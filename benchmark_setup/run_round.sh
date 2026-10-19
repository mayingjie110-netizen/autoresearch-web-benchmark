#!/usr/bin/env bash
# Manual launcher only. Usage: bash run_round.sh A 1 /absolute/path/to/model.patch
set -euo pipefail
ROOT=/data2/home/yingjie/autoresearch
source "$ROOT/env.sh"
SIDE=${1:?Specify A or B}
ROUND=${2:?Specify round 1..5}
PATCH=${3:?Specify an absolute patch path, --missing, or --violation}
[[ "$SIDE" =~ ^[AB]$ && "$ROUND" =~ ^[1-5]$ ]] || exit 2
if [[ "$PATCH" != --missing && "$PATCH" != --violation ]]; then
    [[ "$PATCH" = /* && -f "$PATCH" ]] || { echo 'Patch path must be absolute and exist.'; exit 2; }
fi
CODE="$ROOT/comparison/$SIDE"
RUN="$ROOT/records/formal/$SIDE/round-$ROUND"
STATE="$ROOT/comparison/sequence.tsv"
COMMON=$(cat "$ROOT/comparison/common_start_commit.txt")

# Reject wrong order, missing review, and unexpected code changes before creating a run.
if [[ ! -f "$STATE" ]]; then
    [[ "$SIDE:$ROUND" = A:1 ]] || { echo 'First opportunity must be A 1.'; exit 2; }
    [[ "$(git -C "$ROOT/comparison/A" rev-parse HEAD)" = "$COMMON" ]]
    [[ "$(git -C "$ROOT/comparison/B" rev-parse HEAD)" = "$COMMON" ]]
else
    LAST=$(tail -n 1 "$STATE")
    LAST_SIDE=$(printf '%s' "$LAST" | cut -f 1)
    LAST_ROUND=$(printf '%s' "$LAST" | cut -f 2)
    [[ -f "$ROOT/records/formal/$LAST_SIDE/round-$LAST_ROUND/review.txt" ]] || {
        echo 'STOP: previous opportunity needs a recorded review and keep/revert decision.'; exit 2;
    }
    if [[ "$LAST_SIDE" = A ]]; then EXPECTED="B:$LAST_ROUND";
    else EXPECTED="A:$((LAST_ROUND + 1))"; fi
    [[ "$SIDE:$ROUND" = "$EXPECTED" ]] || { echo "Expected $EXPECTED"; exit 2; }
fi
[[ -z "$(git -C "$CODE" status --porcelain)" ]] || {
    echo 'STOP: checkout is not clean. Do not reset without preserving changes.'; exit 2;
}
mkdir -p "$(dirname "$RUN")"
mkdir "$RUN" # An existing run is never overwritten.
cp "$CODE/train.py" "$RUN/start_train.py"
git -C "$CODE" rev-parse HEAD > "$RUN/start_commit.txt"
date -u '+%Y-%m-%dT%H:%M:%SZ' > "$RUN/start_utc.txt"
printf '%s\t%s\n' "$SIDE" "$ROUND" >> "$STATE"
if [[ "$PATCH" = --missing || "$PATCH" = --violation ]]; then
    printf '%s\n' "$PATCH" > "$RUN/status.txt"
    echo 'Opportunity recorded without executing code. Save response/evidence and finalize.'
    exit 0
fi
cp "$PATCH" "$RUN/model.patch"

# A submitted patch must change only the existing train.py, not rename/delete it.
if ! git -C "$CODE" apply --numstat "$RUN/model.patch" > "$RUN/patch_numstat.txt" 2> "$RUN/patch_parse.log"; then
    echo PATCH_INVALID | tee "$RUN/status.txt"; exit 0
fi
if ! awk -F '\t' 'NF != 3 || $3 != "train.py" || $1 !~ /^[0-9]+$/ || $2 !~ /^[0-9]+$/ {bad=1} END {exit (NR != 1 || bad)}' "$RUN/patch_numstat.txt"; then
    echo PATCH_OUT_OF_SCOPE | tee "$RUN/status.txt"; exit 0
fi
if ! git -C "$CODE" apply --check "$RUN/model.patch" > "$RUN/apply_check.log" 2>&1; then
    echo PATCH_NOT_APPLICABLE | tee "$RUN/status.txt"; exit 0
fi
git -C "$CODE" apply "$RUN/model.patch"
if [[ ! -f "$CODE/train.py" || -L "$CODE/train.py" ]]; then
    echo PATCH_INVALID_FILE | tee "$RUN/status.txt"; exit 0
fi
git -C "$CODE" diff --exit-code HEAD -- prepare.py pyproject.toml uv.lock
cp "$CODE/train.py" "$RUN/candidate_train.py"
git -C "$CODE" diff > "$RUN/applied.patch"
sha256sum "$CODE/train.py" "$CODE/prepare.py" "$CODE/uv.lock" > "$RUN/file_hashes.txt"
nvidia-smi > "$RUN/gpu-before.txt"
printf '%s\n' 'GPU0; uv run --locked --no-sync train.py; shared prepared environment; timeout TERM 600s / KILL +30s' > "$RUN/command.txt"
cd "$CODE"
echo "Running $SIDE round $ROUND; output saved to $RUN/run.log"
set +e
timeout --signal=TERM --kill-after=30s 600s \
    env CUDA_VISIBLE_DEVICES=0 UV_PROJECT_ENVIRONMENT="$ROOT/repo/.venv" \
    "$ROOT/tools/uv/uv" run --locked --no-sync train.py > "$RUN/run.log" 2>&1
CODE_EXIT=$?
set -e
printf '%s\n' "$CODE_EXIT" > "$RUN/exit_code.txt"
date -u '+%Y-%m-%dT%H:%M:%SZ' > "$RUN/end_utc.txt"
nvidia-smi > "$RUN/gpu-after.txt" || true
echo NEEDS_REVIEW > "$RUN/status.txt"
echo "Exit code: $CODE_EXIT"
tail -n 40 "$RUN/run.log"
echo 'Candidate and evidence preserved. Do not begin the next round before review.'
