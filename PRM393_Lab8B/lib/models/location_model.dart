class LocationModel {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final String country;
  final String? admin1;
  final String? timezone;

  const LocationModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.country,
    this.admin1,
    this.timezone,
  });

  String get displayName {
    if (admin1 != null && admin1!.isNotEmpty && admin1 != name) {
      return '$name, $admin1, $country';
    }
    return country.isNotEmpty ? '$name, $country' : name;
  }

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name'] as String? ?? 'Unknown',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      country: json['country'] as String? ?? json['country_code'] as String? ?? '',
      admin1: json['admin1'] as String?,
      timezone: json['timezone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'country': country,
      'admin1': admin1,
      'timezone': timezone,
    };
  }

  // Predefined popular cities for quick selection
  static const List<LocationModel> popularCities = [
    LocationModel(
      id: 1581130,
      name: 'Hanoi',
      latitude: 21.0285,
      longitude: 105.8542,
      country: 'Vietnam',
      admin1: 'Hanoi',
      timezone: 'Asia/Bangkok',
    ),
    LocationModel(
      id: 1566083,
      name: 'Ho Chi Minh City',
      latitude: 10.8231,
      longitude: 106.6297,
      country: 'Vietnam',
      admin1: 'Ho Chi Minh',
      timezone: 'Asia/Bangkok',
    ),
    LocationModel(
      id: 1583992,
      name: 'Da Nang',
      latitude: 16.0544,
      longitude: 108.2022,
      country: 'Vietnam',
      admin1: 'Da Nang',
      timezone: 'Asia/Bangkok',
    ),
    LocationModel(
      id: 1850147,
      name: 'Tokyo',
      latitude: 35.6895,
      longitude: 139.6917,
      country: 'Japan',
      admin1: 'Tokyo',
      timezone: 'Asia/Tokyo',
    ),
    LocationModel(
      id: 2643743,
      name: 'London',
      latitude: 51.5074,
      longitude: -0.1278,
      country: 'United Kingdom',
      admin1: 'England',
      timezone: 'Europe/London',
    ),
    LocationModel(
      id: 5128581,
      name: 'New York',
      latitude: 40.7128,
      longitude: -74.0060,
      country: 'United States',
      admin1: 'New York',
      timezone: 'America/New_York',
    ),
    LocationModel(
      id: 2988507,
      name: 'Paris',
      latitude: 48.8566,
      longitude: 2.3522,
      country: 'France',
      admin1: 'Île-de-France',
      timezone: 'Europe/Paris',
    ),
  ];
}
