// lib/features/challenges/domain/usecases/watch_group_progress_by_context_id_usecase.dart

import '../../../../core/usecases/use_case.dart'; // IMPORTANT: Import the base class
import '../../domain/entities/group_challenge_progress_entity.dart';
import '../../domain/repositories/challenge_progress_repository.dart';

/// This Use Case provides a stream of group challenge progress for a specific context (e.g., a group chat).
/// It now implements the generic UseCase interface for architectural consistency.
class WatchGroupProgressByContextIdUseCase implements UseCase<Stream<List<GroupChallengeProgressEntity>>, String> {
  final ChallengeProgressRepository _repository;

  WatchGroupProgressByContextIdUseCase(this._repository);

  /// Executes the use case.
  ///
  /// [contextId] The contextId to watch for progress.
  /// Returns a stream of a list of [GroupChallengeProgressEntity].
  @override
  Future<Stream<List<GroupChallengeProgressEntity>>> call(String contextId) async {
    return _repository.watchGroupProgressByContextId(contextId);
  }
}