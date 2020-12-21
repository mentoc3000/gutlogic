# Gut Logic Server

Before working on the various aspects of the server, make sure you're logged in with the Firebase CLI.

```sh
firebase login
```

## Deployment

The server is deployed automatically after commits to `develop` or `master`. To manually deploy the server to the development environment, use:

```sh
firebase deploy --project=development
```

Likewise, to deploy the backend to the production environment, use:

```sh
firebase deploy --project=production
```

The default environment is the development environment.

## Testing

The test command will automatically start the Firebase emulator before running the tests. Simply run:

```sh
npm run test
```

## Config

The cloud functions require some configuration. You can check the current configuration with:

```sh
firebase functions:config:get
```

This should return a JSON object that looks like:

```json
{
  "auth": {
    "token": "..."
  }
}
```

If any of these values are missing, set them with:

```sh
firebase functions:config:set path.of.key=value
```

Below is a list of config values and how to set them.

- `auth.token` is a token returned by `firebase login:ci`. This should match the token provided to the CI/CD pipeline for the associated project.

### GitLab CI/CD

Set the following variables in the GitLab CI/CD settings

| Type     | Key                 | Value                                                                                                                                        |
| -------- | ------------------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| Variable | `FASTLANE_PASSWORD` | App Store Connect password                                                                                                                   |
| Variable | `FIREBASE_PROJECT`  | `default` or `production`, depending on environment                                                                                          |
| Variable | `FIREBASE_TOKEN`    | Token obtained from `firebase login:ci`                                                                                                      |
| File     | `GC_KEYS`           | Key generated for GCP account to access storage bucket for certificates. Obtain by running `fastlane match init` and following instructions. |
