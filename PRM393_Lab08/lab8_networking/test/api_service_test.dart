import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lab8_networking/models/post.dart';
import 'package:lab8_networking/services/api_service.dart';

void main() {
  group('ApiService Tests', () {
    test('fetchPosts returns a list of posts on 200 HTTP response', () async {
      final mockData = [
        {
          'userId': 1,
          'id': 1,
          'title': 'Test Post 1',
          'body': 'Content of test post 1',
        },
        {
          'userId': 1,
          'id': 2,
          'title': 'Test Post 2',
          'body': 'Content of test post 2',
        },
      ];

      final mockClient = MockClient((request) async {
        expect(request.url.path, '/posts');
        expect(request.method, 'GET');
        return http.Response(
          json.encode(mockData),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final apiService = ApiService(client: mockClient);
      final List<Post> posts = await apiService.fetchPosts();

      expect(posts.length, 2);
      expect(posts[0].id, 1);
      expect(posts[0].title, 'Test Post 1');
      expect(posts[1].id, 2);
      expect(posts[1].title, 'Test Post 2');
    });

    test('fetchPosts throws Exception on 404/500 HTTP error', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Not Found', 404);
      });

      final apiService = ApiService(client: mockClient);

      expect(() => apiService.fetchPosts(), throwsA(isA<Exception>()));
    });

    test('fetchPosts throws Exception when simulateError is true', () async {
      final apiService = ApiService();
      expect(
        () => apiService.fetchPosts(simulateError: true),
        throwsA(isA<Exception>()),
      );
    });

    test('createPost sends POST request and returns created post', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/posts');
        expect(request.method, 'POST');

        final payload = json.decode(request.body);
        expect(payload['title'], 'New Test Post');
        expect(payload['body'], 'New Test Description');

        return http.Response(
          json.encode({
            'id': 101,
            'title': payload['title'],
            'body': payload['body'],
            'userId': 1,
          }),
          201,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final apiService = ApiService(client: mockClient);
      final createdPost = await apiService.createPost(
        title: 'New Test Post',
        body: 'New Test Description',
      );

      expect(createdPost.id, 101);
      expect(createdPost.title, 'New Test Post');
      expect(createdPost.body, 'New Test Description');
    });

    test('fetchPostById returns specific post on 200 response', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/posts/5');
        return http.Response(
          json.encode({
            'userId': 2,
            'id': 5,
            'title': 'Specific Post 5',
            'body': 'Body 5',
          }),
          200,
        );
      });

      final apiService = ApiService(client: mockClient);
      final post = await apiService.fetchPostById(5);

      expect(post.id, 5);
      expect(post.userId, 2);
      expect(post.title, 'Specific Post 5');
    });
  });
}
