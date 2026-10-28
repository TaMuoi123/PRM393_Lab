import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/weather_model.dart';

class DailyForecastView extends StatelessWidget {
  final List<DailyForecastItem> daily;

  const DailyForecastView({
    super.key,
    required this.daily,
  });

  @override
  Widget build(BuildContext context) {
    if (daily.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.calendar_today_rounded, color: Colors.indigo, size: 18),
              ),
              const SizedBox(width: 10),
              const Text(
                'Dự báo 7 ngày tới',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: daily.length,
            separatorBuilder: (_, _) => Divider(color: Colors.grey.shade100, height: 16),
            itemBuilder: (context, index) {
              final item = daily[index];
              final isToday = index == 0;
              final dayName = isToday
                  ? 'Hôm nay'
                  : DateFormat('EEEE', 'vi_VN').format(item.date);
              final dateStr = DateFormat('dd/MM').format(item.date);

              return Row(
                children: [
                  // Day Name & Date
                  SizedBox(
                    width: 90,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dayName,
                          style: TextStyle(
                            fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                            color: isToday ? Colors.blue.shade700 : Colors.black87,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          dateStr,
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Weather Icon & Rain Prob
                  SizedBox(
                    width: 70,
                    child: Row(
                      children: [
                        Icon(item.conditionIcon, size: 22, color: Colors.blueGrey),
                        const SizedBox(width: 4),
                        if (item.precipitationProbabilityMax > 15)
                          Text(
                            '${item.precipitationProbabilityMax}%',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.blue.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Min - Max Temp
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${item.temperatureMin.toStringAsFixed(0)}°',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Temperature bar indicator
                        Container(
                          width: 80,
                          height: 6,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF64B5F6), Color(0xFFFFB74D)],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${item.temperatureMax.toStringAsFixed(0)}°',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
