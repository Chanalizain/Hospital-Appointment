import 'package:uuid/uuid.dart';

final _uuid = Uuid();

String generateId(String prefix) {
  return '$prefix-${_uuid.v4()}';
}