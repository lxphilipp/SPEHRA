/// Provides state management for SDG (Sustainable Development Goal) detail view.
///
/// This provider handles fetching and storing the details of a specific SDG,
/// managing loading states, and error handling. It uses a [ChangeNotifier]
/// to notify listeners when the state changes.
import 'package:flutter/material.dart';
import '../../domain/entities/sdg_detail_entity.dart';
import '../../domain/usecases/get_sdg_detail_by_id_usecase.dart';

/// A [ChangeNotifier] that manages the state for displaying SDG details.
///
/// It fetches SDG details using [GetSdgDetailByIdUseCase] and provides
/// the current SDG detail, loading status, and error messages to the UI.
class SdgDetailProvider with ChangeNotifier {
  /// The use case responsible for fetching SDG details by ID.
  final GetSdgDetailByIdUseCase _getSdgDetailsByIdUseCase;

  /// Creates an instance of [SdgDetailProvider].
  ///
  /// Requires a [GetSdgDetailByIdUseCase] to fetch SDG details.
  SdgDetailProvider({required GetSdgDetailByIdUseCase getSdgDetailsByIdUseCase})
      : _getSdgDetailsByIdUseCase = getSdgDetailsByIdUseCase;

  /// The currently loaded SDG detail. Null if no detail is loaded or an error occurred.
  SdgDetailEntity? _currentSdgDetail;
  /// Getter for the currently loaded SDG detail.
  SdgDetailEntity? get currentSdgDetail => _currentSdgDetail;

  /// Indicates whether SDG details are currently being fetched.
  bool _isLoading = false;
  /// Getter for the loading status. True if data is being fetched, false otherwise.
  bool get isLoading => _isLoading;

  /// Stores any error message that occurred during fetching SDG details. Null if no error.
  String? _error;
  /// Getter for the error message.
  String? get error => _error;

  /// Fetches the details for a given [sdgId].
  ///
  /// If [sdgId] is empty, an error state is set.
  /// If the details for the given [sdgId] are already loaded and there's no error,
  /// this method might do nothing to avoid redundant fetches (currently, this condition is empty).
  ///
  /// Sets loading state to true, clears previous errors and details, and notifies listeners.
  /// After fetching, updates [_currentSdgDetail] with the fetched data or [_error] if fetching fails.
  /// Finally, sets loading state to false and notifies listeners again.
  Future<void> fetchSdgDetails(String sdgId) async {
    if (sdgId.isEmpty) {
      _error = "SDG ID is missing.";
      _isLoading = false;
      _currentSdgDetail = null;
      notifyListeners();
      return;
    }

    // Optimization: If the same SDG is already loaded and no error occurred,
    // and not currently loading, potentially skip refetching.
    // This condition is currently a no-op but can be expanded.
    if (_currentSdgDetail?.id == sdgId && _error == null && !_isLoading) {
    }


    _isLoading = true;
    _error = null;
    _currentSdgDetail = null;
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

  /// Clears the current SDG details, error message, and resets loading state.
  ///
  /// This method can be called, for example, when the SDG detail screen is disposed
  /// to ensure that stale data is not shown when the screen is revisited.
  /// The `notifyListeners()` call is optional and depends on whether the UI
  /// needs to react immediately to the cleared state.
  void clearDetails() {
    _currentSdgDetail = null;
    _error = null;
    _isLoading = false;
    // notifyListeners(); // Optional, depending on whether the UI needs to react
  }
}
