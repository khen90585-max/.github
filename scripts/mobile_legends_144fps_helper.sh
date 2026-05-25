#!/usr/bin/env bash
set -euo pipefail

# Mobile Legends performance helper (Android via ADB)
# This script does NOT modify game files and does NOT guarantee 144 FPS.
# It applies safe device-side settings that may reduce frame drops.

SCRIPTABLE_URL="scriptable:///run/Untitled%20Script"
OPEN_SCRIPTABLE=false

if [[ "${1:-}" == "--open-scriptable" ]]; then
  OPEN_SCRIPTABLE=true
fi

if ! command -v adb >/dev/null 2>&1; then
  echo "adb not found. Install Android platform-tools first."
  exit 1
fi

echo "Checking ADB device..."
adb get-state >/dev/null

echo "Applying performance-oriented settings..."
# Keep Wi-Fi active while plugged in (helps reduce reconnect jitter)
adb shell svc wifi enable || true
adb shell settings put global wifi_sleep_policy 2 || true

# Prefer 5 GHz when both 2.4/5 are available (device support dependent)
adb shell settings put global wifi_frequency_band 1 || true

# Reduce background pressure
adb shell settings put global window_animation_scale 0.5 || true
adb shell settings put global transition_animation_scale 0.5 || true
adb shell settings put global animator_duration_scale 0.5 || true

# High refresh rate preference (device support dependent)
adb shell settings put system peak_refresh_rate 144 || true
adb shell settings put system min_refresh_rate 120 || true

# Optional: battery optimizations can throttle sustained FPS
adb shell cmd power set-adaptive-power-saver-enabled false || true

if [[ "$OPEN_SCRIPTABLE" == true ]]; then
  echo "Opening Scriptable URL: $SCRIPTABLE_URL"
  if command -v open >/dev/null 2>&1; then
    open "$SCRIPTABLE_URL" || true
  elif command -v xdg-open >/dev/null 2>&1; then
    xdg-open "$SCRIPTABLE_URL" || true
  else
    echo "No URL opener found. Copy/paste this URL manually: $SCRIPTABLE_URL"
  fi
fi

cat <<MSG
Done.

Next steps in Mobile Legends:
1) Graphics: Smooth/Medium (for stable frame pacing)
2) Enable High Frame Rate mode in game settings
3) Close overlays/recorders and background downloads
4) Use stable 5 GHz Wi-Fi close to router
5) Optional Scriptable URL: $SCRIPTABLE_URL

Tip: run with --open-scriptable to try opening the Scriptable URL automatically.

Note: Actual 144 FPS depends on your phone SoC, display panel, thermals,
and whether the game build/server allows that frame cap.
MSG
