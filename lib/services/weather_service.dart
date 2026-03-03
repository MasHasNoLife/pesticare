import 'dart:convert';
import 'package:http/http.dart' as http;

/// Weather data from Open-Meteo API
class WeatherData {
  final double temperature;
  final int humidity;
  final String condition;
  final DateTime timestamp;

  WeatherData({
    required this.temperature,
    required this.humidity,
    required this.condition,
    required this.timestamp,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>;
    final temp = (current['temperature_2m'] as num).toDouble();
    final humidity = (current['relative_humidity_2m'] as num).toInt();
    
    // Determine condition based on humidity
    String condition;
    if (humidity > 80) {
      condition = 'humid';
    } else if (humidity > 60) {
      condition = 'moderate';
    } else if (humidity > 40) {
      condition = 'comfortable';
    } else {
      condition = 'dry';
    }
    
    return WeatherData(
      temperature: temp,
      humidity: humidity,
      condition: condition,
      timestamp: DateTime.now(),
    );
  }

  String get temperatureDisplay => '${temperature.toStringAsFixed(1)}°C';
  String get humidityDisplay => '$humidity%';
}

/// Service for fetching weather data from Open-Meteo API (free, no API key)
class WeatherService {
  // Default to Multan, Pakistan coordinates (can be made dynamic)
  static const double _defaultLat = 30.19;
  static const double _defaultLon = 71.47;
  
  WeatherData? _cachedData;
  DateTime? _lastFetch;
  static const _cacheDuration = Duration(minutes: 30);

  /// Fetch current weather data
  Future<WeatherData?> getWeather({double? lat, double? lon}) async {
    // Return cached data if still valid
    if (_cachedData != null && _lastFetch != null) {
      if (DateTime.now().difference(_lastFetch!) < _cacheDuration) {
        return _cachedData;
      }
    }

    try {
      final latitude = lat ?? _defaultLat;
      final longitude = lon ?? _defaultLon;
      
      final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?'
        'latitude=$latitude&longitude=$longitude&'
        'current=temperature_2m,relative_humidity_2m'
      );
      
      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
      );
      
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        _cachedData = WeatherData.fromJson(json);
        _lastFetch = DateTime.now();
        return _cachedData;
      }
    } catch (e) {
      // Return cached data on error, or null
      return _cachedData;
    }
    return null;
  }

  /// Get disease risk based on humidity
  String getDiseaseRiskLevel(int humidity) {
    if (humidity > 80) {
      return 'High risk of fungal diseases';
    } else if (humidity > 60) {
      return 'Moderate disease risk';
    } else {
      return 'Low disease risk';
    }
  }
}
