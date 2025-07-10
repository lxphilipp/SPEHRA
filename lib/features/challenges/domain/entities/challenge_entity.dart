import 'dart:math'; // Wird für die min()-Funktion im Punkte-Getter benötigt.
import 'package:equatable/equatable.dart';
import 'trackable_task.dart'; // Importiert die neuen, modularen Aufgaben-Entitäten.

/// Repräsentiert eine Challenge in der Domain-Schicht.
///
/// Diese Klasse ist unveränderlich und enthält die gesamte Geschäftslogik
/// zur Berechnung von Punkten und Schwierigkeit sowie zur Validierung
/// der Aufgaben-Zusammensetzung.
class ChallengeEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final List<String> categories;
  final String authorId;
  final DateTime? createdAt;
  final List<TrackableTask> tasks;
  final Map<String, String>? llmFeedback;

  // --- Konstanten für die Spielbalance ---

  /// Die Basispunktzahl für eine einfache, nicht verifizierbare Checkbox-Aufgabe.
  static const int _pointsPerCheckbox = 5;

  /// Die Basispunktzahl für eine Aufgabe, die einen Beweis erfordert (z.B. Foto, Standort).
  static const int _pointsPerProvableTask = 50;

  /// Bonuspunkte pro 1000 Schritte für die Schrittzähler-Aufgabe.
  static const int _pointsPer1000Steps = 10;

  /// Das absolute Punktelimit, das eine einzelne Challenge gewähren kann.
  static const int maxPoints = 500;

  /// Definiert, wie viele Punkte für Checkboxen pro beweisbarer Aufgabe freigeschaltet werden.
  /// Dies ist der Kern des "Punkte-Budget"-Modells.
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
  });

  /// Berechnet die Gesamtpunktzahl der Challenge.
  ///
  /// Diese Methode implementiert die "Punkte-Budget"-Logik:
  /// 1. Sie berechnet die Summe der Punkte aus beweisbaren Aufgaben.
  /// 2. Sie berechnet, wie viele Punkte durch Checkboxen verdient werden können (das Budget).
  /// 3. Sie addiert die Punkte aus Checkboxen nur bis zu diesem Budget-Limit.
  /// 4. Die Gesamtpunktzahl wird durch `maxPoints` gedeckelt.
  int get calculatedPoints {
    // 1. Zähle die beweisbaren Aufgaben, um das Budget zu bestimmen.
    final provableTaskCount = tasks.where((task) => task is! CheckboxTask).length;

    // 2. Berechne das maximale Punkte-Budget, das durch Checkboxen verdient werden kann.
    final maxAllowedCheckboxPoints = provableTaskCount * unlockedCheckboxPointsPerProvableTask;

    // 3. Berechne die tatsächlichen, potenziellen Punkte aus den Checkboxen.
    final actualCheckboxPoints = tasks
        .whereType<CheckboxTask>()
        .fold(0, (sum, task) => sum + _pointsPerCheckbox);

    // 4. Ermittle die anrechenbaren Checkbox-Punkte (das Minimum aus Budget und tatsächlichen Punkten).
    final countableCheckboxPoints = min(maxAllowedCheckboxPoints, actualCheckboxPoints);

    // 5. Berechne die Punkte aus den beweisbaren Aufgaben.
    final int provableTasksPoints = tasks.fold(0, (sum, task) {
      if (task is LocationVisitTask || task is ImageUploadTask) {
        return sum + _pointsPerProvableTask;
      }
      if (task is StepCounterTask) {
        final stepBonus = (task.targetSteps / 1000).floor() * _pointsPer1000Steps;
        return sum + _pointsPerProvableTask + stepBonus;
      }
      return sum; // Ignoriert Checkboxen in dieser Faltung.
    });

    // 6. Addiere die Punkte der beweisbaren Aufgaben und die anrechenbaren Checkbox-Punkte.
    final totalPoints = countableCheckboxPoints + provableTasksPoints;

    // 7. Wende das globale Punktelimit an.
    return min(totalPoints, maxPoints);
  }

  /// Berechnet die Schwierigkeit der Challenge basierend auf der Gesamtpunktzahl.
  String get calculatedDifficulty {
    final points = calculatedPoints;
    if (points > 350) return "Experienced";
    if (points > 150) return "Advanced";
    if (points > 50) return "Normal";
    return "Easy";
  }

  /// Gibt die anrechenbaren Punkte für eine bestimmte Aufgabe an einem Index zurück.
  /// Dies ist die "Auskunfts-Methode" für die UI, damit diese die Logik nicht kennen muss.
  int getPointsForTaskAtIndex(int index) {
    if (index < 0 || index >= tasks.length) {
      return 0; // Sicherung gegen ungültigen Index.
    }

    final task = tasks[index];

    // Punkte für beweisbare Aufgaben sind unkompliziert.
    if (task is! CheckboxTask) {
      if (task is LocationVisitTask || task is ImageUploadTask) {
        return _pointsPerProvableTask;
      }
      if (task is StepCounterTask) {
        final stepBonus = (task.targetSteps / 1000).floor() * _pointsPer1000Steps;
        return _pointsPerProvableTask + stepBonus;
      }
      return 0; // Sollte nicht vorkommen.
    }

    // Für CheckboxTasks muss das Budget geprüft werden.
    final provableTaskCount = tasks.where((t) => t is! CheckboxTask).length;
    final maxAllowedCheckboxPoints = provableTaskCount * unlockedCheckboxPointsPerProvableTask;

    // Finde den "Rang" der aktuellen Checkbox heraus.
    int checkboxRank = -1;
    for (int i = 0; i <= index; i++) {
      if (tasks[i] is CheckboxTask) {
        checkboxRank++;
      }
    }

    // Berechne die Punkte, die durch vorherige Checkboxen bereits "verbraucht" wurden.
    final pointsConsumedByPreviousCheckboxes = checkboxRank * _pointsPerCheckbox;

    // Wenn die aktuelle Checkbox noch ins Budget passt, gibt sie Punkte, sonst nicht.
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
  ];
}