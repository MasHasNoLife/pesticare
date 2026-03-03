import 'dart:convert';

/// Represents a saved scan record for disease prediction history.
class ScanRecord {
  final String id;
  final String cropName;
  final String diseaseName;
  final double confidence;
  final String pesticide;
  final String dosage;
  final String instructions;
  final String imagePath;
  final DateTime timestamp;

  ScanRecord({
    required this.id,
    required this.cropName,
    required this.diseaseName,
    required this.confidence,
    required this.pesticide,
    required this.dosage,
    required this.instructions,
    required this.imagePath,
    required this.timestamp,
  });

  /// Create a ScanRecord from prediction result map
  factory ScanRecord.fromPrediction({
    required Map<String, dynamic> result,
    required String imagePath,
  }) {
    return ScanRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      cropName: result['crop']?.toString() ?? '',
      diseaseName: result['disease']?.toString() ?? '',
      confidence: (result['confidence'] as num?)?.toDouble() ?? 0.0,
      pesticide: result['pesticide']?.toString() ?? '',
      dosage: result['dosage']?.toString() ?? '',
      instructions: result['instructions']?.toString() ?? '',
      imagePath: imagePath,
      timestamp: DateTime.now(),
    );
  }

  /// Create from JSON map
  factory ScanRecord.fromJson(Map<String, dynamic> json) {
    return ScanRecord(
      id: json['id'] as String,
      cropName: json['cropName'] as String,
      diseaseName: json['diseaseName'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      pesticide: json['pesticide'] as String,
      dosage: json['dosage'] as String,
      instructions: json['instructions'] as String? ?? '',
      imagePath: json['imagePath'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cropName': cropName,
      'diseaseName': diseaseName,
      'confidence': confidence,
      'pesticide': pesticide,
      'dosage': dosage,
      'instructions': instructions,
      'imagePath': imagePath,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Format timestamp for display
  String get formattedDate {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    
    if (diff.inDays == 0) {
      return 'Today ${_formatTime(timestamp)}';
    } else if (diff.inDays == 1) {
      return 'Yesterday ${_formatTime(timestamp)}';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : dt.hour;
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:${dt.minute.toString().padLeft(2, '0')} $period';
  }
}
