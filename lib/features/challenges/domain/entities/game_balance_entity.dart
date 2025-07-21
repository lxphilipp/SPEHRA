import 'package:equatable/equatable.dart';

class GameBalanceEntity extends Equatable {
  final int pointsPerCheckboxTask;
  final int pointsPerProvableTask;
  final int pointsPer1000Steps;
  final int maxTotalPoints;
  final int unlockedCheckboxPointsPerProvableTask;
  final List<Map<String, dynamic>> difficultyThresholds;
  final Map<int, double> groupChallengeMilestones;

  const GameBalanceEntity({
    required this.pointsPerCheckboxTask,
    required this.pointsPerProvableTask,
    required this.pointsPer1000Steps,
    required this.maxTotalPoints,
    required this.unlockedCheckboxPointsPerProvableTask,
    required this.difficultyThresholds,
    required this.groupChallengeMilestones,
  });

  @override
  List<Object?> get props => [
    pointsPerCheckboxTask,
    pointsPerProvableTask,
    pointsPer1000Steps,
    maxTotalPoints,
    unlockedCheckboxPointsPerProvableTask,
    difficultyThresholds,
    groupChallengeMilestones,
  ];
}