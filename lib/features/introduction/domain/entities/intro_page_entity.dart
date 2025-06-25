import 'package:equatable/equatable.dart';

// Dieser Enum ist reine Logik, keine UI.
enum IntroPageType { gradientCard, question }

class IntroPageEntity extends Equatable {
  final String id;
  final IntroPageType type;

  // Daten für gradientCard
  final String? title;
  final String? description;
  final String? ctaText;
  final String? gradientStartColorHex; // Farbe als reiner Daten-String

  // Daten für question
  final String? widgetName; // Identifikator für das Widget

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