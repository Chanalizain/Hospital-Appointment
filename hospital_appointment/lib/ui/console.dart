import 'dart:io';
import 'package:hospital_appointment/domain/booking_slot.dart';
import 'package:hospital_appointment/domain/guardian.dart';
import 'package:hospital_appointment/domain/person.dart';
import '../domain/hospital_appointment.dart';
import '../domain/doctor.dart';
import '../domain/patient.dart';
import '../domain/appointment.dart';
import '../data/appointment_repository.dart';

class AppointmentConsole {
  final AppointmentRepository repository;
  late HospitalAppointment hospital;

  AppointmentConsole({required this.repository, required List<Doctor> doctors}) {
    hospital = repository.readAppointments(doctors);
  }

  void start() {
    hospital.autoCancelPastDueAppointments();
    repository.writeAppointments(hospital);
    print("============= Hospital Appointment System =============\n");

    while (true) {
      printMainMenu();
      String? optionString = stdin.readLineSync();

      if (optionString == null || optionString.isEmpty) {
        print("No input provided.");
        continue;
      }

      int option;
      try {
        option = int.parse(optionString);
      } catch (e) {
        print("Invalid input! Enter a number.");
        continue;
      }

      switch (option) {
        case 1:
          bookAppointmentFlow();
          break;
        case 2:
          viewAppointmentsFlow();
          break;
        case 3:
          cancelAppointmentFlow();
          break;
        case 4:
          updateAppointmentFlow();
          break;
        case 0:
          print("Bye!");
          return;
        default:
          print("Invalid option! Choose 0-4.");
      }
    }
  }

  void printMainMenu() {
    print("\n********************************\n");
    print("1. Book Appointment");
    print("2. View Appointments");
    print("3. Cancel Appointment");
    print("4. Update Appointment status");
    print("0. Exit");
    print("********************************");
    stdout.write("Enter your choice: ");
  }

  /// BOOK APPOINTMENT FLOW
  void bookAppointmentFlow() {
    print("\n-- Book Appointment --\n");
    print("Is the patient:");
    print("1. Existing");
    print("2. New Patient");
    print("0. Return to Main Menu");
    stdout.write("Enter choice: ");

    String? input = stdin.readLineSync();
    if (input == null || input.isEmpty) return;

    int choice = int.parse(input);
    if (choice == 0) return;

    Patient? patient;

    if (choice == 1) {
      patient = findExistingPatient();
      if (patient == null) return;
    } else if (choice == 2) {
      patient = registerNewPatient();
      if (patient == null) return;
    } else {
      print("Invalid choice.");
      return;
    }

  // Booking date with past date validation
  DateTime? date;

  while (true) {
    stdout.write("Enter the date to book (yyyy-mm-dd): ");
    String? dateInput = stdin.readLineSync();

    if (dateInput == null || dateInput.isEmpty) return;

    try {
      date = DateTime.parse(dateInput);

      // Check if the date is before today
      DateTime today = DateTime.now();
      if (date.isBefore(DateTime(today.year, today.month, today.day))) {
        print("The date you entered is already past. Please enter a future date.\n");
        continue;
      }
      break; 
    } catch (e) {
      print("Invalid date format. Please use yyyy-mm-dd.\n");
    }
  }

    hospital.initializeSlotsForDate(date);

    // Doctor selection
    print("\nChoose doctor:");
    print("1. View all doctors");
    print("2. Get doctors by specialization");
    print("3. Search doctor");
    stdout.write("Enter choice: ");
    String? doctorChoiceInput = stdin.readLineSync();
    if (doctorChoiceInput == null || doctorChoiceInput.isEmpty) return;

    int doctorChoice = int.parse(doctorChoiceInput);
    List<Doctor>? selectedDoctors = [];

    switch (doctorChoice) {
      case 1:
        selectedDoctors = hospital.getAllDoctors();
        break;
      case 2:
  print("\nSelect Specialization:");
  for (int i = 0; i < Specialization.values.length; i++) {
    print("${i + 1}. ${Specialization.values[i].name}");
  }
  stdout.write("Enter choice: ");
  String? specChoiceInput = stdin.readLineSync();
  if (specChoiceInput == null || specChoiceInput.isEmpty) return;

  int specIndex;
  try {
    specIndex = int.parse(specChoiceInput) - 1;
  } catch (e) {
    print("Invalid input.");
    return;
  }

  if (specIndex < 0 || specIndex >= Specialization.values.length) {
    print("Invalid choice.");
    return;
  }

  var selectedSpec = Specialization.values[specIndex];
  selectedDoctors = hospital.getDoctorsBySpecialization(selectedSpec);
  break;

      case 3:
        stdout.write("Enter doctor name to search: ");
        String? nameInput = stdin.readLineSync();
        if (nameInput == null || nameInput.isEmpty) return;
        selectedDoctors = hospital.searchDoctor(name: nameInput);
        break;
      default:
        print("Invalid choice.");
        return;
    }

    // Show available slots
    Map<Doctor, List<BookingSlot>> availableSlotsMap = {};
    for (var doc in selectedDoctors) {
      var slots = hospital.getAvailableSlots(date, doc);
      if (slots.isNotEmpty) availableSlotsMap[doc] = slots;
    }

    if (availableSlotsMap.isEmpty) {
      print("No available slots for selected doctors.");
      return;
    }

    print("\nAvailable slots:");
    int counter = 1;
    Map<int, BookingSlot> slotMap = {};
    availableSlotsMap.forEach((doc, slots) {
      print("Doctor: ${doc.name} (${doc.specialization.name})");
      for (var slot in slots) {
        print("  [$counter] ${slot.shift.name} - ${slot.getTimeSlotLabel(slot.shift, slot.timeSlot)}");
        slotMap[counter] = slot;
        counter++;
      }
    });

    stdout.write("Select slot number to book: ");
    String? slotInput = stdin.readLineSync();
    if (slotInput == null || slotInput.isEmpty) return;
    int slotNum = int.parse(slotInput);

    if (!slotMap.containsKey(slotNum)) {
      print("Invalid slot.");
      return;
    }

    var selectedSlot = slotMap[slotNum];
    var appointment = Appointment(patient: patient, doctor: selectedSlot!.doctor, slot: selectedSlot);
    hospital.bookAppointment(appointment);

    repository.writeAppointments(hospital);
  }

