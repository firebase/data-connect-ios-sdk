#!/usr/bin/env bash

# Copyright 2025 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Sets up Firebase Data Connect emulator to execute
# integration tests.

set -e

# Get the absolute path to the directory containing this script.
SCRIPT_DIR="$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)"
TEMP_DIR="$(mktemp -d -t firebase-data-connect)"
echo "Starting Firebase Data Connect emulator in ${TEMP_DIR}"
cd "${TEMP_DIR}"

INFO_URL="https://raw.githubusercontent.com/firebase/firebase-tools/main/src/emulator/downloadableEmulatorInfo.json"
echo "Fetching latest Data Connect emulator info from ${INFO_URL}"
EMULATOR_URL=$(curl -s "${INFO_URL}" | python3 -c "import sys, json; print(json.load(sys.stdin)['dataconnect']['darwin_arm64']['remoteUrl'])" 2>/dev/null) || true

if [ -z "${EMULATOR_URL}" ]; then
  echo "Failed to fetch latest emulator info. Falling back to v3.4.7"
  EMULATOR_URL="https://storage.googleapis.com/firemat-preview-drop/emulator/dataconnect-emulator-macos-arm64-v3.4.7"
fi

EMULATOR_FILENAME=$(basename "${EMULATOR_URL}")

echo "Downloading emulator from ${EMULATOR_URL}"

curl -o "${EMULATOR_FILENAME}" "${EMULATOR_URL}"

chmod 755 "${EMULATOR_FILENAME}"

./${EMULATOR_FILENAME} --logtostderr -v=2  dev --listen="127.0.0.1:3628" &