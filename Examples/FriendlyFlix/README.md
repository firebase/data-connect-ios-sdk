# FriendlyFlix

## Introduction

This quickstart is a movie tracker app to demonstrate the use of Firebase Data Connect
 with a Cloud SQL database.

For more information about Firebase Data Connect visit [the docs](https://firebase.google.com/docs/data-connect/).


## Getting Started (local development)

Follow these steps to get up and running with Firebase Data Connect locally (i.e., without setting up a production SQL instance). At the end of this guide, you will find instructions for connecting to a production SQL instance.

For more detailed instructions,
check out the [official documentation](https://firebase.google.com/docs/data-connect/quickstart-local).

### Prerequisites

To use this quickstart, you'll need the following:
- A computer running macOS
- Latest version of [Xcode](https://developer.apple.com/xcode/)
- Latest version of [Visual Studio Code](https://code.visualstudio.com/)
- The [Firebase Data Connect VS Code Extension](https://marketplace.visualstudio.com/items?itemName=GoogleCloudTools.firebase-dataconnect-vscode)

### 1. Connect to your Firebase project

1. If you haven't already, create a Firebase project.
    * In the [Firebase console](https://console.firebase.google.com), click
        **Create a project**, then follow the on-screen instructions.


### 2. Get the code for the FriendlyFLix quickstart app

1. Clone this repository to your local machine:
   ```sh
   git clone https://github.com/firebase/data-connect-ios-sdk.git
   ```

### 3. Open in Visual Studio Code (VS Code)

1. Open the `data-connect-ios-sdk/Examples/FriendlyFlix` directory in VS Code.
2. Click on the Firebase Data Connect icon on the VS Code sidebar to load the Extension.
   a. Sign in with your Google Account if you haven't already.
3. Click on "Connect a Firebase project" and choose the project where you have set up Data Connect.
4. Click on "Start Emulators" - this should generate the Swift SDK for you and start the emulators.

### 4. Populate the database
In VS Code, open the `data-connect-ios-sdk/Examples/FriendlyFlix/dataconnect/data_seed.gql` file and click the
 `Run (local)` button at the top of the file.

If you’d like to confirm that the data was correctly inserted,
open `data-connect-ios-sdk/Examples/FriendlyFlix/dataconnect/movie-connector/queries.gql` and run the `ListMovies` query.

### 5. Run the app

Press the Run button in Xcode to run the sample app on the iOS Simulator.

# Connect to a production instance of CloudSQL

### 1. Connect to your Firebase project

1. If you haven’t already, add an iOS app to your Firebase project, using `com.google.firebase.samples.FriendlyFlix` as the bundle ID.
 Click **Download GoogleService-Info.plist** to obtain your Firebase config file.

2. Move the `GoogleService-Info.plist` config file (downloaded in the previous step) into the root folder of the sample app in the
  `data-connect-ios-sdk/Examples/FriendlyFlix/app/FriendlyFlix/FriendlyFlix/GoogleService-Info.plist` directory, replacing the existing `GoogleService-Info.plist` (which contains dummy values).

### 2. Upgrade your Firebase project to Blaze

1. Upgrade your project to the Blaze plan. This lets you create a Cloud SQL
    for PostgreSQL instance.

    > Note: Though you set up billing in your Blaze upgrade, you won't be
    charged for usage of Firebase Data Connect or the
    [default Cloud SQL for PostgreSQL configuration](https://firebase.google.com/docs/data-connect/#pricing) during the preview.

### 3. Provision a PostgreSQL database

1. Navigate to the [Data Connect section](https://console.firebase.google.com/u/0/project/_/dataconnect)
    of the Firebase console, click on the "Get Started" button and follow the setup workflow:
     - Select a location for your Cloud SQL for PostgreSQL database (this sample uses `us-central1`). If you choose a different location, you'll also need to change the `data-connect-ios-sdk/Examples/FriendlyFlix/dataconnect/dataconnect.yaml` file.
     - Select the option to create a new Cloud SQL instance and fill in the following fields:
       - Service ID: `dataconnect`
       - Cloud SQL Instance ID: `fdc-sql`
       - Database name: `fdcdb`
1. Allow some time for the Cloud SQL instance to be provisioned. After it's provisioned, the instance
   can be managed in the [Cloud Console](https://console.cloud.google.com/sql).


### 4. Run the app

1. In Xcode, select Product > Schemed > Edit Scheme, and then disable the check box labeled "useEmulator" to use your production project instead.
2. Press the Run button in Xcode to run the sample app on the iOS Simulator.
