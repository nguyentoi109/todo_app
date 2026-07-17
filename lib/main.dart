import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/screens/home/home_screen.dart';
import 'package:todo_app/screens/task/add_task_screen.dart';
import 'package:todo_app/screens/task/edit_task_screen.dart';
import 'package:todo_app/screens/task/task_detail_screen.dart';
import 'package:todo_app/screens/task/task_list_screen.dart';

import 'providers/auth_provider.dart';
import 'providers/task_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => TaskProvider(),
        ),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: HomeScreen(),
      ),
    ),
  );
}