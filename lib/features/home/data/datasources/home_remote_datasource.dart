import 'package:cloud_firestore/cloud_firestore.dart';

abstract class HomeRemoteDataSource {
  Stream<List<DocumentSnapshot>> getChallengesByIdsStream(List<String> challengeIds, int limit);
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final FirebaseFirestore _firestore;

  HomeRemoteDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  @override
  Stream<List<DocumentSnapshot>> getChallengesByIdsStream(List<String> challengeIds, int limit) {
    if (challengeIds.isEmpty) {
      return Stream.value([]);
    }
    // Firestore "whereIn" hat ein Limit (z.B. 10 oder 30).
    // Wir nehmen die ersten (bis zu) 10 IDs für die Abfrage. Das Limitieren auf `limit` (z.B. 3)
    // passiert dann im Repository oder Provider nach dem Mapping.
    List<String> idsToQuery = challengeIds.take(10).toList();
    if (idsToQuery.isEmpty && challengeIds.isNotEmpty) {
      // Fall: challengeIds hat Elemente, aber nach take(0) (falls limit 0 wäre) ist es leer.
      // Oder wenn challengeIds zwar Elemente hat, aber alle sind leer (sollte nicht sein).
      // In diesem Fall geben wir einen leeren Stream zurück, um Fehler zu vermeiden.
      // Dies ist ein Edge-Case, der aber auftreten kann, wenn take(0) passiert.
      // Normalerweise sollte limit > 0 sein.
      return Stream.value([]);
    }
    if (idsToQuery.isEmpty) { // Wenn nach take(10) immer noch leer (weil challengeIds leer war)
      return Stream.value([]);
    }


    return _firestore
        .collection('challenges')
        .where(FieldPath.documentId, whereIn: idsToQuery)
    // Das .limit(limit) hier in der Datasource ist nur dann sinnvoll,
    // wenn die Anzahl der `idsToQuery` bereits <= `limit` ist.
    // Die finale Limitierung auf die gewünschte Anzahl (z.B. 3 für Vorschau)
    // machen wir besser im Repository oder Provider nach dem Mapping.
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }
}