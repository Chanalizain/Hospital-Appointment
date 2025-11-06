enum Gender{ female, male, preferNotToSay}

abstract class Person {
  String name;
  Gender gender;
  DateTime dob;
  String phoneNumber;

  Person({required this.name, required this.gender, required this.dob, required this.phoneNumber});


  void displayInfo() {
    print('Name: $name');
    print('Gender: $gender');
    print('Date of Birth: ${dob.toLocal()}');
    print('Phone Number: $phoneNumber');
  }

  int get age {
    DateTime today = DateTime.now();
    int age = today.year - dob.year;

    if (today.month < dob.month || (today.month == dob.month && today.day < dob.day)) {
      age--;
    }
    return age;
  }
}