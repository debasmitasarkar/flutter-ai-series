#!/bin/zsh
# Runs every launch case against one APK on the connected device/emulator.
# Usage: tool/run_matrix.sh <apk> <label>   (writes results/<label>.txt)
set -u
APK=$1; LABEL=$2; PKG=dev.debo.r09.intent_lab; ACT=$PKG/.MainActivity
OUT=results/$LABEL.txt; mkdir -p results
adb uninstall $PKG >/dev/null 2>&1
adb install -r $APK >/dev/null
adb shell pm grant $PKG android.permission.POST_NOTIFICATIONS 2>/dev/null
echo "# $LABEL  ($(adb shell getprop ro.product.model) API $(adb shell getprop ro.build.version.sdk))" > $OUT

run() {  # run <case name> <am start args...>
  local name=$1; shift
  adb shell am force-stop $PKG; adb logcat -c
  adb shell am start -W "$@" >/dev/null
  sleep 4
  echo "## $name: am start $*" >> $OUT
  adb logcat -d | grep -E "LAB entry|rendering backend|IGNORED|Engine flag|Intent verification|not supported in release" \
    | sed -E 's/^[0-9-]+ [0-9:.]+ +[0-9]+ +[0-9]+ //' >> $OUT
  adb exec-out screencap -p > results/$LABEL-$name.png
}

run plain        -n $ACT
run route        -n $ACT --es route /checkout
run entrypoint   -n $ACT --es dart_entrypoint qaMain
run engine_flag  -n $ACT --es impeller-backend vulkan
run deep_link    -a android.intent.action.VIEW -d intentlab://open/checkout $PKG
echo "done $OUT"
