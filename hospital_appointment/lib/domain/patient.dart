import 'package:hospital_appointment/domain/guardian.dart';
import 'package:hospital_appointment/domain/person.dart';
import 'package:hospital_appointment/utils/id_generator.dart';

class Patient extends Person {
  final String _patientId;
  Guardian? guardian;

  Patient({
    String? patientId,
    required super.name,
    required super.gender,
    required super.dob,
    String? phoneNumber, 
    required this.guardian,
  })  : _patientId = patientId ?? generateId('p'),
        super(phoneNumber: phoneNumber ?? guardian?.phone ?? '');
  
  String get patientId => _patientId;
}