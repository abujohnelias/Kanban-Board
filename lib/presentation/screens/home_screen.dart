import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kanban_board_app/blocs/kanban_bloc/kanban_bloc.dart';
import 'package:kanban_board_app/blocs/kanban_bloc/kanban_event.dart';
import 'package:kanban_board_app/blocs/kanban_bloc/kanban_state.dart';
import 'package:kanban_board_app/data/models/task_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:kanban_board_app/presentation/widgets/loading_placeholder.dart';
import 'package:kanban_board_app/presentation/widgets/task_column.dart';
import 'package:kanban_board_app/utils/const/color_const.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeView();
  }
}

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  Task? draggedTask;

  @override
  void initState() {
    super.initState();
    context.read<KanbanBloc>().add(LoadTasks());
    checkInternet();
  }

  void checkInternet() async {
    final result = await Connectivity().checkConnectivity();
    log("[DEBUG] Connectivity result: $result");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConst.scaffoldColor,
      appBar: AppBar(elevation: 0, backgroundColor: ColorConst.scaffoldColor),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context),
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<KanbanBloc, KanbanState>(
        builder: (context, state) {
          if (state.isLoading) {
            return LoadingPlaceholder();
          }
          final noTasks =
              state.todo.isEmpty &&
              state.inProgress.isEmpty &&
              state.done.isEmpty;

          if (noTasks) {
            return const Center(
              child: Text(
                "If you've already created tasks, they will show here when internet comes.",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            );
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Row(
              spacing: 6,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TaskColumn(
                    title: "To Do",
                    color: ColorConst.todoColor,
                    tasks: state.todo,
                    targetColumn: "todo",
                    onEdit: (task) => _showEditTaskDialog(context, task),
                  ),
                ),

                Expanded(
                  child: TaskColumn(
                    title: "In Progress",
                    color: ColorConst.progressColor,
                    tasks: state.inProgress,
                    targetColumn: "inProgress",
                    onEdit: (task) => _showEditTaskDialog(context, task),
                  ),
                ),

                Expanded(
                  child: TaskColumn(
                    title: "Done",
                    color: ColorConst.doneColor,
                    tasks: state.done,
                    targetColumn: "done",
                    onEdit: (task) => _showEditTaskDialog(context, task),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    List<String> attachments = [];

    void pickAttachment() async {
      final result = await FilePicker.platform.pickFiles();
      if (result != null && result.files.single.path != null) {
        setState(() {
          attachments.add(result.files.single.path!);
        });
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Add New Task"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      hintText: "Enter task title",
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(
                      hintText: "Enter description",
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: pickAttachment,
                    icon: const Icon(Icons.attach_file),
                    label: const Text("Add Attachment"),
                  ),
                  if (attachments.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      children: attachments
                          .map(
                            (path) => Chip(label: Text(path.split('/').last)),
                          )
                          .toList(),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    final title = titleController.text.trim();
                    final desc = descController.text.trim();
                    if (title.isNotEmpty && desc.isNotEmpty) {
                      context.read<KanbanBloc>().add(
                        AddTask(
                          title: title,
                          description: desc,
                          attachments: attachments,
                        ),
                      );
                    }
                    Navigator.pop(context);
                  },
                  child: const Text("Add"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditTaskDialog(BuildContext context, Task task) {
    final titleController = TextEditingController(text: task.title);
    final descController = TextEditingController(text: task.description);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Task"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(hintText: "Enter new title"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  hintText: "Enter new description",
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                final newTitle = titleController.text.trim();
                final newDesc = descController.text.trim();
                if (newTitle.isNotEmpty && newDesc.isNotEmpty) {
                  context.read<KanbanBloc>().add(
                    EditTask(
                      oldTask: task,
                      newTitle: newTitle,
                      newDescription: newDesc,
                    ),
                  );
                }
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }
}
