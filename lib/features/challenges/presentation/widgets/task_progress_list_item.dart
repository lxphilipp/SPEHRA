// lib/features/challenges/presentation/widgets/task_progress_list_item.dart
import 'dart:convert';
import 'dart:io' as io;
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:iconsax/iconsax.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/trackable_task.dart';
import '../../domain/entities/task_progress_entity.dart';
import '../providers/challenge_provider.dart';

class TaskProgressListItem extends StatefulWidget {
  final TrackableTask taskDefinition;
  final TaskProgressEntity? taskProgress;
  final int taskIndex;

  const TaskProgressListItem({
    super.key,
    required this.taskDefinition,
    required this.taskProgress,
    required this.taskIndex,
  });

  @override
  State<TaskProgressListItem> createState() => _TaskProgressListItemState();
}

class _TaskProgressListItemState extends State<TaskProgressListItem> {
  String? _locationAddress;
  bool _isLoadingAddress = false;

  @override
  void initState() {
    super.initState();
    if (widget.taskDefinition is LocationVisitTask) {
      _fetchAddressForLocation();
    }
  }

  Future<void> _fetchAddressForLocation() async {
    final task = widget.taskDefinition as LocationVisitTask;
    setState(() {
      _isLoadingAddress = true;
    });

    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=${task.latitude}&lon=${task.longitude}');

    try {
      final response = await http.get(url, headers: {'User-Agent': 'de.app.sphera'});
      if (response.statusCode == 200 && mounted) {
        final data = json.decode(response.body);
        setState(() {
          _locationAddress = data['display_name'] ?? 'Address not found';
          _isLoadingAddress = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _locationAddress = 'Could not load address';
          _isLoadingAddress = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ChallengeProvider>();
    final isCompleted = widget.taskProgress?.isCompleted ?? false;
    final theme = Theme.of(context);

    Widget trailingWidget = _buildTrailingWidget(context, provider, isCompleted, theme);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      elevation: isCompleted ? 0 : 2,
      color: theme.colorScheme.surfaceContainerHighest,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: _buildLeadingIcon(isCompleted, theme),
            title: Text(
              widget.taskDefinition.description,
              style: TextStyle(
                decoration: isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                color: isCompleted ? theme.disabledColor : theme.textTheme.bodyLarge?.color,
              ),
            ),
            subtitle: _buildSubtitle(),
            trailing: trailingWidget,
          ),
          _buildContextualContent(theme), // Map or Image content
        ],
      ),
    );
  }

  /// Builds the icon on the left side.
  Icon _buildLeadingIcon(bool isCompleted, ThemeData theme) {
    if (isCompleted) {
      return Icon(Iconsax.tick_circle, color: Colors.green);
    }

    IconData iconData;
    switch (widget.taskDefinition.runtimeType) {
      case StepCounterTask:
        iconData = Iconsax.ruler;
        break;
      case LocationVisitTask:
        iconData = Iconsax.location;
        break;
      case ImageUploadTask:
        iconData = Iconsax.camera;
        break;
      default:
        iconData = Iconsax.task_square;
    }
    return Icon(iconData, color: theme.colorScheme.primary);
  }

