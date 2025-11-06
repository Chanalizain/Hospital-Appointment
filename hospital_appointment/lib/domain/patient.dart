import 'package:hospital_appointment/domain/guardian.dart';
import 'package:hospital_appointment/domain/person.dart';
import 'package:hospital_appointment/utils/id_generator.dart';

class Patient extends Person {
  final String _patientId;
  Guardian? _guardian;

  Patient({
    String? patientId,
    required super.name,
    required super.gender,
    required super.dob,
    String? phoneNumber, 
    Guardian? guardian,
  })  : _patientId = patientId ?? generateId('p'),
        _guardian = guardian,
        super(phoneNumber: phoneNumber ?? guardian?.phone ?? '');
  
  String get patientId => _patientId;
  Guardian? get guardian => _guardian;
  set guardian(Guardian? g) => _guardian = g;
}