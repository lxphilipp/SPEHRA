// lib/features/profile/data/repositories/user_profile_repository_impl.dart
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../../domain/utils/level_utils.dart';
import '../datasources/profile_remote_datasource.dart';
import '../datasources/profile_stats_datasource.dart';
import '../models/user_profile_model.dart';

class UserProfileRepositoryImpl implements UserProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final ProfileStatsDataSource statsDataSource;

  final Map<String, Color> _sdgColorMap = const {
    'goal1': goal1, 'goal2': goal2, 'goal3': goal3, 'goal4': goal4,
    'goal5': goal5, 'goal6': goal6, 'goal7': goal7, 'goal8': goal8,
    'goal9': goal9, 'goal10': goal10, 'goal11': goal11, 'goal12': goal12,
    'goal13': goal13, 'goal14': goal14, 'goal15': goal15, 'goal16': goal16,
    'goal17': goal17,
  };

  UserProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.statsDataSource,
  });

  @override
  Stream<List<PieChartSectionData>?> getProfileStatsPieChartStream(String userId) {
    if (userId.isEmpty) return Stream.value(null);

    return statsDataSource.getCompletedTaskIdsStream(userId).asyncMap((taskIds) async {
      // --- DEBUG CHECKPOINT 4 ---
      AppLogger.debug("DEBUG (Repository): Received task IDs for processing: ${taskIds?.length ?? 'null'}");
      if (taskIds == null) return null;
      if (taskIds.isEmpty) return <PieChartSectionData>[];

      try {
        final challengesData = await statsDataSource.getChallengeDetailsForTasks(taskIds);
        // --- DEBUG CHECKPOINT 5 ---
        AppLogger.debug("DEBUG (Repository): Received challenge data for processing: ${challengesData?.length ?? 'null'} documents.");
        if (challengesData == null) return null;

        Map<String, int> categoryCounts = {};
        for (var challengeMap in challengesData) {
          final dynamic categoriesData = challengeMap['categories'] ?? challengeMap['category'];
          if (categoriesData is List) {
            final categories = List<String>.from(categoriesData);
            for (var category in categories) {
              categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
            }
          }
        }
        // --- DEBUG CHECKPOINT 6 ---
        AppLogger.debug("DEBUG (Repository): Final category counts: $categoryCounts");

        if (categoryCounts.isEmpty) return <PieChartSectionData>[];

        final double total = categoryCounts.values.reduce((a, b) => a + b).toDouble();
        List<PieChartSectionData> sections = [];

        categoryCounts.forEach((category, count) {
          final double percentage = (count / total) * 100;
          final section = PieChartSectionData(
            color: _sdgColorMap[category] ?? defaultGoalColor,
            value: count.toDouble(),
            title: '${percentage.toStringAsFixed(0)}%',
            radius: 80,
            titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white, shadows: [Shadow(color: Colors.black, blurRadius: 2)]),
          );
          sections.add(section);
        });

        // --- DEBUG CHECKPOINT 7 ---
        AppLogger.debug("DEBUG (Repository): Successfully created ${sections.length} pie chart sections. Notifying UI.");
        return sections;
      } catch (e, s) {
        AppLogger.error("Error processing pie chart data in Repository", e, s);
        return null;
      }
    }).handleError((error, s) {
      AppLogger.error("Fatal error in getProfileStatsPieChartStream", error, s);
      return null;
    });
  }

  // --- All other methods remain unchanged ---

  UserProfileEntity? _mapModelToEntity(UserProfileModel? model) {
    if (model == null) return null;
    return UserProfileEntity(
      id: model.id,
      name: model.name,
      email: model.email,
      age: model.age,
      studyField: model.studyField,
      school: model.school,
      profileImageUrl: model.imageURL,
      points: model.points,
      level: model.level,
      completedTasks: model.completedTasks,
      ongoingTasks: model.ongoingTasks,
    );
  }

  @override
  Future<UserProfileEntity?> getUserProfile(String userId) async {
    if (userId.isEmpty) return null;
    try {
      final model = await remoteDataSource.getUserProfile(userId);
      return _mapModelToEntity(model);
    } catch (e) { return null; }
  }

  @override
  Stream<UserProfileEntity?> watchUserProfile(String userId) {
    if (userId.isEmpty) return Stream.value(null);
    return remoteDataSource.watchUserProfile(userId).map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        try {
          final model = UserProfileModel.fromMap(
              snapshot.data()! as Map<String, dynamic>, snapshot.id);
          return _mapModelToEntity(model);
        } catch (e) { return null; }
      }
      return null;
    }).handleError((error) { return null; });
  }

  @override
  Future<bool> updateProfileData({
    required String userId, required String name, required int age,
    required String studyField, required String school,
  }) async {
    if (userId.isEmpty) return false;
    try {
      await remoteDataSource.updateUserProfileData(userId, {
        'name': name, 'age': age, 'studyField': studyField, 'school': school,
      });
      return true;
    } catch (e) { return false; }
  }

  @override
  Future<String?> uploadAndUpdateProfileImage({
    required String userId, required File imageFile, String? oldImageUrl,
  }) async {
    if (userId.isEmpty) return null;
    try {
      if (oldImageUrl != null && oldImageUrl.isNotEmpty) {
        await remoteDataSource.deleteOldProfileImage(oldImageUrl);
      }
      final newImageUrl = await remoteDataSource.uploadProfileImage(userId, imageFile);
      await remoteDataSource.updateUserProfileData(userId, {'imageURL': newImageUrl});
      return newImageUrl;
    } catch (e) { return null; }
  }

  @override
  Future<bool> addTaskToOngoing(String userId, String challengeId) async {
    if (userId.isEmpty || challengeId.isEmpty) return false;
    try {
      await remoteDataSource.addUserOngoingTask(userId, challengeId);
      return true;
    } catch (e) { return false; }
  }

  @override
  Future<bool> removeTaskFromOngoing(String userId, String challengeId) async {
    if (userId.isEmpty || challengeId.isEmpty) return false;
    try {
      await remoteDataSource.removeUserOngoingTask(userId, challengeId);
      return true;
    } catch (e) { return false; }
  }

  @override
  Future<bool> markTaskAsCompleted({
    required String userId, required String challengeId, required int pointsEarned,
  }) async {
    if (userId.isEmpty || challengeId.isEmpty) return false;
    try {
      return await remoteDataSource.runUserProfileTransaction<bool>(
        userId: userId,
        updateFunction: (transaction, userDocRef) async {
          DocumentSnapshot userSnapshot = await transaction.get(userDocRef);
          if (!userSnapshot.exists) throw Exception("User not found.");

          final model = UserProfileModel.fromMap(userSnapshot.data()! as Map<String, dynamic>, userSnapshot.id);
          final ongoing = List<String>.from(model.ongoingTasks)..remove(challengeId);
          final completed = List<String>.from(model.completedTasks);
          if (!completed.contains(challengeId)) completed.add(challengeId);

          final newPoints = model.points + pointsEarned;
          final newLevel = LevelUtils.calculateLevel(newPoints);

          transaction.update(userDocRef, {
            'ongoingTasks': ongoing, 'completedTasks': completed,
            'points': newPoints, 'level': newLevel,
          });
          return true;
        },
      );
    } catch (e) { return false; }
  }

  @override
  Future<void> addBonusPoints({required List<String> userIds, required int points}) async {
    if (userIds.isEmpty || points <= 0) return;
    WriteBatch batch = FirebaseFirestore.instance.batch();
    for (String userId in userIds) {
      final userDocRef = FirebaseFirestore.instance.collection('users').doc(userId);
      batch.update(userDocRef, {'points': FieldValue.increment(points)});
    }
    await batch.commit();
  }
}