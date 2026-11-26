#!/bin/bash
# rotate.sh <apk> <label>: unfolded, set up state, rotate 90 degrees, rotate back; log only.
A="$(dirname "$0")/a.sh"; APK=$1; L=$2; OUT="$(dirname "$0")/../results/$L"; mkdir -p "$OUT"
PKG=dev.debo.v15.fold_lab
mark() { "$A" shell log -t V15STEP "$1"; }
"$A" emu unfold >/dev/null; sleep 2; "$A" shell wm dismiss-keyguard
"$A" uninstall $PKG >/dev/null 2>&1; "$A" install -r "$APK" >/dev/null
"$A" logcat -c; "$A" logcat -s V15ACT:I flutter:I V15STEP:* > "$OUT/raw.txt" & LC=$!
mark launch; "$A" shell am start -n $PKG/.MainActivity >/dev/null; sleep 14
mark rotate; "$A" emu rotate >/dev/null; sleep 2; "$A" shell wm dismiss-keyguard; sleep 4
mark rotate-again; "$A" emu rotate >/dev/null; sleep 2; "$A" shell wm dismiss-keyguard; sleep 4
sleep 1; kill $LC; grep -E "V15ACT|V15STATE|V15STEP" "$OUT/raw.txt" | sed 's/^.*\(V15[A-Z]*\)/\1/' | tee "$OUT/log.txt"
