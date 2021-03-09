const functions = require('firebase-functions');
const tools = require('firebase-tools');

/**
 * Deletes user data when an account is deleted.
 */
exports.onUserDeleted = async (user) => {
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
};
