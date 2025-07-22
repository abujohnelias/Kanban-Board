import 'package:flutter/material.dart';
import 'package:kanban_board_app/data/models/task_model.dart';
import 'package:kanban_board_app/utils/const/color_const.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final Function(Task) onEdit;

  const TaskTile({super.key, required this.task, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        onTap: () => _showTaskDetailsDialog(context, task),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              task.description,
              style: TextStyle(color: ColorConst.black, fontSize: 14),
            ),
            if (task.attachments.isNotEmpty) ...[
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: -6,
                children: task.attachments
                    .map(
                      (attachment) => Chip(
                        label: Text(
                          attachment.split('/').last,
                          style: const TextStyle(fontSize: 12),
                        ),
                        avatar: const Icon(Icons.attachment, size: 16),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
        trailing: GestureDetector(
          onTap: () => onEdit(task),
          child: const Icon(Icons.edit, size: 20),
        ),
        contentPadding: const EdgeInsets.all(8.0),
      ),
    );
  }

  void _showTaskDetailsDialog(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(task.title),
          content: SingleChildScrollView(
            child: Column(
              spacing: 8,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Description: ${task.description}"),

                Text("Status: ${task.status}"),

                Text("Assigned To: ${task.assignedTo}"),

                Text("Updated By: ${task.updatedBy}"),

                Text("Updated At: ${task.updatedAt}"),
                if (task.attachments.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  const Text("Attachments:"),
                  ...task.attachments.map((file) => Text("• $file")),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }
}
