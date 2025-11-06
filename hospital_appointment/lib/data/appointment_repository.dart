import 'dart:convert';
import 'dart:io';
import '../domain/hospital_appointment.dart';
import '../domain/doctor.dart';
import '../domain/patient.dart';
import '../domain/booking_slot.dart';
import '../domain/appointment.dart';
import 'patient_repository.dart';

class AppointmentRepository {
  final String filePath;
  final PatientRepository patientRepo;

  AppointmentRepository(this.filePath, this.patientRepo);

  HospitalAppointment readAppointments(List<Doctor> doctors) {
    final file = File(filePath);
    if (!file.existsSync()) {
      return HospitalAppointment(doctors: doctors);
    }

    final content = file.readAsStringSync();
    if (content.trim().isEmpty) {
      return HospitalAppointment(doctors: doctors);
    }
    final data = jsonDecode(content);

    final patients = patientRepo.readPatients();

    HospitalAppointment hospital = HospitalAppointment(doctors: doctors);

    if (data['appointments'] != null) {
      var appointmentsJson = data['appointments'] as List;
      for (var a in appointmentsJson) {
        // Get patient by patientId
        String patientId = a['patientId'];
        Patient? patient = patients.firstWhere(
          (p) => p.patientId == patientId,
          orElse: () => throw Exception('Patient $patientId not found'),
        );

        Doctor doctor = doctors.firstWhere((d) => d.doctorId == a['doctorId']);

        DateTime slotDate = DateTime.parse(a['date']);
        hospital.initializeSlotsForDate(slotDate);

        BookingSlot slot = hospital.slots.firstWhere((s) =>
            s.doctor.doctorId == doctor.doctorId &&
            s.date.year == slotDate.year &&
            s.date.month == slotDate.month &&
            s.date.day == slotDate.day &&
            s.shift.toString() == a['shift'] &&
            s.timeSlot.toString() == a['timeSlot']);

        Appointment appt = Appointment(
          appointmentId: a['appointmentId'],
          patient: patient,
          doctor: doctor,
          slot: slot,
          status: Status.values.firstWhere((st) => st.toString() == a['status']),
        );

        slot.appointment = appt;
        slot.isBooked = appt.status != Status.canceled;

        hospital.appointments.add(appt);
      }
    }

    return hospital;
  }

  void writeAppointments(HospitalAppointment hospital) {
    final data = {
      'appointments': hospital.appointments.map((a) => {
        'appointmentId': a.appointmentId,
        'patientId': a.patient.patientId, // store only patientId
        'doctorId': a.doctor.doctorId,
        'date': a.slot.date.toIso8601String(),
        'shift': a.slot.shift.toString(),
        'timeSlot': a.slot.timeSlot.toString(),
        'status': a.status.toString(),
      }).toList(),
    };

    final jsonString = JsonEncoder.withIndent('  ').convert(data);
    final file = File(filePath);
    file.writeAsStringSync(jsonString);
  }
}
