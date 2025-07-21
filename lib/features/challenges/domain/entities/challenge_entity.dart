import 'dart:math';
import 'package:equatable/equatable.dart';
import 'game_balance_entity.dart';
import 'trackable_task.dart';

class ChallengeEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final List<String> categories;
  final String authorId;
  final DateTime? createdAt;
  final List<TrackableTask> tasks;
  final Map<String, String>? llmFeedback;
  final int? durationInDays;

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