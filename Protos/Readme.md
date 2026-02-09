# Data Connect protos
This folder contains the Data Connect protos defining the GRPC service.

# Google Protos
The google protos are obtained from https://github.com/googleapis/googleapis/tree/master

# Instructions to Generate the Swift files for the protos

## Step 1:
(for Googlers) Copy the .proto files from

`third_party/firebase/dataconnect/emulator/server/api/connector_service.proto`

`third_party/firebase/dataconnect/emulator/server/api/graphql_error.proto`

`third_party/firebase/dataconnect/emulator/server/api/graphql_response_extensions.proto`


## Step 2:
If needed, adjust package name after discussion with server team.

Make following changes if needed -
- Follow (make) same changes as specified by the copybara lines.
- Where it says strip, take that line out and follow any replace rules with a replace
- If protos reference any internal packages, those are typically not needed by the SDKs or these are marked with copybara strip rules.

## Step 3:
Get the standard protoc compiler and ensure that it is in your system path

## Step 4:
Get the protoc Swift gen plugin from the releases section of Swift GRPC

https://github.com/grpc/grpc-swift/releases

Under the 'Assets' section of a release, download the protoc-grpc-swift-plugins file for macOS.
Example:
protoc-grpc-swift-plugins-1.24.2.zip

## Step 5:
Extract this in a location of your choice. You will need the folder path of the extracted folder.

## Step 6:
Edit the `build_protos.sh` script that is present in the same folder as this Readme file.

Adjust the variables that configure the folder paths needed by the script

Note: If you don't have the protoc compiler in your PATH, you will need specify the full path of the protoc binary in the script above

## Step 7:
Open a Terminal at the folder where the script is and run the build_protos.sh script

`sh build_protos.sh`


## Step 8:
If this script executes successfully (i.e. no errors printed), it will place the generated files in the
`data-connect-ios-sdk/Sources/ProtoGen` folder

If any of the generated Swift files doesn't have the standard License, insert one.

## Step 9:
If the proto package or endpoint names have changed you may get build errors. You will need to adjust the new name in two files

`data-connect-ios-sdk/Sources/Internal/GrpcClient.swift`

`data-connect-ios-sdk/Sources/Internal/Codec.swift`

## Step 10:
Run Integration tests to confirm that the new protos are working fine.



