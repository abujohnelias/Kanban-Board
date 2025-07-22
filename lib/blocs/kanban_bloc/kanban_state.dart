import 'package:kanban_board_app/data/models/task_model.dart';

class KanbanState {
  final List<Task> todo;
  final List<Task> inProgress;
  final List<Task> done;
  final bool isLoading;

  KanbanState({
    this.todo = const [],
    this.inProgress = const [],
    this.done = const [],
    this.isLoading = false,
  });

  KanbanState copyWith({
    List<Task>? todo,
    List<Task>? inProgress,
    List<Task>? done,
    bool? isLoading,
  }) {
    return KanbanState(
      todo: todo ?? this.todo,
      inProgress: inProgress ?? this.inProgress,
      done: done ?? this.done,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
