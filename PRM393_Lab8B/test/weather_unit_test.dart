import 'package:flutter_test/flutter_test.dart';
import 'package:weather_companion/models/location_model.dart';
import 'package:weather_companion/models/weather_model.dart';
import 'package:weather_companion/models/weather_recommendation.dart';

void main() {
  group('LocationModel Tests', () {
    test('LocationModel.fromJson parses correctly', () {
      final json = {
        'id': 1581130,
        'name': 'Hanoi',
        'latitude': 21.0285,
        'longitude': 105.8542,
        'country': 'Vietnam',
        'admin1': 'Hanoi',
        'timezone': 'Asia/Bangkok',
      };

      final loc = LocationModel.fromJson(json);
      expect(loc.id, 1581130);
      expect(loc.name, 'Hanoi');
      expect(loc.country, 'Vietnam');
      expect(loc.latitude, 21.0285);
      expect(loc.longitude, 105.8542);
      expect(loc.displayName, 'Hanoi, Vietnam');
    });

    test('popularCities has predefined cities', () {
      expect(LocationModel.popularCities.isNotEmpty, true);
      expect(LocationModel.popularCities.first.name, 'Hanoi');
    });
  });

  group('WeatherModel & Recommendation Tests', () {
    test('WeatherModel.fromJson parses current, hourly, and daily correctly', () {
      final json = {
        'latitude': 21.05,
        'longitude': 105.8,
        'timezone': 'Asia/Bangkok',
        'current': {
          'time': '2026-10-28T12:00',
          'temperature_2m': 31.5,
          'relative_humidity_2m': 55,
          'apparent_temperature': 35.0,
          'is_day': 1,
          'precipitation': 0.0,
          'weather_code': 0,
          'wind_speed_10m': 10.2,
        },
        'hourly': {
          'time': ['2026-10-28T12:00', '2026-10-28T13:00'],
          'temperature_2m': [31.5, 32.0],
          'weather_code': [0, 1],
          'precipitation_probability': [10, 15],
        },
        'daily': {
          'time': ['2026-10-28'],
          'weather_code': [0],
          'temperature_2m_max': [33.0],
          'temperature_2m_min': [24.0],
          'precipitation_probability_max': [15],
        }
      };

      final weather = WeatherModel.fromJson(json, locationName: 'Hanoi', country: 'Vietnam');

      expect(weather.locationName, 'Hanoi');
      expect(weather.current.temperature, 31.5);
      expect(weather.current.relativeHumidity, 55);
      expect(weather.current.apparentTemperature, 35.0);
      expect(weather.current.isDay, true);
      expect(weather.current.windSpeed, 10.2);
    });

    test('WeatherRecommendation advises umbrella when rain probability is high', () {
      final json = {
        'latitude': 21.05,
        'longitude': 105.8,
        'timezone': 'Asia/Bangkok',
        'current': {
          'time': '2026-10-28T12:00',
          'temperature_2m': 26.0,
          'relative_humidity_2m': 80,
          'apparent_temperature': 27.0,
          'is_day': 1,
          'precipitation': 2.5,
          'weather_code': 61, // Slight rain
          'wind_speed_10m': 15.0,
        },
        'hourly': {
          'time': ['2026-10-28T12:00'],
          'temperature_2m': [26.0],
          'weather_code': [61],
          'precipitation_probability': [80],
        },
        'daily': {
          'time': ['2026-10-28'],
          'weather_code': [61],
          'temperature_2m_max': [28.0],
          'temperature_2m_min': [22.0],
          'precipitation_probability_max': [85],
        }
      };

      final weather = WeatherModel.fromJson(json, locationName: 'Hanoi', country: 'Vietnam');
      final rec = WeatherRecommendation.fromWeather(weather);

      expect(rec.umbrella.needed, true);
      expect(rec.umbrella.title.contains('dù') || rec.umbrella.title.contains('áo mưa'), true);
      expect(rec.activity.suitability != ActivitySuitability.excellent, true);
    });
  });
}
