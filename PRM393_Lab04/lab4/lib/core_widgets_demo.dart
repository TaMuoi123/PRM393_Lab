import 'package:flutter/material.dart';

class CoreWidgetsDemo extends StatelessWidget {
  const CoreWidgetsDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: const Color(0xFFF9F9FB),
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text('Exercise 1 – Core Widge...'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Headline Text
            const Text(
              'Welcome to Flutter UI',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 32),
            
            // Icon
            const Center(
              child: Icon(
                Icons.movie, // Tương tự biểu tượng clapperboard
                size: 80,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 32),
            
            // Image
            Image.network(
              'https://picsum.photos/seed/highway/600/300', // Hình ảnh minh họa
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 24),
            
            // Card chứa ListTile
            Card(
              elevation: 0,
              color: const Color(0xFFF5F5FA),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade300, width: 0.5),
              ),
              child: const ListTile(
                leading: Icon(Icons.star, color: Colors.black54),
                title: Text('Movie Item', style: TextStyle(color: Colors.black87)),
                subtitle: Text('This is a sample ListTile inside a Card.'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
