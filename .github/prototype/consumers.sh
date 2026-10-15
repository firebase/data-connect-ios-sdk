#!/usr/bin/env bash
# Prototype check: resolves small consumer packages that depend on Data Connect
# and reports which Data Connect / Firebase versions and Firestore-related
# packages SwiftPM pulls in.
#
# Usage: consumers.sh <prototype-dc-path> <baseline-dc-path> <prototype-dc-git-url>
#
# <prototype-dc-git-url> is a local git repo whose tags include the real
# Data Connect releases (e.g. 11.12.6) plus a fake `11.99.0` tag on the
# prototype commit, so SwiftPM can choose between them.

set -euo pipefail

PROTO_DC="$1"
BASE_DC="$2"
PROTO_DC_URL="$3"
WORK="${RUNNER_TEMP:-/tmp}/consumers"
FIRESTORE_PKGS='abseil-cpp-binary|abseil-cpp-swiftpm|grpc-binary|grpc-ios|leveldb'
FAILED=0

DC_PRODUCT='.product(name: "FirebaseDataConnect", package: "data-connect-ios-sdk")'
FIREBASE_URL='https://github.com/firebase/firebase-ios-sdk'

# make_consumer <name> <dependencies> <target-deps> <main.swift>
make_consumer() {
  local dir="${WORK}/$1"
  mkdir -p "${dir}/Sources/App"
  cat > "${dir}/Package.swift" <<EOF
// swift-tools-version:6.1
import PackageDescription

let package = Package(
  name: "App",
  platforms: [.macOS(.v12)],
  dependencies: [
    $2
  ],
  targets: [
    .executableTarget(name: "App", dependencies: [$3])
  ]
)
EOF
  printf '%s\n' "$4" > "${dir}/Sources/App/main.swift"
  echo "${dir}"
}

pin() {
  jq -r --arg id "$2" '.pins[] | select(.identity == $id) | .state.version // .state.revision // "path"' "$1/Package.resolved"
}

# check <name> <dir> <expected-firebase-major> [expected-dc-version]
check() {
  local name="$1" dir="$2" fb_expect="$3" dc_expect="${4:-}"
  local fb dc firestore
  fb=$(pin "${dir}" firebase-ios-sdk)
  dc=$(pin "${dir}" data-connect-ios-sdk)
  firestore=$(jq -r '.pins[].identity' "${dir}/Package.resolved" | grep -E "^(${FIRESTORE_PKGS})$" | tr '\n' ' ' || true)
  echo "RESULT ${name}: data-connect=${dc:-path} firebase=${fb} firestore-pkgs=[${firestore:-none}]"
  if [[ "${fb}" != "${fb_expect}".* ]]; then
    echo "FAIL ${name}: expected Firebase ${fb_expect}.x, got '${fb}'"
    FAILED=1
  fi
  if [[ -n "${dc_expect}" && "${dc}" != "${dc_expect}" ]]; then
    echo "FAIL ${name}: expected Data Connect ${dc_expect}, got '${dc}'"
    FAILED=1
  fi
}

# resolve <name> <dir>: resolves, recording failure instead of aborting.
resolve() {
  if (cd "$2" && swift package resolve); then
    return 0
  fi
  echo "FAIL $1: resolution failed"
  FAILED=1
  return 1
}

# 1. Baseline: Data Connect only (nc.xcode26, no traits).
d=$(make_consumer baseline-dc-only ".package(path: \"${BASE_DC}\")," \
  "${DC_PRODUCT}" "import FirebaseDataConnect")
resolve baseline-dc-only "${d}" && check baseline-dc-only "${d}" 13

# 2. Prototype: Data Connect only (`traits: []`).
d=$(make_consumer proto-dc-only ".package(path: \"${PROTO_DC}\")," \
  "${DC_PRODUCT}" "import FirebaseDataConnect")
resolve proto-dc-only "${d}" && check proto-dc-only "${d}" 13

# 3. Prototype via versioned git URL, no Firebase pin: should pick the new
#    (fake 11.99.0) Data Connect with Firebase 13.
d=$(make_consumer proto-remote-dc-only \
  ".package(url: \"${PROTO_DC_URL}\", from: \"11.12.0\")," \
  "${DC_PRODUCT}" "import FirebaseDataConnect")
resolve proto-remote-dc-only "${d}" && check proto-remote-dc-only "${d}" 13 11.99.0

# 4. Prototype via versioned git URL + app pins Firebase 12: SwiftPM should
#    fall back to the last Data Connect release that allows Firebase 12.
d=$(make_consumer proto-remote-f12-pinned \
  ".package(url: \"${PROTO_DC_URL}\", from: \"11.12.0\"), .package(url: \"${FIREBASE_URL}\", \"12.0.0\" ..< \"13.0.0\")," \
  "${DC_PRODUCT}" "import FirebaseDataConnect")
resolve proto-remote-f12-pinned "${d}" && check proto-remote-f12-pinned "${d}" 12 11.12.6

# 5. Prototype + app uses Firestore from Firebase 13 (default traits). Builds
#    to prove Firestore is still enabled via trait unification.
d=$(make_consumer proto-dc-firestore \
  ".package(path: \"${PROTO_DC}\"), .package(url: \"${FIREBASE_URL}\", \"13.0.0\" ..< \"14.0.0\")," \
  "${DC_PRODUCT}, .product(name: \"FirebaseFirestore\", package: \"firebase-ios-sdk\")" \
  $'import FirebaseDataConnect\nimport FirebaseFirestore\nprint(Firestore.self)')
if resolve proto-dc-firestore "${d}"; then
  check proto-dc-firestore "${d}" 13
  if (cd "${d}" && swift build); then
    echo "OK proto-dc-firestore: built with FirebaseFirestore"
  else
    echo "FAIL proto-dc-firestore: build failed"
    FAILED=1
  fi
fi

[[ ${FAILED} -eq 0 ]] && echo "ALL CONSUMER CHECKS PASSED"
exit "${FAILED}"
