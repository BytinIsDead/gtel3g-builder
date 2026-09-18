# gtel3g-builder — LineageOS 16.0 builder for Samsung Galaxy Tab E 9.6 (SM-T561)

Builder repo that ties together **BytinIsDead's** device + kernel trees to produce a flashable LineageOS 16.0 build for `gtel3g` / `gtelwifi` (SC7730SE / sc8830).

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

## Links

- Device: https://github.com/BytinIsDead/android_device_samsung_gtel3g (branch `lineage-16.0`)
- Kernel: https://github.com/BytinIsDead/android_kernel_samsung_gtel3g (branch `main`)
- Upstream org: https://github.com/gtel3g/local_manifests
