# Automated Screenshots

The screenshots package drives the main app in an automated screenshot environment. Run the
screenshot process manager with:

```bash
flutter pub run bin/screenshots
```

This loads the `screenshots_config.yaml` file and kicks off the various screenshot processes. The
screenshots are automatically saved to the platform specific Fastlane directories for deployment.

## Required Devices

The required devices for screenshots on iOS are available [here](https://help.apple.com/app-store-connect/#/devd274dd925).

## Setup

For Android devices the `.ini` files should include the following lines:

```
hw.gpu.enabled=yes
hw.gpu.mode=host
```