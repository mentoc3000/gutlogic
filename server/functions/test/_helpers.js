const projectConfig = { projectId: 'gutlogic-dev' };
const fft = require('firebase-functions-test')(projectConfig, './gutlogic-dev-firebase-adminsdk.json');

exports.firebaseFunctionsTest = fft;
