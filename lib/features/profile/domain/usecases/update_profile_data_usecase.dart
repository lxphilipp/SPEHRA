import '../repositories/user_profile_repository.dart';

class UpdateProfileDataUseCase {
  final UserProfileRepository repository;

  UpdateProfileDataUseCase(this.repository);

  Future<bool> call(UpdateProfileDataParams params) async {
    if (params.userId.isEmpty || params.name.isEmpty) return false;

    return await repository.updateProfileData(
      userId: params.userId,
      name: params.name,
      age: params.age,
      studyField: params.studyField,
      school: params.school,
      hasCompletedIntro: params.hasCompletedIntro,
    );
  }
}

class UpdateProfileDataParams {
  final String userId;
  final String name;
  final int age;
  final String studyField;
  final String school;
  final bool? hasCompletedIntro;

  UpdateProfileDataParams({
    required this.userId,
    required this.name,
    required this.age,
    required this.studyField,
    required this.school,
    this.hasCompletedIntro,
  });
}