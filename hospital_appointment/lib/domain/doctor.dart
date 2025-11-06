import 'package:hospital_appointment/domain/person.dart';
import 'package:hospital_appointment/utils/id_generator.dart';

//AI generated
enum Specialization {
  generalPractice,       // Family doctor
  pediatrics,            // Children
  obstetricsGynecology,  // Women’s health & pregnancy
  cardiology,            // Heart specialists
  dermatology,           // Skin problems
  ophthalmology,         // Eye doctor
  orthopedics,           // Bones & joint issues
  dentistry,             // Dental care
  diabetes               // Diabetes / endocrinology care
}

class Doctor extends Person{
  final String _doctorId;
  final Specialization _specialization;

  Doctor({String? doctorId, required super.name,required super.gender,required super.dob,required super.phoneNumber, required Specialization specialization,})
        : _doctorId = doctorId ?? generateId('d'),
          _specialization = specialization;

  String get doctorId => _doctorId;
  Specialization get specialization => _specialization;

}