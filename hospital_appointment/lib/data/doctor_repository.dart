import 'dart:convert';
import 'dart:io';
import '../domain/doctor.dart';
import '../domain/person.dart'; 

class DoctorRepository {
  final String filePath;

  DoctorRepository(this.filePath);

  List<Doctor> readDoctors() {
    final file = File(filePath);
    if (!file.existsSync()) return [];

    final content = file.readAsStringSync();
    if (content.trim().isEmpty) return [];

    final data = jsonDecode(content);

    var doctorsJson = data as List;
    var doctors = doctorsJson.map((d) {
      return Doctor(
        doctorId: d['doctorId'],
        name: d['name'],
        gender: Gender.values.firstWhere(
          (g) => g.toString() == d['gender'],
          orElse: () => Gender.preferNotToSay,
        ),
        dob: DateTime.parse(d['dob']),
        phoneNumber: d['phoneNumber'],
        specialization: Specialization.values.firstWhere(
          (s) => s.toString() == d['specialization'],
          orElse: () => Specialization.generalPractice,
        ),
      );
    }).toList();

    return doctors;
  }

  void writeDoctors(List<Doctor> doctors) {
    final data = doctors.map((d) => {
      'doctorId': d.doctorId,
      'name': d.name,
      'gender': d.gender.toString(),
      'dob': d.dob.toIso8601String(),
      'phoneNumber': d.phoneNumber,
      'specialization': d.specialization.toString(),
    }).toList();

    final jsonString = JsonEncoder.withIndent('  ').convert(data);
    final file = File(filePath);
    file.writeAsStringSync(jsonString);
  }
}
