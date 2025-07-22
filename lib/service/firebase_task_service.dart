import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as fb_storage;
import 'package:kanban_board_app/data/models/task_model.dart' as app_model;
import 'dart:developer';

class FirebaseTaskService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final fb_storage.FirebaseStorage storage =
      fb_storage.FirebaseStorage.instance;

  Future<void> saveTask(app_model.Task task) async {
    try {
      final docId = task.id ?? firestore.collection('tasks').doc().id;
      await firestore.collection('tasks').doc(docId).set(task.toJson());
      log("[FirebaseTaskService] Task saved with ID: $docId");
    } catch (e) {
      log("[FirebaseTaskService] ERROR saving task -> $e");
      rethrow;
    }
  }

  Future<List<app_model.Task>> fetchTasks() async {
    try {
      final querySnapshot = await firestore.collection('tasks').get();
      return querySnapshot.docs
          .map((doc) => app_model.Task.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      log("[FirebaseTaskService] ERROR fetching tasks -> $e");
      return [];
    }
  }

  Future<void> syncTask(app_model.Task task) async {
    try {
      final docId = task.id ?? firestore.collection('tasks').doc().id;
      final docRef = firestore.collection('tasks').doc(docId);

      final doc = await docRef.get();

      if (doc.exists) {
        final remoteTask = app_model.Task.fromJson({
          ...doc.data()!,
          'id': doc.id,
        });
        if (remoteTask.updatedAt.isBefore(task.updatedAt)) {
          await docRef.set(task.toJson());
          log(
            "[FirebaseTaskService] Task updated remotely (conflict resolved).",
          );
        } else {
          log("[FirebaseTaskService] Remote task is newer, skipping sync.");
        }
      } else {
        await docRef.set(task.toJson());
        log("[FirebaseTaskService] New task synced to Firestore.");
      }
    } catch (e) {
      log("[FirebaseTaskService] ERROR syncing task -> $e");
    }
  }

  Future<void> updateTask(app_model.Task task) async {
    if (task.id == null) {
      log("[FirebaseTaskService] ERROR: Cannot update task without ID.");
      return;
    }
    try {
      await firestore.collection('tasks').doc(task.id).update(task.toJson());
      log("[FirebaseTaskService] Task updated with ID: ${task.id}");
    } catch (e) {
      log("[FirebaseTaskService] ERROR updating task -> $e");
    }
  }
}
