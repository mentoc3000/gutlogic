fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew install fastlane`

# Available Actions
### certificate_develop_local
```
fastlane certificate_develop_local
```
Match the local development certificate for the development app.
### certificate_develop_adhoc
```
fastlane certificate_develop_adhoc
```
Match the staging development certificate for the development app.
### certificate_release
```
fastlane certificate_release
```
Match the certificate for the release app.
### certificates
```
fastlane certificates
```
Match all of the certificates.

----

## iOS
### ios build_develop
```
fastlane ios build_develop
```
Build the development app for distribution, signed with the staging certificate.
### ios build_release
```
fastlane ios build_release
```
Build the production app for the distribution, signed with the release certificate.
### ios develop
```
fastlane ios develop
```
Push a new develop channel build to Firebase App Distribution.
### ios staging
```
fastlane ios staging
```
Push a new release channel build to TestFlight.
### ios release
```
fastlane ios release
```
Push a new release channel build to the App Store.

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
