import 'package:hospital_appointment/domain/booking_slot.dart';
import 'package:hospital_appointment/domain/appointment.dart';
import 'package:hospital_appointment/domain/doctor.dart';
import 'package:hospital_appointment/domain/patient.dart';

class HospitalAppointment {
  List<Doctor> doctors;
  List<Appointment> appointments = [];
  List<BookingSlot> slots = [];
  List<Patient> patients = [];

  HospitalAppointment({required this.doctors});

  void registerPatient(Patient newPatient) {

    if(newPatient.age < 18 && newPatient.guardian == null){
      print("Patient is under 18 and must have a gaurdian");
      return;
    }
    if (newPatient.age >= 18) {
      newPatient.guardian = null;
    }
    
    bool exists;

    if (newPatient.guardian != null) {
      // Child with guardian
      exists = patients.any((p) =>
        p.name == newPatient.name &&
        p.dob == newPatient.dob &&
        p.guardian?.phone == newPatient.guardian?.phone
      );
    } else {
      // adult
      exists = patients.any((p) => p.phoneNumber == newPatient.phoneNumber);
    }

    if (exists) {
      print("Patient already registered.");
    } else {
      patients.add(newPatient);
      print("Patient ${newPatient.name} registered successfully.");
    }
  }

  Patient? searchPatient({String? phoneNumber, String? name, DateTime? dob}) {
    for (var patient in patients) {
      // adult
      if (phoneNumber != null && patient.guardian == null && patient.phoneNumber == phoneNumber) {
        if (name == null || patient.name == name) {
          return patient;
        }
      }

      // child with a gaurdian
      if (phoneNumber != null && patient.guardian != null && patient.guardian!.phone == phoneNumber) {
        if ((name == null || patient.name == name) &&
            (dob == null || patient.dob == dob)) {
          return patient;
        }
      }
    }

    print("No patient found.");
    return null;
  }

    //Get all doctors
  List<Doctor> getAllDoctors() {
    return doctors;
  }

  //Search doctor
  List<Doctor> searchDoctor({String? name, Specialization? specialization}) {
    return doctors.where((doctor) {
      bool matches = true;

      if (name != null && name.isNotEmpty) {
        matches &= doctor.name.toLowerCase().contains(name.toLowerCase());
      }

      if (specialization != null) {
        matches &= doctor.specialization == specialization;
      }

      return matches;
    }).toList();
  }

  //cancel appointment if passed the due date
  void autoCancelPastAppointments() {
    final now = DateTime.now();

    for (var appointment in appointments) {
      if (appointment.isPastDue) {
        appointment.changeStatus(Status.canceled);
        //print("Auto-canceled appointment ${appointment.appointmentId} (time passed)");
      }
    }
  }

  // get all available slots for a doctor on a specific date
  List<BookingSlot> getAvailableSlots(DateTime date, Doctor doctor) {
    return slots.where((slot) =>
      slot.date.year == date.year &&
      slot.date.month == date.month &&
      slot.date.day == date.day &&
      slot.doctor == doctor &&
      !slot.isBooked
    ).toList();
  }


  // Get all available slots for all doctors on a specific date
  Map<Doctor, List<BookingSlot>> getAvailableSlotsAllDoctors(DateTime date) {
    Map<Doctor, List<BookingSlot>> result = {};

    for (var doctor in doctors) {
      var availableSlots = getAvailableSlots(date, doctor);
      if (availableSlots.isNotEmpty) {
        result[doctor] = availableSlots;
      }
    }

    return result;
  }

  void printAvailableSlotsAllDoctors(DateTime date) {
    var allSlots = getAvailableSlotsAllDoctors(date);

    if (allSlots.isEmpty) {
      print("No available slots for any doctor on ${date.toLocal()}");
      return;
    }

    print("Available slots for all doctors on ${date.toLocal()}:");
    allSlots.forEach((doctor, slots) {
      print("Doctor: ${doctor.name} (${doctor.specialization.name})");
      for (var slot in slots) {
        print("  ${slot.shift} - ${slot.getTimeSlotLabel(slot.shift, slot.timeSlot)}");
      }
    });
  }

  // get doctors by specialization
  List<Doctor> getDoctorsBySpecialization(Specialization specialization) {
    return doctors
        .where((doctor) => doctor.specialization == specialization)
        .toList();
  }

  // get available slots for doctors of a specific specialization
  Map<Doctor, List<BookingSlot>> getAvailableSlotsBySpecialization(DateTime date, Specialization specialization) {
    var allSlots = getAvailableSlotsAllDoctors(date);

    return Map.fromEntries(
      allSlots.entries.where(
        (entry) => entry.key.specialization == specialization,
      ),
    );
  }

  void printAvailableSlotsBySpecialization(DateTime date, Specialization specialization) {
    var available = getAvailableSlotsBySpecialization(date, specialization);

    if (available.isEmpty) {
      print("No available slots for ${specialization.name} doctors on ${date.toLocal()}");
      return;
    }

    print("Available slots for ${specialization.name} doctors on ${date.toLocal()}:");
    available.forEach((doctor, slots) {
      print("Doctor: ${doctor.name}");
      for (var slot in slots) {
        print("  ${slot.shift.name} - ${slot.getTimeSlotLabel(slot.shift, slot.timeSlot)}");
      }
    });
  }

  // Book appointment
  void bookAppointment(Appointment appointment) {
    if (appointment.bookingslot.isBooked) {
      throw Exception("Slot already booked!");
    }

    appointments.add(appointment);
    appointment.bookingslot.book(appointment);
    print("Appointment booked successfully for ${appointment.patient.name} with Dr.${appointment.doctor.name}");
  }

  // Cancel appointment by id
  void cancelAppointment(String appointmentId) {
    final appointment = appointments.firstWhere((a) => a.appointmentId == appointmentId);
    appointment.changeStatus(Status.canceled);
    print("Appointment ${appointment.appointmentId} canceled.");
  }

  //function for check appoinments of a patient
  List<Appointment> getAppointmentsForPatient(
    Patient patient, {Status? status}) {
    return appointments.where((appt) {
      if (appt.patient != patient) return false;
      if (status != null && appt.status != status) return false;
      return true;
    }).toList();
  }

  void printAppointmentsForPatient(Patient patient) {
    final appts = getAppointmentsForPatient(patient);
    if (appts.isEmpty) {
      print("No appointments found for ${patient.name}");
      return;
    }
    for (var appt in appts) {
      appt.displayAppointment();
      print('---');
    }
  }


}