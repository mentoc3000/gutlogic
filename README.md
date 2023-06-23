# Gut Logic

## Setup

### Screenshots

To generate screenshots, run the command:

```bash
cd client
dart run bin/screenshots.dart
```

### Continuous Integration / Continuous Deployment

To build for iOS, GitLab Runner must run on MacOS. Set up a
[local runner](https://docs.gitlab.com/runner/install/osx.html) for these
builds. It expects the following resources (that are not installed by default)
to be installed globally:

- [flutter](https://flutter.dev/docs/get-started/install)
- [fastlane](https://docs.fastlane.tools/getting-started/ios/setup/)
- [lcov](https://formulae.brew.sh/formula/lcov)

## Deployment

To deploy the app and server create a branch that begins with "release", e.g.
`release/1.2`. The project will be tested, build, and automatically deployed for
beta testing. The `client:deploy:ios:release` job must be manually run to deploy
the app to the App Store.
