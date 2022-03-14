// Ava excludes files in **/helpers/** from the test runner.

exports.fft = require('firebase-functions-test')({
  projectId: 'gutlogic-dev'
}, process.env.GOOGLE_APPLICATION_CREDENTIALS);
