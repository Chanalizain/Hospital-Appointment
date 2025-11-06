import 'package:hospital_appointment/domain/guardian.dart';
import 'package:hospital_appointment/domain/person.dart';
import 'package:test/test.dart';
import 'package:hospital_appointment/domain/hospital_appointment.dart';
import 'package:hospital_appointment/domain/doctor.dart';
import 'package:hospital_appointment/domain/patient.dart';
import 'package:hospital_appointment/domain/booking_slot.dart';
import 'package:hospital_appointment/domain/appointment.dart';

void main() {
  Doctor d1 = Doctor(
    name: "Dr. Linna", 
    specialization: Specialization.cardiology, 
    gender: Gender.female, 
    dob: DateTime(1980, 4, 12), 
    phoneNumber: '012345678',
  );
  Doctor d2 = Doctor(
    name: 'Dr. Liza',
    gender: Gender.female,
    dob: DateTime(1985, 9, 20),
    phoneNumber: '099888777',
    specialization: Specialization.pediatrics,
  );

  HospitalAppointment hospital = HospitalAppointment(doctors: [d1, d2]);

  Patient adultPatient = Patient(
      name: "Kem Veysean", 
      dob: DateTime(1990, 5, 12), 
      phoneNumber: "123456789", 
      guardian: null, 
      gender: Gender.female
  );

  Guardian guardian = Guardian(
    name: "lol", 
    phone: '0123456789', 
    relation: Relation.brother
  );
  Patient childPatient = Patient(
      name: "Bro Vy", 
      dob: DateTime(2015, 8, 20), 
      phoneNumber: "987654321", 
      guardian: guardian,
      gender: Gender.male
  );


  test('Register adult patient successfully', () {
    hospital.registerPatient(adultPatient);
    expect(hospital.patients.contains(adultPatient), isTrue);
  });

   test('Register child patient successfully', () {
    hospital.registerPatient(childPatient);
    expect(hospital.patients.contains(childPatient), isTrue);
  });

  test('Find patient by name, dob, phone', () {
    var found = hospital.findPatientByNamePhone("Kem Veysean", "123456789");
    expect(found, isNotNull);
    expect(found!.name, equals("Kem Veysean"));
  });

  test('Book an appointment', () {
    BookingSlot slot = BookingSlot(doctor: d1, date: DateTime.now(), shift: WorkShift.morning, timeSlot: TimeSlot.slot1);
    Appointment appt = Appointment(patient: adultPatient, doctor: d1, slot: slot);

    hospital.bookAppointment(appt);
    expect(hospital.appointments.contains(appt), isTrue);
    expect(slot.isBooked, isTrue);
  });

  test('Cancel an appointment', () {
    var appt = hospital.appointments.first;
    hospital.cancelAppointment(appt.appointmentId);
    expect(appt.status, equals(Status.canceled));
    expect(appt.slot.isBooked, isFalse);
  });

  test('Auto-cancel past appointments', () {
    BookingSlot pastSlot = BookingSlot(
        doctor: d1,
        date: DateTime.now().subtract(Duration(days: 1)),
        shift: WorkShift.morning,
        timeSlot: TimeSlot.slot2);
    Appointment pastAppt = Appointment(patient: adultPatient, doctor: d1, slot: pastSlot);
    hospital.bookAppointment(pastAppt);

    var canceled = hospital.autoCancelPastDueAppointments();
    expect(canceled.contains(pastAppt), isTrue);
    expect(pastAppt.status, equals(Status.canceled));
  });

  test('Get available slots', () {
    DateTime date = DateTime.now().add(Duration(days: 1));
    hospital.initializeSlotsForDate(date);

    List<BookingSlot> slots = hospital.getAvailableSlots(date, d1);
    expect(slots.isNotEmpty, isTrue);
    expect(slots.every((s) => s.doctor == d1), isTrue);
  });

  test('Search appointments by patient name', () {
    BookingSlot slot = BookingSlot(doctor: d2, date: DateTime.now(), shift: WorkShift.afternoon, timeSlot: TimeSlot.slot3);
    Appointment appt = Appointment(patient: adultPatient, doctor: d2, slot: slot);
    hospital.bookAppointment(appt);

    var searchResults = hospital.searchAppointmentsByPatientName("Veysean");
    expect(searchResults.contains(appt), isTrue);
  });
}