  /// Builds the subtitle, which now also includes the address for location tasks.
  Widget? _buildSubtitle() {
    if (widget.taskDefinition is LocationVisitTask) {
      return Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Text(
          _isLoadingAddress ? 'Loading address...' : _locationAddress ?? '',
          style: Theme.of(context).textTheme.bodySmall,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }
    // Subtitle for images is now handled in _buildContextualContent
    return null;
  }

  /// Builds the content that depends on the task type (e.g., map or image).
  Widget _buildContextualContent(ThemeData theme) {
    final task = widget.taskDefinition;

    if (task is LocationVisitTask) {
      return Container(
        height: 200,
        color: theme.colorScheme.surfaceContainer,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: LatLng(task.latitude, task.longitude),
            initialZoom: 15.0,
            interactionOptions: const InteractionOptions(flags: InteractiveFlag.none), // Non-interactive
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'de.app.sphera',
              tileProvider: CancellableNetworkTileProvider(),
            ),
            CircleLayer(
              circles: [
                CircleMarker(
                  point: LatLng(task.latitude, task.longitude),
                  radius: task.radius,
                  useRadiusInMeter: true,
                  color: theme.colorScheme.primary.withOpacity(0.2),
                  borderColor: theme.colorScheme.primary,
                  borderStrokeWidth: 2,
                )
              ],
            ),
            // OSM Tile Usage Policy Requirement: Add attribution.
            RichAttributionWidget(
              attributions: [
                TextSourceAttribution(
                  'OpenStreetMap contributors',
                  onTap: () => launchUrl(Uri.parse('https://openstreetmap.org/copyright')),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // --- IMAGE FOR IMAGE UPLOAD TASK ---
    if (task is ImageUploadTask) {
      final imagePath = (widget.taskProgress?.progressValue is String)
          ? widget.taskProgress!.progressValue as String
          : null;
      if (imagePath != null && imagePath.isNotEmpty) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: io.File(imagePath).existsSync()
                ? Image.file(
              io.File(imagePath),
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
            )
                : Container( // Placeholder if image file is missing
              height: 150,
              width: double.infinity,
              color: theme.colorScheme.surfaceContainer,
              child: const Center(child: Icon(Iconsax.image, color: Colors.grey)),
            ),
          ),
        );
      }
    }

    // Return empty for other task types
    return const SizedBox.shrink();
  }

  /// Builds the interactive widget on the right side.
  Widget _buildTrailingWidget(BuildContext context, ChallengeProvider provider, bool isCompleted, ThemeData theme) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: _buildCurrentTrailingState(context, provider, isCompleted, theme),
    );
  }

  Widget _buildCurrentTrailingState(BuildContext context, ChallengeProvider provider, bool isCompleted, ThemeData theme) {
    if (provider.isVerifyingTask(widget.taskIndex)) {
      return Container(
        key: const ValueKey('loader'),
        width: 48.0,
        height: 48.0,
        padding: const EdgeInsets.all(12.0),
        child: const CircularProgressIndicator(strokeWidth: 2.0),
      );
    }

    switch (widget.taskDefinition) {
      case CheckboxTask():
        return Checkbox(
          key: const ValueKey('checkbox'),
          value: isCompleted,
          onChanged: (bool? value) {
            if (value != null) provider.toggleCheckboxTask(widget.taskIndex, value);
          },
        );

      case StepCounterTask():
        final stepsDone = (widget.taskProgress?.progressValue as int?) ?? 0;
        final target = (widget.taskDefinition as StepCounterTask).targetSteps;
        return TextButton(
          key: const ValueKey('steps'),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('$stepsDone / $target', style: theme.textTheme.bodyMedium),
              const Text('Refresh', style: TextStyle(fontSize: 12)),
            ],
          ),
          onPressed: () => provider.refreshStepCounterTask(widget.taskIndex),
        );

      case LocationVisitTask():
        return IconButton(
          key: const ValueKey('location'),
          icon: Icon(Iconsax.location_tick, color: isCompleted ? Colors.green : theme.iconTheme.color),
          tooltip: "Check-in",
          onPressed: isCompleted ? null : () => provider.verifyLocationForTask(widget.taskIndex),
        );

      case ImageUploadTask():
        if (isCompleted) {
          return const Icon(Icons.check_circle, color: Colors.green, key: ValueKey('image_done'));
        }
        return IconButton(
          key: const ValueKey('image'),
          icon: const Icon(Iconsax.camera),
          tooltip: "Select image as proof",
          onPressed: () => provider.selectImageForTask(widget.taskIndex),
        );

      default:
        return const SizedBox.shrink(key: ValueKey('empty'));
    }
  }
}