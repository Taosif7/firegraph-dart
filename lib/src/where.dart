import 'package:cloud_firestore/cloud_firestore.dart';

/// A method that takes a map of [filters] and applies `.where()`
/// firebase filters on [query] based on key operatior and value
Query applyWhereFilters(Query query, Map<String, dynamic> filters) {
  filters.entries.forEach((filter) {
    String key = filter.key;
    dynamic value = filter.value;
    List<String> keySplits = key.split("_");
    String operator = keySplits.last;
    String keyName = keySplits.length > 0
        ? key.substring(0, key.length - operator.length - 1)
        : key;

    switch (operator) {
      case 'eq':
        query = query.where(keyName, isEqualTo: value);
        break;

      case 'neq':
        query = query.where(keyName, isNotEqualTo: value);
        break;

      case 'gt':
        query = query.where(keyName, isGreaterThan: value);
        break;

      case 'gte':
        query = query.where(keyName, isGreaterThanOrEqualTo: value);
        break;

      case 'lt':
        query = query.where(keyName, isLessThan: value);
        break;

      case 'lte':
        query = query.where(keyName, isLessThanOrEqualTo: value);
        break;

      case 'null':
        query = query.where(keyName, isNull: value);
        break;

      case 'contains':
        query = query.where(keyName, arrayContains: value);
        break;

      case 'containsAny':
        query = query.where(keyName, arrayContainsAny: List.castFrom(value));
        break;

      case 'in':
        query = query.where(keyName, whereIn: List.castFrom(value));
        break;

      case 'notIn':
        query = query.where(keyName, whereNotIn: List.castFrom(value));
        break;
    }
  });

  return query;
}
