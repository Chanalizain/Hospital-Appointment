import 'package:hospital_appointment/domain/person.dart';
import 'package:hospital_appointment/domain/BookingSlot.dart';
import 'package:uuid/uuid.dart';

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

var uuid = Uuid();

class Doctor extends Person{
  String doctorId;
  Specialization specialization;
  List<BookingSlot> bookingSlot = [];

  Doctor({String? doctorId, required super.name,required super.gender,required super.dob,required super.phoneNumber, required this.specialization})
        : doctorId = doctorId ?? uuid.v4();

}