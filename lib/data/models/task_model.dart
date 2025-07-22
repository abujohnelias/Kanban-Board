import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'task_model.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final List<String> attachments;

  @HiveField(4)
  final String status;

  @HiveField(5)
  final String assignedTo;

  @HiveField(6)
  final String updatedBy;

  @HiveField(7)
  final DateTime updatedAt;

  Task({
    this.id = '',
    required this.title,
    required this.description,
    this.attachments = const [],
    this.status = 'todo',
    required this.assignedTo,
    required this.updatedBy,
    required this.updatedAt,
  });


  Task copyWith({
    String? id,
    String? title,
    String? description,
    List<String>? attachments,
    String? status,
    String? assignedTo,
    String? updatedBy,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      attachments: attachments ?? this.attachments,
      status: status ?? this.status,
      assignedTo: assignedTo ?? this.assignedTo,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'attachments': attachments,
      'status': status,
      'assignedTo': assignedTo,
      'updatedBy': updatedBy,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }


  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      attachments: List<String>.from(json['attachments'] ?? []),
      status: json['status'] ?? 'todo',
      assignedTo: json['assignedTo'] ?? '',
      updatedBy: json['updatedBy'] ?? '',
      updatedAt: (json['updatedAt'] is Timestamp)
          ? (json['updatedAt'] as Timestamp).toDate()
          : DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
                DateTime.now(),
    );
  }
}
