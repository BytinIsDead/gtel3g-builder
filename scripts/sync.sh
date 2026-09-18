#!/usr/bin/env bash
set -euo pipefail

# gtel3g sync helper — repo init + sync with builder manifest
# Usage: ./scripts/sync.sh [WORKDIR]

WORKDIR="${1:-$HOME/lineage-16.0-gtel3g}"
MANIFEST_URL="https://raw.githubusercontent.com/BytinIsDead/gtel3g-builder/main/manifests/gtel3g.xml"
MANIFEST_LOCAL="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/manifests/gtel3g.xml"

mkdir -p "$WORKDIR"
cd "$WORKDIR"

if [ ! -d .repo ]; then
  echo "==> repo init lineage-16.0"
  repo init -u https://github.com/LineageOS/android.git -b lineage-16.0 --git-lfs
fi

mkdir -p .repo/local_manifests

if [ -f "$MANIFEST_LOCAL" ]; then
  echo "==> using local manifests/gtel3g.xml"
  cp -v "$MANIFEST_LOCAL" .repo/local_manifests/gtel3g.xml
else
  echo "==> fetching $MANIFEST_URL"
  curl -L "$MANIFEST_URL" -o .repo/local_manifests/gtel3g.xml
fi

echo "==> repo sync"
repo sync -c -j"$(nproc --all)" --force-sync --no-clone-bundle --no-tags

echo "==> sync done: $WORKDIR"
echo "Next: source build/envsetup.sh && lunch lineage_gtel3g-userdebug && mka bacon"
