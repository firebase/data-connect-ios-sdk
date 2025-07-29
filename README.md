# Firebase Data Connect iOS Open Source Development

This repository contains the source code of Firebase Data Connect Swift SDKs for development on iOS and other Apple platforms.

Firebase Data Connect (https://firebase.google.com/docs/data-connect) lets you build applications with CloudSQL for PostgreSQL.

Firebase is an app development platform with tools to help you build, grow, and
monetize your app. More information about Firebase can be found on the
[official Firebase website](https://firebase.google.com).

## Installation

This process shows you how to setup Firebase Data Connect tools with Xcode.

* Get the Firebase Data Connect iOS SDK.
    ```
    git clone https://github.com/firebase/data-connect-ios-sdk.git
    ```
* Add it as a local package dependency in your Xcode project
    * From your Xcode project, select `File -> Add Package Dependencies -> Add Local`.
    * Select the `data-connect-ios-sdk` folder containing the cloned SDK.
    * Add `FirebaseDataConnect` to your app target.
* Add and Edit Xcode Scheme
    * From your list of schemes, select `New Scheme`.
    * Xcode should show you `Start FDC Tools` as a potential scheme. Select that.
* Adjust working directory
    * Edit the `Start FDC Tools` Scheme from  `Edit Scheme... -> Start FDC Tools`.
    * Go to `Run -> Options -> Working Directory`
        * Select `Custom working directory` and pick your Xcode project folder
        * This ensures that Firebase Data Connect tools start in the correct folder each time.
* Run the `Start FDC Tools` target selecting `My Mac` as the device.
* This should start the tools in a separate browser window (or tab).
* Now that you have the tools, try out our [Codelab](https://firebase.google.com/codelabs/firebase-dataconnect-ios#0)
* Learn more about designing schemas, queries and mutations - [Design Schemas](https://firebase.google.com/docs/data-connect/schemas-guide)

* Generated SDKs are Swift packages. Add the generated SDKs to your project as a Local Package dependency and start using them in your app.
    * Generated APIs support `@Observable` (Observation framework) for easy integration into SwiftUI apps.
        * UIKit apps can make use of the underlying `Combine` publishers.
    * All Query and Mutation APIs are `async` calls and can participate in Swift concurrency.
* Since you cloned the `data-connect-ios-sdk`, be sure to reference your local folder to generate SDKs.
    * In the `connector.yaml`, configure the Swift SDK generation to point to the local path where you cloned the Data Connect iOS SDK using the `coreSdkPackageLocation` parameter. Example -
        ```yaml
        generate:
            swiftSdk:
                outputDir: ../../dataconnect-generated/swift
                package: DefaultConnector #change this to your project specific name
                coreSdkPackageLocation: /Users/abc/Code/data-connect-ios-sdk
        ```

There are other paths to get setup with Firebase Data Connect tools such as from the Firebase Console. To  learn more visit - [Quick Start](https://firebase.google.com/docs/data-connect/quickstart).

## Sample App and Code Lab

* [Codelab](https://firebase.google.com/codelabs/firebase-dataconnect-ios#0)

* Comprehensive Sample app - [FriendlyFlix](https://github.com/firebase/data-connect-ios-sdk/tree/main/Examples/FriendlyFlix)

### Swift Package Manager
Instructions for [Swift Package Manager](https://swift.org/package-manager/) support can be
found in the [SwiftPackageManager.md](SwiftPackageManager.md) Markdown file.

## Contributing

See [Contributing](CONTRIBUTING.md) for more information on contributing to the Firebase Data Connect
iOS SDK.

## License

The contents of this repository are licensed under the
[Apache License, version 2.0](http://www.apache.org/licenses/LICENSE-2.0).

Your use of Firebase is governed by the
[Terms of Service for Firebase Services](https://firebase.google.com/terms/).
