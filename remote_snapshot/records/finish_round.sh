#!/usr/bin/env bash
# Manual protocol bookkeeping, not an agent. clean means no observed violation.
# Usage: bash finish_round.sh A 1 clean|violation
set -euo pipefail
ROOT=/data2/home/yingjie/autoresearch
SIDE=${1:?Specify A or B}
ROUND=${2:?Specify round 1..5}
AUDIT=${3:?Specify clean or violation after manual rule review}
[[ "$SIDE" =~ ^[AB]$ && "$ROUND" =~ ^[1-5]$ ]] || exit 2
[[ "$AUDIT" = clean || "$AUDIT" = violation ]] || exit 2
CODE="$ROOT/comparison/$SIDE"
RUN="$ROOT/records/formal/$SIDE/round-$ROUND"
[[ -d "$RUN" && ! -e "$RUN/review.txt" ]] || { echo 'Missing run or already finalized.'; exit 2; }
[[ "$(tail -n 1 "$ROOT/comparison/sequence.tsv")" = "$(printf '%s\t%s' "$SIDE" "$ROUND")" ]] || {
    echo 'Only the latest opportunity can be finalized.'; exit 2;
}
START=$(cat "$RUN/start_commit.txt")
[[ "$(git -C "$CODE" rev-parse HEAD)" = "$START" ]] || { echo 'Unexpected HEAD; stop.'; exit 2; }
git -C "$CODE" diff --exit-code HEAD -- . ':!train.py'
[[ -z "$(git -C "$CODE" ls-files --others --exclude-standard)" ]] || {
    echo 'Unexpected untracked files; preserve and investigate external deviation.'; exit 2;
}
if [[ -f "$RUN/candidate_train.py" ]]; then
    cmp "$CODE/train.py" "$RUN/candidate_train.py"
else
    cmp "$CODE/train.py" "$RUN/start_train.py"
fi
# Persist evidence before any restore. Never use git reset --hard or delete candidates.
cp "$CODE/train.py" "$RUN/pre_decision_train.py"
git -C "$CODE" diff --binary > "$RUN/pre_decision.patch"
BEST_FILE="$ROOT/comparison/$SIDE-best.txt"
BEST=1.164027
if [[ -f "$BEST_FILE" ]]; then BEST=$(cat "$BEST_FILE"); fi
VALUE=NA
VALID=no
STATUS=$(cat "$RUN/status.txt")
if [[ "$AUDIT" = clean && "$STATUS" = NEEDS_REVIEW && -f "$RUN/exit_code.txt" && "$(cat "$RUN/exit_code.txt")" = 0 ]]; then
    # Exactly one final score, finite, positive decimal. No NaN/Inf or arbitrary log matches.
    if VALUE=$(awk '/^val_bpb:/ {n++; if (NF != 2 || $2 !~ /^[0-9]+([.][0-9]+)?$/ || $2+0 <= 0) bad=1; value=$2} END {if (n != 1 || bad) exit 1; print value}' "$RUN/run.log"); then
        VALID=yes
    else VALUE=NA; fi
fi
DECISION=revert
if [[ "$VALID" = yes ]] && awk -v candidate="$VALUE" -v best="$BEST" 'BEGIN {exit !(candidate+0 < best+0)}'; then
    DECISION=keep
fi
if [[ "$DECISION" = keep ]]; then
    git -C "$CODE" add -- train.py
    git -C "$CODE" -c user.name='Benchmark Records' -c user.email='benchmark@localhost' \
        -c commit.gpgsign=false -c core.hooksPath=/dev/null \
        commit -m "Keep $SIDE round $ROUND: val_bpb $VALUE"
    BEST="$VALUE"
else
    # Restore only train.py, after saving its exact content and diff.
    cp "$RUN/start_train.py" "$CODE/train.py"
fi
printf '%s\n' "$BEST" > "$BEST_FILE"
cp "$CODE/train.py" "$RUN/next_train.py"
NEXT=$(git -C "$CODE" rev-parse HEAD)
[[ -z "$(git -C "$CODE" status --porcelain)" ]] || { echo 'Unexpected dirty checkout after decision.'; exit 2; }
{
    printf 'side=%s\nround=%s\nmanual_rule_review=%s\nvalid=%s\ncandidate_val_bpb=%s\ndecision=%s\nbest_val_bpb=%s\nnext_commit=%s\n' \
        "$SIDE" "$ROUND" "$AUDIT" "$VALID" "$VALUE" "$DECISION" "$BEST" "$NEXT"
} > "$RUN/review.txt"
cat "$RUN/review.txt"
echo "Feedback uses original logs and $RUN/next_train.py. No next round started."
