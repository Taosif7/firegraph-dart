library firegraph;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firegraph/src/CacheManager.dart';
import 'package:firegraph/src/arguments.dart';
import 'package:firegraph/src/collection.dart';
import 'package:graphql_parser/graphql_parser.dart';

/// Firegraph class statically provides all querying and global level operations
class Firegraph {
  /// "\__all__" : When this field is included inside a document query, all fields of the document are loaded excluding sub-collections
  static const ALL_FIELDS_IDENTIFIER = "__all__";

  /// "id" : When this field is included inside a document query, id of the document is loaded
  static const ID_FIELD_IDENTIFIER = "id";

  /// Method to query firestore
  /// [firestore] is an instance of FirebaseFirestore
  /// [query] is a raw string that should define the structure of data to be queried
  static Future<Map<String, dynamic>> resolve(
    FirebaseFirestore firestore,
    String query,
  ) async {
    /// result of the query as a map
    Map<String, dynamic> result = {};

    /// Cache to store current cached document
    CacheManager cacheManager = new CacheManager();

    // Parse query int selection sets
    var tokens = scan(query);
    var definitions = new Parser(tokens).parseDocument().definitions.first
        as OperationDefinitionContext;
    var selectionSet = definitions.selectionSet;

    // for every root selection, which is a collection
    // Resolve using collection method and add to result set
    await Future.forEach(selectionSet.selections, (SelectionContext set) async {
      String collectionPath = set.field.fieldName.name;
      String collectionName = set.field.fieldName.name;
      String collectionAlias = set.field.fieldName.alias?.alias;
      if (collectionAlias != null)
        collectionPath = collectionName = set.field.fieldName.alias.name;

      // Parse list of field selection arguments into a map
      List<ArgumentContext> arguments = set.field.arguments;
      Map argumentsMap = parseArguments(arguments);

      // resolve collection and put documents into results map
      List<dynamic> collectionResult = await resolveCollection(
        firestore,
        collectionPath,
        set,
        cacheManager,
        collectionArgs: argumentsMap,
      );

      result[collectionAlias ?? collectionName] = collectionResult;
    });

    return result;
  }
}
