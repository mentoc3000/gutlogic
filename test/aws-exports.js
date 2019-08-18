'use strict';
Object.defineProperty(exports, '__esModule', { value: true });
var config = {
  AWS_ACCESS_KEY_ID: 'AKIATH7OL72IGRLR2YYS',
  AWS_SECRET_ACCESS_KEY: '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',
  HOST: 'tfdivmprjfd2phwlwdalzzpk2u.appsync-api.us-east-1.amazonaws.com',
  REGION: 'us-east-1',
  PATH: '/graphql',
  ENDPOINT: '',
};
config.ENDPOINT = 'https://' + config.HOST + config.PATH;
exports.default = config;

global.WebSocket = require('ws');
global.window = global.window || {
  setTimeout: setTimeout,
  clearTimeout: clearTimeout,
  WebSocket: global.WebSocket,
  ArrayBuffer: global.ArrayBuffer,
  addEventListener: function() {},
  navigator: { onLine: true },
};
global.localStorage = {
  store: {},
  getItem: function(key) {
    return this.store[key];
  },
  setItem: function(key, value) {
    this.store[key] = value;
  },
  removeItem: function(key) {
    delete this.store[key];
  },
};

require('es6-promise').polyfill();
require('isomorphic-fetch');

// Require AppSync module
const AUTH_TYPE = require('aws-appsync/lib/link/auth-link').AUTH_TYPE;
const AWSAppSyncClient = require('aws-appsync').default;

const url = config.ENDPOINT;
const region = config.REGION;
// const type = AUTH_TYPE.AWS_IAM;
const type = AUTH_TYPE.API_KEY;
// const type = AUTH_TYPE.AMAZON_COGNITO_USER_POOLS

// If you want to use API key-based auth
const apiKey = 'da2-dq2yiriyi5aa3du5nlineuwjom';
// If you want to use a jwtToken from Amazon Cognito identity:
const jwtToken = 'xxxxxxxx';

// If you want to use AWS...
const AWS = require('aws-sdk');
const credentials = AWS.config.credentials;

// Set up Apollo client
const client = new AWSAppSyncClient(
  {
    url: url,
    region: region,
    auth: {
      type: type,
      // credentials: credentials,
      apiKey: apiKey,
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
