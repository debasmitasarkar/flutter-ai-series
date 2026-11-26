#!/bin/bash
# run.sh <apk> <label>: install, set up state, fold / unfold / rotate, log + screenshots.
# Emulator setting used: Continue apps on fold = always (fold_lock_behavior_setting).
A="$(dirname "$0")/a.sh"; APK=$1; L=$2; OUT="$(dirname "$0")/../results/$L"; mkdir -p "$OUT"
PKG=dev.debo.v15.fold_lab
INNER=4619827259835644672; OUTER=4619827551948147201
shot() { "$A" exec-out screencap -p -d $2 > "$OUT/$1.png"; }
mark() { "$A" shell log -t V15STEP "$1"; }
"$A" emu unfold >/dev/null; "$A" shell settings put system accelerometer_rotation 0; "$A" shell settings put system user_rotation 0; sleep 3
"$A" uninstall $PKG >/dev/null 2>&1; "$A" install -r "$APK" >/dev/null
"$A" logcat -G 16M; "$A" logcat -c
"$A" logcat -s V15ACT:I flutter:I V15STEP:* > "$OUT/raw.txt" & LC=$!
mark launch-unfolded; "$A" shell am start -n $PKG/.MainActivity >/dev/null; sleep 14; shot 1-unfolded $INNER
mark fold; "$A" emu fold >/dev/null; sleep 2; "$A" shell wm dismiss-keyguard; sleep 4; shot 2-folded $OUTER
mark unfold; "$A" emu unfold >/dev/null; sleep 2; "$A" shell wm dismiss-keyguard; sleep 4; shot 3-unfolded-again $INNER
mark rotate-landscape; "$A" emu rotate >/dev/null; sleep 2; "$A" shell wm dismiss-keyguard; sleep 4; shot 4-unfolded-landscape $INNER
mark rotate-back; "$A" emu rotate >/dev/null; "$A" emu rotate >/dev/null; "$A" emu rotate >/dev/null; sleep 5
sleep 2; kill $LC; cat "$OUT/raw.txt" | grep -E "V15ACT|V15STATE|V15STEP" | sed 's/^.*\(V15[A-Z]*\)/\1/' | tee "$OUT/log.txt"
