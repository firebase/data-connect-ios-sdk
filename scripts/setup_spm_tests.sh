#!/bin/bash

# Copyright 2021 Google LLC
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


# Point SPM CI to the tip of main of https://github.com/google/GoogleAppMeasurement
# so that the release process can defer publishing the GoogleAppMeasurement tag
# until after testing.

# For example: Change `exact: "8.3.1"` to `branch: "main"`

sed -i '' 's#exact:[[:space:]]*"[0-9.]*"#branch: "main"#' Package.swift


# Move schemes into place to run Swift Package Manager tests
# These cannot be stored in the correct location because they cause
# clutter for SDK clients.
# Details in https://github.com/firebase/firebase-ios-sdk/issues/8167 and
# https://forums.swift.org/t/swiftpm-and-library-unit-testing/26255/21

mkdir -p .swiftpm/xcode/xcshareddata/xcschemes
cp scripts/spm_test_schemes/* .swiftpm/xcode/xcshareddata/xcschemes/
xcodebuild -list
