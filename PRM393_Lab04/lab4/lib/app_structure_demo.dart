import 'package:flutter/material.dart';

class AppStructureDemo extends StatefulWidget {
  const AppStructureDemo({super.key});

  @override
  State<AppStructureDemo> createState() => _AppStructureDemoState();
}

class _AppStructureDemoState extends State<AppStructureDemo> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Exercise 4: App Structure',
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFFAFAFA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFAFAFA),
          foregroundColor: Colors.black,
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      themeMode: _themeMode,
      home: Exercise4Screen(
        toggleTheme: _toggleTheme,
        isDarkMode: _themeMode == ThemeMode.dark,
      ),
    );
  }
}

class Exercise4Screen extends StatelessWidget {
  final Function(bool) toggleTheme;
  final bool isDarkMode;

  const Exercise4Screen({
    super.key,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
          },
        ),
        titleSpacing: 0,
        title: const Text(
          'Exercise 4 – App Structure',
          style: TextStyle(fontSize: 20),
        ),
        actions: [
          Center(
            child: Text(
              'Dark',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ),
          Switch(
            value: isDarkMode,
            onChanged: toggleTheme,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: Text(
          'This is a simple screen with theme toggle.',
          style: TextStyle(
            fontSize: 16,
            // Sử dụng màu tương thích với theme hiện tại
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
