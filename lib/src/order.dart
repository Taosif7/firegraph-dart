import 'package:cloud_firestore/cloud_firestore.dart';

/// Method to add `orderBy` firebase filters to [query]
/// from the provided [filters]
Query applyOrderFilters(Query query, Map<String, dynamic> filters) {
  // Here revered order of filters are applied due to firebase rule
  List<MapEntry> reversedFilters = filters.entries.toList().reversed.toList();
  reversedFilters.forEach((filter) {
    String field = filter.key;
    bool descOrder = filter.value.toLowerCase() == "desc";
    query = query.orderBy(field, descending: descOrder);
  });

  return query;
}