  /// FIND EXISTING PATIENT
  Patient? findExistingPatient() {
    hospital.patients = repository.patientRepo.readPatients();

    stdout.write("Enter patient name: ");
    String? name = stdin.readLineSync();

    stdout.write("Enter phone number: ");
    String? phone = stdin.readLineSync();

    if (name == null || phone == null || name.isEmpty || phone.isEmpty) {
      print("Invalid input.");
      return null;
    }

    var patient = hospital.findPatientByNamePhone(name, phone);
    if (patient == null) {
      print("Patient not found.");
    }
    return patient;
  }

  /// REGISTER NEW PATIENT
  Patient? registerNewPatient() {
    stdout.write("Enter patient name: ");
    String? name = stdin.readLineSync();
    stdout.write("Enter date of birth (yyyy-mm-dd): ");
    String? dobInput = stdin.readLineSync();
    if (name == null || dobInput == null) return null;

    DateTime dob;
    try {
      dob = DateTime.parse(dobInput);
    } catch (e) {
      print("Invalid date format.");
      return null;
    }

    stdout.write("Enter Gender: ");
    String? genderInput = stdin.readLineSync();

    Gender gender;
    String normalized = (genderInput ?? '').toLowerCase().trim();
    
    if (normalized.startsWith('m')) {
        gender = Gender.male;
    } else if (normalized.startsWith('f')) {
        gender = Gender.female;
    } else {
        gender = Gender.preferNotToSay;
    }

    Guardian? guardian;
    String? phone;
    final age = DateTime.now().year - dob.year;

    if (age < 18) {
      print("Patient is under 18. Enter guardian information.");
      stdout.write("Guardian name: ");
      String? gName = stdin.readLineSync();
      stdout.write("Guardian phone: ");
      String? gPhone = stdin.readLineSync();
      stdout.write("Guardian relation: ");
      String? gRelation = stdin.readLineSync();
      if (gName == null || gPhone == null || gRelation == null) return null;

      try {
        guardian = Guardian(
          name: gName,
          phone: gPhone,
          relation: Relation.values.firstWhere(
            (r) => r.toString().split('.').last == gRelation,
            orElse: () => Relation.other,
          ),
        );
      } catch (e) {
        guardian = Guardian(name: gName, phone: gPhone, relation: Relation.other);
      }
      phone = guardian.phone;
    } else {
      stdout.write("Enter phone number: ");
      phone = stdin.readLineSync() ?? '';
    }

    List<Patient> existingPatients = repository.patientRepo.readPatients();

    bool alreadyExists = existingPatients.any(
      (p) =>
          p.name.toLowerCase() == name.toLowerCase() &&
          p.phoneNumber == phone &&
          p.dob.year == dob.year &&
          p.dob.month == dob.month &&
          p.dob.day == dob.day 
    );

    if (alreadyExists) {
      var existingPatient = existingPatients.firstWhere(
        (p) =>
            p.name.toLowerCase() == name.toLowerCase() &&
            p.phoneNumber == phone,
      );

      print("\nPatient already registered.");
      print("Name: ${existingPatient.name}");
      print("Phone: ${existingPatient.phoneNumber}");
      print("DOB: ${existingPatient.dob.toIso8601String().split('T').first}");

      stdout.write("\nUse this existing patient? (y/n): ");
      String? choice = stdin.readLineSync();

      if (choice != null && choice.toLowerCase() == 'y') {
        return existingPatient; 
      } else {
        print("Returning to patient menu...");
        return null;
      }
    }

    // If not exist
    var newPatient = Patient(
      name: name,
      gender: gender,
      dob: dob,
      phoneNumber: phone,
      guardian: guardian,
    );

    hospital.registerPatient(newPatient);
    existingPatients.add(newPatient);
    repository.patientRepo.writePatients(existingPatients);
    hospital.patients = existingPatients;
    print("New patient registered successfully!");
    return newPatient;
  }


