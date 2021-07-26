import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:graphql_parser/graphql_parser.dart';
import 'document.dart';

Future<List<dynamic>> resolveCollection(
  FirebaseFirestore firestore,
  String collectionPath,
  SelectionContext selections,
) async {
  // List of docs for this collection
  List<dynamic> docs = [];

  // Query the collection with its path
  QuerySnapshot query = await firestore.collection(collectionPath).get();

  if ((selections.field.selectionSet?.selections?.length ?? 0) > 0) {

    // For every document, resolve the document using method
    await Future.forEach(query.docs, (doc) async {
      String path = collectionPath + "/" + doc.id;
      Map docData = await resolveDocument(
        firestore,
        path,
        selections.field.selectionSet,
        fetchedDocument: doc,
      );
      docs.add(docData);
    });
    
  }

  return docs;
}
