import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/invite_entity.dart';

class InviteModel {
  final String id;
  final String inviterId;
  final String targetId;
  final String targetTitle;
  final String context;
  final String? contextId;
  final Map<String, String> recipients; // In Firestore speichern wir den Enum-Wert als String
  final Timestamp createdAt;

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

  /// Konvertiert ein Firestore-Dokument in ein InviteModel
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

  /// Konvertiert das Model in eine Map für Firestore
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

  /// Konvertiert eine InviteEntity (aus der Domain-Schicht) in ein InviteModel
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

  /// Konvertiert das InviteModel in eine InviteEntity
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