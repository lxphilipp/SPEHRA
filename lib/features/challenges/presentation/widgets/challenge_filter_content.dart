import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/challenge_filter_state.dart';

class ChallengeFilterContent extends StatefulWidget {
  final ChallengeFilterState initialState;
  final ValueChanged<ChallengeFilterState> onStateChanged;

  const ChallengeFilterContent({
    super.key,
    required this.initialState,
    required this.onStateChanged,
  });

  @override
  State<ChallengeFilterContent> createState() => _ChallengeFilterContentState();
}

class _ChallengeFilterContentState extends State<ChallengeFilterContent> {
  late ChallengeFilterState _currentFilterState;
  late final TextEditingController _searchController;

  // Data for filter options
  final List<String> _difficulties = ["Easy", "Normal", "Advanced", "Experienced"];
  final Map<String, String> _sdgData = {
    for (var i = 1; i <= 17; i++) 'goal$i': 'SDG $i'
  };
  final Map<String, String> _sdgImagePaths = {
    for (var i = 1; i <= 17; i++) 'goal$i': 'assets/icons/17_SDG_Icons/$i.png'
  };

  @override
  void initState() {
    super.initState();
    _currentFilterState = widget.initialState;
    _searchController = TextEditingController(text: _currentFilterState.searchText);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateState(ChallengeFilterState newState) {
    if (!mounted) return;
    setState(() {
      _currentFilterState = newState;
    });
    widget.onStateChanged(_currentFilterState);
  }

  void _pickDateRange() async {
    final newDateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _currentFilterState.dateRange,
    );
    if (newDateRange != null) {
      _updateState(_currentFilterState.copyWith(dateRange: newDateRange));
    }
  }

  void _showAddSdgDialog() {
    final availableOptions = _sdgData.keys.where((key) => !_currentFilterState.selectedSdgKeys.contains(key)).toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add SDG Category'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: availableOptions.length,
            itemBuilder: (context, index) {
              final key = availableOptions[index];
              return ListTile(
                leading: Image.asset(_sdgImagePaths[key]!, width: 32, height: 32),
                title: Text(_sdgData[key]!),
                onTap: () {
                  final newSet = Set<String>.from(_currentFilterState.selectedSdgKeys)..add(key);
                  _updateState(_currentFilterState.copyWith(selectedSdgKeys: newSet));
                  Navigator.of(context).pop();
                },
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // 1. Text Search
        TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            labelText: 'Search by title...',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
          onChanged: (value) => _updateState(_currentFilterState.copyWith(searchText: value)),
        ),
        const SizedBox(height: 24),

        // 2. Difficulty
        Text('Difficulty', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          children: _difficulties.map((difficulty) {
            final isSelected = _currentFilterState.selectedDifficulties.contains(difficulty);
            return FilterChip(
              label: Text(difficulty),
              selected: isSelected,
              onSelected: (selected) {
                final newSet = Set<String>.from(_currentFilterState.selectedDifficulties);
                if (selected) {
                  newSet.add(difficulty);
                } else {
                  newSet.remove(difficulty);
                }
                _updateState(_currentFilterState.copyWith(selectedDifficulties: newSet));
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 24),

        // 3. SDG Categories (interactive)
        Text('SDG Categories', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: [
            // The already selected chips
            ..._currentFilterState.selectedSdgKeys.map((key) {
              return InputChip(
                label: Text(_sdgData[key] ?? key),
                avatar: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  child: Image.asset(_sdgImagePaths[key]!),
                ),
                onDeleted: () {
                  final newSet = Set<String>.from(_currentFilterState.selectedSdgKeys)..remove(key);
                  _updateState(_currentFilterState.copyWith(selectedSdgKeys: newSet));
                },
              );
            }),
            // The button to add new chips
            ActionChip(
              avatar: const Icon(Icons.add),
              label: const Text('Add'),
              onPressed: _showAddSdgDialog,
            ),
          ],
        ),
        const SizedBox(height: 24),

        // 4. Date Range
        Text('Creation Date', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        InkWell(
          onTap: _pickDateRange,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outline),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _currentFilterState.dateRange == null
                      ? 'Select date range'
                      : '${DateFormat('dd.MM.yy').format(_currentFilterState.dateRange!.start)} - ${DateFormat('dd.MM.yy').format(_currentFilterState.dateRange!.end)}',
                ),
                const Icon(Icons.calendar_today_outlined),
              ],
            ),
          ),
        ),
      ],
    );
  }
}