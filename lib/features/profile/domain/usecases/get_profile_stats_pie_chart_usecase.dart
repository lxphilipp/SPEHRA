import 'package:fl_chart/fl_chart.dart'; // Für PieChartSectionData
import '../repositories/user_profile_repository.dart';

class GetProfileStatsPieChartUseCase {
  final UserProfileRepository repository;

  GetProfileStatsPieChartUseCase(this.repository);

  Stream<List<PieChartSectionData>?> call(String userId) {
    if (userId.isEmpty) return Stream.value(null);
    // Hier könnte Logik stehen, um z.B. die Berechnung der PieChart-Daten
    // aus Rohdaten vom Repository zu übernehmen, falls das Repository nur
    // die categoryCounts liefern würde. In unserem Fall liefert das Repo
    // schon die fertigen Sektionen, also leiten wir es meist nur weiter.
    return repository.getProfileStatsPieChartStream(userId);
  }
}