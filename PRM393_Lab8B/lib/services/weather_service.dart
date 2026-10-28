import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/location_model.dart';
import '../models/weather_model.dart';

class WeatherApiException implements Exception {
  final String message;
  final int? statusCode;

  WeatherApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class WeatherService {
  final http.Client _client;
  static const Duration _timeoutDuration = Duration(seconds: 10);

  WeatherService({http.Client? client}) : _client = client ?? http.Client();

  // Flag to simulate error for testing / lab requirement demo
  bool simulateError = false;

  /// Fetches weather for a given latitude & longitude from Open-Meteo REST API
  Future<WeatherModel> fetchWeather({
    required double latitude,
    required double longitude,
    required String cityName,
    String country = '',
  }) async {
    if (simulateError) {
      throw WeatherApiException('Lỗi mạng mô phỏng (Simulated Network Error): Không thể kết nối tới máy chủ thời tiết.');
    }

    final uri = Uri.parse(
      'https://api.open-meteo.com/v1/forecast?'
      'latitude=$latitude&longitude=$longitude'
      '&current=temperature_2m,relative_humidity_2m,apparent_temperature,is_day,precipitation,weather_code,wind_speed_10m'
      '&hourly=temperature_2m,weather_code,precipitation_probability'
      '&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max'
      '&timezone=auto',
    );

    try {
      final response = await _client.get(uri).timeout(_timeoutDuration);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return WeatherModel.fromJson(
          data,
          locationName: cityName,
          country: country,
        );
      } else {
        throw WeatherApiException(
          'Máy chủ trả về mã lỗi: ${response.statusCode} (${response.reasonPhrase ?? "Lỗi không xác định"})',
          response.statusCode,
        );
      }
    } on SocketException {
      throw WeatherApiException('Không có kết nối mạng Internet. Vui lòng kiểm tra Wifi/4G của bạn.');
    } on TimeoutException {
      throw WeatherApiException('Kết nối quá thời gian chờ (10s). Vui lòng thử lại sau.');
    } on FormatException {
      throw WeatherApiException('Không thể phân tích dữ liệu JSON phản hồi từ API thời tiết.');
    } catch (e) {
      if (e is WeatherApiException) rethrow;
      throw WeatherApiException('Đã xảy ra lỗi không mong muốn: ${e.toString()}');
    }
  }

  /// Searches locations matching the query using Open-Meteo Geocoding REST API
  Future<List<LocationModel>> searchCities(String query) async {
    if (query.trim().isEmpty) return [];

    final uri = Uri.parse(
      'https://geocoding-api.open-meteo.com/v1/search?'
      'name=${Uri.encodeComponent(query.trim())}&count=10&language=en&format=json',
    );

    try {
      final response = await _client.get(uri).timeout(_timeoutDuration);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final results = data['results'] as List<dynamic>?;
        if (results == null || results.isEmpty) {
          return [];
        }
        return results
            .map((item) => LocationModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw WeatherApiException('Lỗi tìm kiếm địa điểm: HTTP ${response.statusCode}');
      }
    } on SocketException {
      throw WeatherApiException('Lỗi kết nối mạng khi tìm kiếm thành phố.');
    } on TimeoutException {
      throw WeatherApiException('Hết thời gian chờ phản hồi tìm kiếm địa điểm.');
    } catch (e) {
      if (e is WeatherApiException) rethrow;
      throw WeatherApiException('Lỗi tìm kiếm: ${e.toString()}');
    }
  }

  void dispose() {
    _client.close();
  }
}
