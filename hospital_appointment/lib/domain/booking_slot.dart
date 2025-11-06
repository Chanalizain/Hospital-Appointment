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
  });

  void book(Appointment appt) {
    if (isBooked) throw Exception("Slot already booked.");
    appointment = appt;
    isBooked = true;
  }
  
  void unbook() {
    appointment = null;
    isBooked = false;
  }

  String getTimeSlotLabel(WorkShift shift, TimeSlot timeSlot) {
    if (shift == WorkShift.morning) {
      switch (timeSlot) {
      case TimeSlot.slot1:
      return "08:00 - 09:00";
      case TimeSlot.slot2:
      return "09:15 - 10:15";
      case TimeSlot.slot3:
      return "10:30 - 11:30";
    }
    } 
    else {
      switch (timeSlot) {
      case TimeSlot.slot1:
      return "13:30 - 14:30";
      case TimeSlot.slot2:
      return "14:45 - 15:45";
      case TimeSlot.slot3:
      return "16:00 - 17:00";
    }
    }
  }

    DateTime getStartDateTime() {
    // Return DateTime of slot start
    int hour = 0;
    int minute = 0;

    switch (shift) {
      case WorkShift.morning:
        switch (timeSlot) {
          case TimeSlot.slot1:
            hour = 8;
            minute = 0;
            break;
          case TimeSlot.slot2:
            hour = 9;
            minute = 15;
            break;
          case TimeSlot.slot3:
            hour = 10;
            minute = 30;
            break;
        }
        break;

      case WorkShift.afternoon:
        switch (timeSlot) {
          case TimeSlot.slot1:
            hour = 13;
            minute = 30;
            break;
          case TimeSlot.slot2:
            hour = 14;
            minute = 45;
            break;
          case TimeSlot.slot3:
            hour = 16;
            minute = 0;
            break;
        }
        break;
    }

    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  DateTime getEndDateTime() {
    // Return DateTime of slot end
    int hour = 0;
    int minute = 0;

    switch (shift) {
      case WorkShift.morning:
        switch (timeSlot) {
          case TimeSlot.slot1:
            hour = 9;
            minute = 0;
            break;
          case TimeSlot.slot2:
            hour = 10;
            minute = 15;
            break;
          case TimeSlot.slot3:
            hour = 11;
            minute = 30;
            break;
        }
        break;

      case WorkShift.afternoon:
        switch (timeSlot) {
          case TimeSlot.slot1:
            hour = 14;
            minute = 30;
            break;
          case TimeSlot.slot2:
            hour = 15;
            minute = 45;
            break;
          case TimeSlot.slot3:
            hour = 17;
            minute = 0;
            break;
        }
        break;
    }

    return DateTime(date.year, date.month, date.day, hour, minute);
  }

}