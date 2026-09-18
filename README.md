# gtel3g-builder — LineageOS 16.0 builder for Samsung Galaxy Tab E 9.6 (SM-T561)

[![Crave gtel3g](https://github.com/BytinIsDead/gtel3g-builder/actions/workflows/crave.yml/badge.svg)](https://github.com/BytinIsDead/gtel3g-builder/actions/workflows/crave.yml) [![Build gtel3g](https://github.com/BytinIsDead/gtel3g-builder/actions/workflows/build.yml/badge.svg)](https://github.com/BytinIsDead/gtel3g-builder/actions/workflows/build.yml)

Builder repo that ties together **BytinIsDead's** device + kernel trees to produce a flashable LineageOS 16.0 build for `gtel3g` / `gtelwifi` (SC7730SE / sc8830).

> **Crave.io now primary** — `crave.yml` uses your `foss.crave.io` AOSP/ROM builder account (no 6h GitHub limits). `build.yml` kept as fallback (GitHub runners).

## What this pulls

| path | source | revision |
|------|--------|----------|
| `device/samsung/gtel3g` | `BytinIsDead/android_device_samsung_gtel3g` | `lineage-16.0` (fixed `Android.mk`, fstab, power_profile etc.) |
| `kernel/samsung/gtel3g` | `BytinIsDead/android_kernel_samsung_gtel3g` | `main` (3.10.108, Spreadtrum fixes) |
| `device/samsung/scx35-common` | `gtel3g/android_device_samsung_scx35-common` | `lineage-16.0` |
| `hardware/sprd` | `gtel3g/android_hardware_sprd` | `lineage-16.0` |
| `vendor/samsung/gtel3g` | `gtel3g/android_vendor_samsung_gtel3g` | `lineage-16.0` |
| `external/stlport` | `LineageOS/android_external_stlport` | `lineage-15.1` |
| `packages/resources/devicesettings` | `LineageOS/android_packages_resources_devicesettings` | `lineage-16.0` |

> Upstream `gtel3g/local_manifests` had a typo `reivision` — fixed here.

## Quick start (Ubuntu 20.04 / 22.04)

```bash
# 1. Install deps (https://wiki.lineageos.org/devices/gtel3g/build)
sudo apt update && sudo apt install -y bc bison build-essential ccache curl flex g++-multilib gcc-multilib git gnupg gperf imagemagick lib32ncurses5-dev lib32readline-dev lib32z1-dev libelf-dev liblz4-tool libncurses5 libncurses5-dev libsdl1.2-dev libssl-dev libxml2 libxml2-utils lzop pngcrush rsync schedtool squashfs-tools xsltproc zip zlib1g-dev python3 openjdk-8-jdk

# 2. Init Lineage source
mkdir lineage-16.0 && cd lineage-16.0
repo init -u https://github.com/LineageOS/android.git -b lineage-16.0 --git-lfs

# 3. Add this builder's manifest
mkdir -p .repo/local_manifests
curl -L https://raw.githubusercontent.com/BytinIsDead/gtel3g-builder/main/manifests/gtel3g.xml -o .repo/local_manifests/gtel3g.xml
# or: cp /path/to/gtel3g-builder/manifests/gtel3g.xml .repo/local_manifests/

repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags

# 4. Extract vendor blobs (from stock dump or adb)
#    device/samsung/gtel3g/extract-files.sh /path/to/system-dump

# 5. Build
source build/envsetup.sh
# patches are auto-applied via device/samsung/gtel3g/apply-patches.sh (called from vendorsetup.sh)
lunch lineage_gtel3g-userdebug
mka bacon -j$(nproc --all)
```

Output: `out/target/product/gtel3g/lineage-*.zip`

## Using the helper script

```bash
git clone https://github.com/BytinIsDead/gtel3g-builder.git
cd gtel3g-builder
./scripts/sync.sh   # does repo init + sync
./scripts/build.sh  # lunch + mka bacon
```

## Patches

`device/samsung/gtel3g/patches/` contains source patches applied automatically by `apply-patches.sh` during `source build/envsetup.sh`.

## Logs

On-device debug logger: `device/samsung/gtel3g/tools/debug/collect_t561_full_logs.sh`

## Crave.io (recommended)

Uses `foss.crave.io` devspace — no 6h limit, ccache persisted, 300GB+ workspace. Works with your AOSP/ROM builder team account.

**Setup (once):**

1. Create account at `foss.crave.io` (or use your AOSP team account) → Dashboard → **API Keys** → download `crave.conf`
2. In this repo → **Settings → Secrets and variables → Actions → New repository secret**
   - `CRAVE_USERNAME` = username line from `crave.conf` (your email)
   - `CRAVE_TOKEN` = token line from `crave.conf` (hash after `:`)
   - Optional: `CRAVE_FLAGS` (extra flags), `PAID=true` (use `aosp-silver` wallet), `CUSTOM_YAML` (override `configs/crave/crave.yaml.aosp`), `GH_UPLOAD_LIMIT` etc.
3. **Settings → Actions → General → Workflow permissions → Read and write permissions → Save** (required for Releases)
4. (Self-hosted only) If you prefer self-hosted runner inside Crave devspace, also create a self-hosted runner token and run workflow `Create Selfhosted Runner` first — see `sounddrill31/crave_aosp_builder` wiki. Otherwise just use the default `Crave gtel3g` workflow (uses `crave run` remotely).

**Run:**

```bash
gh workflow run crave.yml -f variant=userdebug -f clean=no
# or: GitHub → Actions → Crave gtel3g (Lineage 16.0) → Run workflow → variant=userdebug
```

What it does:
- `crave clone create --projectID 81 /crave-devspaces/Lineage16` (Lineage 16.0 base, `accupara/los16`) if missing
- `crave run --no-patch -- "rm .repo/local_manifests/*; curl manifests/gtel3g.xml -> .repo/local_manifests/gtel3g.xml; /opt/crave/resync.sh; source build/envsetup.sh; lunch lineage_gtel3g-userdebug; mka bacon"`
- `crave pull` + `crave push` + `upload-artifact` + `gh-release` (`crave-*` tag)

Local Crave devspace alternative:

```bash
crave devspace -- "cd /crave-devspaces/Lineage16/gtel3g && repo init -u https://github.com/accupara/los16.git -b lineage-16.0 --git-lfs && curl -L https://raw.githubusercontent.com/BytinIsDead/gtel3g-builder/main/manifests/gtel3g.xml -o .repo/local_manifests/gtel3g.xml && /opt/crave/resync.sh && source build/envsetup.sh && lunch lineage_gtel3g-userdebug && mka bacon"
```

See `configs/crave/crave.yaml.aosp` and `crave.conf.sample`.

## GitHub Actions (fallback, no Crave)

Workflow `.github/workflows/build.yml` builds `lineage_gtel3g-userdebug` directly on `ubuntu-22.04` (Java 8 + ccache, ~70GB free):

- Triggers manually via **Actions → Build gtel3g → Run workflow** (push trigger on `main` for manifest/workflow changes)
- `Free disk space` + install deps + `repo init/sync` (uses `manifests/gtel3g.xml`) + `mka bacon`
- Uploads `lineage-*.zip`, `recovery.img`, `build.log` as artifact (14 days) and creates a Release on manual dispatch

Run manually: `gh workflow run build.yml -f variant=userdebug -f upload=true`

> GitHub hosted runners hit disk/time limits for full LOS 16.0; prefer Crave.

## Links

- Device: https://github.com/BytinIsDead/android_device_samsung_gtel3g (branch `lineage-16.0`)
- Kernel: https://github.com/BytinIsDead/android_kernel_samsung_gtel3g (branch `main`)
- Upstream org: https://github.com/gtel3g/local_manifests
- Builder: https://github.com/BytinIsDead/gtel3g-builder
