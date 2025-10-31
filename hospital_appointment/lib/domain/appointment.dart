import 'package:hospital_appointment/domain/doctor.dart';
import 'package:hospital_appointment/domain/patient.dart';
import 'package:hospital_appointment/domain/BookingSlot.dart';
import 'package:uuid/uuid.dart';

var uuid = Uuid();

enum Status {waiting, canceled, completed}

class Appointment {
  String appointmentId;
  Patient patient;
  Doctor doctor;
  BookingSlot schedule;
  Status status;

  Appointment({String? appointmentId, required this.patient, required this.doctor, required this.schedule, required this.status})
              : appointmentId = appointmentId ?? uuid.v4();
}