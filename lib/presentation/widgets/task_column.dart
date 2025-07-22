import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kanban_board_app/data/models/task_model.dart';
import 'package:kanban_board_app/blocs/kanban_bloc/kanban_bloc.dart';
import 'package:kanban_board_app/blocs/kanban_bloc/kanban_event.dart';
import 'package:kanban_board_app/presentation/widgets/task_tile.dart';
import 'package:kanban_board_app/utils/const/color_const.dart';

class TaskColumn extends StatelessWidget {
  final String title;
  final Color color;
  final List<Task> tasks;
  final String targetColumn;
  final Function(Task) onEdit;

  const TaskColumn({
    super.key,
    required this.title,
    required this.color,
    required this.tasks,
    required this.targetColumn,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<Task>(
      onWillAccept: (task) => true,
      onAccept: (task) {
        context.read<KanbanBloc>().add(
          MoveTask(task: task, targetColumn: targetColumn),
        );
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              for (var task in tasks)
                LongPressDraggable<Task>(
                  data: task,
                  feedback: Material(
                    elevation: 6,
                    borderRadius: BorderRadius.circular(0),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minWidth: 200,
                        maxWidth: 250,
                      ),
                      child: TaskTile(task: task, onEdit: onEdit),
                    ),
                  ),
                  child: TaskTile(task: task, onEdit: onEdit),
                ),
              if (candidateData.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white30,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: ColorConst.black, width: 1),
                  ),
                  child: const Text(
                    "Drop here",
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
