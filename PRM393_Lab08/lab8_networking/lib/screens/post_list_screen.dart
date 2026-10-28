import 'package:flutter/material.dart';
import '../models/post.dart';
import '../services/api_service.dart';
import 'create_post_screen.dart';
import 'post_detail_screen.dart';

/// Main screen displaying the list of posts fetched from the REST API.
/// Implements Lab 8.1, 8.2, 8.3, 8.4, and optional enhancements.
class PostListScreen extends StatefulWidget {
  final ApiService? apiService;

  const PostListScreen({super.key, this.apiService});

  @override
  State<PostListScreen> createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {
  late final ApiService _apiService;
  late Future<List<Post>> _postsFuture;

  // Toggle for demonstrating error state in Lab 8.3
  bool _simulateError = false;

  // Track any locally created posts so they appear immediately in the list
  final List<Post> _locallyCreatedPosts = [];

  @override
  void initState() {
    super.initState();
    _apiService = widget.apiService ?? ApiService();
    _loadPosts();
  }

  void _loadPosts() {
    setState(() {
      _postsFuture = _apiService.fetchPosts(simulateError: _simulateError);
    });
  }

  Future<void> _refreshPosts() async {
    // When pull-to-refresh is triggered
    setState(() {
      _postsFuture = _apiService.fetchPosts(simulateError: _simulateError);
    });
    await _postsFuture.catchError((_) => <Post>[]);
  }

  Future<void> _navigateToCreatePost() async {
    final newPost = await Navigator.push<Post>(
      context,
      MaterialPageRoute(
        builder: (context) => CreatePostScreen(apiService: _apiService),
      ),
    );

    if (newPost != null && mounted) {
      setState(() {
        _locallyCreatedPosts.insert(0, newPost);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã tạo thành công bài viết #${newPost.id}!'),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Xem',
            textColor: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PostDetailScreen(post: newPost),
                ),
              );
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('API Posts List'),
        centerTitle: true,
        actions: [
          // Button to toggle simulate error (Lab 8.3 demonstration)
          IconButton(
            tooltip: _simulateError
                ? 'Đang ở chế độ mô phỏng lỗi (Bấm để tắt)'
                : 'Mô phỏng lỗi kết nối (Lab 8.3)',
            icon: Icon(
              _simulateError ? Icons.error : Icons.bug_report_outlined,
              color: _simulateError ? Colors.amber : null,
            ),
            onPressed: () {
              setState(() {
                _simulateError = !_simulateError;
              });
              _loadPosts();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _simulateError
                        ? 'Đã bật mô phỏng lỗi kết nối (Lab 8.3)'
                        : 'Đã tắt mô phỏng lỗi (Tải lại bình thường)',
                  ),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
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
          // State 1: Loading State (ConnectionState.waiting)
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Đang tải danh sách bài viết từ API...',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'jsonplaceholder.typicode.com/posts',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // State 2: Error State (snapshot.hasError)
          if (snapshot.hasError) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 72,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Có lỗi xảy ra!',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        // If simulation was on, turn it off on retry
                        if (_simulateError) {
                          setState(() {
                            _simulateError = false;
                          });
                        }
                        _loadPosts();
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Thử lại (Retry)'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // State 3: Data Loaded Successfully (snapshot.hasData)
          if (snapshot.hasData) {
            final List<Post> remotePosts = snapshot.data ?? [];
            final List<Post> allPosts = [
              ..._locallyCreatedPosts,
              ...remotePosts,
            ];

            if (allPosts.isEmpty) {
              return const Center(
                child: Text('Không có bài viết nào.'),
              );
            }

            return RefreshIndicator(
              onRefresh: _refreshPosts,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                itemCount: allPosts.length,
                itemBuilder: (context, index) {
                  final post = allPosts[index];
                  final isLocal = index < _locallyCreatedPosts.length;

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    elevation: 1.5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: isLocal
                          ? BorderSide(color: theme.colorScheme.primary, width: 1.5)
                          : BorderSide.none,
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PostDetailScreen(post: post),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ID Badge / Circle Avatar
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: isLocal
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.primaryContainer,
                              child: Text(
                                '${post.id}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: isLocal
                                      ? Colors.white
                                      : theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Post details: Title & Body snippet
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (isLocal)
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 4),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade100,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'VỪA TẠO (POST API)',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green.shade800,
                                        ),
                                      ),
                                    ),
                                  Text(
                                    post.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    post.body,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade700,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Chevron icon
                            const SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 16,
                              color: Colors.grey.shade400,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }

          // Fallback state
          return const Center(child: Text('Không có dữ liệu.'));
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreatePost,
        icon: const Icon(Icons.add),
        label: const Text('Thêm bài viết'),
      ),
    );
  }
}
