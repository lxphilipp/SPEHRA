import '../../domain/entities/intro_page_entity.dart';
import '../../domain/repositories/intro_repository.dart';
import '../datasources/intro_local_datasource.dart';
import '../models/intro_page_model.dart';

class IntroRepositoryImpl implements IntroRepository {
  final IntroLocalDataSource localDataSource;
  IntroRepositoryImpl({required this.localDataSource});

  @override
  Future<List<IntroPageEntity>> getIntroPages() async {
    final models = await localDataSource.getIntroPageModels();
    return models.map((model) => _mapModelToEntity(model)).toList();
  }

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