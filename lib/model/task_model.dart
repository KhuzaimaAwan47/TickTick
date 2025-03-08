class Task {
  final String id;
  final int usrId;
  final String title;
  final String date;
  final String description;


  Task({
    required this.id,
    required this.usrId,
    required this.title,
    required this.date,
    required this.description,
});



  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      usrId: json['usrId'] as int,
      title: json['title'] ?? "No Title",
      date: json['date'] ?? 'none',
      description: json['description'] ?? 'No Description',
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'usrId': usrId,
      'title': title,
      'date': date,
      'description': description,
    };
  }

}
