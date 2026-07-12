import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';

class TtsService {
  final FlutterTts _flutterTts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isSpeaking = false;

  bool get isSpeaking => _isSpeaking;

  TtsService() {
    _initTts();
  }

  Future<void> _initTts() async {
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
    
    // Check if ur-PK is available, otherwise it falls back
    var engines = await _flutterTts.getEngines;
    if (engines != null) {
      for (dynamic engine in engines) {
        // Just probing, it usually uses default engine
      }
    }
  }

  Future<bool> setLanguage(String languageCode) async {
    if (languageCode == 'ur') {
      var isAvailable = await _flutterTts.isLanguageAvailable("ur-PK");
      if (isAvailable is bool && isAvailable) {
        await _flutterTts.setLanguage("ur-PK");
        return true;
      }
      isAvailable = await _flutterTts.isLanguageAvailable("ur");
      if (isAvailable is bool && isAvailable) {
        await _flutterTts.setLanguage("ur");
        return true;
      }
      return false; // Urdu not available
    } else {
      await _flutterTts.setLanguage("en-US");
      return true;
    }
  }

  Future<bool> speak(String text, String languageCode, {void Function()? onCompletion}) async {
    bool canSpeakLocally = await setLanguage(languageCode);
    
    if (canSpeakLocally) {
      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
        if (onCompletion != null) onCompletion();
      });

      _isSpeaking = true;
      await _flutterTts.speak(text);
      return true;
    } else {
      // Fallback: Use unofficial Google Translate TTS endpoint via audioplayers
      _isSpeaking = true;
      
      try {
        // Google Translate TTS limits strings to ~200 chars. We split by periods.
        // We replace Urdu dot (۔) with English dot (.) to split uniformly.
        List<String> sentences = text.replaceAll('۔', '.').split('.');
        
        for (String sentence in sentences) {
          if (!_isSpeaking) break;
          sentence = sentence.trim();
          if (sentence.isEmpty) continue;
          
          final url = 'https://translate.google.com/translate_tts?ie=UTF-8&tl=$languageCode&client=tw-ob&q=${Uri.encodeComponent(sentence)}';
          await _audioPlayer.play(UrlSource(url));
          
          // Wait for this sentence to finish playing or be stopped/errored
          await _audioPlayer.onPlayerStateChanged.firstWhere((state) => 
            state == PlayerState.completed || 
            state == PlayerState.stopped || 
            state == PlayerState.disposed
          );
        }
        
        _isSpeaking = false;
        if (onCompletion != null) onCompletion();
        return true;
      } catch (e) {
        _isSpeaking = false;
        return false;
      }
    }
  }

  Future<void> stop() async {
    await _flutterTts.stop();
    await _audioPlayer.stop();
    _isSpeaking = false;
  }
}
