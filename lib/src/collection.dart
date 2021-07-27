import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firegraph/src/order.dart';
import 'package:firegraph/src/where.dart';
import 'package:graphql_parser/graphql_parser.dart';
import 'document.dart';

Future<List<dynamic>> resolveCollection(FirebaseFirestore firestore,
    String collectionPath, SelectionContext selections,
    {Map collectionArgs}) async {
  /// List of docs for this collection
  List<dynamic> docs = [];

  /// Basic query
  Query query = firestore.collection(collectionPath);

  // Process collection arguments if provided
  if (collectionArgs != null) {
    // Look for 'where' arguments and apply where filters to our basic query
    if (collectionArgs['where'] != null) {
      var whereFilters = collectionArgs['where'];
      query = applyWhereFilters(query, whereFilters);
    }

    // If there's orderBy filters, apply them
    if (collectionArgs['orderBy'] != null) {
      var orderFilters = collectionArgs['orderBy'];
      query = applyOrderFilters(query, orderFilters);
    }
  }

  // Query the collection with its path
  QuerySnapshot querySnapshot = await query.get();

  if ((selections.field.selectionSet?.selections?.length ?? 0) > 0) {
    // For every document, resolve the document using method
    await Future.forEach(querySnapshot.docs, (doc) async {
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
