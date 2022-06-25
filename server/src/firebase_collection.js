
// Replace all of the documents in the Firestore [collection] with the entries in the [data] array using the provided BulkWriter [writer].
exports.replaceFirestoreCollection = async function replaceFirestoreCollection(writer, collection, data) {
  for (const doc of await collection.listDocuments()) {
    writer.delete(doc);
  }

  for (const entry of data) {
    writer.create(collection.doc(), entry);
  }
};

