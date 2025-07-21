import 'package:equatable/equatable.dart';

enum InviteStatus { pending, accepted, declined }
enum InviteContext { group, direct }

class InviteEntity extends Equatable {
  final String id;
  final String inviterId;
  final String targetId;
  final String targetTitle;
  final InviteContext context;
  final String? contextId;
  final Map<String, InviteStatus> recipients;
  final DateTime createdAt;

  const InviteEntity({
    required this.id,
    required this.inviterId,
    required this.targetId,
    required this.targetTitle,
    required this.context,
    this.contextId,
    required this.recipients,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, inviterId, targetId, targetTitle, context, contextId, recipients, createdAt];

  /// Creates a copy of this InviteEntity but with the given fields replaced with the new values.
  InviteEntity copyWith({
    String? id,
    String? inviterId,
    String? targetId,
    String? targetTitle,
    InviteContext? context,
    String? contextId,
    Map<String, InviteStatus>? recipients,
    DateTime? createdAt,
  }) {
    return InviteEntity(
      id: id ?? this.id,
      inviterId: inviterId ?? this.inviterId,
      targetId: targetId ?? this.targetId,
      targetTitle: targetTitle ?? this.targetTitle,
      context: context ?? this.context,
      contextId: contextId ?? this.contextId,
      recipients: recipients ?? this.recipients,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}