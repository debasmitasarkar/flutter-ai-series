#!/bin/zsh
# In-app launches on one device: the app's own startActivity and its own notification,
# first with the "route" extra, then with a deep link. Usage: tool/run_inapp.sh <label>
# Button y positions: env Y="1066 1229 1424 1587" (1080x2340 default). The APK must already be installed.
set -u
PKG=dev.debo.r09.intent_lab; OUT=results/$1-inapp.txt
echo "# $1 in-app ($(adb shell getprop ro.product.model) API $(adb shell getprop ro.build.version.sdk))" > $OUT
fresh() { adb shell cmd statusbar collapse; adb shell input keyevent KEYCODE_BACK; adb shell am force-stop $PKG; adb shell am start -W -n $PKG/.MainActivity >/dev/null; sleep 3; }
lab() { adb logcat -d | grep "LAB entry" | tail -1 | sed -E 's/^[0-9-]+ [0-9:.]+ +[0-9]+ +[0-9]+ //'; }
relaunch() { fresh; adb logcat -c; adb shell input tap 540 $2; sleep 5; echo "## $1: $(lab)" >> $OUT; adb exec-out screencap -p > results/$OUT:t:r-$1.png; }
notify() {
  fresh; adb shell input tap 540 $2; sleep 2; adb shell cmd statusbar expand-notifications; sleep 2
  adb shell uiautomator dump /sdcard/u.xml >/dev/null
  local b=$(adb shell cat /sdcard/u.xml | grep -o 'text="Your order is ready"[^>]*' | grep -o '\[[0-9]*,[0-9]*\]' | head -1 | tr -d '[]')
  [ -z "$b" ] && b=349,725
  adb logcat -c; adb shell input tap $(( ${b%,*} + 120 )) $(( ${b#*,} + 25 )); sleep 5; echo "## $1: $(lab)" >> $OUT
}
ys=(${=${Y:-1066 1229 1424 1587}})
notify   notify_route_extra   $ys[1]
relaunch relaunch_route_extra $ys[2]
notify   notify_deep_link     $ys[3]
relaunch relaunch_deep_link   $ys[4]
cat $OUT
