import '../../domain/entities/intro_page_entity.dart';

class IntroPageModel {
  final String id;
  final IntroPageType type;
  final String? title;
  final String? description;
  final String? ctaText;
  final String? gradientStartColorHex;
  final String? widgetName;

  const IntroPageModel({
    required this.id,
    required this.type,
    this.title,
    this.description,
    this.ctaText,
    this.gradientStartColorHex,
    this.widgetName,
  });

  factory IntroPageModel.fromJson(Map<String, dynamic> json) {
    return IntroPageModel(
      id: json['id'],
      type: IntroPageType.values.firstWhere(
            (e) => e.name == json['type'],
        orElse: () => IntroPageType.gradientCard,
      ),
      title: json['title'],
      description: json['description'],
      ctaText: json['ctaText'],
      gradientStartColorHex: json['gradientStartColor'],
      widgetName: json['widgetName'],
    );
  }
}