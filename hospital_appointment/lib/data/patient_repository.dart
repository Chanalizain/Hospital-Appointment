import 'dart:convert';
import 'dart:io';
import '../domain/patient.dart';
import '../domain/person.dart';
import '../domain/guardian.dart';

class PatientRepository {
  final String filePath;

  PatientRepository(this.filePath);

  List<Patient> readPatients() {
    final file = File(filePath);
    if (!file.existsSync()) return [];

    final content = file.readAsStringSync();
    if (content.trim().isEmpty) return [];

    final data = jsonDecode(content) as List;

    return data.map((p) {
      Guardian? guardian;
      if (p['guardian'] != null) {
        var g = p['guardian'];
        guardian = Guardian(
          name: g['name'],
          phone: g['phone'],
          relation: Relation.values.firstWhere(
            (r) => r.toString() == g['relation'],
            orElse: () => Relation.other,
          ),
        );
      }

      return Patient(
        patientId: p['patientId'],
        name: p['name'],
        gender: Gender.values.firstWhere(
          (g) => g.name == p['gender'],
          orElse: () => Gender.preferNotToSay,
        ),
        dob: DateTime.parse(p['dob']),
        phoneNumber: p['phoneNumber'],
        guardian: guardian,
      );
    }).toList();
  }

  /// Write patients list to JSON file
  void writePatients(List<Patient> patients) {
  final List<Map<String, dynamic>> data = patients.map((p) {
    final Map<String, dynamic> patientData = {
      'patientId': p.patientId,
      'name': p.name,
      'gender': p.gender.name,
      'dob': p.dob.toIso8601String(),
      'phoneNumber': p.phoneNumber,
    };

    if (p.guardian != null) {
      patientData['guardian'] = {
        'name': p.guardian!.name,
        'phone': p.guardian!.phone,
        'relation': p.guardian!.relation.toString(),
      };
    }

    return patientData;
  }).toList();

  final jsonString = JsonEncoder.withIndent('  ').convert(data);
  final file = File(filePath);
  file.writeAsStringSync(jsonString);
}

}
