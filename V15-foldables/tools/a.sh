#!/bin/bash
# adb against the V15 emulator (set SERIAL to switch)
exec "$HOME/Library/Android/sdk/platform-tools/adb" -s "${SERIAL:-emulator-5556}" "$@"
