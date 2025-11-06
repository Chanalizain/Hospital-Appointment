enum Gender{ female, male, preferNotToSay}

abstract class Person {
  final String _name;
  final Gender _gender;
  final DateTime _dob;
  final String _phoneNumber;

  Person({required String name, required Gender gender, required DateTime dob, required String phoneNumber,})  
    : _name = name,
      _gender = gender,
      _dob = dob,
      _phoneNumber = phoneNumber;

  // Getters
  String get name => _name;
  Gender get gender => _gender;
  DateTime get dob => _dob;
  String get phoneNumber => _phoneNumber;

  int get age {
    DateTime today = DateTime.now();
    int age = today.year - _dob.year;

    if (today.month < _dob.month || (today.month == _dob.month && today.day < _dob.day)) {
      age--;
    }
    return age;
  }
}