  // view appointments
  void viewAppointmentsFlow() {
    hospital = repository.readAppointments(hospital.doctors);
    while (true) {
      print("\n-- View Appointments --");
      print("1. View All Appointments");
      print("2. Search by Patient Name");
      print("0. Return to Main Menu");
      stdout.write("Enter choice: ");
      String? choice = stdin.readLineSync();
      if (choice == '0') return;

      List<Appointment> listToShow = [];
      if (choice == '1'){ 
        listToShow = hospital.appointments;
      }
      else if (choice == '2') {
        stdout.write("Enter Patient Name (or part of name): ");
        String name = stdin.readLineSync() ?? "";
        stdout.write("Enter Phone Number (Patient or Guardian): ");
        String phone = stdin.readLineSync() ?? "";
        
        if (name.isEmpty || phone.isEmpty) {
            print("Name and phone number cannot be empty.");
            continue; 
        }
        listToShow = hospital.searchAppointmentsByPatientDetails(name, phone); 
      } 
      else {
        print("Invalid choice.");
        continue;
      }

      if (listToShow.isEmpty) {
        print("No appointments found.");
        continue;
      }

      print("\nAppointments:");
      for (int i = 0; i < listToShow.length; i++) {
        var a = listToShow[i];
        print(
            "${i + 1}. Dr. ${a.slot.doctor.name} | ${a.slot.date.toIso8601String().split('T').first} | ${a.patient.name} | ${a.slot.shift.name}-${a.slot.timeSlot.name} | Status: ${a.status.name}");
      }
      stdout.write("\nPress Enter to return to the main menu...");
      stdin.readLineSync();
      break;
    }
  }

