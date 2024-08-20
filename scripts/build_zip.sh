#!/bin/bash

# Copyright 2020 Google LLC
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#      http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -x
REPO=`pwd`

if [[ $# -lt 2 ]]; then
  cat 2>&2 <<EOF
USAGE: $0 [output_directory]
USAGE: $1 [custom-spec-repos]
EOF
  exit 1
fi

# The release build won't generage Carthage distro if the curreent
# PackageManifest version has already been released.
carthage_version_check="--enable-carthage-version-check"

# If there is a third option set, add options to build from head instead of
# staging and/or trunk.
if [[ $# -gt 2 ]]; then
  build_head_option="--local-podspec-path"
  build_head_value="$REPO"
  carthage_version_check="--disable-carthage-version-check"
fi

# The first and only argument to this script should be the name of the
# output directory.
OUTPUT_DIR="$REPO/$1"
CUSTOM_SPEC_REPOS="$2"

source_repo=()
IFS=','
read -a specrepo <<< "${CUSTOM_SPEC_REPOS}"

cd ReleaseTooling
swift run zip-builder --keep-build-artifacts --update-pod-repo \
    ${build_head_option} ${build_head_value} \
    --output-dir "${OUTPUT_DIR}" \
    "${carthage_version_check}" \
    --custom-spec-repos  "${specrepo[@]}"
