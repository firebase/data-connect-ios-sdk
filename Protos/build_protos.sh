#!/bin/bash

# Copyright 2024 Google LLC
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


#This is a convenience script to build protos and generate Swift files
#It requires the Swift grpc and proto plugins which are part of swift-grpc project
#Script should be run from the folder containing this script

protoc_path="protoc"
sdk_folder="/Users/aashishp/Code/data-connect-ios-sdk"
plugin_folder="/Users/aashishp/protoc-grpc-swift-plugins-1.24.2/bin"


protoc graphql_error.proto connector_service.proto graphql_response_extensions.proto \
    --proto_path=$sdk_folder/Protos/ \
    --plugin=$plugin_folder/protoc-gen-swift \
    --swift_opt=Visibility=Public \
    --swift_out=$sdk_folder/Sources/ProtoGen \
    --plugin=$plugin_folder/protoc-gen-grpc-swift \
    --grpc-swift_opt=Visibility=Public \
    --grpc-swift_out=$sdk_folder/Sources/ProtoGen


