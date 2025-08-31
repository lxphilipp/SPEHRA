import 'package:flutter/material.dart';
import '../../domain/entities/sdg_list_item_entity.dart';
import '../../domain/usecases/get_all_sdg_list_items_usecase.dart';

/// A [ChangeNotifier] that provides a list of SDG items.
///
/// This provider fetches and manages the state of the SDG list items,
/// including loading status and error handling.
class SdgListProvider with ChangeNotifier {
  final GetAllSdgListItemsUseCase _getAllSdgListItemsUseCase;

  /// Creates an [SdgListProvider].
  ///
  /// Requires a [GetAllSdgListItemsUseCase] to fetch the SDG list items.
  /// Immediately calls [fetchSdgListItems] upon initialization.
  SdgListProvider({required GetAllSdgListItemsUseCase getAllSdgListItemsUseCase})
      : _getAllSdgListItemsUseCase = getAllSdgListItemsUseCase {
    fetchSdgListItems();
  }

  /// The list of SDG list items.
  List<SdgListItemEntity> _sdgListItems = [];
  /// Returns the current list of SDG list items.
  List<SdgListItemEntity> get sdgListItems => _sdgListItems;

  /// Whether the SDG list items are currently being fetched.
  bool _isLoading = false;
  /// Returns `true` if the SDG list items are currently being fetched, `false` otherwise.
  bool get isLoading => _isLoading;

  /// Any error that occurred while fetching the SDG list items.
  String? _error;
  /// Returns an error message if an error occurred while fetching, otherwise `null`.
  String? get error => _error;

  /// Fetches the list of SDG items.
  ///
  /// Sets [isLoading] to `true` and clears any previous [error].
  /// Notifies listeners before and after the fetch operation.
  /// If the fetch is successful, [sdgListItems] is updated.
  /// If an error occurs, [error] is set and [sdgListItems] is cleared.
  Future<void> fetchSdgListItems() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final items = await _getAllSdgListItemsUseCase();

    if (items != null) {
      _sdgListItems = items;
    } else {
      _error = "Could not load the list of SDGs.";
      _sdgListItems = [];
    }
    _isLoading = false;
    notifyListeners();
  }
}
