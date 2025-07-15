import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/challenge_progress_model.dart';

// Interface
abstract class ChallengeProgressRemoteDataSource {
  Stream<ChallengeProgressModel?> watchChallengeProgress(String progressId);
  Future<void> createChallengeProgress(ChallengeProgressModel progress);
  Future<void> updateTaskState(String progressId, String taskIndex, Map<String, dynamic> newStateMap);
}

// Implementierung
class ChallengeProgressRemoteDataSourceImpl implements ChallengeProgressRemoteDataSource {
  final FirebaseFirestore _firestore;

  ChallengeProgressRemoteDataSourceImpl({required FirebaseFirestore firestore}) : _firestore = firestore;

  CollectionReference get _progressCollection => _firestore.collection('challenge_progress');

  @override
  Future<void> createChallengeProgress(ChallengeProgressModel progress) async {
    try {
      await _progressCollection.doc(progress.id).set(progress.toMap());
    } catch (e) {
      // Hier Logging hinzufügen
      throw Exception("Could not create challenge progress: $e");
    }
  }

  @override
  Stream<ChallengeProgressModel?> watchChallengeProgress(String progressId) {
    return _progressCollection.doc(progressId).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return ChallengeProgressModel.fromSnapshot(snapshot);
      }
      return null;
    });
  }

  @override
  Future<void> updateTaskState(String progressId, String taskIndex, Map<String, dynamic> newStateMap) async {
    try {
      // Nutze die Punkt-Notation, um ein einzelnes Feld in einer Map zu aktualisieren
      await _progressCollection.doc(progressId).update({
        'taskStates.$taskIndex': newStateMap,
      });
    } catch (e) {
      // Hier Logging hinzufügen
      throw Exception("Could not update task state: $e");
    }
  }
}