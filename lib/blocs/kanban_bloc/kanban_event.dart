import 'package:kanban_board_app/data/models/task_model.dart';

abstract class KanbanEvent {}



class LoadTasks extends KanbanEvent {}

class MoveTask extends KanbanEvent {
  final Task task;
  final String targetColumn;

  MoveTask({required this.task, required this.targetColumn});
}

class AddTask extends KanbanEvent {
  final String title;
  final String description;
  final List<String> attachments;

  AddTask({
    required this.title,
    required this.description,
    this.attachments = const [],
  });
}

class EditTask extends KanbanEvent {
  final Task oldTask;
  final String newTitle;
  final String newDescription;

  EditTask({
    required this.oldTask,
    required this.newTitle,
    required this.newDescription,
  });
}
