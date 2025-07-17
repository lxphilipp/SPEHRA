import 'dart:math'; // Required for the min() function in the points getter.
import 'package:equatable/equatable.dart';
import 'trackable_task.dart'; // Imports the new, modular task entities.

/// Represents a challenge in the domain layer.
///
/// This class is immutable and contains all business logic
/// for calculating points and difficulty, as well as validatin^^g
/// the task composition.
class ChallengeEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final List<String> categories;
  final String authorId;
  final DateTime? createdAt;
  final List<TrackableTask> tasks;
  final Map<String, String>? llmFeedback;
  final int? durationInDays; // <-- NEW FIELD ADDED

  // --- Constants for game balance ---

  /// The base points for a simple, non-verifiable checkbox task.
  static const int _pointsPerCheckbox = 5;

  /// The base points for a task that requires proof (e.g., photo, location).
  static const int _pointsPerProvableTask = 50;

  /// Bonus points per 1000 steps for the step counter task.
  static const int _pointsPer1000Steps = 10;

  /// The absolute point limit that a single challenge can grant.
  static const int maxPoints = 500;

  /// Defines how many points for checkboxes are unlocked per provable task.
  /// This is the core of the "points budget" model.
  static const int unlockedCheckboxPointsPerProvableTask = 25;


  const ChallengeEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.categories,
    required this.authorId,
    this.createdAt,
    this.tasks = const [],
    this.llmFeedback,
    this.durationInDays, // <-- NEW FIELD ADDED
  });

  /// Calculates the total points of the challenge.
  ///
  /// This method implements the "points budget" logic:
  /// 1. It calculates the sum of points from provable tasks.
  /// 2. It calculates how many points can be earned through checkboxes (the budget).
  /// 3. It adds points from checkboxes only up to this budget limit.
  /// 4. The total score is capped by `maxPoints`.
  int get calculatedPoints {
    // 1. Count the provable tasks to determine the budget.
    final provableTaskCount = tasks.where((task) => task is! CheckboxTask).length;

    // 2. Calculate the maximum points budget that can be earned through checkboxes.
    final maxAllowedCheckboxPoints = provableTaskCount * unlockedCheckboxPointsPerProvableTask;

    // 3. Calculate the actual, potential points from the checkboxes.
    final actualCheckboxPoints = tasks
        .whereType<CheckboxTask>()
        .fold(0, (sum, task) => sum + _pointsPerCheckbox);

    // 4. Determine the creditable checkbox points (the minimum of budget and actual points).
    final countableCheckboxPoints = min(maxAllowedCheckboxPoints, actualCheckboxPoints);

    // 5. Calculate the points from the provable tasks.
    final int provableTasksPoints = tasks.fold(0, (sum, task) {
      if (task is LocationVisitTask || task is ImageUploadTask) {
        return sum + _pointsPerProvableTask;
      }
      if (task is StepCounterTask) {
        final stepBonus = (task.targetSteps / 1000).floor() * _pointsPer1000Steps;
        return sum + _pointsPerProvableTask + stepBonus;
      }
      return sum; // Ignores checkboxes in this fold.
    });

    // 6. Add the points from provable tasks and the creditable checkbox points.
    final totalPoints = countableCheckboxPoints + provableTasksPoints;

    // 7. Apply the global point limit.
    return min(totalPoints, maxPoints);
  }

  /// Calculates the difficulty of the challenge based on the total points.
  String get calculatedDifficulty {
    final points = calculatedPoints;
    if (points > 350) return "Experienced";
    if (points > 150) return "Advanced";
    if (points > 50) return "Normal";
    return "Easy";
  }

  /// Returns the creditable points for a specific task at an index.
  /// This is the "information method" for the UI, so it doesn't need to know the logic.
  int getPointsForTaskAtIndex(int index) {
    if (index < 0 || index >= tasks.length) {
      return 0; // Safeguard against invalid index.
    }

    final task = tasks[index];

    // Points for provable tasks are straightforward.
    if (task is! CheckboxTask) {
      if (task is LocationVisitTask || task is ImageUploadTask) {
        return _pointsPerProvableTask;
      }
      if (task is StepCounterTask) {
        final stepBonus = (task.targetSteps / 1000).floor() * _pointsPer1000Steps;
        return _pointsPerProvableTask + stepBonus;
      }
      return 0; // Should not happen.
    }

    // For CheckboxTasks, the budget must be checked.
    final provableTaskCount = tasks.where((t) => t is! CheckboxTask).length;
    final maxAllowedCheckboxPoints = provableTaskCount * unlockedCheckboxPointsPerProvableTask;

    // Find the "rank" of the current checkbox.
    int checkboxRank = -1;
    for (int i = 0; i <= index; i++) {
      if (tasks[i] is CheckboxTask) {
        checkboxRank++;
      }
    }

    // Calculate the points already "consumed" by previous checkboxes.
    final pointsConsumedByPreviousCheckboxes = checkboxRank * _pointsPerCheckbox;

    // If the current checkbox still fits within the budget, it grants points, otherwise not.
    if (pointsConsumedByPreviousCheckboxes < maxAllowedCheckboxPoints) {
      return _pointsPerCheckbox;
    } else {
      return 0;
    }
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    categories,
    authorId,
    createdAt,
    tasks,
    llmFeedback,
    durationInDays,
  ];
}