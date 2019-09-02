// const AWS = require('aws-sdk');
global.WebSocket = require('ws');

Object.defineProperty(exports, '__esModule', { value: true });
const config = {
  AWS_ACCESS_KEY_ID: 'AKIATH7OL72IGRLR2YYS',
  AWS_SECRET_ACCESS_KEY: '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',
  HOST: 'ndxzbvrlwfeerat5rz27xmj2ea.appsync-api.us-east-1.amazonaws.com',
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
const AmazonCognitoIdentity = require('amazon-cognito-identity-js');
const awsCredientials = require('./aws-credentials');
// const { CognitoUserPool } = AmazonCognitoIdentity;
// const AWS = require('aws-sdk');
// const request = require('request');
// const jwkToPem = require('jwk-to-pem');
// const jwt = require('jsonwebtoken');
global.fetch = require('node-fetch');

const url = config.ENDPOINT;
const region = config.REGION;
// const type = AUTH_TYPE.AWS_IAM;
// const type = AUTH_TYPE.API_KEY;
const type = AUTH_TYPE.AMAZON_COGNITO_USER_POOLS;

async function getJwtToken(username, password) {
  const poolData = {
    UserPoolId: 'us-east-1_cUSIiRhO3', // Your user pool id here
    ClientId: '7a8qhbu3d5kddqui69l0a42uh6', // Your client id here
  };
  const userPool = new AmazonCognitoIdentity.CognitoUserPool(poolData);

  const authenticationDetails = new AmazonCognitoIdentity.AuthenticationDetails(
    {
      Username: username,
      Password: password,
    }
  );

  const userData = {
    Username: username,
    Pool: userPool,
  };
  const cognitoUser = new AmazonCognitoIdentity.CognitoUser(userData);
  return new Promise((resolve, reject) => {
    cognitoUser.authenticateUser(authenticationDetails, {
      onSuccess(result) {
        resolve(result.getIdToken().getJwtToken());
      },
      onFailure(err) {
        reject(err);
      },
    });
  });
}

// If you want to use API key-based auth
// const apiKey = 'da2-r7xglsfcjbb33cmpzfbzyrxd64';
// If you want to use a jwtToken from Amazon Cognito identity:
// const jwtToken = await getJwtToken(username, password);

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
      // apiKey,
      jwtToken: async () =>
        getJwtToken(awsCredientials.username, awsCredientials.password),
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
