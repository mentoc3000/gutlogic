const chai = require('chai');

var expect = chai.expect;

global.WebSocket = require('ws');
require('es6-promise').polyfill();
require('isomorphic-fetch');

// Require exports file with endpoint and auth info
const aws_exports = require('./aws-exports').default;

// Require AppSync module
const AUTH_TYPE = require('aws-appsync/lib/link/auth-link').AUTH_TYPE;
const AWSAppSyncClient = require('aws-appsync').default;

const url = aws_exports.ENDPOINT;
const region = aws_exports.REGION;
// const type = AUTH_TYPE.AWS_IAM;
const type = AUTH_TYPE.API_KEY
// const type = AUTH_TYPE.AMAZON_COGNITO_USER_POOLS

// If you want to use API key-based auth
const apiKey = 'da2-dq2yiriyi5aa3du5nlineuwjom';
// If you want to use a jwtToken from Amazon Cognito identity:
const jwtToken = 'xxxxxxxx';

// If you want to use AWS...
const AWS = require('aws-sdk');
const credentials = AWS.config.credentials;


// Set up Apollo client
const client = new AWSAppSyncClient({
    url: url,
    region: region,
    auth: {
        type: type,
        // credentials: credentials,
        apiKey: apiKey,
    }
    //disableOffline: true      //Uncomment for AWS Lambda
});

// Import gql helper and craft a GraphQL query
const gql = require('graphql-tag');


describe('Food database', function () {
    it('should add a food', async function () {
        const query = gql(`
        query CreateFood {
        createFood (name: "Orange") {
            nameId
            entryId
            name
        }
        }`);

        await client.hydrated();
        const result = await client.query({query: query});
        expect(result.name).to.equal('Orange'); 
    });
});