import 'package:flutter/material.dart';

class WeatherModel {
  final double latitude;
  final double longitude;
  final String timezone;
  final String locationName;
  final String country;
  final CurrentWeather current;
  final List<HourlyForecastItem> hourly;
  final List<DailyForecastItem> daily;

  const WeatherModel({
    required this.latitude,
    required this.longitude,
    required this.timezone,
    required this.locationName,
    required this.country,
    required this.current,
    required this.hourly,
    required this.daily,
  });

  factory WeatherModel.fromJson(
    Map<String, dynamic> json, {
    String locationName = 'Current Location',
    String country = '',
  }) {
    final currentJson = json['current'] as Map<String, dynamic>? ?? {};
    final hourlyJson = json['hourly'] as Map<String, dynamic>? ?? {};
    final dailyJson = json['daily'] as Map<String, dynamic>? ?? {};

    // Parse Hourly
    final List<HourlyForecastItem> parsedHourly = [];
    final hourlyTimes = hourlyJson['time'] as List<dynamic>? ?? [];
    final hourlyTemps = hourlyJson['temperature_2m'] as List<dynamic>? ?? [];
    final hourlyCodes = hourlyJson['weather_code'] as List<dynamic>? ?? [];
    final hourlyPrecipProb = hourlyJson['precipitation_probability'] as List<dynamic>? ?? [];

    final now = DateTime.now();
    for (int i = 0; i < hourlyTimes.length && parsedHourly.length < 24; i++) {
      final timeStr = hourlyTimes[i]?.toString() ?? '';
      final dt = DateTime.tryParse(timeStr) ?? now;
      // Keep from current hour onwards
      if (dt.isAfter(now.subtract(const Duration(hours: 1)))) {
        parsedHourly.add(HourlyForecastItem(
          time: dt,
          temperature: (hourlyTemps[i] as num?)?.toDouble() ?? 0.0,
          weatherCode: (hourlyCodes[i] as num?)?.toInt() ?? 0,
          precipitationProbability: (hourlyPrecipProb.isNotEmpty && i < hourlyPrecipProb.length)
              ? (hourlyPrecipProb[i] as num?)?.toInt() ?? 0
              : 0,
        ));
      }
    }

    // Parse Daily
    final List<DailyForecastItem> parsedDaily = [];
    final dailyTimes = dailyJson['time'] as List<dynamic>? ?? [];
    final dailyCodes = dailyJson['weather_code'] as List<dynamic>? ?? [];
    final dailyMaxTemps = dailyJson['temperature_2m_max'] as List<dynamic>? ?? [];
    final dailyMinTemps = dailyJson['temperature_2m_min'] as List<dynamic>? ?? [];
    final dailyPrecipProb = dailyJson['precipitation_probability_max'] as List<dynamic>? ?? [];

    for (int i = 0; i < dailyTimes.length; i++) {
      final timeStr = dailyTimes[i]?.toString() ?? '';
      final dt = DateTime.tryParse(timeStr) ?? now;
      parsedDaily.add(DailyForecastItem(
        date: dt,
        weatherCode: (dailyCodes.isNotEmpty && i < dailyCodes.length) ? (dailyCodes[i] as num?)?.toInt() ?? 0 : 0,
        temperatureMax: (dailyMaxTemps.isNotEmpty && i < dailyMaxTemps.length) ? (dailyMaxTemps[i] as num?)?.toDouble() ?? 0.0 : 0.0,
        temperatureMin: (dailyMinTemps.isNotEmpty && i < dailyMinTemps.length) ? (dailyMinTemps[i] as num?)?.toDouble() ?? 0.0 : 0.0,
        precipitationProbabilityMax: (dailyPrecipProb.isNotEmpty && i < dailyPrecipProb.length) ? (dailyPrecipProb[i] as num?)?.toInt() ?? 0 : 0,
      ));
    }

    return WeatherModel(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      timezone: json['timezone'] as String? ?? 'UTC',
      locationName: locationName,
      country: country,
      current: CurrentWeather.fromJson(currentJson),
      hourly: parsedHourly,
      daily: parsedDaily,
    );
  }
}

class CurrentWeather {
  final DateTime time;
  final double temperature;
  final int relativeHumidity;
  final double apparentTemperature;
  final bool isDay;
  final double precipitation;
  final int weatherCode;
  final double windSpeed;

