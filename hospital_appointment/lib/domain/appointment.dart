import 'package:hospital_appointment/utils/id_generator.dart';
import 'package:hospital_appointment/domain/patient.dart';
import 'package:hospital_appointment/domain/doctor.dart';
import 'package:hospital_appointment/domain/booking_slot.dart';

enum Status { waiting, canceled, completed }
class Appointment {
  final String _appointmentId;
  final Patient _patient;

  final BookingSlot _slot;
  Status _status;

  Appointment({
    String? appointmentId,
    required Patient patient,
    required Doctor doctor,
    required BookingSlot slot,
    Status status = Status.waiting,
  })  : _appointmentId = appointmentId ?? generateId('a'),
        _patient = patient,
      
        _slot = slot,
        _status = status {
    if (!_slot.isBooked && _status != Status.canceled) {
      _slot.book(this);
    }
  }

  String get appointmentId => _appointmentId;
  Patient get patient => _patient;

  BookingSlot get slot => _slot;
  Status get status => _status;

  void display() {
    print("Appointment ID: $appointmentId");
    print("Date: ${slot.date.toLocal().toIso8601String().split('T')[0]}");
    print("Time: ${slot.getTimeSlotLabel(slot.shift, slot.timeSlot)}");
    print("Doctor: ${slot.doctor.name}");
    print("Patient: ${patient.name}");
    print("Status: $status");
  }
  bool get isPastDue {
    final now = DateTime.now();
    final endTimeStr = slot.getTimeSlotLabel(slot.shift, slot.timeSlot).split('-').last.trim();
    final parts = endTimeStr.split(':');
    final endHour = int.parse(parts[0]);
    final endMinute = int.parse(parts[1]);
    final endDateTime = DateTime(slot.date.year, slot.date.month, slot.date.day, endHour, endMinute);
    return endDateTime.isBefore(now) && status == Status.waiting;
  }

  void changeStatus(Status newStatus) {
    if (status == Status.canceled && newStatus != Status.canceled) {
      throw Exception("Cannot change canceled appointment.");
    }

    if (newStatus == Status.completed) {
      final now = DateTime.now();
      final slotStart = slot.getStartDateTime();
      if (now.isBefore(slotStart)) {
        throw Exception("Cannot mark appointment as completed before its scheduled time.");
      }
    }

    if (newStatus == Status.canceled) {
      // Unbook slot only if it was booked
      if (slot.isBooked) slot.unbook();
    }

    _status = newStatus;
    print("Appointment $appointmentId status changed to $status");
  }

}