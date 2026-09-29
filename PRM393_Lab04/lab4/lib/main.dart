import 'package:flutter/material.dart';
import 'core_widgets_demo.dart';
import 'input_controls_demo.dart';
import 'layout_basics_demo.dart';
import 'app_structure_demo.dart';
import 'debug_fixes_demo.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lab 4 - Flutter UI Fundamentals',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF9F9FB),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF9F9FB),
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        primarySwatch: Colors.indigo,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  Widget _buildMenuButton(BuildContext context, String title, Widget page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5FA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300, width: 0.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.black54),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: const Padding(
          padding: EdgeInsets.only(left: 16.0),
          child: Text('Lab 4 – Flutter UI Fundament...'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 8.0),
        children: [
          _buildMenuButton(context, 'Exercise 1 – Core Widgets Demo', const CoreWidgetsDemo()),
          _buildMenuButton(context, 'Exercise 2 – Input Controls Demo', const InputControlsDemo()),
          _buildMenuButton(context, 'Exercise 3 – Layout Demo', const LayoutBasicsDemo()),
          _buildMenuButton(context, 'Exercise 4 – App Structure & Theme', const AppStructureDemo()),
          _buildMenuButton(context, 'Exercise 5 – Common UI Fixes', const DebugFixesDemo()),
        ],
      ),
    );
  }
}
