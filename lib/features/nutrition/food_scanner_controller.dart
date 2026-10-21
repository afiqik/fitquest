import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/ai/food_ai_service.dart';
import '../../core/ai/scanned_food_result.dart';

enum FoodScannerState {
  idle,
  selectingImage,
  imageSelected,
  analyzing,
  success,
  error,
  cancelled,
}

class FoodScannerController extends ChangeNotifier {
  final FoodAiService _aiService;
  final ImagePicker _picker;

  FoodScannerState _state = FoodScannerState.idle;
  FoodScannerState get state => _state;

  File? _selectedImage;
  File? get selectedImage => _selectedImage;

  ScannedFoodResult? _result;
  ScannedFoodResult? get result => _result;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _disposed = false;

  FoodScannerController({
    FoodAiService? aiService,
    ImagePicker? picker,
  })  : _aiService = aiService ?? FoodAiService(),
        _picker = picker ?? ImagePicker();

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  /// Select image from camera or gallery
  Future<void> pickImage(ImageSource source) async {
    if (_state == FoodScannerState.analyzing) return; // guard duplicate

    _state = FoodScannerState.selectingImage;
    _errorMessage = null;
    _safeNotifyListeners();

    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (picked == null) {
        // User cancelled picker
        _state = _selectedImage != null
            ? FoodScannerState.imageSelected
            : FoodScannerState.cancelled;
        _safeNotifyListeners();
        return;
      }

      _selectedImage = File(picked.path);
      _state = FoodScannerState.imageSelected;
      _safeNotifyListeners();
    } catch (e) {
      _state = FoodScannerState.error;
      _errorMessage = 'Unable to open camera/gallery: ${e.toString()}';
      _safeNotifyListeners();
    }
  }

  /// Analyze currently selected image
  Future<void> analyzeImage() async {
    if (_selectedImage == null) {
      _state = FoodScannerState.idle;
      _errorMessage = 'Please select an image first.';
      _safeNotifyListeners();
      return;
    }

    if (_state == FoodScannerState.analyzing) return; // prevent duplicate submission

    _state = FoodScannerState.analyzing;
    _errorMessage = null;
    _safeNotifyListeners();

    try {
      final res = await _aiService.analyzeFoodImage(_selectedImage!);
      _result = res;
      _state = FoodScannerState.success;
      _safeNotifyListeners();
    } on FoodAiException catch (e) {
      _state = FoodScannerState.error;
      _errorMessage = e.message;
      _safeNotifyListeners();
    } catch (e) {
      _state = FoodScannerState.error;
      _errorMessage = 'An unexpected error occurred while analyzing the meal. Please try again.';
      _safeNotifyListeners();
    }
  }

  /// Retry analysis or image selection
  void retry() {
    if (_selectedImage != null) {
      analyzeImage();
    } else {
      _state = FoodScannerState.idle;
      _errorMessage = null;
      _safeNotifyListeners();
    }
  }

  /// Reset to clean idle state
  void reset() {
    _state = FoodScannerState.idle;
    _selectedImage = null;
    _result = null;
    _errorMessage = null;
    _safeNotifyListeners();
  }

  /// Cancel and return
  void cancel() {
    _state = FoodScannerState.cancelled;
    _safeNotifyListeners();
  }
}
