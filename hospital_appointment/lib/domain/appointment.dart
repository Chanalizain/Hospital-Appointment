import 'package:hospital_appointment/domain/doctor.dart';
import 'package:hospital_appointment/domain/patient.dart';
import 'package:hospital_appointment/domain/booking_slot.dart';
import 'package:uuid/uuid.dart';

var uuid = Uuid();

enum Status {waiting, canceled, completed}

class Appointment {
  String appointmentId;
  Patient patient;
  Doctor doctor;
  BookingSlot bookingslot;
  Status status;

  Appointment({String? appointmentId, required this.patient, required this.doctor, required this.bookingslot, this.status = Status.waiting})
              : appointmentId = appointmentId ?? uuid.v4(){
                    bookingslot.book(this);
              }

  void displayAppointment(){
    print("Date: ${bookingslot.date}");
    print("Time: ${bookingslot.getTimeSlotLabel(bookingslot.shift, bookingslot.timeSlot)}");
    print("Doctor: ${doctor.name}");
    print("Patient: ${patient.name}");
    print("Status: $status");
  }

  void changeStatus(Status newStatus) {
    if (status == Status.canceled) {
      throw Exception("Cannot change a canceled appointment.");
    }

    // if trying to mark as completed before appointment date
    if (newStatus == Status.completed) {
      final now = DateTime.now();
      // Extract end time from the slot
      final slotStartTime = bookingslot.getTimeSlotLabel(bookingslot.shift, bookingslot.timeSlot).split('-').first.trim();
      final parts = slotStartTime.split(':');
      final endHour = int.parse(parts[0]);
      final endMinute = int.parse(parts[1]);

      final appointmentStartDateTime = DateTime(
        bookingslot.date.year,
        bookingslot.date.month,
        bookingslot.date.day,
        endHour,
        endMinute,
      );

      if (now.isBefore(appointmentStartDateTime)) {
        throw Exception("Cannot mark appointment as completed before the slot starts.");
      }
    }

    status = newStatus;

    //free up the booking slot
    if (newStatus == Status.canceled) {
      bookingslot.unbook();
    }
  }

  // Helper to check if appointment is past due
  bool get isPastDue {
    final now = DateTime.now();
    final slotEndTime = bookingslot.getTimeSlotLabel(bookingslot.shift, bookingslot.timeSlot).split('-').last.trim();
    final parts = slotEndTime.split(':');
    final endHour = int.parse(parts[0]);
    final endMinute = int.parse(parts[1]);
    final appointmentEndDateTime = DateTime(
      bookingslot.date.year,
      bookingslot.date.month,
      bookingslot.date.day,
      endHour,
      endMinute,
    );
    return appointmentEndDateTime.isBefore(now) && status == Status.waiting;
  }

}