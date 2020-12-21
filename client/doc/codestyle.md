# Flutter Bloc Conventions

Flutter Bloc requires creating a large number of types for each piece of the app. These are our
naming conventions:

### Blocs

Blocs should start with their subject, and end with `Bloc`.

```
LoginBloc
RegisterBloc
TimelineBloc
```

### States

Bloc states should start with their bloc name and be named in _present tense_ using nouns or
adjectives that describe the state, or gerunds for progress states. Common states are `Ready`,
`Loading`, `Success`, and `Error`.

```
LoginReady
LoginLoading
LoginSuccess
LoginError
```

States should always be marked as `@immutable` with `const` constructors and inherit from
`Equatable`. Error states should also mixin `ErrorRecorder` and expose a `fromError` constructor
that can be used for unknown exceptions and errors.

```
  BlocError.fromError({@required dynamic error, @required StackTrace trace})
      : message = 'Some generic error message',
        report = ErrorReport(error: error, trace: trace);
```

### Events

Bloc events should start with their bloc name and be named in _past tense_ using verbs that describe
the event.

```
LoginSubmitted
LoginCancelled
TimelineUpdated
AccountDeleteConfirmed
```

### Error Recovery

When blocs emit error states that do not need input to recover from, they should immediately emit a
non-error state indicating they have recovered.

```
try {
  RegisterWithEmail(email: email);
  yield RegisterSuccess();
} on DuplicateEmailException {
  yield RegisterError(message: 'An account with that email already exists.');
  yield RegisterReady();
}
```

Blocs should only maintain an error state if it requires input on how to recover.

```
try {
  compressedFileBlob = PerformExpensiveCompression();
  UploadFile(compressedFileBlob);
} on UploadInterruptedException {
  // We could either cancel the file upload or retry with the same file blob, or discard it. The
  // bloc consumer needs to submit a UploadRetried or UploadCancelled event to proceed.
  yield UploadInterruptedError();
}
```