enum Relation {father, mother, sister, brother, son, daughter, other}

class Guardian {
  String name;
  String phone;
  Relation relation;

  Guardian({required this.name, required this.phone, required this.relation});
}