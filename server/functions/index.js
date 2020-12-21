const admin = require('firebase-admin');
const axios = require('axios');
const functions = require('firebase-functions');
const tools = require('firebase-tools');

admin.initializeApp();

/**
 * Deletes user data when an account is deleted.
 */
exports.onUserDeleted = functions.auth.user().onDelete(async (user) => {
  console.log(`Deleting data associated with ${user.uid}.`);

  // Provided automatically in the Cloud Functions environment.
  const project = process.env.GCLOUD_PROJECT;

  // Set manually with firebase config:set
  const token = functions.config().auth.token;

  await tools.firestore.delete(`/user_data/${user.uid}`, {
    token,
    project,
    recursive: true,
    yes: true,
  });

  await tools.firestore.delete(`/users/${user.uid}`, {
    token,
    project,
    recursive: true,
    yes: true,
  });

  console.log(`Successfully deleted data associated with ${user.uid}.`);
});

const _appId = '47b2ce40';
const _appKey = '6baa72019f5be55b501442052edf134b';
const _edamamUrl = 'http://api.edamam.com/api/food-database/v2/parser';

/**
 * Retrieve Edamam food data
 */
const edamamFoodSearch = async (query) => {
  const edamamQuery = await axios.create({
    baseURL: _edamamUrl,
    params: {
      app_id: _appId,
      app_key: _appKey,
      ingr: query,
    },
  });
  const response = await edamamQuery.get();
  return response;
};

exports.edamamFoodSearch = functions.https.onCall(async (input, context) => {
  const response = await edamamFoodSearch(input.query);
  const { status, data } = response;
  return { status, data };
});
