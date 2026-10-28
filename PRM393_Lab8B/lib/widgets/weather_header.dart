import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/weather_model.dart';

class WeatherHeader extends StatelessWidget {
  final WeatherModel weather;
  final VoidCallback onSearchTap;
  final VoidCallback onRefresh;

  const WeatherHeader({
    super.key,
    required this.weather,
    required this.onSearchTap,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final current = weather.current;
    final isDay = current.isDay;
    final theme = Theme.of(context);

    // Dynamic gradient based on weather & time of day
    final List<Color> gradientColors = isDay
        ? [const Color(0xFF1E88E5), const Color(0xFF42A5F5), const Color(0xFF90CAF9)]
        : [const Color(0xFF0D47A1), const Color(0xFF1A237E), const Color(0xFF311B92)];

    final formattedDate = DateFormat('EEEE, dd/MM/yyyy', 'vi_VN').format(current.time);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            children: [
              // Top Bar: Location + Actions
              Row(
                children: [
                  const Icon(Icons.location_on_rounded, color: Colors.white, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InkWell(
                      onTap: onSearchTap,
                      borderRadius: BorderRadius.circular(8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              weather.locationName,
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (weather.country.isNotEmpty) ...[
                            Text(
                              ', ${weather.country}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_drop_down, color: Colors.white70),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search_rounded, color: Colors.white),
                    tooltip: 'Tìm kiếm thành phố',
                    onPressed: onSearchTap,
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                    tooltip: 'Làm mới dữ liệu',
                    onPressed: onRefresh,
                  ),
                ],
              ),

              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  formattedDate,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Main Temperature & Icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            current.temperature.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 64,
                              fontWeight: FontWeight.w300,
                              color: Colors.white,
                              height: 1.0,
                            ),
                          ),
                          const Text(
                            '°C',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          current.conditionText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Hero(
                    tag: 'weather_icon_main',
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        current.conditionIcon,
                        size: 72,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Sub-info bar: Feels like, Max, Min
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSubInfo(
                      icon: Icons.thermostat_rounded,
                      label: 'Cảm giác như',
                      value: '${current.apparentTemperature.toStringAsFixed(1)}°C',
                    ),
                    Container(height: 24, width: 1, color: Colors.white24),
                    _buildSubInfo(
                      icon: Icons.air_rounded,
                      label: 'Gió',
                      value: '${current.windSpeed.toStringAsFixed(1)} km/h',
                    ),
                    Container(height: 24, width: 1, color: Colors.white24),
                    _buildSubInfo(
                      icon: Icons.water_drop_outlined,
                      label: 'Độ ẩm',
                      value: '${current.relativeHumidity}%',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubInfo({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: Colors.white.withValues(alpha: 0.9)),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.75),
                fontSize: 11,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
