library firegraph;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firegraph/collection.dart';
import 'package:graphql_parser/graphql_parser.dart';

class Firegraph {
  static Future<Map<String, dynamic>> resolve(
    FirebaseFirestore firestore,
    String query,
  ) async {
    Map<String, dynamic> result = {};

    // Parse query int selection sets
    var tokens = scan(query);
    var definitions = new Parser(tokens).parseDocument().definitions.first as OperationDefinitionContext;
    var selectionSet = definitions.selectionSet;

    // for every root selection, which is a collection
    // Resolve using collection method and add to result set
    await Future.forEach(selectionSet.selections, (set) async {
      String collectionPath = set.field.fieldName.name;
      String collectionName = set.field.fieldName.name;
      
      List<dynamic> collectionResult =
          await resolveCollection(firestore, collectionPath, set);

      result[collectionName] = collectionResult;
    });

    return result;
  }
}
