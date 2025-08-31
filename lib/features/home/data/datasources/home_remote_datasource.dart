import 'package:cloud_firestore/cloud_firestore.dart';

/// Abstract class for remote data operations related to the home feature.
///
/// This class defines the contract for fetching challenge data from a remote source.
abstract class HomeRemoteDataSource {
  /// Retrieves a stream of [DocumentSnapshot] lists for challenges based on the provided [challengeIds].
  ///
  /// The stream will emit a new list of document snapshots whenever the underlying
  /// challenge data changes in Firestore.
  /// The number of documents fetched from Firestore is limited by an internal
  /// mechanism (e.g., first 10 IDs from [challengeIds]) due to Firestore query limitations.
  /// The final limiting to the passed [limit] parameter should be handled by the caller (e.g., Repository or Provider).
  ///
  /// - [challengeIds]: A list of challenge IDs to fetch.
  /// - [limit]: An indicative limit for the number of challenges. Note that the
  ///   actual number of documents initially queried from Firestore might be different
  ///   (e.g., up to 10) due to backend constraints. The final filtering to this
  ///   limit should be done by the caller.
  /// Returns a [Stream] of [List<DocumentSnapshot>] representing the challenges.
  /// Returns an empty stream if [challengeIds] is empty or if no challenges match the query.
  Stream<List<DocumentSnapshot>> getChallengesByIdsStream(List<String> challengeIds, int limit);
}

/// Implementation of [HomeRemoteDataSource] that uses Firebase Firestore.
///
/// This class handles fetching challenge data from Firestore.
class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  /// The Firestore instance used for database operations.
  final FirebaseFirestore _firestore;

  /// Creates an instance of [HomeRemoteDataSourceImpl].
  ///
  /// Requires a [FirebaseFirestore] instance.
  HomeRemoteDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  @override
  Stream<List<DocumentSnapshot>> getChallengesByIdsStream(List<String> challengeIds, int limit) {
    if (challengeIds.isEmpty) {
      return Stream.value([]);
    }
    // Firestore "whereIn" has a limit (e.g., 10 or 30).
    // We take the first (up to) 10 IDs for the query. The limiting to `limit` (e.g., 3)
    // happens then in the Repository or Provider after mapping.
    List<String> idsToQuery = challengeIds.take(10).toList();

    // Handles edge cases where idsToQuery might be empty even if challengeIds is not.
    // This can happen if challengeIds contains only empty strings (which shouldn't occur)
    // or if challengeIds.take(10) results in an empty list (e.g., if challengeIds was not empty but only had empty strings,
    // or if the `take` operation itself somehow resulted in an empty list under unusual circumstances).
    // It also explicitly handles the case where the original challengeIds was empty.
    if (idsToQuery.isEmpty) {
      return Stream.value([]);
    }

    return _firestore
        .collection('challenges')
        .where(FieldPath.documentId, whereIn: idsToQuery)
    // The .limit(limit) here in the Datasource is only meaningful
    // if the number of `idsToQuery` is already <= `limit`.
    // The final limitation to the desired number (e.g., 3 for preview)
    // is better done in the Repository or Provider after mapping.
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }
}
