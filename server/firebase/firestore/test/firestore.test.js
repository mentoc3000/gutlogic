const test = require("ava");
const tools = require("firebase-tools");
const firebase = require("@firebase/testing");

const userID = "test-user-id";

function initialize(auth) {
  return firebase.initializeTestApp({ projectId: "gutlogic-dev", auth: auth }).firestore();
}

test("cannot read and write user data when unauthorized", async (t) => {
  const db = initialize();

  const userMetaDocument = db.doc(`users/${userID}`);
  const userDataDocument = db.doc(`user_data/${userID}`);
  const userDataSubdocument = db.doc(`user_data/${userID}/timeline/entry`);

  await firebase.assertFails(userMetaDocument.get());
  await firebase.assertFails(userMetaDocument.set({ test: "value" }));

  await firebase.assertFails(userDataDocument.get());
  await firebase.assertFails(userDataDocument.set({ test: "value" }));

  await firebase.assertFails(userDataSubdocument.get());
  await firebase.assertFails(userDataSubdocument.set({ test: "value" }));

  t.pass();
});

test("can read and write user data when authorized", async (t) => {
  const db = initialize({ uid: userID });

  const userMetaDocument = db.doc(`users/${userID}`);
  const userDataDocument = db.doc(`user_data/${userID}`);
  const userDataSubdocument = db.doc(`user_data/${userID}/timeline/entry`);

  await firebase.assertSucceeds(userMetaDocument.get());
  await firebase.assertSucceeds(userMetaDocument.set({ test: "value" }));

  await firebase.assertSucceeds(userDataDocument.get());
  await firebase.assertSucceeds(userDataDocument.set({ test: "value" }));

  await firebase.assertSucceeds(userDataSubdocument.get());
  await firebase.assertSucceeds(userDataSubdocument.set({ test: "value" }));

  t.pass();
});
