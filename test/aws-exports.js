// const AWS = require('aws-sdk');
global.WebSocket = require('ws');

Object.defineProperty(exports, '__esModule', { value: true });
const config = {
  AWS_ACCESS_KEY_ID: 'AKIATH7OL72IGRLR2YYS',
  AWS_SECRET_ACCESS_KEY: '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',
  HOST: 'tfdivmprjfd2phwlwdalzzpk2u.appsync-api.us-east-1.amazonaws.com',
  REGION: 'us-east-1',
  PATH: '/graphql',
  ENDPOINT: '',
};
config.ENDPOINT = `https://${config.HOST}${config.PATH}`;
exports.default = config;

global.window = global.window || {
  setTimeout,
  clearTimeout,
  WebSocket: global.WebSocket,
  ArrayBuffer: global.ArrayBuffer,
  addEventListener() {},
  navigator: { onLine: true },
};
global.localStorage = {
  store: {},
  getItem(key) {
    return this.store[key];
  },
  setItem(key, value) {
    this.store[key] = value;
  },
  removeItem(key) {
    delete this.store[key];
  },
};

require('es6-promise').polyfill();
require('isomorphic-fetch');

// Require AppSync module
const { AUTH_TYPE } = require('aws-appsync/lib/link/auth-link');
const AWSAppSyncClient = require('aws-appsync').default;

const url = config.ENDPOINT;
const region = config.REGION;
// const type = AUTH_TYPE.AWS_IAM;
const type = AUTH_TYPE.API_KEY;
// const type = AUTH_TYPE.AMAZON_COGNITO_USER_POOLS

// If you want to use API key-based auth
const apiKey = 'da2-dq2yiriyi5aa3du5nlineuwjom';
// If you want to use a jwtToken from Amazon Cognito identity:
// const jwtToken = 'xxxxxxxx';

// If you want to use AWS...
// const { credentials } = AWS.config;

// Set up Apollo client
const client = new AWSAppSyncClient(
  {
    url,
    region,
    auth: {
      type,
      // credentials: credentials,
      apiKey,
    },
    disableOffline: true,
  },
  {
    defaultOptions: {
      query: {
        fetchPolicy: 'network-only',
        // errorPolicy: 'all',
      },
      mutate: {
        fetchPolicy: 'no-cache',
        // errorPolicy: 'all',
      },
    },
  }
);

exports.client = client;
