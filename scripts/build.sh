#!/usr/bin/env bash
set -euo pipefail

# gtel3g build helper
# Usage: ./scripts/build.sh [WORKDIR] [lunch_target]
# Default: ~/lineage-16.0-gtel3g lineage_gtel3g-userdebug

WORKDIR="${1:-$HOME/lineage-16.0-gtel3g}"
TARGET="${2:-lineage_gtel3g-userdebug}"

if [ ! -f "$WORKDIR/build/envsetup.sh" ]; then
  echo "ERROR: $WORKDIR/build/envsetup.sh not found. Run sync.sh first."
  exit 1
fi

cd "$WORKDIR"
source build/envsetup.sh

echo "==> lunch $TARGET"
lunch "$TARGET"

echo "==> mka bacon"
mka bacon -j"$(nproc --all)"

echo "==> build done"
ls -lh out/target/product/gtel3g/lineage*.zip 2>/dev/null || true
