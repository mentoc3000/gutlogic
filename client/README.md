# Gut Logic Client

## Getting Started

Install Flutter dependencies.

```
flutter pub get
```

Build `built_values` serializers.

```
flutter pub run build_runner build
```

### Firebase Analytics

To have your Firebase Analytics events shown immediately as debug events, use the command

```
adb shell setprop debug.firebase.analytics.app com.gutlogic.app.dev
```

## Development

The app has multiple flavors, which are mapped to different cloud projects and app configurations.

```
# Build for development/production.
flutter run --flavor=development
flutter run --flavor=production

# Build for development/production.
flutter build [apk/ios] --flavor=development
flutter build [apk/ios] --flavor=production
```

## Distribution

The app is distributed on several channels using Fastlane.

1. `develop` - The earliest internally distributed releases are on the develop channel, which are
   built from the `develop` branch and linked against the `gutlogic-dev` project. Data from the
   develop channel is ephemeral and can be deleted during development. The develop channel is
   distributed to **Firebase App Distribution** with internally managed groups, and has a different
   package identifier so it can be installed adjacent to a staging or release build.

2. `staging` - The earliest publicly distributed releases are on the staging channel, which are
   built from the `master` branch and linked against the `gutlogic` project. Data from the staging
   channel is shared with the release channel. The staging channel should be feature complete. The
   staging channel is distributed to **Google Play Store Open Tests** and **Apple TestFlight** and
   shares a package identifier with the release build.

3. `release` - The release channel is built from the `release` branch after user testing on the
   staging builds. Hotfixes to the release channel might be branched from these tagged commits while
   the staging channel is experiencing user testing on a new feature. The release channel is
   distributed to the **Google Play Store** and the **Apple App Store**.

### Configuring Certificates

The app signing certificates for all channels are hosted in the cloud storage of the `gutlogic`
project. To sign a build from a developer machine, you need access permissions for the
`fastlane_match_gutlogic` bucket. Next use the `gcloud` SDK to authenticate with Google Cloud:

```
gcloud auth application-default login
```

Fastlane will use these credentials to access the signing certificates. Next, fetch the certificates
using Fastlane:

```
(cd ios; bundle exec fastlane certificates)
(cd android; bundle exec fastlane certificates)
```

CI builds use the Fastlane service account key to access these certificates instead.

## A/B Testing

To build an A/B test, add a parameter key to the `RemoteConfigService` and provide its value
to wherever in the app needs it. Instrument the user actions you want to measure using the
`AnalyticsService`. Once the update is pushed to users you can run the experiment through
Firebase.
