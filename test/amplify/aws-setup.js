// messy because of the export/import syntax differences
const AmplifyCore = require('aws-amplify');
const Amplify = require('aws-amplify').default;
global.fetch = require('node-fetch');

const { API, Auth } = Amplify;
const { graphqlOperation } = AmplifyCore;

const awsmobile = {
  aws_project_region: 'us-east-1',
  aws_cognito_identity_pool_id:
    'us-east-1:c8d0392f-2ecb-49eb-b5c1-926d2dd868ad',
  aws_cognito_region: 'us-east-1',
  aws_user_pools_id: 'us-east-1_oaqINGrgZ',
  aws_user_pools_web_client_id: '7g89vc37d3pc441ou4iqlb8erq',
  oauth: {},
  aws_appsync_graphqlEndpoint:
    'https://vaakik5q2fguvg5q2ibwmhblo4.appsync-api.us-east-1.amazonaws.com/graphql',
  aws_appsync_region: 'us-east-1',
  aws_appsync_authenticationType: 'AMAZON_COGNITO_USER_POOLS',
};

Amplify.configure(awsmobile);

const username = 'jp.sheehan2@gmail.com';
const password = 'Abra2Cadabra!!';

exports.signIn = async function signIn() {
  const user = await Auth.signIn(username, password);
  if (user.challengeName) {
    throw Error(`Encountered challenge when signing in: ${user.challengeName}`);
  }
};

exports.signOut = async function signOut() {
  await Auth.signOut();
};

exports.config = awsmobile;
exports.Amplify = Amplify;
