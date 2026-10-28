import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../screens/detail_screen.dart';

class WeatherDetailsGrid extends StatelessWidget {
  final WeatherModel weather;

  const WeatherDetailsGrid({
    super.key,
    required this.weather,
  });

  @override
  Widget build(BuildContext context) {
    final current = weather.current;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Chỉ số khí tượng chi tiết',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                ),
              ),
              TextButton.icon(
                icon: const Icon(Icons.analytics_outlined, size: 16),
                label: const Text('Xem thêm'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WeatherDetailScreen(weather: weather),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.5,
            children: [
              _buildDetailTile(
                icon: Icons.water_drop_outlined,
                color: Colors.blue,
                label: 'Độ ẩm không khí',
                value: '${current.relativeHumidity}%',
                subtitle: current.relativeHumidity < 40
                    ? 'Khá khô ráo'
                    : (current.relativeHumidity <= 70 ? 'Mức dễ chịu' : 'Độ ẩm cao'),
              ),
              _buildDetailTile(
                icon: Icons.air_rounded,
                color: Colors.teal,
                label: 'Tốc độ gió',
                value: '${current.windSpeed.toStringAsFixed(1)} km/h',
                subtitle: current.windSpeed < 15
                    ? 'Gió hiu hiu'
                    : (current.windSpeed <= 30 ? 'Gió vừa phải' : 'Gió giật mạnh'),
              ),
              _buildDetailTile(
                icon: Icons.grain_rounded,
                color: Colors.indigo,
                label: 'Lượng mưa hiện tại',
                value: '${current.precipitation.toStringAsFixed(1)} mm',
                subtitle: current.precipitation == 0 ? 'Không có mưa' : 'Đang có mưa',
              ),
              _buildDetailTile(
                icon: Icons.device_thermostat_rounded,
                color: Colors.deepOrange,
                label: 'Cảm nhận thực tế',
                value: '${current.apparentTemperature.toStringAsFixed(1)}°C',
                subtitle: current.apparentTemperature > current.temperature
                    ? 'Oi bức hơn thực tế'
                    : 'Mát mẻ hơn thực tế',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailTile({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
