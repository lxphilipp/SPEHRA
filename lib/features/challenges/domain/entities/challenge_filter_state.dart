// ...
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class ChallengeFilterState extends Equatable {
  final String searchText;
  final Set<String> selectedSdgKeys; // <-- HINZUGEFÜGT
  final Set<String> selectedDifficulties;
  final DateTimeRange? dateRange;

  const ChallengeFilterState({
    this.searchText = '',
    this.selectedSdgKeys = const {}, // <-- HINZUGEFÜGT
    this.selectedDifficulties = const {},
    this.dateRange,
  });

  ChallengeFilterState copyWith({
    String? searchText,
    Set<String>? selectedSdgKeys, // <-- HINZUGEFÜGT
    Set<String>? selectedDifficulties,
    DateTimeRange? dateRange,
  }) {
    return ChallengeFilterState(
      searchText: searchText ?? this.searchText,
      selectedSdgKeys: selectedSdgKeys ?? this.selectedSdgKeys, // <-- HINZUGEFÜGT
      selectedDifficulties: selectedDifficulties ?? this.selectedDifficulties,
      dateRange: dateRange ?? this.dateRange,
    );
  }

  @override
  List<Object?> get props => [searchText, selectedSdgKeys, selectedDifficulties, dateRange]; // <-- ERGÄNZT
}