import 'package:flutter/material.dart';
import 'weather_model.dart';

enum ActivitySuitability {
  excellent,
  moderate,
  poor,
}

class UmbrellaAdvice {
  final bool needed;
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const UmbrellaAdvice({
    required this.needed,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class ActivityAdvice {
  final ActivitySuitability suitability;
  final String title;
  final String summary;
  final List<String> suitableActivities;
  final List<String> warnings;
  final IconData icon;
  final Color color;

  const ActivityAdvice({
    required this.suitability,
    required this.title,
    required this.summary,
    required this.suitableActivities,
    required this.warnings,
    required this.icon,
    required this.color,
  });
}

class OutfitAdvice {
  final String title;
  final String description;
  final List<String> suggestedItems;
  final IconData icon;
  final Color color;

  const OutfitAdvice({
    required this.title,
    required this.description,
    required this.suggestedItems,
    required this.icon,
    required this.color,
  });
}

class WeatherRecommendation {
  final UmbrellaAdvice umbrella;
  final ActivityAdvice activity;
  final OutfitAdvice outfit;

  const WeatherRecommendation({
    required this.umbrella,
    required this.activity,
    required this.outfit,
  });

  factory WeatherRecommendation.fromWeather(WeatherModel weather) {
    final current = weather.current;
    final temp = current.temperature;
    final feelsLike = current.apparentTemperature;
    final rain = current.precipitation;
    final wind = current.windSpeed;
    final code = current.weatherCode;

    // Highest rain probability in the next 12 hours or today
    int maxRainChance = 0;
    if (weather.hourly.isNotEmpty) {
      final next12Hours = weather.hourly.take(12);
      for (final h in next12Hours) {
        if (h.precipitationProbability > maxRainChance) {
          maxRainChance = h.precipitationProbability;
        }
      }
    }
    if (weather.daily.isNotEmpty && weather.daily.first.precipitationProbabilityMax > maxRainChance) {
      maxRainChance = weather.daily.first.precipitationProbabilityMax;
    }

    // 1. UMBRELLA ADVICE
    final bool isRainingNow = rain > 0.1 || (code >= 51 && code <= 99);
    final bool highRainChance = maxRainChance >= 40;
    final bool umbrellaNeeded = isRainingNow || highRainChance;

    final umbrellaAdvice = UmbrellaAdvice(
      needed: umbrellaNeeded,
      title: umbrellaNeeded
          ? (isRainingNow ? 'Mang dù hoặc áo mưa ngay!' : 'Nên mang theo dù / áo mưa!')
          : 'Không cần mang dù',
      description: umbrellaNeeded
          ? (isRainingNow
              ? 'Hiện tại đang có mưa (${current.conditionText}). Đừng quên mang dù khi ra đường!'
              : 'Xác suất mưa hôm nay lên tới $maxRainChance%. Nên chuẩn bị sẵn dù trong túi.')
          : 'Trời khô ráo, xác suất mưa chỉ khoảng $maxRainChance%. Bạn có thể thoải mái di chuyển!',
      icon: umbrellaNeeded ? Icons.umbrella_rounded : Icons.wb_sunny_rounded,
      color: umbrellaNeeded ? const Color(0xFF1E88E5) : const Color(0xFFF57C00),
    );

    // 2. ACTIVITY ADVICE
    ActivitySuitability suitability;
    String activityTitle;
    String activitySummary;
    List<String> suitableActivities = [];
    List<String> warnings = [];

    if (code >= 95 || rain >= 5.0 || wind >= 40.0) {
      suitability = ActivitySuitability.poor;
      activityTitle = 'Không nên hoạt động ngoài trời';
      activitySummary = 'Thời tiết xấu có dông hoặc mưa to, gió mạnh. Ưu tiên các hoạt động trong nhà!';
      suitableActivities = [
        'Đọc sách, thư giãn trong nhà',
        'Luyện tập gym/yoga tại phòng',
        'Xem phim hoặc làm việc trực tuyến',
      ];
      warnings = [
        'Tránh trú mưa dưới tán cây to',
        'Cẩn thận đường trơn trượt khi lái xe',
      ];
    } else if (temp >= 35.0 || feelsLike >= 38.0) {
      suitability = ActivitySuitability.moderate;
      activityTitle = 'Quá nóng cho thể thao ngoài trời';
      activitySummary = 'Nhiệt độ cao ($temp°C, cảm giác như $feelsLike°C). Tránh tập luyện ngoài nắng gắt!';
      suitableActivities = [
        'Bơi lội hoặc thể thao trong nhà có điều hòa',
        'Dạo mát sau 18:00 khi trời dịu bớt',
        'Ghé quán cà phê có máy lạnh',
      ];
      warnings = [
        'Uống đủ nước, tránh sốc nhiệt',
        'Thoa kem chống nắng trước khi ra ngoài',
      ];
    } else if (umbrellaNeeded) {
      suitability = ActivitySuitability.moderate;
      activityTitle = 'Thời tiết có mưa, chú ý khi ra ngoài';
      activitySummary = 'Có thể có mưa bất chợt. Thích hợp cho các hoạt động có mái che.';
      suitableActivities = [
        'Dạo chơi trung tâm thương mại',
        'Đi cafe tán gẫu cùng bạn bè',
        'Bảo tàng hoặc triển lãm nghệ thuật',
      ];
      warnings = ['Đường có thể trơn trượt'];
    } else if (temp >= 18.0 && temp <= 29.0 && wind < 25.0) {
      suitability = ActivitySuitability.excellent;
      activityTitle = 'Thời tiết tuyệt vời để ra ngoài!';
      activitySummary = 'Nhiệt độ $temp°C rất lý tưởng, gió nhẹ $wind km/h. Rất thích hợp cho mọi hoạt động thể thao!';
      suitableActivities = [
        'Chạy bộ hoặc đạp xe công viên',
        'Picnic ngoài trời cùng bạn bè',
        'Đi dạo phố, chụp ảnh check-in',
        'Chơi bóng đá, cầu lông, tennis',
      ];
      warnings = ['Thời tiết thuận lợi, tận hưởng ngày mới!'];
    } else {
      suitability = ActivitySuitability.moderate;
      activityTitle = 'Thời tiết tương đối dễ chịu';
      activitySummary = 'Nhiệt độ $temp°C. Có thể tham gia các hoạt động vừa phải.';
      suitableActivities = [
        'Đi bộ nhẹ nhàng',
        'Gặp gỡ bạn bè ngoài trời',
      ];
      warnings = ['Chú ý nhiệt độ nếu đi vào chiều tối'];
    }

    final activityAdvice = ActivityAdvice(
      suitability: suitability,
      title: activityTitle,
      summary: activitySummary,
      suitableActivities: suitableActivities,
      warnings: warnings,
      icon: suitability == ActivitySuitability.excellent
          ? Icons.directions_run_rounded
          : (suitability == ActivitySuitability.moderate ? Icons.directions_walk_rounded : Icons.home_rounded),
      color: suitability == ActivitySuitability.excellent
          ? const Color(0xFF2E7D32)
          : (suitability == ActivitySuitability.moderate ? const Color(0xFFF9A825) : const Color(0xFFC62828)),
    );

    // 3. OUTFIT ADVICE
    String outfitTitle;
    String outfitDesc;
    List<String> items = [];

    if (temp >= 30.0) {
      outfitTitle = 'Trang phục mỏng nhẹ, thoáng mát';
      outfitDesc = 'Thời tiết oi bức, hãy chọn quần áo làm từ cotton, lanh thấm hút tốt.';
      items = ['Áo thun cotton cộc tay', 'Quần short hoặc vải thoáng', 'Nón/mũ rộng vành', 'Kính râm'];
    } else if (temp >= 22.0) {
      outfitTitle = 'Trang phục thường ngày thoải mái';
      outfitDesc = 'Thời tiết mát mẻ dễ chịu, diện trang phục tự do.';
      items = ['Áo phông hoặc sơ mi cộc', 'Quần jeans nhẹ / kaki', 'Giày sneaker năng động'];
    } else if (temp >= 15.0) {
      outfitTitle = 'Áo khoác mỏng hoặc hoodie';
      outfitDesc = 'Trời se se lạnh, nên khoác thêm áo giữ ấm khi đi xe.';
      items = ['Áo khoác gió mỏng', 'Áo nỉ / Cardigan', 'Quần dài ấm áp'];
    } else {
      outfitTitle = 'Áo ấm dày, khăn choàng cổ';
      outfitDesc = 'Nhiệt độ dưới 15°C khá lạnh, cần giữ ấm cơ thể.';
      items = ['Áo phao / Áo khoác dày', 'Khăn len, găng tay', 'Áo len cao cổ'];
    }

    if (umbrellaNeeded) {
      items.add('Áo mưa hoặc dù cầm tay');
    }

    final outfitAdvice = OutfitAdvice(
      title: outfitTitle,
      description: outfitDesc,
      suggestedItems: items,
      icon: Icons.checkroom_rounded,
      color: const Color(0xFF6A1B9A),
    );

    return WeatherRecommendation(
      umbrella: umbrellaAdvice,
      activity: activityAdvice,
      outfit: outfitAdvice,
    );
  }
}
