import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/invite_entity.dart';

/// Represents the data model for an invite, used for Firestore operations.
class InviteModel {
  /// The unique identifier of the invite.
  final String id;

  /// The ID of the user who sent the invite.
  final String inviterId;

  /// The ID of the target entity (e.g., user, group) being invited.
  final String targetId;

  /// The title or name of the target entity.
  final String targetTitle;

  /// The context of the invite (e.g., "direct", "group").
  final String context;

  /// An optional ID related to the context (e.g., group ID).
  final String? contextId;

  /// A map of recipient IDs to their invite status as a string.
  final Map<String, String> recipients;

  /// The timestamp when the invite was created.
  final Timestamp createdAt;

  /// Creates an [InviteModel].
  InviteModel({
    required this.id,
    required this.inviterId,
    required this.targetId,
    required this.targetTitle,
    required this.context,
    this.contextId,
    required this.recipients,
    required this.createdAt,
  });

  /// Creates an [InviteModel] from a Firestore [DocumentSnapshot].
  factory InviteModel.fromSnapshot(DocumentSnapshot snap) {
    final data = snap.data() as Map<String, dynamic>;
    return InviteModel(
      id: snap.id,
      inviterId: data['inviterId'] ?? '',
      targetId: data['targetId'] ?? '',
      targetTitle: data['targetTitle'] ?? '',
      context: data['context'] ?? 'direct',
      contextId: data['contextId'],
      recipients: Map<String, String>.from(data['recipients'] ?? {}),
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  /// Creates an [InviteModel] from a [Map] of data and an [id].
  factory InviteModel.fromMap(Map<String, dynamic> data, String id) {
    return InviteModel(
      id: id,
      inviterId: data['inviterId'] ?? '',
      targetId: data['targetId'] ?? '',
      targetTitle: data['targetTitle'] ?? '',
      context: data['context'] ?? 'direct',
      contextId: data['contextId'],
      recipients: Map<String, String>.from(data['recipients'] ?? {}),
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  /// Converts this [InviteModel] to a [Map] for Firestore.
  Map<String, dynamic> toMap() {
    return {
      'inviterId': inviterId,
      'targetId': targetId,
      'targetTitle': targetTitle,
      'context': context,
      'contextId': contextId,
      'recipients': recipients,
      'createdAt': createdAt,
    };
  }

  /// Creates an [InviteModel] from an [InviteEntity] (from the domain layer).
  factory InviteModel.fromEntity(InviteEntity entity) {
    return InviteModel(
      id: entity.id,
      inviterId: entity.inviterId,
      targetId: entity.targetId,
      targetTitle: entity.targetTitle,
      context: entity.context.name, // Enum -> String
      contextId: entity.contextId,
      recipients: entity.recipients.map((key, value) => MapEntry(key, value.name)), // Enum -> String
      createdAt: Timestamp.fromDate(entity.createdAt),
    );
  }

  /// Converts this [InviteModel] to an [InviteEntity].
  InviteEntity toEntity() {
    return InviteEntity(
      id: id,
      inviterId: inviterId,
      targetId: targetId,
      targetTitle: targetTitle,
      context: InviteContext.values.firstWhere((e) => e.name == context, orElse: () => InviteContext.direct),
      contextId: contextId,
      recipients: recipients.map((key, value) => MapEntry(key, InviteStatus.values.firstWhere((e) => e.name == value, orElse: () => InviteStatus.pending))),
      createdAt: createdAt.toDate(),
    );
  }
}
