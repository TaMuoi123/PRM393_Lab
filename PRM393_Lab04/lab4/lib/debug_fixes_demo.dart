import 'package:flutter/material.dart';

class DebugFixesDemo extends StatefulWidget {
  const DebugFixesDemo({super.key});

  @override
  State<DebugFixesDemo> createState() => _DebugFixesDemoState();
}

class _DebugFixesDemoState extends State<DebugFixesDemo> {
  int _counter = 0;

  void _increment() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<String> movies = ['Movie A', 'Movie B', 'Movie C', 'Movie D'];

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: const Color(0xFFF9F9FB),
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text('Exercise 5 – Common U...'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Correct ListView inside Column using Expanded',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          
          // FIX: ListView inside Column using Expanded
          Expanded(
            child: ListView.builder(
              itemCount: movies.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.movie, color: Color(0xFF4A4A5A)),
                  title: Text(movies[index], style: const TextStyle(fontSize: 16, color: Colors.black87)),
                );
              },
            ),
          ),

          const Divider(),

          // The other fixes are placed here at the bottom so they don't interfere with the image match
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text('Other Fixes:', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          
          // FIX: SingleChildScrollView for overflow
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                10,
                (index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Chip(label: Text('Item $index')),
                ),
              ),
            ),
          ),
          
          // FIX: State Update & DatePicker
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _increment,
                  child: Text('Counter: $_counter'),
                ),
                Builder(
                  builder: (ctx) => ElevatedButton(
                    onPressed: () async {
                      await showDatePicker(
                        context: ctx,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                    },
                    child: const Text('Picker'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
