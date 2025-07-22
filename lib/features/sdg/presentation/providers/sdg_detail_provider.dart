import 'package:flutter/material.dart';
import '../../domain/entities/sdg_detail_entity.dart';
import '../../domain/usecases/get_sdg_detail_by_id_usecase.dart';

class SdgDetailProvider with ChangeNotifier {
  final GetSdgDetailByIdUseCase _getSdgDetailsByIdUseCase;

  SdgDetailProvider({required GetSdgDetailByIdUseCase getSdgDetailsByIdUseCase})
      : _getSdgDetailsByIdUseCase = getSdgDetailsByIdUseCase;

  SdgDetailEntity? _currentSdgDetail;
  SdgDetailEntity? get currentSdgDetail => _currentSdgDetail;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> fetchSdgDetails(String sdgId) async {
    if (sdgId.isEmpty) {
      _error = "SDG ID is missing.";
      _isLoading = false;
      _currentSdgDetail = null;
      notifyListeners();
      return;
    }
    // Wenn bereits für diese ID geladen und kein Fehler, nicht erneut laden (optional)
    if (_currentSdgDetail?.id == sdgId && _error == null && !_isLoading) {
      // return;
    }


    _isLoading = true;
    _error = null;
    _currentSdgDetail = null; // Vorherige Daten löschen für klares Lade-Feedback
    notifyListeners();

    final detail = await _getSdgDetailsByIdUseCase(sdgId);
    if (detail != null) {
      _currentSdgDetail = detail;
    } else {
      _error = "Details for SDG '$sdgId' could not be loaded.";
    }
    _isLoading = false;
    notifyListeners();
  }

  // Methode, um den State zurückzusetzen, wenn der Screen verlassen wird
  void clearDetails() {
    _currentSdgDetail = null;
    _error = null;
    _isLoading = false;
    // notifyListeners(); // Optional, je nachdem, ob die UI darauf reagieren muss
  }
}