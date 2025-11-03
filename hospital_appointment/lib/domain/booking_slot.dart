import 'package:hospital_appointment/domain/appointment.dart';
import 'package:hospital_appointment/domain/doctor.dart';

enum TimeSlot {
  slot1,
  slot2,
  slot3,
}
enum WorkShift {
  morning,
  afternoon,
}

class BookingSlot {

  final DateTime date;
  final WorkShift shift;
  final TimeSlot timeSlot;
  bool isBooked; 
  Appointment? appointment; 
  Doctor doctor;

  BookingSlot({
    required this.date,
    required this.shift,
    required this.timeSlot,
    this.isBooked = false, 
    this.appointment,
    required this.doctor
  }) : assert(isBooked == (appointment != null), 
            'isBooked must match the presence of an appointment.');

  String get slotLabel {
    final slotDescription = timeSlot.name.toUpperCase(); 

    if (isBooked) {
      final patientName = appointment?.patient.name ?? 'Unknown'; 
      return '$slotDescription (BOOKED by $patientName)';
    } else {
      return '$slotDescription (AVAILABLE)';
    }
  }

  //method to mark the slot as booked
  void book(Appointment newAppointment) {
    if (isBooked) {
      throw Exception('This slot is already booked.');
    }
    appointment = newAppointment;
    isBooked = true;
  }
  
  void unbook() {
    appointment = null;
    isBooked = false;
  }

  String getTimeSlotLabel(WorkShift shift, TimeSlot slot) {
    if (shift == WorkShift.morning) {
      switch (slot) {
        case TimeSlot.slot1:
          return "8:00 - 9:00";
        case TimeSlot.slot2:
          return "9:15 - 10:15";
        case TimeSlot.slot3:
          return "10:30 - 11:45";
      }
    } else {
      switch (slot) {
        case TimeSlot.slot1:
          return "1:30 - 2:30";
        case TimeSlot.slot2:
          return "2:45 - 3:45";
        case TimeSlot.slot3:
          return "4:00 - 5:00";
      }
    }
  }

}