class Schedule {
  DateTime startTime;
  DateTime endTime;
  bool isBooked;

  Schedule({required this.startTime, required this.endTime, this.isBooked = false});
}