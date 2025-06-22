import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/challenge_model.dart';

abstract class ChallengeRemoteDataSource {
  Stream<List<ChallengeModel>> getAllChallengesStream();
  Future<ChallengeModel?> getChallengeById(String challengeId);
  Future<String> createChallenge(ChallengeModel challenge);
}

class ChallengeRemoteDataSourceImpl implements ChallengeRemoteDataSource {
  final FirebaseFirestore firestore;

  ChallengeRemoteDataSourceImpl({required this.firestore});

  @override
  Stream<List<ChallengeModel>> getAllChallengesStream() {
    try {
      AppLogger.info("ChallengeRemoteDS: Starting getAllChallengesStream");
      
      // Try with orderBy first, fallback to without orderBy if it fails
      return firestore.collection('/challenges')
          .snapshots()
          .map((snapshot) => _processSnapshot(snapshot))
          .handleError((error) {
            AppLogger.warning("ChallengeRemoteDS: OrderBy query failed, trying without orderBy: $error");
            // Fallback: Query without orderBy
            return firestore.collection('challenges')
                .snapshots()
                .map((snapshot) => _processSnapshot(snapshot));
          })
          .handleError((error) {
            AppLogger.error("ChallengeRemoteDS: All queries failed: $error", error);
            return <ChallengeModel>[];
          });
    } catch (e) {
      AppLogger.error("ChallengeRemoteDS: Exception in getAllChallengesStream: $e", e);
      return Stream.value([]);
    }
  }

  List<ChallengeModel> _processSnapshot(QuerySnapshot snapshot) {
    AppLogger.info("ChallengeRemoteDS: Firestore snapshot received - ${snapshot.docs.length} documents");
    AppLogger.debug("ChallengeRemoteDS: Document IDs: ${snapshot.docs.map((doc) => doc.id).join(', ')}");
    
    final challenges = <ChallengeModel>[];
    for (var doc in snapshot.docs) {
      try {
        AppLogger.debug("ChallengeRemoteDS: Processing document ${doc.id}");
        final challenge = ChallengeModel.fromSnapshot(doc);
        challenges.add(challenge);
        AppLogger.debug("ChallengeRemoteDS: Successfully processed challenge: ${challenge.title}");
      } catch (e) {
        AppLogger.error("ChallengeRemoteDS: Error processing document ${doc.id}: $e", e);
        AppLogger.debug("ChallengeRemoteDS: Document data: ${doc.data()}");
      }
    }
    
    AppLogger.info("ChallengeRemoteDS: Successfully processed ${challenges.length} challenges");
    return challenges;
  }

  @override
  Future<ChallengeModel?> getChallengeById(String challengeId) async {
    try {
      final doc = await firestore.collection('challenges').doc(challengeId).get();
      if (doc.exists) {
        return ChallengeModel.fromSnapshot(doc);
      }
      return null;
    } catch (e) {
      AppLogger.error("ChallengeRemoteDS: Fehler getChallengeById $challengeId: $e", e);
      throw Exception('Failed to get challenge by ID: $e');
    }
  }

  @override
  Future<String> createChallenge(ChallengeModel challenge) async {
    try {
      final docRef = await firestore.collection('challenges').add(challenge.toMap());
      return docRef.id;
    } catch (e) {
      AppLogger.error("ChallengeRemoteDS: Fehler createChallenge: $e", e);
      throw Exception('Failed to create challenge: $e');
    }
  }
}