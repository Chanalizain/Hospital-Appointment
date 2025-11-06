import 'package:hospital_appointment/ui/console.dart';
import 'package:hospital_appointment/data/appointment_repository.dart';
import 'package:hospital_appointment/data/doctor_repository.dart';
import 'package:hospital_appointment/data/patient_repository.dart';

void main() {
  var doctorRepo = DoctorRepository("data/doctors.json");
  var doctors = doctorRepo.readDoctors();

  var patientRepo = PatientRepository("data/patients.json");

  var repository = AppointmentRepository("data/appointments.json", patientRepo);

  var console = AppointmentConsole(repository: repository, doctors: doctors);
  console.start();
}
