import '../entities/intro_page_entity.dart';

/// Defines the contract for accessing introduction data.
///
/// The domain layer (UseCases) will interact with this interface,
/// without needing to know the specific data source (e.g., local JSON, API, database).
abstract class IntroRepository {
  /// Retrieves a list of [IntroPageEntity] objects, representing all pages
  /// in the introduction sequence.
  ///
  /// Returns a `Future<List<IntroPageEntity>>`.
  /// May throw an exception if loading the data fails.
  Future<List<IntroPageEntity>> getIntroPages();
}
