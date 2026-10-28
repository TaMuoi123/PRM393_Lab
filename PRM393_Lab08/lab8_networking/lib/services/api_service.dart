import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/post.dart';

/// Service Layer for handling all network communications with the REST API.
/// Follows the Service Layer Pattern (Lab 8.4) and supports Dependency Injection.
class ApiService {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';

  final http.Client _client;

  /// Constructor allows injecting a custom [http.Client] for testing,
  /// defaulting to a standard [http.Client] instance.
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetches a list of posts from the REST API.
  ///
  /// [simulateError] parameter allows deliberately triggering an error
  /// to demonstrate the error state UI (Lab 8.3).
  Future<List<Post>> fetchPosts({bool simulateError = false}) async {
    if (simulateError) {
      // Simulate network delay before throwing error
      await Future.delayed(const Duration(milliseconds: 600));
      throw Exception('Mạng không khả dụng hoặc máy chủ phản hồi lỗi (Mô phỏng lỗi).');
    }

    try {
      final uri = Uri.parse('$baseUrl/posts');
      final response = await _client.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        // Decode response body using UTF-8 to ensure special characters display properly
        final dynamic decodedData = json.decode(utf8.decode(response.bodyBytes));

        if (decodedData is List) {
          return decodedData
              .map((dynamic item) => Post.fromJson(item as Map<String, dynamic>))
              .toList();
        } else {
          throw const FormatException('Định dạng dữ liệu trả về không phải là danh sách.');
        }
      } else {
        throw HttpException(
          'Máy chủ phản hồi mã lỗi: ${response.statusCode} (${response.reasonPhrase})',
          uri: uri,
        );
      }
    } on SocketException {
      throw Exception('Không có kết nối Internet. Vui lòng kiểm tra mạng của bạn.');
    } on TimeoutException {
      throw Exception('Yêu cầu hết thời gian chờ (Timeout). Vui lòng thử lại sau.');
    } on FormatException catch (e) {
      throw Exception('Lỗi xử lý dữ liệu JSON: ${e.message}');
    } catch (e) {
      throw Exception('Đã xảy ra lỗi không xác định: $e');
    }
  }

  /// Fetches a single post by its [id].
  Future<Post> fetchPostById(int id) async {
    try {
      final uri = Uri.parse('$baseUrl/posts/$id');
      final response = await _client.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        return Post.fromJson(data);
      } else {
        throw Exception('Không thể tải bài viết #$id (Mã: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Lỗi khi tải chi tiết bài viết: $e');
    }
  }

  /// Sends a POST request to create a new post (Optional Enhancement).
  Future<Post> createPost({
    required String title,
    required String body,
    int userId = 1,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/posts');
      final response = await _client
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: json.encode({
              'title': title,
              'body': body,
              'userId': userId,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> data =
            json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        return Post.fromJson(data);
      } else {
        throw Exception('Tạo bài viết thất bại (Mã: ${response.statusCode})');
      }
    } on SocketException {
      throw Exception('Không có kết nối Internet khi gửi bài viết.');
    } on TimeoutException {
      throw Exception('Yêu cầu gửi bài viết quá thời gian chờ.');
    } catch (e) {
      throw Exception('Lỗi khi gửi yêu cầu POST: $e');
    }
  }

  /// Disposes of the underlying HTTP client.
  void dispose() {
    _client.close();
  }
}
