import 'package:hospital_appointment/domain/appointment.dart';
import 'package:hospital_appointment/domain/doctor.dart';
import 'package:hospital_appointment/domain/patient.dart';

class HospitalAppointment {
  List<Doctor> doctors;
  List<Patient> patients = [];
  List<Appointment> appointments = [];

  HospitalAppointment({required this.doctors});
}