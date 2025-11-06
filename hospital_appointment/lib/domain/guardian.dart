enum Relation {father, mother, sister, brother, son, daughter, other}

class Guardian {
  final String _name;
  final String _phone;
  final Relation _relation;

  Guardian({required String name, required String phone, required Relation relation})
      : _name = name,
        _phone = phone,
        _relation = relation;

  String get name => _name;
  String get phone => _phone;
  Relation get relation => _relation;
}