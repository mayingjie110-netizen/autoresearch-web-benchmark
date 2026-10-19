#!/usr/bin/env bash
# Create isolated code checkouts; do not install, download data, or train.
set -euo pipefail
ROOT=/data2/home/yingjie/autoresearch
SOURCE="$ROOT/repo"
TARGET="$ROOT/comparison"
EXPECTED_COMMIT=228791fb499afffb54b46200aca536f79142f117
EXPECTED_TRAIN=dafb24a0ed985ac462f5ddc902d471dffbe9b927aae5d780904eb34ab9a934d5

test "$(git -C "$SOURCE" rev-parse HEAD)" = "$EXPECTED_COMMIT"
test "$(sha256sum "$SOURCE/train.py" | cut -d ' ' -f 1)" = "$EXPECTED_TRAIN"
git -C "$SOURCE" diff --exit-code HEAD -- prepare.py pyproject.toml uv.lock
if test -e "$TARGET"; then
    echo "STOP: comparison already exists; nothing overwritten." >&2
    exit 1
fi

mkdir "$TARGET"
git clone --no-hardlinks --no-checkout "$SOURCE" "$TARGET/A"
git -C "$TARGET/A" checkout --detach "$EXPECTED_COMMIT"
cp "$SOURCE/train.py" "$TARGET/A/train.py"
git -C "$TARGET/A" add train.py
git -C "$TARGET/A" -c user.name='Benchmark Setup' \
    -c user.email='benchmark@localhost' -c commit.gpgsign=false \
    -c core.hooksPath=/dev/null commit -m 'Common RTX 5090 benchmark starting point: batch 32'
git clone --no-hardlinks "$TARGET/A" "$TARGET/B"

git -C "$TARGET/A" rev-parse HEAD > "$TARGET/common_start_commit.txt"
git -C "$TARGET/A" diff "$EXPECTED_COMMIT" HEAD -- train.py > "$TARGET/platform.patch"
cmp "$TARGET/A/train.py" "$TARGET/B/train.py"
test -z "$(git -C "$TARGET/A" status --porcelain)"
test -z "$(git -C "$TARGET/B" status --porcelain)"
test "$(git -C "$TARGET/A" rev-parse HEAD)" = "$(git -C "$TARGET/B" rev-parse HEAD)"

echo 'PREPARATION_PASSED: A and B have the same starting commit and clean code.'
cat "$TARGET/common_start_commit.txt"
sha256sum "$TARGET/A/train.py" "$TARGET/B/train.py"
echo 'No training started. Existing repo and experiment records preserved.'
