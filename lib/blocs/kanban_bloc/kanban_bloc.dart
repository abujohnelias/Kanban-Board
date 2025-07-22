

import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:kanban_board_app/data/models/task_model.dart';
import 'package:kanban_board_app/service/firebase_task_service.dart';
import 'kanban_event.dart';
import 'kanban_state.dart';

class KanbanBloc extends Bloc<KanbanEvent, KanbanState> {
  final Box<Task> taskBox = Hive.box<Task>('tasks');
  final FirebaseTaskService _firebaseService = FirebaseTaskService();

  KanbanBloc() : super(KanbanState()) {
    on<LoadTasks>(_onLoadTasks);
    on<AddTask>(_onAddTask);
    on<EditTask>(_onEditTask);
    on<MoveTask>(_onMoveTask);
    add(LoadTasks());
  }

  
  void _onLoadTasks(LoadTasks event, Emitter<KanbanState> emit) async {
    emit(state.copyWith(isLoading: true));

    try {
      final tasks = await _firebaseService.fetchTasks();

      if (tasks.isNotEmpty) {
        final todo = tasks.where((task) => task.status == 'todo').toList();
        final inProgress =
            tasks.where((task) => task.status == 'inProgress').toList();
        final done = tasks.where((task) => task.status == 'done').toList();

        emit(KanbanState(todo: todo, inProgress: inProgress, done: done));
        log("[KanbanBloc] Loaded tasks from Firestore.");
      } else {
     
        final hiveTasks = taskBox.values.toList();
        if (hiveTasks.isNotEmpty) {
          final todo =
              hiveTasks.where((task) => task.status == 'todo').toList();
          final inProgress =
              hiveTasks.where((task) => task.status == 'inProgress').toList();
          final done =
              hiveTasks.where((task) => task.status == 'done').toList();

          emit(KanbanState(todo: todo, inProgress: inProgress, done: done));
          log("[KanbanBloc] Loaded tasks from Hive (offline).");
        } else {
          emit(KanbanState(todo: [], inProgress: [], done: []));
          log("[KanbanBloc] No internet and no local tasks.");
        }
      }
    } catch (e) {
      log("[KanbanBloc] Error loading tasks: $e");
      emit(KanbanState(todo: [], inProgress: [], done: []));
    }
  }

  void _onAddTask(AddTask event, Emitter<KanbanState> emit) async {
    final newTask = Task(
      title: event.title,
      description: event.description,
      attachments: event.attachments,
      status: "todo",
      assignedTo: "userId1",
      updatedBy: "userId1",
      updatedAt: DateTime.now(),
    );

    try {
      await taskBox.add(newTask);
      log("[KanbanBloc] Task saved locally in Hive.");
    } catch (e) {
      log("[KanbanBloc] ERROR: Failed to save task in Hive -> $e");
    }

    try {
      await _firebaseService.syncTask(newTask);
      log("[KanbanBloc] Task added to Firestore successfully.");
    } catch (e) {
      log("[KanbanBloc] ERROR: Failed to add task to Firestore -> $e");
    }

    emit(state.copyWith(todo: [...state.todo, newTask]));
  }

  void _onEditTask(EditTask event, Emitter<KanbanState> emit) async {
  final updatedTask = event.oldTask.copyWith(
    title: event.newTitle,
    description: event.newDescription,
    updatedAt: DateTime.now(),
    updatedBy: "userId1",
  );

  final key = taskBox.keys.firstWhere(
    (k) => taskBox.get(k) == event.oldTask,
    orElse: () => null,
  );

  if (key != null) {
    await taskBox.put(key, updatedTask);
    log("[Hive] Edited task locally: ${updatedTask.title}");
  }

 
  final hiveTasks = taskBox.values.toList();
  final todo = hiveTasks.where((task) => task.status == 'todo').toList();
  final inProgress = hiveTasks.where((task) => task.status == 'inProgress').toList();
  final done = hiveTasks.where((task) => task.status == 'done').toList();

  emit(KanbanState(
    todo: List<Task>.from(todo),
    inProgress: List<Task>.from(inProgress),
    done: List<Task>.from(done),
  ));
}



  
  void _onMoveTask(MoveTask event, Emitter<KanbanState> emit) async {
    final movedTask = event.task.copyWith(
      status: _getStatusLabel(event.targetColumn),
      updatedAt: DateTime.now(),
      updatedBy: "userId1",
    );

    final updatedTodo = List<Task>.from(state.todo)..remove(event.task);
    final updatedInProgress = List<Task>.from(state.inProgress)
      ..remove(event.task);
    final updatedDone = List<Task>.from(state.done)..remove(event.task);

    if (event.targetColumn == "todo") {
      updatedTodo.add(movedTask);
    } else if (event.targetColumn == "inProgress") {
      updatedInProgress.add(movedTask);
    } else if (event.targetColumn == "done") {
      updatedDone.add(movedTask);
    }

    final key = taskBox.keys.firstWhere(
      (k) => taskBox.get(k) == event.task,
      orElse: () => null,
    );
    if (key != null) await taskBox.put(key, movedTask);

    
    try {
      await _firebaseService.syncTask(movedTask);
      log("[KanbanBloc] Task moved and synced with Firestore.");
    } catch (e) {
      log("[KanbanBloc] ERROR syncing moved task -> $e");
    }

    emit(
      KanbanState(
        todo: updatedTodo,
        inProgress: updatedInProgress,
        done: updatedDone,
      ),
    );
  }

  List<Task> _replaceTaskInList(
      List<Task> tasks, Task oldTask, Task updatedTask) {
    return tasks.map((task) => task == oldTask ? updatedTask : task).toList();
  }

  String _getStatusLabel(String targetColumn) {
    switch (targetColumn) {
      case "inProgress":
        return "inProgress";
      case "done":
        return "done";
      default:
        return "todo";
    }
  }
}
