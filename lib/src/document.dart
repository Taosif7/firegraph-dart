import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firegraph/firegraph.dart';
import 'package:firegraph/src/CacheManager.dart';
import 'package:firegraph/src/arguments.dart';
import 'package:firegraph/src/collection.dart';
import 'package:graphql_parser/graphql_parser.dart';

Future<Map<String, dynamic>> resolveDocument(
    FirebaseFirestore firestore,
    String documentPath,
    SelectionSetContext selectionSet,
    CacheManager cacheManager,
    {DocumentSnapshot fetchedDocument}) async {
  DocumentSnapshot doc;
  dynamic data;

  /// doc data to be
  Map<String, dynamic> result = {};

  /// Cached Document stored in cache manager
  DocumentSnapshot cachedDoc;

  if (fetchedDocument != null) {
    // If doc is provided, use it
    doc = fetchedDocument;
    data = fetchedDocument.data();
  } else if ((cachedDoc = cacheManager.getCache(documentPath)) != null) {
    // If cache exists, use it
    doc = cachedDoc;
    data = doc.data();
  } else {
    // Fetch the doc if not provided
    doc = await firestore.doc(documentPath).get();
    data = doc.data();

    // store fetched doc into cacheManager
    cacheManager.addCache(doc);
  }

  if ((selectionSet?.selections?.length ?? 0) > 0) {
    var fields = selectionSet.selections;

    // find all fields identifier, and include whole document if found
    if (fields.any((f) => f.field.fieldName.name == Firegraph.ALL_FIELDS_IDENTIFIER)) {
      result = doc.data();
      result.putIfAbsent(Firegraph.ID_FIELD_IDENTIFIER, () => doc.id);
    }

    // Iterate over document's all fields
    await Future.forEach(fields, (SelectionContext field) async {
      String fieldName = field.field.fieldName.name;
      String fieldAlias = field.field.fieldName.alias?.alias;
      if (fieldAlias != null) fieldName = field.field.fieldName.alias.name;

      // If field has selection set, treat it as document reference or a sub-collection
      if (field.field.selectionSet != null && field.field.selectionSet.selections.length >= 0) {
        // Parse arguments for the field selection set into a map
        List<ArgumentContext> arguments = field.field.arguments;
        Map argumentsMap = parseArguments(arguments);

        if (data[fieldName] is String) {
          // If there's a string raw path field in document,
          // parse the document via its path

          String parentPath = argumentsMap['path'] ?? "";
          String documentPath = parentPath + data[fieldName];
          Map<String, dynamic> document = await resolveDocument(
            firestore,
            documentPath,
            field.field.selectionSet,
            cacheManager,
          );

          result[fieldAlias ?? fieldName] = document;
        } else if (data[fieldName] is DocumentReference) {
          // If its a document reference field, fetch document through reference
          DocumentReference docRef = data[fieldName];
          String documentPath = docRef.path;
          Map<String, dynamic> document = await resolveDocument(
            firestore,
            documentPath,
            field.field.selectionSet,
            cacheManager,
          );
          result[fieldAlias ?? fieldName] = document;
        } else {
          // Else consider it as a  sub-collection and fetch documents in it
          String collectionPath = documentPath + "/" + fieldName;
          List<dynamic> collectionResult = await resolveCollection(
            firestore,
            collectionPath,
            field,
            cacheManager,
            collectionArgs: argumentsMap,
          );

          result[fieldAlias ?? fieldName] = collectionResult;
        }
      } else if (fieldName == Firegraph.ID_FIELD_IDENTIFIER) {
        // If field is id, put Id of doc into result
        result[Firegraph.ID_FIELD_IDENTIFIER] = doc.id;
      } else {
        // Else put the field as is
        result[fieldAlias ?? fieldName] = data[fieldName];
      }
    });
  } else {
    result = doc.data();
    result.putIfAbsent(Firegraph.ID_FIELD_IDENTIFIER, () => doc.id);
  }

  // Finally remove the All field identifier from result if exists
  result.removeWhere((key, value) => key == Firegraph.ALL_FIELDS_IDENTIFIER);

  return result;
}
