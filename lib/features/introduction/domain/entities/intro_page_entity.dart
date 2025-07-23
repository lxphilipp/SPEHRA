import 'package:equatable/equatable.dart';

enum IntroPageType { gradientCard, question }

class IntroPageEntity extends Equatable {
  final String id;
  final IntroPageType type;

  final String? title;
  final String? description;
  final String? ctaText;
  final String? gradientStartColorHex;
  final String? widgetName;

  const IntroPageEntity({
    required this.id,
    required this.type,
    this.title,
    this.description,
    this.ctaText,
    this.gradientStartColorHex,
    this.widgetName,
  });

  @override
  List<Object?> get props => [id, type, title, description, ctaText, gradientStartColorHex, widgetName];
}