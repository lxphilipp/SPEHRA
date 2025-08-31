import '../../domain/entities/intro_page_entity.dart';

/// Represents the data model for an introduction page.
///
/// This model is typically used for parsing data from a data source (e.g., JSON)
/// and is usually converted into an `IntroPageEntity` for use in the domain layer.
class IntroPageModel {
  /// The unique identifier for the intro page.
  final String id;

  /// The type of the intro page, which determines its layout and content.
  /// See [IntroPageType] for possible values (defined in `intro_page_entity.dart`).
  final IntroPageType type;

  /// The optional title displayed on the intro page.
  final String? title;

  /// The optional description or main text content of the intro page.
  final String? description;

  /// The optional text for a call-to-action button on the intro page.
  final String? ctaText;

  /// The optional starting color (in hex format, e.g., "#RRGGBB") for a gradient background.
  /// This is typically used when [type] is [IntroPageType.gradientCard].
  final String? gradientStartColorHex;

  /// The optional name of a custom widget to be displayed on this intro page.
  /// This allows for embedding specific Flutter widgets as part of the introduction flow.
  final String? widgetName;

  /// Creates an instance of [IntroPageModel].
  ///
  /// The [id] and [type] parameters are required.
  /// Other parameters ([title], [description], [ctaText], [gradientStartColorHex],
  /// and [widgetName]) are optional.
  const IntroPageModel({
    required this.id,
    required this.type,
    this.title,
    this.description,
    this.ctaText,
    this.gradientStartColorHex,
    this.widgetName,
  });

  /// Creates an instance of [IntroPageModel] from a JSON map.
  ///
  /// This factory constructor is used for deserializing intro page data.
  /// It expects 'id' and 'type' fields in the JSON.
  /// - `id`: The unique identifier.
  /// - `type`: The string representation of [IntroPageType]. If parsing fails or
  ///   the type is not recognized, it defaults to [IntroPageType.gradientCard].
  /// - `title`: Optional title.
  /// - `description`: Optional description.
  /// - `ctaText`: Optional call-to-action text.
  /// - `gradientStartColor`: Optional hex color string for gradient start (maps to [gradientStartColorHex]).
  /// - `widgetName`: Optional name of a custom widget.
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
