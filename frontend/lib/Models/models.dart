class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final List<Clocking>? clockings;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.clockings,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'] ?? 'employee',
      clockings: json['clockings'] != null 
          ? (json['clockings'] as List).map((e) => Clocking.fromJson(e)).toList() 
          : null,
    );
  }
}

class Clocking {
  final String id;
  final String type;
  final String method;
  final DateTime clockTime;
  final double? latitude;
  final double? longitude;

  Clocking({
    required this.id,
    required this.type,
    required this.method,
    required this.clockTime,
    this.latitude,
    this.longitude,
  });

  factory Clocking.fromJson(Map<String, dynamic> json) {
    return Clocking(
      id: json['id'],
      type: json['type'],
      method: json['method'],
      clockTime: DateTime.parse(json['clock_time']),
      latitude: json['latitude'] != null ? double.parse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.parse(json['longitude'].toString()) : null,
    );
  }
}

class Task {
  final String id;
  final String title;
  final String description;
  final String status;
  final DateTime? dueDate;
  final String createdAt;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    this.dueDate,
    required this.createdAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      status: json['status'],
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date']) : null,
      createdAt: json['created_at'] ?? DateTime.now().toIso8601String(),
    );
  }
}

class Schedule {
  final String id;
  final String startTime;
  final String endTime;
  final String dayOfWeek;
  final String status;

  Schedule({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.dayOfWeek,
    required this.status,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      dayOfWeek: json['day_of_week'].toString(),
      status: json['status'],
    );
  }
}
class UserStats {
  final String status;
  final double hoursToday;
  final int tasksCompleted;
  final int totalTasks;

  UserStats({
    required this.status,
    required this.hoursToday,
    required this.tasksCompleted,
    required this.totalTasks,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      status: json['status'],
      hoursToday: double.parse(json['hours_today'].toString()),
      tasksCompleted: json['tasks_completed'],
      totalTasks: json['total_tasks'],
    );
  }
}
