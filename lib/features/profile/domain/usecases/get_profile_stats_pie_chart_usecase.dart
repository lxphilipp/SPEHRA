import 'package:fl_chart/fl_chart.dart'; // Für PieChartSectionData
import '../repositories/user_profile_repository.dart';

class GetCategoryCountsStream {
  final UserProfileRepository repository;

  GetCategoryCountsStream(this.repository);

  Stream<Map<String, int>?> call(String userId) {
    if (userId.isEmpty) return Stream.value(null);
    return repository.getSdgCategoryCountsStream(userId);
  }
}