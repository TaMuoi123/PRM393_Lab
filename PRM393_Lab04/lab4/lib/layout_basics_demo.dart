import 'package:flutter/material.dart';

class LayoutBasicsDemo extends StatelessWidget {
  const LayoutBasicsDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> movies = [
      {'title': 'Avatar', 'desc': 'Sample description', 'initial': 'A'},
      {'title': 'Inception', 'desc': 'Sample description', 'initial': 'I'},
      {'title': 'Interstellar', 'desc': 'Sample description', 'initial': 'I'},
      {'title': 'Joker', 'desc': 'Sample description', 'initial': 'J'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: const Color(0xFFF9F9FB),
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text('Exercise 3 – Layout De...'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Now Playing',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: movies.length,
              itemBuilder: (context, index) {
                final movie = movies[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Card(
                    elevation: 0,
                    color: const Color(0xFFF5F5FA),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade300, width: 0.5),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFFE0E0FF),
                        child: Text(
                          movie['initial']!,
                          style: const TextStyle(color: Color(0xFF1E1E40), fontWeight: FontWeight.w500),
                        ),
                      ),
                      title: Text(
                        movie['title']!,
                        style: const TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                      subtitle: Text(
                        movie['desc']!,
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
