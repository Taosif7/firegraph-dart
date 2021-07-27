import 'package:graphql_parser/graphql_parser.dart';

/// Method to parse List of [arguments] obtained from graphql_parser into Map
Map<String, dynamic> parseArguments(List<ArgumentContext> arguments) {
  Map<String, dynamic> argsMap = {};

  arguments.forEach((arg) {
    String argName = arg.name;
    ValueContext argValue = arg.valueOrVariable.value;
    if (argValue is ObjectValueContext) {
      argsMap[argName] = _objectValueToMap(argValue);
    } else {
      argsMap[argName] = argValue.value;
    }
  });

  return argsMap;
}

/// Method to convert an [ObjectValueContext] object value Map
Map<String, dynamic> _objectValueToMap(ObjectValueContext objectValue) {
  Map<String, dynamic> objectFields = {};
  objectValue.fields.forEach((field) {
    String fieldName = field.NAME.text;
    ValueContext fieldValue = field.value;
    if (fieldValue is ObjectValueContext) {
      objectFields[fieldName] = _objectValueToMap(fieldValue);
    } else {
      objectFields[fieldName] = fieldValue.value;
    }
  });

  return objectFields;
}
