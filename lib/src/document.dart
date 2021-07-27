import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firegraph/src/arguments.dart';
import 'package:firegraph/src/collection.dart';
import 'package:graphql_parser/graphql_parser.dart';

Future<Map<String, dynamic>> resolveDocument(FirebaseFirestore firestore,
    String documentPath, SelectionSetContext selectionSet,
    {DocumentSnapshot fetchedDocument}) async {
  DocumentSnapshot doc;
  dynamic data;

  /// doc data to be
  Map<String, dynamic> result = {};

  // If doc is provided, use it
  if (fetchedDocument != null) {
    doc = fetchedDocument;
    data = fetchedDocument.data();
  } else {
    // Fetch the doc if not provided
    doc = await firestore.doc(documentPath).get();
    data = doc.data();
  }

  if ((selectionSet?.selections?.length ?? 0) > 0) {
    var fields = selectionSet.selections;

    // Iterate over document's all fields
    await Future.forEach(fields, (SelectionContext field) async {
      String fieldName = field.field.fieldName.name;

      // If field has selection set, treat it as sub-collection
      if ((field.field.selectionSet?.selections?.length ?? 0) > 0) {
        // Parse arguments for the field selection set into a map
        List<ArgumentContext> arguments = field.field.arguments;
        Map argumentsMap = parseArguments(arguments);

        String collectionPath = documentPath + "/" + fieldName;
        List<dynamic> collectionResult = await resolveCollection(
          firestore,
          collectionPath,
          field,
          collectionArgs: argumentsMap,
        );

        result[field.field.fieldName.name] = collectionResult;
      } else if (fieldName == 'id') {
        // If field is id, put Id of doc into result
        result['id'] = doc.id;
      } else {
        // Else put the field as is
        result[fieldName] = data[fieldName];
      }
    });
  }

  return result;
}