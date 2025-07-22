import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:kanban_board_app/app_providers.dart';
import 'package:kanban_board_app/data/models/task_model.dart';
import 'package:kanban_board_app/firebase_options.dart';
import 'package:kanban_board_app/presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initializing Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  log("Firebase initialized successfully!", name: "MAIN");

  // Initializing Hive
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  await Hive.openBox<Task>('tasks');
  log("Hive initialized successfully!", name: "MAIN");

  runApp(const MyApp());
  log("Flutter App Started Successfully!", name: "MAIN");
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: AppBlocProviders.providers,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Kanban Board App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: const Color(0xfff0f0f0),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
