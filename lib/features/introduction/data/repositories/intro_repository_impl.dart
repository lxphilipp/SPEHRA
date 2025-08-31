import '../../domain/entities/intro_page_entity.dart';
import '../../domain/repositories/intro_repository.dart';
import '../datasources/intro_local_datasource.dart';
import '../models/intro_page_model.dart';

/// Implements the [IntroRepository] interface.
///
/// This repository is responsible for fetching introduction page data.
class IntroRepositoryImpl implements IntroRepository {
  /// The local data source for introduction pages.
  final IntroLocalDataSource localDataSource;

  /// Creates an instance of [IntroRepositoryImpl].
  ///
  /// Requires a [localDataSource] to fetch data from.
  IntroRepositoryImpl({required this.localDataSource});

  @override
  Future<List<IntroPageEntity>> getIntroPages() async {
    final models = await localDataSource.getIntroPageModels();
    return models.map((model) => _mapModelToEntity(model)).toList();
  }

  /// Maps an [IntroPageModel] to an [IntroPageEntity].
  IntroPageEntity _mapModelToEntity(IntroPageModel model) {
    return IntroPageEntity(
      id: model.id,
      type: model.type,
      title: model.title,
      description: model.description,
      ctaText: model.ctaText,
      gradientStartColorHex: model.gradientStartColorHex,
      widgetName: model.widgetName,
    );
  }
}