library firegraph;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firegraph/src/collection.dart';
import 'package:graphql_parser/graphql_parser.dart';

/// Firegraph class statically provides all querying and global level operations
class Firegraph {

  /// Method to query firestore
  /// [firestore] is an instance of FirebaseFirestore
  /// [query] is a raw string that should define the structure of data to be queried
  static Future<Map<String, dynamic>> resolve(
    FirebaseFirestore firestore,
    String query,
  ) async {

    /// result of the query as a map
    Map<String, dynamic> result = {};

    // Parse query int selection sets
    var tokens = scan(query);
    var definitions = new Parser(tokens).parseDocument().definitions.first
        as OperationDefinitionContext;
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
