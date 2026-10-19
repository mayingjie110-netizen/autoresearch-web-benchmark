#!/usr/bin/env bash
# Synthetic bookkeeping tests only: no real model, data, GPU, or training.
set -euo pipefail
HERE=$(cd "$(dirname "$0")" && pwd)
TEST_ROOT=$(mktemp -d /data2/home/yingjie/autoresearch/tmp/protocol-check-XXXXXX)
mkdir -p "$TEST_ROOT/comparison" "$TEST_ROOT/records" "$TEST_ROOT/tools/uv" "$TEST_ROOT/bin"
sed "s|^ROOT=/data2/home/yingjie/autoresearch$|ROOT=$TEST_ROOT|" "$HERE/run_round.sh" > "$TEST_ROOT/run.sh"
sed "s|^ROOT=/data2/home/yingjie/autoresearch$|ROOT=$TEST_ROOT|" "$HERE/finish_round.sh" > "$TEST_ROOT/finish.sh"
printf 'export PATH="%s/bin:$PATH"\n' "$TEST_ROOT" > "$TEST_ROOT/env.sh"
printf '#!/bin/sh\necho MOCK_GPU\n' > "$TEST_ROOT/bin/nvidia-smi"
cat > "$TEST_ROOT/tools/uv/uv" <<'MOCK'
#!/bin/sh
echo "val_bpb: ${MOCK_SCORE:-1.1}"
exit "${MOCK_EXIT:-0}"
MOCK
chmod +x "$TEST_ROOT/tools/uv/uv" "$TEST_ROOT/bin/nvidia-smi"
git init -q "$TEST_ROOT/comparison/A"
printf 'value = 0\n' > "$TEST_ROOT/comparison/A/train.py"
for file in prepare.py pyproject.toml uv.lock; do echo fixture > "$TEST_ROOT/comparison/A/$file"; done
git -C "$TEST_ROOT/comparison/A" add .
git -C "$TEST_ROOT/comparison/A" -c user.name=Test -c user.email=test@localhost -c commit.gpgsign=false -c core.hooksPath=/dev/null commit -qm fixture
git -C "$TEST_ROOT/comparison/A" rev-parse HEAD > "$TEST_ROOT/comparison/common_start_commit.txt"
git clone -q "$TEST_ROOT/comparison/A" "$TEST_ROOT/comparison/B"
make_patch() {
    printf 'value = %s\n' "$3" > "$TEST_ROOT/comparison/$1/train.py"
    git -C "$TEST_ROOT/comparison/$1" diff > "$TEST_ROOT/$2.patch"
    git -C "$TEST_ROOT/comparison/$1" show HEAD:train.py > "$TEST_ROOT/comparison/$1/train.py"
}
make_patch A a1 1
MOCK_SCORE=1.10 bash "$TEST_ROOT/run.sh" A 1 "$TEST_ROOT/a1.patch" > "$TEST_ROOT/a1.out"
bash "$TEST_ROOT/finish.sh" A 1 clean >> "$TEST_ROOT/a1.out"
grep -q '^decision=keep$' "$TEST_ROOT/records/formal/A/round-1/review.txt"
make_patch B b1 1
MOCK_SCORE=1.20 bash "$TEST_ROOT/run.sh" B 1 "$TEST_ROOT/b1.patch" > "$TEST_ROOT/b1.out"
bash "$TEST_ROOT/finish.sh" B 1 clean >> "$TEST_ROOT/b1.out"
grep -q '^decision=revert$' "$TEST_ROOT/records/formal/B/round-1/review.txt"
grep -q '^value = 0$' "$TEST_ROOT/comparison/B/train.py"
bash "$TEST_ROOT/run.sh" A 2 --missing > "$TEST_ROOT/a2.out"
bash "$TEST_ROOT/finish.sh" A 2 clean >> "$TEST_ROOT/a2.out"
grep -q '^best_val_bpb=1.10$' "$TEST_ROOT/records/formal/A/round-2/review.txt"
make_patch B b2 2
MOCK_EXIT=1 bash "$TEST_ROOT/run.sh" B 2 "$TEST_ROOT/b2.patch" > "$TEST_ROOT/b2.out"
bash "$TEST_ROOT/finish.sh" B 2 clean >> "$TEST_ROOT/b2.out"
grep -q '^valid=no$' "$TEST_ROOT/records/formal/B/round-2/review.txt"
printf 'not a patch\n' > "$TEST_ROOT/invalid.patch"
bash "$TEST_ROOT/run.sh" A 3 "$TEST_ROOT/invalid.patch" > "$TEST_ROOT/a3.out"
bash "$TEST_ROOT/finish.sh" A 3 clean >> "$TEST_ROOT/a3.out"
bash "$TEST_ROOT/run.sh" B 3 --violation > "$TEST_ROOT/b3.out"
bash "$TEST_ROOT/finish.sh" B 3 violation >> "$TEST_ROOT/b3.out"
make_patch A a4 4
MOCK_SCORE=1.10 bash "$TEST_ROOT/run.sh" A 4 "$TEST_ROOT/a4.patch" > "$TEST_ROOT/a4.out"
bash "$TEST_ROOT/finish.sh" A 4 clean >> "$TEST_ROOT/a4.out"
grep -q '^decision=revert$' "$TEST_ROOT/records/formal/A/round-4/review.txt"
if bash "$TEST_ROOT/run.sh" A 5 --missing > "$TEST_ROOT/wrong-order.out" 2>&1; then
    echo 'FAIL: wrong order accepted'; exit 1
fi
if bash "$TEST_ROOT/finish.sh" A 4 clean > "$TEST_ROOT/duplicate.out" 2>&1; then
    echo 'FAIL: duplicate finalization accepted'; exit 1
fi
test -z "$(git -C "$TEST_ROOT/comparison/A" status --porcelain)"
test -z "$(git -C "$TEST_ROOT/comparison/B" status --porcelain)"
echo 'PROTOCOL_TESTS_PASSED: improve/worse/equal/crash/missing/invalid/violation/order/duplicate'
echo "Synthetic fixtures retained at $TEST_ROOT; no real training executed."
