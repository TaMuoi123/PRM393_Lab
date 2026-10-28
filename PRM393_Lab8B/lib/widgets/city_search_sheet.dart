import 'dart:async';
import 'package:flutter/material.dart';
import '../models/location_model.dart';
import '../services/weather_service.dart';

class CitySearchSheet extends StatefulWidget {
  final WeatherService weatherService;
  final Function(LocationModel) onLocationSelected;

  const CitySearchSheet({
    super.key,
    required this.weatherService,
    required this.onLocationSelected,
  });

  @override
  State<CitySearchSheet> createState() => _CitySearchSheetState();
}

class _CitySearchSheetState extends State<CitySearchSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<LocationModel> _searchResults = [];
  bool _isLoading = false;
  String? _errorMessage;
  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
        _errorMessage = null;
      });
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _executeSearch(query);
    });
  }

  Future<void> _executeSearch(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await widget.weatherService.searchCities(query);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isLoading = false;
          if (results.isEmpty) {
            _errorMessage = 'Không tìm thấy địa điểm nào khớp với "$query"';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Chọn địa điểm',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Search Field
          TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            onSubmitted: _executeSearch,
            autofocus: false,
            decoration: InputDecoration(
              hintText: 'Nhập tên thành phố (vd: Hanoi, Da Nang, Tokyo...)',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              prefixIcon: const Icon(Icons.search_rounded, color: Colors.blue),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 20),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.grey.shade100,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Popular Cities chips
          const Text(
            'Thành phố phổ biến:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: LocationModel.popularCities.map((city) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    avatar: const Icon(Icons.location_city_rounded, size: 16, color: Colors.blue),
                    label: Text(city.name),
                    backgroundColor: Colors.blue.shade50,
                    side: BorderSide(color: Colors.blue.shade100),
                    onPressed: () {
                      widget.onLocationSelected(city);
                      Navigator.pop(context);
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          const Divider(height: 24),

          // Search Results Area
          Expanded(
            child: _buildResultsArea(),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsArea() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('Đang tìm kiếm qua REST API...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_off_rounded, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.travel_explore_rounded, size: 48, color: Colors.blue.shade200),
            const SizedBox(height: 12),
            const Text(
              'Gõ tên thành phố để tìm kiếm dữ liệu thời tiết',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final loc = _searchResults[index];
        return ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.pin_drop_rounded, color: Colors.blue, size: 20),
          ),
          title: Text(
            loc.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            loc.displayName,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
          trailing: Text(
            '${loc.latitude.toStringAsFixed(2)}°, ${loc.longitude.toStringAsFixed(2)}°',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
          ),
          onTap: () {
            widget.onLocationSelected(loc);
            Navigator.pop(context);
          },
        );
      },
    );
  }
}
