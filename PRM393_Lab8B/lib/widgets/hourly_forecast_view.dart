import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/weather_model.dart';

class HourlyForecastView extends StatelessWidget {
  final List<HourlyForecastItem> hourly;

  const HourlyForecastView({
    super.key,
    required this.hourly,
  });

  @override
  Widget build(BuildContext context) {
    if (hourly.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.schedule_rounded, color: Colors.blue, size: 20),
              ),
              const SizedBox(width: 10),
              const Text(
                'Dự báo theo giờ (24h tới)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 130,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: hourly.length,
            itemBuilder: (context, index) {
              final item = hourly[index];
              final isFirst = index == 0;
              final hourStr = isFirst ? 'Bây giờ' : DateFormat('HH:mm').format(item.time);

              return Container(
                width: 78,
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                decoration: BoxDecoration(
                  color: isFirst ? Colors.blue.shade50 : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isFirst ? Colors.blue.shade300 : Colors.grey.shade200,
                    width: isFirst ? 1.5 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      hourStr,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isFirst ? FontWeight.bold : FontWeight.w500,
                        color: isFirst ? Colors.blue.shade800 : Colors.grey.shade700,
                      ),
                    ),
                    Icon(
                      item.conditionIcon,
                      size: 26,
                      color: isFirst ? Colors.blue : Colors.blueGrey,
                    ),
                    Text(
                      '${item.temperature.toStringAsFixed(0)}°C',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (item.precipitationProbability > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.water_drop, size: 9, color: Colors.blue),
                            const SizedBox(width: 2),
                            Text(
                              '${item.precipitationProbability}%',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade900,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      const SizedBox(height: 14),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
