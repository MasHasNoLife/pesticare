import 'package:flutter/material.dart';
import '../services/weather_service.dart';

/// Weather widget for home screen showing temperature, humidity, and disease risk
class WeatherWidget extends StatefulWidget {
  const WeatherWidget({super.key});

  @override
  State<WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  final WeatherService _weatherService = WeatherService();
  WeatherData? _weather;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final weather = await _weatherService.getWeather();
    
    if (mounted) {
      setState(() {
        _weather = weather;
        _isLoading = false;
        if (weather == null) {
          _error = 'Unable to fetch weather';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (_isLoading) {
      return _buildContainer(
        theme,
        child: const Center(
          child: SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (_error != null || _weather == null) {
      return const SizedBox.shrink();
    }

    final riskLevel = _weatherService.getDiseaseRiskLevel(_weather!.humidity);
    final isHighRisk = _weather!.humidity > 80;

    return _buildContainer(
      theme,
      child: Row(
        children: [
          // Weather icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getWeatherIcon(_weather!.condition),
              color: theme.colorScheme.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          // Weather info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _weather!.temperatureDisplay,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.water_drop,
                            size: 14,
                            color: theme.colorScheme.onSecondaryContainer,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _weather!.humidityDisplay,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSecondaryContainer,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (isHighRisk)
                      Icon(
                        Icons.warning_amber,
                        size: 14,
                        color: Colors.orange.shade600,
                      ),
                    if (isHighRisk) const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        riskLevel,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isHighRisk 
                            ? Colors.orange.shade700
                            : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          fontWeight: isHighRisk ? FontWeight.w500 : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Refresh button
          IconButton(
            onPressed: _loadWeather,
            icon: Icon(
              Icons.refresh,
              size: 20,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  Widget _buildContainer(ThemeData theme, {required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: child,
    );
  }

  IconData _getWeatherIcon(String condition) {
    switch (condition) {
      case 'humid':
        return Icons.water;
      case 'moderate':
        return Icons.cloud;
      case 'comfortable':
        return Icons.wb_sunny;
      case 'dry':
        return Icons.wb_sunny_outlined;
      default:
        return Icons.thermostat;
    }
  }
}
