import 'dart:io'; // Für File
import '../entities/user_profile_entity.dart';
import 'package:fl_chart/fl_chart.dart'; // Für PieChartSectionData

abstract class UserProfileRepository {

  Future<UserProfileEntity?> getUserProfile(String userId);

  Stream<UserProfileEntity?> watchUserProfile(String userId);

  Future<bool> updateProfileData({
    required String userId,
    required String name,
    required int age,
    required String studyField,
    required String school,
  });

  Future<String?> uploadAndUpdateProfileImage({
    required String userId,
    required File imageFile,
    String? oldImageUrl,
  });

  Stream<List<PieChartSectionData>?> getProfileStatsPieChartStream(String userId);

  Future<bool> addTaskToOngoing(String userId, String challengeId);
  Future<bool> removeTaskFromOngoing(String userId, String challengeId);
  Future<bool> markTaskAsCompleted({
    required String userId,
    required String challengeId,
    required int pointsEarned,
  });

}