  const CurrentWeather({
    required this.time,
    required this.temperature,
    required this.relativeHumidity,
    required this.apparentTemperature,
    required this.isDay,
    required this.precipitation,
    required this.weatherCode,
    required this.windSpeed,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      time: DateTime.tryParse(json['time']?.toString() ?? '') ?? DateTime.now(),
      temperature: (json['temperature_2m'] as num?)?.toDouble() ?? 0.0,
      relativeHumidity: (json['relative_humidity_2m'] as num?)?.toInt() ?? 0,
      apparentTemperature: (json['apparent_temperature'] as num?)?.toDouble() ?? 0.0,
      isDay: (json['is_day'] as num?)?.toInt() == 1,
      precipitation: (json['precipitation'] as num?)?.toDouble() ?? 0.0,
      weatherCode: (json['weather_code'] as num?)?.toInt() ?? 0,
      windSpeed: (json['wind_speed_10m'] as num?)?.toDouble() ?? 0.0,
    );
  }

  String get conditionText => getWeatherDescription(weatherCode);

  IconData get conditionIcon => getWeatherIcon(weatherCode, isDay);
}

class HourlyForecastItem {
  final DateTime time;
  final double temperature;
  final int weatherCode;
  final int precipitationProbability;

  const HourlyForecastItem({
    required this.time,
    required this.temperature,
    required this.weatherCode,
    required this.precipitationProbability,
  });

  String get conditionText => getWeatherDescription(weatherCode);
  IconData get conditionIcon => getWeatherIcon(weatherCode, true);
}

class DailyForecastItem {
  final DateTime date;
  final int weatherCode;
  final double temperatureMax;
  final double temperatureMin;
  final int precipitationProbabilityMax;

  const DailyForecastItem({
    required this.date,
    required this.weatherCode,
    required this.temperatureMax,
    required this.temperatureMin,
    required this.precipitationProbabilityMax,
  });

  String get conditionText => getWeatherDescription(weatherCode);
  IconData get conditionIcon => getWeatherIcon(weatherCode, true);
}

// WMO Weather Interpretation Codes (WW)
String getWeatherDescription(int code) {
  switch (code) {
    case 0:
      return 'Trời quang đãng (Clear sky)';
    case 1:
      return 'Nhiều mây nhẹ (Mainly clear)';
    case 2:
      return 'Mây rải rác (Partly cloudy)';
    case 3:
      return 'Trời âm u (Overcast)';
    case 45:
    case 48:
      return 'Sương mù dày (Foggy)';
    case 51:
      return 'Mưa phùn nhẹ (Light drizzle)';
    case 53:
      return 'Mưa phùn vừa (Moderate drizzle)';
    case 55:
      return 'Mưa phùn đậm hạt (Dense drizzle)';
    case 61:
      return 'Mưa rào nhẹ (Slight rain)';
    case 63:
      return 'Mưa vừa (Moderate rain)';
    case 65:
      return 'Mưa to xối xả (Heavy rain)';
    case 71:
      return 'Tuyết rơi nhẹ (Slight snow)';
    case 73:
      return 'Tuyết rơi vừa (Moderate snow)';
    case 75:
      return 'Tuyết rơi dày (Heavy snow)';
    case 80:
      return 'Mưa rào thoáng qua (Light showers)';
    case 81:
      return 'Mưa rào rải rác (Showers)';
    case 82:
      return 'Mưa rào dữ dội (Violent rain showers)';
    case 95:
      return 'Dông bão (Thunderstorm)';
    case 96:
    case 99:
      return 'Dông có mưa đá (Thunderstorm with hail)';
    default:
      return 'Thời tiết biến đổi (Variable)';
  }
}

IconData getWeatherIcon(int code, bool isDay) {
  switch (code) {
    case 0:
      return isDay ? Icons.wb_sunny_rounded : Icons.nightlight_round;
    case 1:
    case 2:
      return isDay ? Icons.cloud_queue_rounded : Icons.nights_stay_rounded;
    case 3:
      return Icons.cloud_rounded;
    case 45:
    case 48:
      return Icons.foggy;
    case 51:
    case 53:
    case 55:
      return Icons.grain_rounded;
    case 61:
    case 63:
    case 80:
    case 81:
      return Icons.water_drop_rounded;
    case 65:
    case 82:
      return Icons.thunderstorm_rounded;
    case 71:
    case 73:
    case 75:
      return Icons.ac_unit_rounded;
    case 95:
    case 96:
    case 99:
      return Icons.flash_on_rounded;
    default:
      return Icons.wb_cloudy_rounded;
  }
}
