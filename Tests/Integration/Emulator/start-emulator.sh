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
EMULATOR_INFO=$(curl -s -f "${INFO_URL}")
EMULATOR_URL=$(echo "${EMULATOR_INFO}" | jq -r '.dataconnect.darwin_arm64.remoteUrl')
EXPECTED_SHA256=$(echo "${EMULATOR_INFO}" | jq -r '.dataconnect.darwin_arm64.expectedChecksumSHA256')

if [ -z "${EMULATOR_URL}" ] || [ "${EMULATOR_URL}" = "null" ]; then
  echo "Failed to determine latest Data Connect emulator URL."
  exit 1
fi

EMULATOR_FILENAME=$(basename "${EMULATOR_URL}")

echo "Downloading emulator from ${EMULATOR_URL}"

curl -f -o "${EMULATOR_FILENAME}" "${EMULATOR_URL}"

echo "Verifying SHA256 checksum..."
ACTUAL_SHA256=$(shasum -a 256 "${EMULATOR_FILENAME}" | awk '{print $1}')

if [ "${ACTUAL_SHA256}" != "${EXPECTED_SHA256}" ]; then
  echo "Error: SHA256 checksum mismatch!"
  echo "Expected: ${EXPECTED_SHA256}"
  echo "Actual:   ${ACTUAL_SHA256}"
  exit 1
fi
echo "Checksum verified successfully."

chmod 755 "${EMULATOR_FILENAME}"

./${EMULATOR_FILENAME} --logtostderr -v=2  dev --listen="127.0.0.1:3628" &