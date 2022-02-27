fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

### get_app_store_connect_api_key

```sh
[bundle exec] fastlane get_app_store_connect_api_key
```



### certificate_develop_local

```sh
[bundle exec] fastlane certificate_develop_local
```

Match the local development certificate for the development app.

### certificate_develop_adhoc

```sh
[bundle exec] fastlane certificate_develop_adhoc
```

Match the staging development certificate for the development app.

### certificate_release

```sh
[bundle exec] fastlane certificate_release
```

Match the certificate for the release app.

### certificates

```sh
[bundle exec] fastlane certificates
```

Match all of the certificates.

----


## iOS

### ios build_develop

```sh
[bundle exec] fastlane ios build_develop
```

Build the development app for distribution, signed with the staging certificate.

### ios build_release

```sh
[bundle exec] fastlane ios build_release
```

Build the production app for the distribution, signed with the release certificate.

### ios develop

```sh
[bundle exec] fastlane ios develop
```

Push a new develop channel build to Firebase App Distribution.

### ios frames

```sh
[bundle exec] fastlane ios frames
```

Frame screenshots

### ios staging

```sh
[bundle exec] fastlane ios staging
```

Push a new release channel build to TestFlight.

### ios release

```sh
[bundle exec] fastlane ios release
```

Push a new release channel build to the App Store.

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
