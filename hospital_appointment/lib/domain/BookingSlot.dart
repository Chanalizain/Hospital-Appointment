import 'appointment.dart';

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

  BookingSlot({
    required this.date,
    required this.shift,
    required this.timeSlot,
    this.isBooked = false, 
    this.appointment,
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
}