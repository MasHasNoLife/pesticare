import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/scan_record.dart';

/// Service for managing scan history persistence.
class HistoryService {
  static const String _historyKey = 'scan_history';
  static const int _maxHistoryItems = 50;

  /// Save a scan record to history
  Future<void> saveRecord(ScanRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistory();
    
    // Copy image to app storage for persistence
    final savedImagePath = await _saveImageToStorage(record.imagePath, record.id);
    
    // Create record with saved image path
    final savedRecord = ScanRecord(
      id: record.id,
      cropName: record.cropName,
      diseaseName: record.diseaseName,
      confidence: record.confidence,
      pesticide: record.pesticide,
      dosage: record.dosage,
      instructions: record.instructions,
      imagePath: savedImagePath,
      timestamp: record.timestamp,
    );
    
    // Add to beginning of list (newest first)
    history.insert(0, savedRecord);
    
    // Limit history size
    if (history.length > _maxHistoryItems) {
      // Delete old images
      for (int i = _maxHistoryItems; i < history.length; i++) {
        await _deleteImage(history[i].imagePath);
      }
      history.removeRange(_maxHistoryItems, history.length);
    }
    
    // Save to SharedPreferences
    final jsonList = history.map((r) => r.toJson()).toList();
    await prefs.setString(_historyKey, jsonEncode(jsonList));
  }

  /// Get all scan history records
  Future<List<ScanRecord>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_historyKey);
    
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    
    try {
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList
          .map((json) => ScanRecord.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Delete a specific record by ID
  Future<void> deleteRecord(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistory();
    
    final index = history.indexWhere((r) => r.id == id);
    if (index != -1) {
      // Delete associated image
      await _deleteImage(history[index].imagePath);
      history.removeAt(index);
      
      final jsonList = history.map((r) => r.toJson()).toList();
      await prefs.setString(_historyKey, jsonEncode(jsonList));
    }
  }

  /// Clear all history
  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistory();
    
    // Delete all images
    for (final record in history) {
      await _deleteImage(record.imagePath);
    }
    
    await prefs.remove(_historyKey);
  }

  /// Copy image to app's documents directory for persistence
  Future<String> _saveImageToStorage(String sourcePath, String recordId) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final historyDir = Directory('${directory.path}/scan_history');
      if (!await historyDir.exists()) {
        await historyDir.create(recursive: true);
      }
      
      final sourceFile = File(sourcePath);
      final extension = sourcePath.split('.').last;
      final destPath = '${historyDir.path}/$recordId.$extension';
      
      await sourceFile.copy(destPath);
      return destPath;
    } catch (e) {
      // Return original path if copy fails
      return sourcePath;
    }
  }

  /// Delete an image file
  Future<void> _deleteImage(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Ignore deletion errors
    }
  }
}
