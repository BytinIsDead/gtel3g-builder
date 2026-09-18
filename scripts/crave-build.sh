#!/usr/bin/env bash
set -euo pipefail
# Helper to run gtel3g build inside a Crave devspace (local or via crave run)
# Usage: ./scripts/crave-build.sh [variant] [clean]
#  variant: user|userdebug|eng (default userdebug)
#  clean: yes|no (default no)

VARIANT="${1:-userdebug}"
CLEAN="${2:-no}"

PROJECTID="81"
PROJECTFOLDER="/crave-devspaces/Lineage16"
MANIFEST_URL="https://raw.githubusercontent.com/BytinIsDead/gtel3g-builder/main/manifests/gtel3g.xml"

if [[ "${DCDEVSPACE:-}" == *1* ]]; then
  echo "Inside Crave devspace"
  INSIDE=1
else
  echo "Outside Crave — will use 'crave run' remotely"
  INSIDE=0
  if ! command -v crave >/dev/null 2>&1; then
    echo "ERROR: crave not installed. curl -s https://raw.githubusercontent.com/accupara/crave/master/get_crave.sh | bash -s --"
    exit 1
  fi
fi

LUNCH="lunch lineage_gtel3g-$VARIANT"
BUILD_CMD="mka bacon -j\$(nproc --all)"

CLEAN_FLAG=""
[[ "$CLEAN" == "yes" ]] && CLEAN_FLAG="--clean"

if [[ "$INSIDE" == "1" ]]; then
  set -x
  cd "$PROJECTFOLDER" 2>/dev/null || cd "$(pwd)"
  mkdir -p .repo/local_manifests
  curl -L "$MANIFEST_URL" -o .repo/local_manifests/gtel3g.xml
  cat .repo/local_manifests/gtel3g.xml
  if [ -f /opt/crave/resync.sh ]; then /opt/crave/resync.sh; else repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags; fi
  source build/envsetup.sh
  $LUNCH
  make installclean || true
  $BUILD_CMD
else
  # Remote via crave
  echo "Queuing: crave run --projectID $PROJECTID $CLEAN_FLAG"
  crave run --no-patch $CLEAN_FLAG -- "
    set -e
    mkdir -p .repo/local_manifests && rm -rf .repo/local_manifests/* || true
    curl -L $MANIFEST_URL -o .repo/local_manifests/gtel3g.xml
    cat .repo/local_manifests/gtel3g.xml
    if [ -f /opt/crave/resync.sh ]; then /opt/crave/resync.sh; else /usr/bin/resync || repo sync -c -j\$(nproc --all) --force-sync --no-clone-bundle --no-tags; fi
    source build/envsetup.sh
    $LUNCH
    make installclean || true
    $BUILD_CMD
  "
  echo "Done. Pull with: crave pull out/target/product/gtel3g/*.zip"
fi
