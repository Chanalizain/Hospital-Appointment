import 'guardian.dart';
import 'person.dart';

import 'package:uuid/uuid.dart';

var uuid = Uuid();

class Patient extends Person {
  String patientId;
  Guardian? guardian;

  Patient({String? patientId, required super.name, required super.gender, required super.dob, required super.phoneNumber, this.guardian})
          : patientId = patientId ?? uuid.v4();
}