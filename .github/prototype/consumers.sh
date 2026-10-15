#!/usr/bin/env bash
# Prototype check: resolves small consumer packages that depend on Data Connect
# and reports which Firebase version and Firestore-related packages SwiftPM
# pulls in. Compares the traits prototype (this checkout) against the baseline
# Data Connect branch (no traits).
#
# Usage: consumers.sh <prototype-dc-path> <baseline-dc-path>

set -euo pipefail

PROTO_DC="$1"
BASE_DC="$2"
WORK="${RUNNER_TEMP:-/tmp}/consumers"
FIRESTORE_PKGS='abseil-cpp-binary|abseil-cpp-swiftpm|grpc-binary|grpc-ios|leveldb'
FAILED=0

# make_consumer <name> <dc-path> <extra-dependency> <target-deps> <imports>
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
    .package(path: "$2"),
    $3
  ],
  targets: [
    .executableTarget(name: "App", dependencies: [$4])
  ]
)
EOF
  printf '%s\n' "$5" > "${dir}/Sources/App/main.swift"
  echo "${dir}"
}

report() {
  local name="$1" dir="$2"
  local version firestore
  version=$(jq -r '.pins[] | select(.identity == "firebase-ios-sdk") | .state.version' "${dir}/Package.resolved")
  firestore=$(jq -r '.pins[].identity' "${dir}/Package.resolved" | grep -E "^(${FIRESTORE_PKGS})$" | tr '\n' ' ' || true)
  echo "RESULT ${name}: firebase=${version} firestore-pkgs=[${firestore:-none}]"
  echo "${version}"
}

expect_version() {
  local name="$1" actual="$2" expected="$3"
  if [[ "${actual}" == "${expected}".* ]]; then
    echo "OK ${name}: Firebase ${actual}"
  else
    echo "FAIL ${name}: expected Firebase ${expected}.x, got '${actual}'"
    FAILED=1
  fi
}

DC_PRODUCT='.product(name: "FirebaseDataConnect", package: "data-connect-ios-sdk")'

# 1. Baseline: Data Connect only, no traits declared by Data Connect.
d=$(make_consumer baseline-dc-only "${BASE_DC}" "" "${DC_PRODUCT}" "import FirebaseDataConnect")
(cd "${d}" && swift package resolve)
v=$(report baseline-dc-only "${d}" | tee /dev/stderr | tail -1)
expect_version baseline-dc-only "${v}" 13

# 2. Prototype: Data Connect only, Data Connect declares `traits: []`.
d=$(make_consumer proto-dc-only "${PROTO_DC}" "" "${DC_PRODUCT}" "import FirebaseDataConnect")
(cd "${d}" && swift package resolve)
v=$(report proto-dc-only "${d}" | tee /dev/stderr | tail -1)
expect_version proto-dc-only "${v}" 13

# 3. Prototype + app pins Firebase 12 (Firebase 12 declares no traits).
d=$(make_consumer proto-dc-f12 "${PROTO_DC}" \
  '.package(url: "https://github.com/firebase/firebase-ios-sdk", "12.0.0" ..< "13.0.0"),' \
  "${DC_PRODUCT}" "import FirebaseDataConnect")
(cd "${d}" && swift package resolve)
v=$(report proto-dc-f12 "${d}" | tee /dev/stderr | tail -1)
expect_version proto-dc-f12 "${v}" 12

# 4. Prototype + app uses Firestore from Firebase 13 (default traits).
#    Builds to prove Firestore is still enabled via trait unification.
d=$(make_consumer proto-dc-firestore "${PROTO_DC}" \
  '.package(url: "https://github.com/firebase/firebase-ios-sdk", "13.0.0" ..< "14.0.0"),' \
  "${DC_PRODUCT}, .product(name: \"FirebaseFirestore\", package: \"firebase-ios-sdk\")" \
  $'import FirebaseDataConnect\nimport FirebaseFirestore\nprint(Firestore.self)')
(cd "${d}" && swift package resolve)
v=$(report proto-dc-firestore "${d}" | tee /dev/stderr | tail -1)
expect_version proto-dc-firestore "${v}" 13
if (cd "${d}" && swift build); then
  echo "OK proto-dc-firestore: built with FirebaseFirestore"
else
  echo "FAIL proto-dc-firestore: build failed"
  FAILED=1
fi

exit "${FAILED}"
