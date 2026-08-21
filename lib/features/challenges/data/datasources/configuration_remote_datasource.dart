import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/game_balance_model.dart';

/// Abstract class for fetching configuration data.
///
/// Implemented by [ConfigurationRemoteDataSourceImpl] (Firestore) and
/// [ConfigurationLocalDataSourceImpl]
abstract class ConfigurationDataSource {
  /// Fetches the game balance configuration.
  ///
  /// Returns a [Future] that completes with a [GameBalanceModel]. Throws if
  /// the configuration cannot be obtained from this source.
  Future<GameBalanceModel> getGameBalance();
}

/// Thrown when the remote configuration document does not exist (yet).
class ConfigurationNotFoundException implements Exception {
  /// Path of the missing document.
  final String path;

  /// Creates a [ConfigurationNotFoundException] for [path].
  const ConfigurationNotFoundException(this.path);

  @override
  String toString() => 'ConfigurationNotFoundException: no document at $path';
}

/// Implementation of [ConfigurationDataSource] that reads the game balance
/// from a Firestore document.
class ConfigurationRemoteDataSourceImpl implements ConfigurationDataSource {
  /// Name of the Firestore collection holding app-wide configuration documents.
  static const String collectionName = 'configuration';

  /// ID of the document holding the game balance.
  static const String gameBalanceDocumentId = 'game_balance';

  final FirebaseFirestore _firestore;

  /// Creates a [ConfigurationRemoteDataSourceImpl] backed by [firestore].
  ConfigurationRemoteDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  DocumentReference<Map<String, dynamic>> get _docRef =>
      _firestore.collection(collectionName).doc(gameBalanceDocumentId);

  @override
  Future<GameBalanceModel> getGameBalance() async {
    final snapshot = await _docRef.get();
    final data = snapshot.data();
    if (!snapshot.exists || data == null) {
      throw ConfigurationNotFoundException(_docRef.path);
    }
    return GameBalanceModel.fromJson(data);
  }

  Future<void> saveGameBalance(GameBalanceModel model) {
    return _docRef.set(model.toJson());
  }
}
