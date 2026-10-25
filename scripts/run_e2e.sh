#!/usr/bin/env bash
# Run tests/integration_test e2e on a platform.
# Starts the Firebase Emulator Suite in the background if it is not already up.
#
# Usage:
#   scripts/run_e2e.sh macos|ios|android
#
# Env:
#   FLUTTER_TEST_DEVICE  Override flutter -d target (id or name from `flutter devices`)
#   E2E_CI=1             Pass --dart-define=CI=true (matches GitHub Actions skips)
#   E2E_REPORTER         flutter test reporter (default: github)
#   E2E_SKIP_EMULATOR=1  Fail if emulators are offline (do not auto-start)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PLATFORM="${1:-}"
REPORTER="${E2E_REPORTER:-github}"

usage() {
  echo "Usage: $0 macos|ios|android" >&2
  echo "  FLUTTER_TEST_DEVICE=<id>  override device" >&2
  echo "  E2E_CI=1                  match CI dart-defines / skips" >&2
  echo "  E2E_SKIP_EMULATOR=1       require emulators already running" >&2
  echo "Web: use \`dart run melos run test:e2e:web\` (CI builds examples; no web driver)." >&2
  exit 1
}

[[ -n "$PLATFORM" ]] || usage
case "$PLATFORM" in
  macos|ios|android) ;;
  *) usage ;;
esac

emulator_online() {
  curl --output /dev/null --silent --fail --max-time 2 http://localhost:8080 &&
    curl --output /dev/null --silent --fail --max-time 2 http://localhost:9099
}

# Reuse a running suite; otherwise start via the CI background path of
# start-firebase-emulator.sh (that script itself does not know about e2e).
ensure_firebase_emulator() {
  if emulator_online; then
    echo "Firebase Emulator Suite already running."
    return 0
  fi
  if [[ "${E2E_SKIP_EMULATOR:-}" == "1" || "${E2E_SKIP_EMULATOR:-}" == "true" ]]; then
    echo "Firebase Emulator Suite is not running (E2E_SKIP_EMULATOR=1)." >&2
    exit 1
  fi

  echo "Firebase Emulator Suite not detected; starting (CI background mode)..."
  (
    cd "$ROOT/functions"
    if [[ ! -d node_modules ]]; then
      npm i
    fi
    npm run build
  )
  CI=1 bash "$ROOT/scripts/start-firebase-emulator.sh"
}

ensure_firebase_emulator

# Prefer PATH flutter; fall back to fvm (common when flutter is only a shell alias).
flutter_cmd() {
  if command -v flutter >/dev/null 2>&1; then
    flutter "$@"
  elif command -v fvm >/dev/null 2>&1; then
    fvm flutter "$@"
  else
    echo "flutter not found on PATH (and fvm missing). Install Flutter or FVM." >&2
    exit 1
  fi
}

resolve_device() {
  if [[ -n "${FLUTTER_TEST_DEVICE:-}" ]]; then
    echo "$FLUTTER_TEST_DEVICE"
    return
  fi

  if [[ "$PLATFORM" == "macos" ]]; then
    echo macos
    return
  fi

  local machines
  machines="$(flutter_cmd devices --machine 2>/dev/null || true)"
  if [[ -z "$machines" ]]; then
    echo "No Flutter devices found. Start a simulator/emulator, then retry." >&2
    exit 1
  fi

  PLATFORM="$PLATFORM" python3 -c '
import json, os, sys

platform = os.environ["PLATFORM"]
raw = sys.argv[1]
start = raw.find("[")
if start < 0:
    sys.stderr.write("Could not parse `flutter devices --machine` output.\n")
    sys.exit(1)
devices = json.loads(raw[start:])
if not devices:
    sys.stderr.write("No Flutter devices found. Start a simulator/emulator, then retry.\n")
    sys.exit(1)

def pick_ios(devs):
    ios = [d for d in devs if (d.get("targetPlatform") or "").startswith("ios")]
    if not ios:
        return None
    sims = [
        d for d in ios
        if d.get("emulator") is True
        or "simulator" in (d.get("name") or "").lower()
        or "simruntime" in (d.get("sdk") or "").lower()
    ]
    return (sims or ios)[0]

def pick_android(devs):
    android = [
        d for d in devs if (d.get("targetPlatform") or "").startswith("android")
    ]
    return android[0] if android else None

chosen = pick_ios(devices) if platform == "ios" else pick_android(devices)
if not chosen:
    hint = (
        "Boot an iOS Simulator"
        if platform == "ios"
        else "Start an Android emulator"
    )
    sys.stderr.write(
        f"No {platform} device connected. {hint} "
        f"(see `flutter devices`), or set FLUTTER_TEST_DEVICE.\n"
    )
    sys.exit(1)
print(chosen.get("id") or chosen.get("name"))
' "$machines"
}

# Xcode 16.3+ / Xcode-beta rejects `_type(from:)` in FirebaseDataEncoder
# (firebase-ios-sdk#14678). tests/{ios,macos}/Podfile post_install patches it,
# but Flutter often skips `pod install` when Pods already exist — so re-run when
# the unpatched string is still present.
ensure_firebase_data_encoder_patched() {
  case "$PLATFORM" in
    ios|macos) ;;
    *) return 0 ;;
  esac

  local pods_root="$ROOT/tests/$PLATFORM/Pods"
  [[ -d "$pods_root" ]] || return 0

  local encoder
  encoder="$(
    find "$pods_root" -path '*/FirebaseDataEncoder/FirebaseDataEncoder.swift' \
      2>/dev/null | head -n 1
  )"
  [[ -n "$encoder" ]] || return 0

  if grep -q 'return try _type(from: self)' "$encoder"; then
    echo "FirebaseDataEncoder still unpatched for Xcode; running pod install in tests/$PLATFORM..."
    (cd "$ROOT/tests/$PLATFORM" && pod install)
  fi
}

DEVICE="$(resolve_device)"
echo "Running e2e on platform=$PLATFORM device=$DEVICE"

ensure_firebase_data_encoder_patched

EXTRA_ARGS=()
if [[ "${E2E_CI:-}" == "1" || "${E2E_CI:-}" == "true" ]]; then
  EXTRA_ARGS+=(--dart-define=CI=true)
  echo "E2E_CI enabled (--dart-define=CI=true)"
fi

cd "$ROOT/tests"
flutter_cmd test integration_test/firebase_ui_test.dart \
  -r "$REPORTER" \
  -d "$DEVICE" \
  ${EXTRA_ARGS[@]+"${EXTRA_ARGS[@]}"}
