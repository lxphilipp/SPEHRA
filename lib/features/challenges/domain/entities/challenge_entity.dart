import 'dart:math';
import 'package:equatable/equatable.dart';
import 'game_balance_entity.dart';
import 'trackable_task.dart';

/// Represents a challenge in the application.
class ChallengeEntity extends Equatable {
  /// The unique identifier of the challenge.
  final String id;

  /// The title of the challenge.
  final String title;

  /// A description of the challenge.
  final String description;

  /// A list of categories the challenge belongs to.
  final List<String> categories;

  /// The ID of the author who created the challenge.
  final String authorId;

  /// The date and time when the challenge was created.
  final DateTime? createdAt;

  /// A list of tasks associated with the challenge.
  final List<TrackableTask> tasks;

  /// Optional feedback from an LLM regarding the challenge.
  final Map<String, String>? llmFeedback;

  /// The duration of the challenge in days.
  final int? durationInDays;

  /// Creates a [ChallengeEntity].
  const ChallengeEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.categories,
    required this.authorId,
    this.createdAt,
    this.tasks = const [],
    this.llmFeedback,
    this.durationInDays,
  });

  /// Calculates the total points for the challenge based on the provided [balance].
  int calculatePoints(GameBalanceEntity balance) {
    final provableTaskCount = tasks.where((task) => task is! CheckboxTask).length;
    final maxAllowedCheckboxPoints = provableTaskCount * balance.unlockedCheckboxPointsPerProvableTask;
    final actualCheckboxPoints = tasks.whereType<CheckboxTask>().length * balance.pointsPerCheckboxTask;
    final countableCheckboxPoints = min(maxAllowedCheckboxPoints, actualCheckboxPoints);

    final int provableTasksPoints = tasks.fold(0, (sum, task) {
      if (task is LocationVisitTask || task is ImageUploadTask) {
        return sum + balance.pointsPerProvableTask;
      }
      if (task is StepCounterTask) {
        final stepBonus = (task.targetSteps / 1000).floor() * balance.pointsPer1000Steps;
        return sum + balance.pointsPerProvableTask + stepBonus;
      }
      return sum;
    });

    final totalPoints = countableCheckboxPoints + provableTasksPoints;
    return min(totalPoints, balance.maxTotalPoints);
  }

  /// Calculates the difficulty of the challenge based on its points and the provided [balance].
  String calculateDifficulty(GameBalanceEntity balance) {
    final points = calculatePoints(balance);
    String difficulty = "Easy"; // Default
    for (var threshold in balance.difficultyThresholds.reversed) {
      if (points >= (threshold['points'] as int)) {
        difficulty = threshold['name'] as String;
        break;
      }
    }
    return difficulty;
  }

  /// Calculates the points for a specific task at the given [index] based on the provided [balance].
  ///
  /// Returns 0 if the index is out of bounds.
  int getPointsForTaskAtIndex(int index, GameBalanceEntity balance) {
    if (index < 0 || index >= tasks.length) {
      return 0;
    }

    final task = tasks[index];

    if (task is! CheckboxTask) {
      if (task is LocationVisitTask || task is ImageUploadTask) {
        return balance.pointsPerProvableTask;
      }
      if (task is StepCounterTask) {
        final stepBonus = (task.targetSteps / 1000).floor() * balance.pointsPer1000Steps;
        return balance.pointsPerProvableTask + stepBonus;
      }
      return 0;
    }

    final provableTaskCount = tasks.where((t) => t is! CheckboxTask).length;
    final maxAllowedCheckboxPoints = provableTaskCount * balance.unlockedCheckboxPointsPerProvableTask;

    int checkboxRank = -1;
    for (int i = 0; i <= index; i++) {
      if (tasks[i] is CheckboxTask) {
        checkboxRank++;
      }
    }

    final pointsConsumedByPreviousCheckboxes = checkboxRank * balance.pointsPerCheckboxTask;

    if (pointsConsumedByPreviousCheckboxes < maxAllowedCheckboxPoints) {
      return balance.pointsPerCheckboxTask;
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
