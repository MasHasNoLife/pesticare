import 'dart:io';

import 'package:flutter/material.dart';

import '../services/api_service.dart';

class PredictionProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  String? _selectedCrop;
  File? _selectedImage;
  Map<String, dynamic>? _predictionResult;
  bool _isAnalyzing = false;
  String? _errorMessage;
  bool _isLowConfidence = false;

  String? get selectedCrop => _selectedCrop;
  File? get selectedImage => _selectedImage;
  Map<String, dynamic>? get predictionResult => _predictionResult;
  bool get isAnalyzing => _isAnalyzing;
  String? get errorMessage => _errorMessage;
  
  /// True if the last prediction had confidence below threshold
  bool get isLowConfidence => _isLowConfidence;
  
  /// The confidence threshold used for low confidence detection
  double get confidenceThreshold => 0.85;

  void selectCrop(String cropName) {
    _selectedCrop = cropName;
    _predictionResult = null;
    _errorMessage = null;
    _isLowConfidence = false;
    notifyListeners();
  }

  void setImage(File? image) {
    _selectedImage = image;
    _errorMessage = null;
    _isLowConfidence = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>> analyzeDisease() async {
    if (_selectedCrop == null || _selectedImage == null) {
      throw Exception('Crop or image missing');
    }
    _isAnalyzing = true;
    _errorMessage = null;
    _isLowConfidence = false;
    notifyListeners();
    
    try {
      final result = await _apiService.predictDisease(imageFile: _selectedImage!);
      
      // Inject crop from UI just in case backend doesn't return it or its formatting is weird
      // but backend Gemini schema includes "crop", so we could also just leave it.
      
      _predictionResult = result;
      
      // Check if confidence is below threshold
      final confidence = (result['confidence'] as num).toDouble();
      
      if (confidence < 0.75) {
        _errorMessage = 'Prediction confidence too low (${(confidence * 100).toStringAsFixed(1)}%). Please upload a clearer picture.';
        throw Exception(_errorMessage);
      }
      
      _isLowConfidence = confidence < 0.85;
      
      if (_isLowConfidence) {
        _errorMessage = 'Low confidence Warning (${(confidence * 100).toStringAsFixed(1)}%). '
            'Consider uploading a clearer image of the affected leaf for better results.';
      }
      
      return result;
    } catch (e) {
      _errorMessage = 'Failed to analyze image: ${e.toString()}';
      rethrow;
    } finally {
      _isAnalyzing = false;
      notifyListeners();
    }
  }

  void reset() {
    _selectedImage = null;
    _predictionResult = null;
    _errorMessage = null;
    _isLowConfidence = false;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}

