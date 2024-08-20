<p align="center">
  <a href="https://swiftpackageindex.com/firebase/firebase-ios-sdk">
    <img src="https://img.shields.io/github/v/release/Firebase/firebase-ios-sdk?style=flat&label=Swift%20Package%20Index&color=red"/>
  </a>
  <a href="https://swiftpackageindex.com/firebase/firebase-ios-sdk">
    <img src="https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Ffirebase%2Ffirebase-ios-sdk%2Fbadge%3Ftype%3Dplatforms"/>
  </a>
  <a href="https://swiftpackageindex.com/firebase/firebase-ios-sdk">
    <img src="https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Ffirebase%2Ffirebase-ios-sdk%2Fbadge%3Ftype%3Dswift-versions"/>
  </a>
</p>

# Firebase Apple Open Source Development

This repository contains the source code for Apple platform Firebase Data Connect SDKs. 

Firebase Data Connect (https://firebase.google.com/products/data-connect) lets you build applications with CloudSQL for PostgreSQL

Firebase is an app development platform with tools to help you build, grow, and
monetize your app. More information about Firebase can be found on the
[official Firebase website](https://firebase.google.com).

## Installation

### Swift Package Manager

Instructions for [Swift Package Manager](https://swift.org/package-manager/) support can be
found in the [SwiftPackageManager.md](SwiftPackageManager.md) Markdown file.

### Installing from GitHub

These instructions can be used to access the Firebase repo at other branches,
tags, or commits.

#### Background

See [the Podfile Syntax Reference](https://guides.cocoapods.org/syntax/podfile.html#pod)
for instructions and options about overriding pod source locations.

### Using Firebase from a Framework or a library

For details on using Firebase from a Framework or a library, refer to [firebase_in_libraries.md](docs/firebase_in_libraries.md).

## Getting Started
Firebase Data Connect is in Private Preview at no cost for a limited time. Sign up the program at https://firebase.google.com/products/data-connect.

Once you are selected as an allowlist member, you should be able to create a Cloud SQL instance through Firebase Data Connect console.

Here's a quick rundown of steps to get you started. Learn more about details at the official [Getting Started documentation](https://firebase.google.com/docs/data-connect/quickstart).

### 1. Create a new Data Connect service and Cloud SQL instance.
* Go to Firebase Console and select Firebase Data Connect from the Left Navigation bar to create a new Data Connect service and a Cloud SQL instance. You have to be in Blaze plan and you can view the details of pricing at https://firebase.google.com/pricing.
* Select us-central1 region if you want to try out vector search with Data Connect later.
* Your Cloud SQL instance is now to be provisioned, you can view and manage the instance at the [Cloud console](https://pantheon.corp.google.com/sql).

### 2. Setup your iOS app and [initialize Firebase](https://firebase.google.com/docs/ios/setup)

#### The following steps will guide you to setup your schema and create query operation that you need for your app. The toolings below will help you to test out your query with dummy data and once you are happy with your query, the tools will help generate client code for that query so you can call directly from your app.


### 3. Set up [Firebase CLI](https://firebase.devsite.corp.google.com/docs/cli)

* If you already have CLI, make sure you always update to the latest version
```
npm install -g firebase-tools
```

### 4. Set up VSCode
You will need VS Code and its Firebase extension (VS Code extension) to automatically generate Swift code for your queries.
* Install VS Code
* Download the [extension](https://firebasestorage.googleapis.com/v0/b/firemat-preview-drop/o/vsix%2Ffirebase-vscode-latest.vsix?alt=media) and drag it into the "Extensions" in the Left Navigation bar for installation. Keep in mind double clicking the file won't install.
* Create a fdc folder where you like to have firebase data connect configuration.
```
mkdir fdc
```
* Open VS Code from folder you just created
* Select the Firebase icon on the left and login
* Click on "Run firebase init" button

* Select the first option of Data Connect
* Enter/Select the project, service and database ID you setup on the console
* Enter to select the default connector ID and complete the rest of the process

### 5. Set up generated SDK location
In the connector.yaml file, add the following code to enable swift code to be generated.

```
  swiftSdk:
     outputDir: "../swift-generated/"
     package: "User"
```
* You should see swift code is generated inside the ../swift-generated/User/ folder

### 6. Create a schema and generate some dummy data
* In the schema.gql file, uncomment the schema
```
type User @table(key: "uid") {
   uid: String!
   name: String!
   address: String!
}
```
* On top of the schema User, an "Add data" button start showing up, click on it to generate a User_insert.gql file
* Fill out the fields and click on Run button to run the query to add a user dummy data for testing

### 7. Deploy your schema
* To deploy your schema, you will need your Cloud SQL instance to be ready. You can view the instance at the [Cloud console](https://pantheon.corp.google.com/sql).
* Select the Firebase icon on the left and Click on the "Deploy all" button to deploy all the schema and operations to backend.
* You can now see your schemas on the Firebase Console.

### 8. Set up a mutation
In the mutations.gql file, uncomment the "CreateUser" query.
* In the CONFIGURATION -> VARIABLES, enter
```
{
  "name" : "dummy_name",
  "address" : "dummy_address"
}
```
* In the CONFIGURATION -> AUTHENTICATION, select Run as "Authenticated".
* Click on the "Run" button above the query.
* You should see your dummy data is added.
* Select the Firebase icon on the left and Click on the "Deploy all" button to deploy all the schema and operations to backend.
* As you see this operation needs authentication, so you will need to be authenticated with Firebase Authentication in your client app when you call this operation in iOS app.

#### At this point, you have the code generated for the queries you need for your app. Now let's see how you can use the generated query code in your iOS app:

### 9. Adding the generated package to your app project
* Go to File -> Add Package Dependencies -> Add Local
* Navigate to the generated folder and select the "swift-generated/User" folder (You should see a Package.swift file in it).

### 10. Calling the generated code from your app
```
import FirebaseDataConnect
import Users //change this to the name of your generated package

func executeFDCCreateUserQuery() {
    Task {
      do {
        let result = try await DataConnect.defaultConnectorClient.createUserMutationRef(name: "dummyUserName", address: "dummyUserAddress").execute()
      } catch {
      }
    }
  }

```




## Development

To develop Firebase software in this repository, ensure that you have at least
the following software:

* Xcode 15.2 (or later)

### Swift Package Manager
* To enable test schemes: `./scripts/setup_spm_tests.sh`
* `open Package.swift` or double click `Package.swift` in Finder.
* Xcode will open the project
  * Choose a scheme for a library to build or test suite to run
  * Choose a target platform by selecting the run destination along with the scheme

### Code Formatting

To ensure that the code is formatted consistently, run the script
[./scripts/check.sh](https://github.com/firebase/firebase-ios-sdk/blob/main/scripts/check.sh)
before creating a pull request (PR).

GitHub Actions will verify that any code changes are done in a style-compliant
way. Install `clang-format` and `mint`:

```console
brew install clang-format@18
brew install mint
```

### Running Unit Tests

Select a scheme and press Command-u to build a component and run its unit tests.

### Running Sample Apps
To run the sample apps and integration tests, you'll need a valid
`GoogleService-Info.plist
` file. The Firebase Xcode project contains dummy plist
files without real values, but they can be replaced with real plist files. To get your own
`GoogleService-Info.plist` files:

1. Go to the [Firebase Console](https://console.firebase.google.com/)
2. Create a new Firebase project, if you don't already have one
3. For each sample app you want to test, create a new Firebase app with the sample app's bundle
identifier (e.g., `com.google.Database-Example`)
4. Download the resulting `GoogleService-Info.plist` and add it to the Xcode project.

### Coverage Report Generation

For coverage report generation instructions, see [scripts/code_coverage_report/README](scripts/code_coverage_report/README.md) Markdown file.

## Specific Component Instructions
See the sections below for any special instructions for those components.

## Building with Firebase on Apple platforms

Firebase provides official beta support for macOS, Catalyst, and tvOS. visionOS and watchOS
are community supported. Thanks to community contributions for many of the multi-platform PRs.

At this time, most of Firebase's products are available across Apple platforms. There are still
a few gaps, especially on visionOS and watchOS. For details about the current support matrix, see
[this chart](https://firebase.google.com/docs/ios/learn-more#firebase_library_support_by_platform)
in Firebase's documentation.

### watchOS
Thanks to contributions from the community, many of Firebase SDKs now compile, run unit tests, and
work on watchOS. See the [Independent Watch App Sample](Example/watchOSSample).

Keep in mind that watchOS is not officially supported by Firebase. While we can catch basic unit
test issues with GitHub Actions, there may be some changes where the SDK no longer works as expected
on watchOS. If you encounter this, please
[file an issue](https://github.com/firebase/firebase-ios-sdk/issues).

During app setup in the console, you may get to a step that mentions something like "Checking if the
app has communicated with our servers". This relies on Analytics and will not work on watchOS.
**It's safe to ignore the message and continue**, the rest of the SDKs will work as expected.

## Contributing

See [Contributing](CONTRIBUTING.md) for more information on contributing to the Firebase
Apple SDK.

## License

The contents of this repository are licensed under the
[Apache License, version 2.0](http://www.apache.org/licenses/LICENSE-2.0).

Your use of Firebase is governed by the
[Terms of Service for Firebase Services](https://firebase.google.com/terms/).
