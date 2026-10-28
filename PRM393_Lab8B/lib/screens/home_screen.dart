import 'package:flutter/material.dart';
import '../models/location_model.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import '../widgets/city_search_sheet.dart';
import '../widgets/daily_forecast_view.dart';
import '../widgets/error_view.dart';
import '../widgets/hourly_forecast_view.dart';
import '../widgets/recommendation_cards.dart';
import '../widgets/weather_details_grid.dart';
import '../widgets/weather_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WeatherService _weatherService = WeatherService();
  LocationModel _currentLocation = LocationModel.popularCities[0]; // Default: Hanoi
  late Future<WeatherModel> _weatherFuture;
  bool _isSimulatingError = false;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  void _loadWeather() {
    setState(() {
      _weatherFuture = _weatherService.fetchWeather(
        latitude: _currentLocation.latitude,
        longitude: _currentLocation.longitude,
        cityName: _currentLocation.name,
        country: _currentLocation.country,
      );
    });
  }

  void _changeLocation(LocationModel newLocation) {
    setState(() {
      _currentLocation = newLocation;
    });
    _loadWeather();
  }

  void _openCitySearch() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CitySearchSheet(
        weatherService: _weatherService,
        onLocationSelected: (location) {
          _changeLocation(location);
        },
      ),
    );
  }

  void _toggleSimulateError() {
    setState(() {
      _isSimulatingError = !_isSimulatingError;
      _weatherService.simulateError = _isSimulatingError;
    });
    _loadWeather();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isSimulatingError
              ? 'Đã BẬT mô phỏng lỗi mạng (để kiểm tra Error State & Retry)'
              : 'Đã TẮT mô phỏng lỗi mạng (kết nối bình thường)',
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: _isSimulatingError ? Colors.red.shade700 : Colors.green.shade700,
      ),
    );
  }

  @override
  void dispose() {
    _weatherService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: FutureBuilder<WeatherModel>(
        future: _weatherFuture,
        builder: (context, snapshot) {
          // 1. LOADING STATE
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          }

          // 2. ERROR STATE
          if (snapshot.hasError) {
            return SafeArea(
              child: Column(
                children: [
                  _buildTopControlBar(),
                  Expanded(
                    child: ErrorView(
                      message: snapshot.error.toString(),
                      onRetry: _loadWeather,
                    ),
                  ),
                ],
              ),
            );
          }

          // 3. EMPTY STATE OR UNEXPECTED
          if (!snapshot.hasData) {
            return SafeArea(
              child: Center(
                child: ErrorView(
                  message: 'Không có dữ liệu thời tiết nhận được từ máy chủ.',
                  onRetry: _loadWeather,
                ),
              ),
            );
          }

          // 4. SUCCESS STATE - DATA DISPLAY
          final weather = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async {
              _loadWeather();
              await _weatherFuture;
            },
            color: Colors.blue,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Weather Header
                  WeatherHeader(
                    weather: weather,
                    onSearchTap: _openCitySearch,
                    onRefresh: _loadWeather,
                  ),

                  // Quick City Selection Chips
                  const SizedBox(height: 12),
                  _buildQuickCityChips(),

                  // Testing & Tools Bar (Simulate Error button for testing lab criteria)
                  _buildDemoControlBar(),

                  // Purpose-driven Recommendations (Umbrella, Outdoor, Outfit)
                  const SizedBox(height: 8),
                  RecommendationCardsSection(weather: weather),

                  // Hourly Forecast (24h)
                  const SizedBox(height: 12),
                  HourlyForecastView(hourly: weather.hourly),

                  // 7-day Daily Forecast
                  const SizedBox(height: 12),
                  DailyForecastView(daily: weather.daily),

                  // Weather Details Grid
                  const SizedBox(height: 8),
                  WeatherDetailsGrid(weather: weather),

                  // Bottom Lab Attribution
                  _buildFooter(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCitySearch,
        icon: const Icon(Icons.search_rounded),
        label: const Text('Đổi thành phố'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildLoadingState() {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: const SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(
                    strokeWidth: 3.5,
                    color: Colors.blue,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Đang tải dữ liệu thời tiết...',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Đang kết nối REST API Open-Meteo cho ${_currentLocation.name}...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopControlBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _currentLocation.name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          TextButton.icon(
            onPressed: _toggleSimulateError,
            icon: Icon(
              _isSimulatingError ? Icons.wifi_off_rounded : Icons.wifi_rounded,
              color: _isSimulatingError ? Colors.red : Colors.green,
              size: 18,
            ),
            label: Text(
              _isSimulatingError ? 'Tắt lỗi mạng' : 'Giả lập lỗi mạng',
              style: TextStyle(
                color: _isSimulatingError ? Colors.red : Colors.green,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickCityChips() {
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: LocationModel.popularCities.length,
        itemBuilder: (context, index) {
          final city = LocationModel.popularCities[index];
          final isSelected = city.id == _currentLocation.id;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(city.name),
              selected: isSelected,
              selectedColor: Colors.blue.shade600,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade800,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
              backgroundColor: Colors.white,
              side: BorderSide(
                color: isSelected ? Colors.blue.shade600 : Colors.grey.shade300,
              ),
              onSelected: (selected) {
                if (selected) {
                  _changeLocation(city);
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildDemoControlBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Tooltip(
            message: 'Bật giả lập lỗi mạng để kiểm tra giao diện xử lý lỗi & nút Thử lại',
            child: OutlinedButton.icon(
              onPressed: _toggleSimulateError,
              icon: Icon(
                _isSimulatingError ? Icons.wifi_off_rounded : Icons.bug_report_outlined,
                size: 14,
                color: _isSimulatingError ? Colors.red : Colors.grey.shade700,
              ),
              label: Text(
                _isSimulatingError ? 'Đang bật lỗi mạng (Chạm để tắt)' : 'Test Error State',
                style: TextStyle(
                  fontSize: 11,
                  color: _isSimulatingError ? Colors.red : Colors.grey.shade700,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                side: BorderSide(
                  color: _isSimulatingError ? Colors.red : Colors.grey.shade300,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'PRM393 - Lab 8B: Practical REST API Integration',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Scenario A: Weather Companion App • Powered by Open-Meteo REST API',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
