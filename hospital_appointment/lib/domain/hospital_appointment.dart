import 'package:hospital_appointment/domain/doctor.dart';
import 'package:hospital_appointment/domain/guardian.dart';
import 'package:hospital_appointment/domain/patient.dart';
import 'package:hospital_appointment/domain/booking_slot.dart';
import 'package:hospital_appointment/domain/appointment.dart';
import 'package:hospital_appointment/domain/person.dart';

class HospitalAppointment {
  List<Doctor> doctors;
  List<Patient> patients = [];
  List<BookingSlot> slots = [];
  List<Appointment> appointments = [];

  HospitalAppointment({required this.doctors});

  /// Register a new patient in hospital
  void registerPatient(Patient newPatient) {
    if (newPatient.age < 18 && newPatient.guardian == null) {
      print("Patient under 18 must have a guardian.");
      return;
    }
    if (newPatient.age >= 18) {
      newPatient.guardian = null;
    }

    bool exists = newPatient.guardian != null
        ? patients.any((p) =>
            p.name == newPatient.name &&
            p.dob == newPatient.dob &&
            p.guardian?.phone == newPatient.guardian?.phone)
        : patients.any((p) => p.phoneNumber == newPatient.phoneNumber);

    if (exists) {
      print("Patient already registered.");
      return;
    }

    patients.add(newPatient);
    print("Patient ${newPatient.name} registered successfully.");
  }

  /// Find patient by name and phone number
  Patient? findPatientByNamePhone(String name, String phone) {
    try {
      return patients.firstWhere(
        (p) => p.name.toLowerCase() == name.toLowerCase() && p.phoneNumber == phone,
      );
    } catch (e) {
      return null;
    }
  }


  /// Generic appointment search
  List<Appointment> getAppointments({String? patientName, Patient? patient, Status? status}) {
    return appointments.where((a) {
      if (patientName != null && !a.patient.name.toLowerCase().contains(patientName.toLowerCase())) return false;
      if (patient != null && a.patient != patient) return false;
      if (status != null && a.status != status) return false;
      return true;
    }).toList();
  }

  /// Get all doctors
  List<Doctor> getAllDoctors() => doctors;

  /// Search doctor by name or specialization
  List<Doctor> searchDoctor({String? name, Specialization? specialization}) {
    return doctors.where((d) {
      bool matches = true;
      if (name != null && name.isNotEmpty) {
        matches &= d.name.toLowerCase().contains(name.toLowerCase());
      }
      if (specialization != null) {
        matches &= d.specialization == specialization;
      }
      return matches;
    }).toList();
  }

  /// Get doctors by specialization
  List<Doctor> getDoctorsBySpecialization(Specialization specialization) {
    return doctors.where((d) => d.specialization == specialization).toList();
  }

  /// Initialize slots for a specific date
  void initializeSlotsForDate(DateTime date) {
    for (var doctor in doctors) {
      bool slotsExist = slots.any((s) =>
          s.doctor.doctorId == doctor.doctorId &&
          s.date.year == date.year &&
          s.date.month == date.month &&
          s.date.day == date.day);

      if (!slotsExist) {
        for (var shift in WorkShift.values) {
          for (var timeSlot in TimeSlot.values) {
            slots.add(BookingSlot(
              doctor: doctor,
              date: date,
              shift: shift,
              timeSlot: timeSlot,
            ));
          }
        }
      }
    }
  }

  /// Get available slots for a doctor on a date
  List<BookingSlot> getAvailableSlots(DateTime date, Doctor doctor) {
    return slots.where((s) =>
        s.doctor.doctorId == doctor.doctorId &&
        s.date.year == date.year &&
        s.date.month == date.month &&
        s.date.day == date.day &&
        (s.appointment == null || s.appointment!.status == Status.canceled)).toList();
  }

  /// Book an appointment
  void bookAppointment(Appointment appointment) {
    bool isAlreadyBooked = appointments.any((a) =>
        a.slot.doctor.doctorId == appointment.slot.doctor.doctorId &&
        a.slot.date.year == appointment.slot.date.year &&
        a.slot.date.month == appointment.slot.date.month &&
        a.slot.date.day == appointment.slot.date.day &&
        a.slot.shift == appointment.slot.shift &&
        a.slot.timeSlot == appointment.slot.timeSlot &&
        a.status != Status.canceled);

    if (isAlreadyBooked) {
      throw Exception('Slot already booked!');
    }

    appointments.add(appointment);
    appointment.slot.isBooked = true;
    print('Appointment booked successfully!');
  }

  /// Cancel an appointment
  void cancelAppointment(String appointmentId) {
    var appointment = appointments.firstWhere((a) => a.appointmentId == appointmentId);
    changeAppointmentStatus(appointment, Status.canceled);
    print("Appointment ${appointment.appointmentId} canceled.");
  }

  /// Change appointment status (handles slot updates)
  void changeAppointmentStatus(Appointment appt, Status newStatus) {
    appt.changeStatus(newStatus);
    if (newStatus == Status.canceled) {
      appt.slot.unbook();
    } else {
      appt.slot.isBooked = true;
      appt.slot.appointment = appt;
    }
  }

  /// Auto-cancel past due appointments
  List<Appointment> autoCancelPastDueAppointments() {
    List<Appointment> canceled = [];
    for (var appt in appointments) {
      if (appt.status == Status.waiting && appt.isPastDue) {
        changeAppointmentStatus(appt, Status.canceled);
        canceled.add(appt);
        print("Appointment ${appt.appointmentId} auto-canceled because it is past due.");
      }
    }
    return canceled;
  }

  /// Search appointments by patient name
  List<Appointment> searchAppointmentsByPatientName(String name) {
    return appointments.where((a) => a.patient.name.toLowerCase().contains(name.toLowerCase())).toList();
  }

  /// Get appointment by list index
  Appointment? getAppointmentByIndex(List<Appointment> list, int index) {
    if (index < 0 || index >= list.length) return null;
    return list[index];
  }

  /// Get appointments for a patient
  List<Appointment> getAppointmentsForPatient(Patient patient, {Status? status}) {
    return appointments.where((a) {
      if (a.patient != patient) return false;
      if (status != null && a.status != status) return false;
      return true;
    }).toList();
  }

  /// Print appointments for a patient
  void printAppointmentsForPatient(Patient patient) {
    var appts = getAppointmentsForPatient(patient);
    if (appts.isEmpty) {
      print("No appointments found for ${patient.name}");
      return;
    }
    for (var a in appts) {
      a.display();
      print("---");
    }
  }
  Patient? registerOrGetPatient({required String name, required DateTime dob, required String phone, Guardian? guardian,}) {
    // Check for existing patient
    for (var p in patients) {
      if (p.name.toLowerCase() == name.toLowerCase() &&
      p.phoneNumber == phone &&
      p.dob.year == dob.year &&
      p.dob.month == dob.month &&
      p.dob.day == dob.day) {
      return p; 
    }
    }
    // Register new patient
    var newPatient = Patient(
      name: name,
      gender: Gender.preferNotToSay,
      dob: dob,
      phoneNumber: phone,
      guardian: guardian,
    );
    registerPatient(newPatient);
    return newPatient;
  }

}