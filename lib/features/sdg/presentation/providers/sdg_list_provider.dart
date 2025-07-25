import 'package:flutter/material.dart';
import '../../domain/entities/sdg_list_item_entity.dart';
import '../../domain/usecases/get_all_sdg_list_items_usecase.dart';

class SdgListProvider with ChangeNotifier {
  final GetAllSdgListItemsUseCase _getAllSdgListItemsUseCase;

  SdgListProvider({required GetAllSdgListItemsUseCase getAllSdgListItemsUseCase})
      : _getAllSdgListItemsUseCase = getAllSdgListItemsUseCase {
    fetchSdgListItems();
  }

  List<SdgListItemEntity> _sdgListItems = [];
  List<SdgListItemEntity> get sdgListItems => _sdgListItems;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

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