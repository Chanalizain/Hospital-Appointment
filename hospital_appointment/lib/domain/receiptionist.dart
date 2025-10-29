import 'package:hospital_appointment/domain/person.dart';
import 'package:uuid/uuid.dart';

var uuid = Uuid();

class Receptionist extends Person {
  String recepId;

  Receptionist({String? recepId, required super.name,required super.gender,required super.dob,required super.phoneNumber})
              : recepId = recepId ?? uuid.v4();
}