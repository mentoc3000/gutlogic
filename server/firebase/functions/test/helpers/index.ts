// Ava excludes files in **/helpers/** from the test runner.

import firebaseFunctionsTest from 'firebase-functions-test';

export const fft = firebaseFunctionsTest({
  projectId: 'gutlogic-dev'
}, process.env.GOOGLE_APPLICATION_CREDENTIALS);