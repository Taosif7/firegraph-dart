import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firegraph/src/CacheManager.dart';
import 'package:firegraph/src/order.dart';
import 'package:firegraph/src/where.dart';
import 'package:graphql_parser/graphql_parser.dart';
import 'document.dart';

Future<List<dynamic>> resolveCollection(
    FirebaseFirestore firestore,
    String collectionPath,
    SelectionContext selections,
    CacheManager cacheManager,
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

    // If there's limit argument, apply limit to query
    if (collectionArgs['limit'] != null) {
      query = query.limit(collectionArgs['limit']);
    }
  }

  // Query the collection with its path
  QuerySnapshot querySnapshot = await query.get();

  // For every document, resolve the document using method
  await Future.forEach(querySnapshot.docs, (QueryDocumentSnapshot doc) async {
    // Add fetched doc into cache manager
    cacheManager.addCache(doc);

    String path = collectionPath + "/" + doc.id;
    Map docData = await resolveDocument(
      firestore,
      path,
      selections.field.selectionSet,
      cacheManager,
      fetchedDocument: doc,
    );
    docs.add(docData);
  });

  return docs;
}
