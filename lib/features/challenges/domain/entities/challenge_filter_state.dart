import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Represents the state of the challenge filter.
///
/// This class holds the current filter values for searching and filtering
/// challenges.
class ChallengeFilterState extends Equatable {
  /// The current search text.
  final String searchText;

  /// The set of selected SDG keys.
  final Set<String> selectedSdgKeys;

  /// The set of selected difficulties.
  final Set<String> selectedDifficulties;

  /// The selected date range for filtering challenges.
  final DateTimeRange? dateRange;

  /// Creates a [ChallengeFilterState].
  ///
  /// Defaults to empty search text, no selected SDG keys, no selected
  /// difficulties, and no date range.
  const ChallengeFilterState({
    this.searchText = '',
    this.selectedSdgKeys = const {},
    this.selectedDifficulties = const {},
    this.dateRange,
  });

  /// Creates a copy of this [ChallengeFilterState] but with the given fields
  /// replaced with the new values.
  ChallengeFilterState copyWith({
    String? searchText,
    Set<String>? selectedSdgKeys,
    Set<String>? selectedDifficulties,
    DateTimeRange? dateRange,
  }) {
    return ChallengeFilterState(
      searchText: searchText ?? this.searchText,
      selectedSdgKeys: selectedSdgKeys ?? this.selectedSdgKeys,
      selectedDifficulties: selectedDifficulties ?? this.selectedDifficulties,
      dateRange: dateRange ?? this.dateRange,
    );
  }

  @override
  List<Object?> get props => [searchText, selectedSdgKeys, selectedDifficulties, dateRange];
}
