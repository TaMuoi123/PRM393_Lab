// LAB 8: Building an API-powered List Screen (Flutter + REST API)
// DARTPAD STANDALONE VERSION - Copy & Paste directly into https://dartpad.dev (Flutter)

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

// ==========================================
// 1. DATA MODEL (Lab 8.2)
// ==========================================
class Post {
  final int userId;
  final int id;
  final String title;
  final String body;

  const Post({
    required this.userId,
    required this.id,
    required this.title,
    required this.body,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      userId: json['userId'] as int? ?? 0,
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'id': id,
      'title': title,
      'body': body,
    };
  }
}

// ==========================================
// 2. API SERVICE LAYER (Lab 8.1 & Lab 8.4)
// ==========================================
class ApiService {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Post>> fetchPosts({bool simulateError = false}) async {
    if (simulateError) {
      await Future.delayed(const Duration(milliseconds: 500));
      throw Exception('Mô phỏng lỗi kết nối mạng (Lab 8.3 Error State)');
    }

    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/posts'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((json) => Post.fromJson(json)).toList();
      } else {
        throw Exception('Lỗi máy chủ: Mã trạng thái ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi tải dữ liệu: $e');
    }
  }

  Future<Post> createPost({required String title, required String body}) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/posts'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: json.encode({'title': title, 'body': body, 'userId': 1}),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return Post.fromJson(json.decode(response.body));
    } else {
      throw Exception('Tạo bài viết thất bại: ${response.statusCode}');
    }
  }
}

// ==========================================
// 3. MAIN APP
// ==========================================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab 8 - API List Screen',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: const PostListScreen(),
    );
  }
}

// ==========================================
// 4. POST LIST SCREEN (Lab 8.2, 8.3, 8.4)
// ==========================================
class PostListScreen extends StatefulWidget {
  const PostListScreen({super.key});

  @override
  State<PostListScreen> createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Post>> _postsFuture;
  bool _simulateError = false;
  final List<Post> _localPosts = [];

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  void _loadPosts() {
    setState(() {
      _postsFuture = _apiService.fetchPosts(simulateError: _simulateError);
    });
  }

  Future<void> _refresh() async {
    _loadPosts();
    await _postsFuture.catchError((_) => <Post>[]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Posts List'),
        actions: [
          IconButton(
            tooltip: 'Mô phỏng lỗi (Lab 8.3)',
            icon: Icon(
              _simulateError ? Icons.error : Icons.bug_report_outlined,
              color: _simulateError ? Colors.amber : null,
            ),
            onPressed: () {
              setState(() {
                _simulateError = !_simulateError;
              });
              _loadPosts();
            },
          ),
          IconButton(
            tooltip: 'Làm mới',
            icon: const Icon(Icons.refresh),
            onPressed: _loadPosts,
          ),
        ],
      ),
      body: FutureBuilder<List<Post>>(
        future: _postsFuture,
        builder: (context, snapshot) {
          // Lab 8.3: Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Đang tải danh sách bài viết từ API...'),
                ],
              ),
            );
          }

          // Lab 8.3: Error state
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Có lỗi xảy ra!',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.red),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _simulateError = false;
                        });
                        _loadPosts();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Thử lại (Retry)'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Lab 8.2: Data loaded state
          if (snapshot.hasData) {
            final allPosts = [..._localPosts, ...(snapshot.data ?? [])];
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: allPosts.length,
                itemBuilder: (context, index) {
                  final post = allPosts[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text('${post.id}'),
                      ),
                      title: Text(
                        post.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        post.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PostDetailScreen(post: post),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Thêm bài viết mới (POST)',
        child: const Icon(Icons.add),
        onPressed: () async {
          final newPost = await Navigator.push<Post>(
            context,
            MaterialPageRoute(
              builder: (context) => CreatePostScreen(apiService: _apiService),
            ),
          );
          if (newPost != null) {
            setState(() {
              _localPosts.insert(0, newPost);
            });
          }
        },
      ),
    );
  }
}

// ==========================================
// 5. POST DETAIL SCREEN (Bonus Enhancement)
// ==========================================
class PostDetailScreen extends StatelessWidget {
  final Post post;
  const PostDetailScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chi tiết bài #${post.id}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  post.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Divider(height: 24),
                Text(
                  post.body,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 6. CREATE POST SCREEN (Optional POST)
// ==========================================
class CreatePostScreen extends StatefulWidget {
  final ApiService apiService;
  const CreatePostScreen({super.key, required this.apiService});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thêm bài viết mới (POST)')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Tiêu đề (Title)'),
                validator: (v) => v == null || v.isEmpty ? 'Vui lòng nhập tiêu đề' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _bodyController,
                decoration: const InputDecoration(labelText: 'Nội dung (Body)'),
                maxLines: 4,
                validator: (v) => v == null || v.isEmpty ? 'Vui lòng nhập nội dung' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _isSubmitting
                    ? null
                    : () async {
                        if (!_formKey.currentState!.validate()) return;
                        setState(() => _isSubmitting = true);
                        try {
                          final post = await widget.apiService.createPost(
                            title: _titleController.text.trim(),
                            body: _bodyController.text.trim(),
                          );
                          if (context.mounted) Navigator.pop(context, post);
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Lỗi: $e')),
                            );
                          }
                        } finally {
                          if (context.mounted) setState(() => _isSubmitting = false);
                        }
                      },
                icon: _isSubmitting
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.send),
                label: const Text('Gửi POST'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
