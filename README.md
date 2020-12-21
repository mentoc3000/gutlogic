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
