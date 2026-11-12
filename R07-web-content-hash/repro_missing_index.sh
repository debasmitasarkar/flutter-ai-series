#!/usr/bin/env bash
# Flutter 3.50.0: a plain `flutter build web` right after a `--web-content-hash`
# build leaves build/web without index.html. A second plain build restores it.
set -euo pipefail
cd "$(dirname "$0")/hash_demo"
[ -d web ] || flutter create . --platforms=web >/dev/null
flutter build web --web-content-hash >/dev/null
echo "after hashed build: $(ls build/web/index.html 2>/dev/null || echo 'index.html MISSING')"
flutter build web >/dev/null
echo "after plain build:  $(ls build/web/index.html 2>/dev/null || echo 'index.html MISSING')"
flutter build web >/dev/null
echo "after second plain: $(ls build/web/index.html 2>/dev/null || echo 'index.html MISSING')"
