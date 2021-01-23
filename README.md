# Gut Logic

Gut Logic app.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.io/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.io/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.io/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Setup

### Server-Side Testing

Gut Logic uses Firebase as its backend. To run the Firestore test you must provide
admin credentials using the following steps:

1. Obtain the private key json file from [Chris](mailto:chris@gutlogic.co)
2. Save it someplace safe. DO NOT COMMIT IT TO THE REPOSITORY.
3. Set the `GOOGLE_APPLICATION_CREDENTIALS` environment variable to the file path

For more information, see
[Add the Firebase Admin SDK to Your Server](https://firebase.google.com/docs/admin/setup?authuser=1).

### Screenshots

Install `screenshots` as described [here](https://github.com/mmcc007/screenshots).

To generate screenshots, run the command:

```bash
cd client
screenshots --flavor=production --config=test_driver/screenshots/ios_screenshots.yaml
```

### Continuous Integration / Continuous Deployment

To build for iOS, GitLab Runner must run on MacOS. Set up a [local runner](https://docs.gitlab.com/runner/install/osx.html) for these builds. It expects the following resources (that are not installed by default) to be installed globally:

- [flutter](https://flutter.dev/docs/get-started/install)
- [fastlane](https://docs.fastlane.tools/getting-started/ios/setup/)
- [pubspec_version](https://pub.dev/packages/pubspec_version)
- [lcov](https://formulae.brew.sh/formula/lcov)
