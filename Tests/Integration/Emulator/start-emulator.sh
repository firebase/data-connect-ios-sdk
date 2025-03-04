#!/usr/bin/env bash

# Copyright 2018 Google
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

# Sets up Firebase Data Connect emulator and starts it to run
# integration tests.

set -e

# Get the absolute path to the directory containing this script.
SCRIPT_DIR="$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)"
TEMP_DIR="$(mktemp -d -t firebase-data-connect)"
echo "Starting Firebase Data Connect emulator in ${TEMP_DIR}"
cd "${TEMP_DIR}"

EMULATOR_VERSION="1.8.3"
EMULATOR_FILENAME="dataconnect-emulator-macos-v${EMULATOR_VERSION}"
EMULATOR_URL="https://storage.googleapis.com/firemat-preview-drop/emulator/${EMULATOR_FILENAME}"
echo "Downloading emulator from ${EMULATOR_URL}"

curl -o "${EMULATOR_FILENAME}" "${EMULATOR_URL}"

chmod 755 "${EMULATOR_FILENAME}"

./${EMULATOR_FILENAME} --logtostderr  dev --listen="127.0.0.1:3628"
