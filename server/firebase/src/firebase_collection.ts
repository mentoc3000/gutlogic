import * as admin from 'firebase-admin';

// Replace all of the documents in the Firestore [collection] with the entries in the [data] array using the provided BulkWriter [writer].
export async function replaceFirestoreCollection(writer: admin.firestore.BulkWriter, collection: admin.firestore.CollectionReference, data: any[]) {
  for (const doc of await collection.listDocuments()) {
    writer.delete(doc);
  }

  for (const entry of data) {
    writer.create(collection.doc(), entry);
  }
}

