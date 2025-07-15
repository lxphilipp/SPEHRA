import 'package:equatable/equatable.dart';

enum InviteStatus { pending, accepted, declined }
enum InviteContext { group, direct } // direct ist für spätere Freundes-Einladungen

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
}