  /// CANCEL APPOINTMENT
  void cancelAppointmentFlow() {
    hospital = repository.readAppointments(hospital.doctors);
    while (true) {
      print("\n-- Cancel Appointment --");
      print("1. View All Appointments");
      print("2. Search by Patient Name");
      print("0. Return to Main Menu");
      stdout.write("Enter choice: ");
      String? choice = stdin.readLineSync();
      if (choice == '0') return;

      List<Appointment> listToShow = [];
      if (choice == '1'){ 
        listToShow = hospital.appointments;
      }
      else if (choice == '2') {
        stdout.write("Enter Patient Name (or part of name): ");
        String name = stdin.readLineSync() ?? "";
        stdout.write("Enter Phone Number (Patient or Guardian): ");
        String phone = stdin.readLineSync() ?? "";
        
        if (name.isEmpty || phone.isEmpty) {
            print("Name and phone number cannot be empty.");
            continue; 
        }
        listToShow = hospital.searchAppointmentsByPatientDetails(name, phone); 
      } else {
        print("Invalid choice.");
        continue;
      }

      if (listToShow.isEmpty) {
        print("No appointments found.");
        continue;
      }

      for (int i = 0; i < listToShow.length; i++) {
        var a = listToShow[i];
        print(
            "${i + 1}. Dr. ${a.slot.doctor.name} | ${a.slot.date.toIso8601String().split('T').first} | ${a.patient.name} | ${a.slot.shift.name}-${a.slot.timeSlot.name} | Status: ${a.status.name}");
      }

      stdout.write("\nEnter number to cancel or 0 to return: ");
      String? input = stdin.readLineSync();
      if (input == '0') return;

      int idx;
      try {
        idx = int.parse(input!) - 1;
      } catch (e) {
        print("Invalid input.");
        continue;
      }

      if (idx < 0 || idx >= listToShow.length) {
        print("Invalid number.");
        continue;
      }

      hospital.cancelAppointment(listToShow[idx].appointmentId);
      repository.writeAppointments(hospital);
      break;
    }
  }

  /// UPDATE APPOINTMENT
  void updateAppointmentFlow() {
    hospital = repository.readAppointments(hospital.doctors);
    while (true) {
      print("\n-- Update Appointment Status --");
      print("1. View All Appointments");
      print("2. Search by Patient Name");
      print("0. Return to Main Menu");
      stdout.write("Enter choice: ");
      String? choice = stdin.readLineSync();
      if (choice == '0') return;

      List<Appointment> listToShow = [];
      if (choice == '1'){ 
        listToShow = hospital.appointments;
      }
      else if (choice == '2') {
        stdout.write("Enter Patient Name (or part of name): ");
        String name = stdin.readLineSync() ?? "";
        stdout.write("Enter Phone Number (Patient or Guardian): ");
        String phone = stdin.readLineSync() ?? "";
        
        if (name.isEmpty || phone.isEmpty) {
            print("Name and phone number cannot be empty.");
            continue; 
        }
        listToShow = hospital.searchAppointmentsByPatientDetails(name, phone); 
      } else {
        print("Invalid choice.");
        continue;
      }

      if (listToShow.isEmpty) {
        print("No appointments found.");
        continue;
      }

      for (int i = 0; i < listToShow.length; i++) {
        var a = listToShow[i];
        print(
            "${i + 1}. Dr. ${a.slot.doctor.name} | ${a.slot.date.toIso8601String().split('T').first} | ${a.patient.name} | ${a.slot.shift.name}-${a.slot.timeSlot.name} | Status: ${a.status.name}");
      }

      stdout.write("\nEnter number to update or 0 to return: ");
      String? input = stdin.readLineSync();
      if (input == '0') return;

      int idx;
      try {
        idx = int.parse(input!) - 1;
      } catch (e) {
        print("Invalid input.");
        continue;
      }

      if (idx < 0 || idx >= listToShow.length) {
        print("Invalid number.");
        continue;
      }

      var appt = listToShow[idx];

      print("\nChoose new status:");
      for (var s in Status.values){ 
        print("${s.index}. ${s.name}");
      }
      stdout.write("Enter number: ");
      String? statusInput = stdin.readLineSync();
      if (statusInput == null) return;
      int statusIndex;
      try {
        statusIndex = int.parse(statusInput);
      } catch (e) {
        print("Invalid input.");
        continue;
      }

      if (statusIndex < 0 || statusIndex >= Status.values.length) {
        print("Invalid choice.");
        continue;
      }

      hospital.changeAppointmentStatus(appt, Status.values[statusIndex]);
      repository.writeAppointments(hospital);
      print("Appointment updated successfully!");
      break;
    }
  }
}