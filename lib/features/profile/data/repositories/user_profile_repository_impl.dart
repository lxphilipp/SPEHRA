import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart'; // Benötigt für DocumentReference, Transaction
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';
import '../datasources/profile_stats_datasource.dart';
import '../models/user_profile_model.dart';

class UserProfileRepositoryImpl implements UserProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final ProfileStatsDataSource statsDataSource;

  UserProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.statsDataSource,
  });

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
      // about: model.about,
    );
  }

  @override
  Future<UserProfileEntity?> getUserProfile(String userId) async {
    if (userId.isEmpty) {
      AppLogger.warning("UserProfileRepoImpl: getUserProfile error - userId is empty");
      return null;
    }
    try {
      final model = await remoteDataSource.getUserProfile(userId);
      return _mapModelToEntity(model);
    } catch (e) {
      AppLogger.error("UserProfileRepoImpl: getUserProfile error for UID $userId", e);
      return null;
    }
  }

  @override
  Stream<UserProfileEntity?> watchUserProfile(String userId) {
    if (userId.isEmpty) {
      AppLogger.warning("UserProfileRepoImpl: watchUserProfile error - userId is empty");
      return Stream.value(null);
    }
    return remoteDataSource.watchUserProfile(userId).map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        try {
          final model = UserProfileModel.fromMap(
              snapshot.data()! as Map<String, dynamic>, snapshot.id);
          return _mapModelToEntity(model);
        } catch (e) {
          AppLogger.error("UserProfileRepoImpl: Mapping error in watchUserProfile stream for UID $userId", e);
          return null;
        }
      }
      return null;
    }).handleError((error) {
      AppLogger.error("UserProfileRepoImpl: Error in watchUserProfile stream for UID $userId", error);
      return null;
    });
  }

  @override
  Future<bool> updateProfileData({
    required String userId,
    required String name,
    required int age,
    required String studyField,
    required String school,
    // String? about,
  }) async {
    if (userId.isEmpty) return false;
    try {
      final Map<String, dynamic> dataToUpdate = {
        'name': name,
        'age': age,
        'studyField': studyField,
        'school': school,
        // if (about != null) 'about': about,
      };
      await remoteDataSource.updateUserProfileData(userId, dataToUpdate);
      return true;
    } catch (e) {
      AppLogger.error("UserProfileRepoImpl: updateProfileData error for UID $userId", e);
      return false;
    }
  }

  @override
  Future<String?> uploadAndUpdateProfileImage({
    required String userId,
    required File imageFile,
    String? oldImageUrl,
  }) async {
    if (userId.isEmpty) return null;
    try {
      if (oldImageUrl != null && oldImageUrl.isNotEmpty) {
        await remoteDataSource.deleteOldProfileImage(oldImageUrl);
      }
      final newImageUrl = await remoteDataSource.uploadProfileImage(userId, imageFile);
      // Nachdem das Bild hochgeladen wurde, aktualisiere das User-Dokument mit der neuen URL
      await remoteDataSource.updateUserProfileData(userId, {'imageURL': newImageUrl});
      return newImageUrl;
    } catch (e) {
      AppLogger.error("UserProfileRepoImpl: uploadProfileImageAndUpdateUrl error for UID $userId", e);
      return null;
    }
  }

  @override
  Stream<List<PieChartSectionData>?> getProfileStatsPieChartStream(String userId) {
    if (userId.isEmpty) return Stream.value(null);
    return statsDataSource.getCompletedTaskIdsStream(userId).asyncMap((taskIds) async {
      if (taskIds == null) return null;
      if (taskIds.isEmpty) return <PieChartSectionData>[];
      try {
        final challengesData = await statsDataSource.getChallengeDetailsForTasks(taskIds);
        if (challengesData == null) return null;
        if (challengesData.isEmpty && taskIds.isNotEmpty) return <PieChartSectionData>[];

        Map<String, int> categoryCounts = {};

        for (var challengeMap in challengesData) { /* ... Zähllogik ... */ }
        List<PieChartSectionData> sections = [];
        if (categoryCounts.isNotEmpty) { /* ... Erstelle Sektionen ... */ }
        return sections;
      } catch (e) { return null; }
    }).handleError((error) => null);
  }

  // --- Implementierung der NEUEN Methoden für Challenge-Interaktionen ---
  @override
  Future<bool> addTaskToOngoing(String userId, String challengeId) async {
    if (userId.isEmpty || challengeId.isEmpty) return false;
    try {
      await remoteDataSource.addUserOngoingTask(userId, challengeId);
      return true;
    } catch (e) {
      AppLogger.error("UserProfileRepoImpl: addTaskToOngoing error", e);
      return false;
    }
  }

  @override
  Future<bool> removeTaskFromOngoing(String userId, String challengeId) async {
    if (userId.isEmpty || challengeId.isEmpty) return false;
    try {
      await remoteDataSource.removeUserOngoingTask(userId, challengeId);
      return true;
    } catch (e) {
      AppLogger.error("UserProfileRepoImpl: removeTaskFromOngoing error", e);
      return false;
    }
  }

  @override
  Future<bool> markTaskAsCompleted({
    required String userId,
    required String challengeId,
    required int pointsEarned,
  }) async {
    if (userId.isEmpty || challengeId.isEmpty) return false;

    try {
      // Rufe die Transaktionsmethode der Datasource auf und übergebe die Logik
      // als anonyme Funktion oder separate private Methode.
      return await remoteDataSource.runUserProfileTransaction<bool>(
        userId: userId,
        updateFunction: (transaction, userDocRef) async {
          // Lese das Dokument INNERHALB der Transaktion
          DocumentSnapshot userSnapshot = await transaction.get(userDocRef);

          if (!userSnapshot.exists || userSnapshot.data() == null) {
            AppLogger.warning("UserProfileRepoImpl (Transaction): User $userId not found");
            // Wichtig: Wirf eine Exception, um die Transaktion fehlschlagen zu lassen
            throw Exception("User document not found for transaction.");
          }

          final currentUserModel = UserProfileModel.fromMap(
              userSnapshot.data()! as Map<String, dynamic>, userSnapshot.id);

          List<String> ongoingTasks = List<String>.from(currentUserModel.ongoingTasks);
          List<String> completedTasks = List<String>.from(currentUserModel.completedTasks);
          int currentPoints = currentUserModel.points;

          ongoingTasks.remove(challengeId);
          if (!completedTasks.contains(challengeId)) {
            completedTasks.add(challengeId);
          }
          int newTotalPoints = currentPoints + pointsEarned;

          // Level-Berechnungslogik
          List<int> levelThresholds = [0, 2000, 3000, 4000, 100000];
          List<int> levels = [1, 2, 3, 4, 5];
          int newUserLevel = 1;
          for (int i = 0; i < levelThresholds.length; i++) {
            if (newTotalPoints >= levelThresholds[i]) {
              newUserLevel = levels[i];
            } else {
              break;
            }
          }

          final Map<String, dynamic> dataToUpdate = {
            'ongoingTasks': ongoingTasks,
            'completedTasks': completedTasks,
            'points': newTotalPoints,
            'level': newUserLevel,
          };

          transaction.update(userDocRef, dataToUpdate);

          return true;
        },
      );
    } catch (e) {
      AppLogger.error("UserProfileRepoImpl: markTaskAsCompleted transaction error", e);
      return false; // Fehler von runUserProfileTransaction oder der updateFunction
    }
  }
}