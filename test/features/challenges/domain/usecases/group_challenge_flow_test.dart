import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_sdg/features/challenges/domain/entities/challenge_entity.dart';
import 'package:flutter_sdg/features/challenges/domain/entities/challenge_progress_entity.dart';
import 'package:flutter_sdg/features/challenges/domain/entities/group_challenge_progress_entity.dart';
import 'package:flutter_sdg/features/challenges/domain/entities/task_progress_entity.dart';
import 'package:flutter_sdg/features/challenges/domain/repositories/challenge_progress_repository.dart';
import 'package:flutter_sdg/features/challenges/domain/repositories/challenge_repository.dart';
import 'package:flutter_sdg/features/challenges/domain/usecases/accept_challenge_usecase.dart';
import 'package:flutter_sdg/features/challenges/domain/usecases/add_participant_to_group_challenge_usecase.dart';
import 'package:flutter_sdg/features/challenges/domain/usecases/create_group_challenge_progress_usecase.dart';
import 'package:flutter_sdg/features/challenges/domain/usecases/get_challenge_by_id_usecase.dart';
import 'package:flutter_sdg/features/challenges/domain/usecases/start_challenge_usecase.dart';
import 'package:flutter_sdg/features/challenges/domain/usecases/update_task_progress_usecase.dart';
import 'package:flutter_sdg/features/chat/domain/entities/chat_user_entity.dart';
import 'package:flutter_sdg/features/chat/domain/entities/message_entity.dart';
import 'package:flutter_sdg/features/chat/domain/usecases/get_chat_user_by_id_usecase.dart';
import 'package:flutter_sdg/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:flutter_sdg/features/invites/domain/entities/invite_entity.dart';
import 'package:flutter_sdg/features/invites/domain/repositories/invites_repository.dart';
import 'package:flutter_sdg/features/invites/domain/usecases/accept_challenge_invite_usecase.dart';
import 'package:flutter_sdg/features/profile/domain/repositories/user_profile_repository.dart';

import 'group_challenge_flow_test.mocks.dart';

// Annotation to generate mock classes
@GenerateMocks([
  ChallengeRepository,
  ChallengeProgressRepository,
  InvitesRepository,
  UserProfileRepository,
  SendMessageUseCase,
  GetChatUserByIdUseCase
])
void main() {
  // Declare all mocks and real use cases
  late MockChallengeRepository mockChallengeRepository;
  late MockChallengeProgressRepository mockChallengeProgressRepository;
  late MockInvitesRepository mockInvitesRepository;
  late MockUserProfileRepository mockUserProfileRepository;
  late MockSendMessageUseCase mockSendMessageUseCase;
  late MockGetChatUserByIdUseCase mockGetChatUserByIdUseCase;

  late GetChallengeByIdUseCase getChallengeByIdUseCase;
  late AcceptChallengeUseCase acceptChallengeUseCase;
  late StartChallengeUseCase startChallengeUseCase;
  late CreateGroupChallengeProgressUseCase createGroupChallengeProgressUseCase;
  late AddParticipantToGroupChallengeUseCase addParticipantToGroupChallengeUseCase;
  late AcceptChallengeInviteUseCase acceptChallengeInviteUseCase;
  late UpdateTaskProgressUseCase updateTaskProgressUseCase;

  setUp(() {
    // Initialize mocks before each test
    mockChallengeRepository = MockChallengeRepository();
    mockChallengeProgressRepository = MockChallengeProgressRepository();
    mockInvitesRepository = MockInvitesRepository();
    mockUserProfileRepository = MockUserProfileRepository();
    mockSendMessageUseCase = MockSendMessageUseCase();
    mockGetChatUserByIdUseCase = MockGetChatUserByIdUseCase();

    // Initialize real use cases with mocked repositories
    getChallengeByIdUseCase = GetChallengeByIdUseCase(mockChallengeRepository);
    acceptChallengeUseCase = AcceptChallengeUseCase(userProfileRepository: mockUserProfileRepository);
    startChallengeUseCase = StartChallengeUseCase(mockChallengeProgressRepository);
    createGroupChallengeProgressUseCase = CreateGroupChallengeProgressUseCase(mockChallengeProgressRepository);
    addParticipantToGroupChallengeUseCase = AddParticipantToGroupChallengeUseCase(mockChallengeProgressRepository);

    acceptChallengeInviteUseCase = AcceptChallengeInviteUseCase(
      mockInvitesRepository,
      startChallengeUseCase,
      acceptChallengeUseCase,
      createGroupChallengeProgressUseCase,
      addParticipantToGroupChallengeUseCase,
    );

    updateTaskProgressUseCase = UpdateTaskProgressUseCase(
      mockChallengeProgressRepository,
      mockSendMessageUseCase,
      mockGetChatUserByIdUseCase,
    );
  });

  // --- Test Data ---
  final tChallenge = ChallengeEntity(
    id: 'challenge1',
    title: 'Test Challenge',
    description: 'A test challenge',
    categories: [],
    authorId: 'author1',
    tasks: [],
    durationInDays: 7,
  );

  final tUser1 = ChatUserEntity(id: 'user1', name: 'Alice');
  final tUser2 = ChatUserEntity(id: 'user2', name: 'Bob');
  final tUser3 = ChatUserEntity(id: 'user3', name: 'Charlie');

  final tInvite = InviteEntity(
    id: 'invite1',
    inviterId: tUser1.id,
    targetId: tChallenge.id,
    targetTitle: tChallenge.title,
    context: InviteContext.group,
    contextId: 'group1',
    recipients: {
      tUser1.id: InviteStatus.pending,
      tUser2.id: InviteStatus.pending,
      tUser3.id: InviteStatus.pending,
    },
    createdAt: DateTime.now(),
  );

  group('Group Challenge Full Flow', () {
    test(
        'should create group progress ONLY when the 3rd user accepts, then send a system message on task completion',
            () async {
          // ARRANGE: Set up all mock responses

          // --- Responses for the 3 acceptance calls ---
          when(mockInvitesRepository.updateAndGetInvite(
            inviteId: anyNamed('inviteId'),
            recipientId: tUser1.id,
            newStatus: anyNamed('newStatus'),
          )).thenAnswer((_) async => tInvite.copyWith(recipients: {tUser1.id: InviteStatus.accepted}));

          when(mockInvitesRepository.updateAndGetInvite(
            inviteId: anyNamed('inviteId'),
            recipientId: tUser2.id,
            newStatus: anyNamed('newStatus'),
          )).thenAnswer((_) async => tInvite.copyWith(recipients: {tUser1.id: InviteStatus.accepted, tUser2.id: InviteStatus.accepted}));

          when(mockInvitesRepository.updateAndGetInvite(
            inviteId: anyNamed('inviteId'),
            recipientId: tUser3.id,
            newStatus: anyNamed('newStatus'),
          )).thenAnswer((_) async => tInvite.copyWith(recipients: {tUser1.id: InviteStatus.accepted, tUser2.id: InviteStatus.accepted, tUser3.id: InviteStatus.accepted}));

          // --- Generic responses for all calls ---
          when(mockUserProfileRepository.addTaskToOngoing(any, any)).thenAnswer((_) async => true);
          when(mockChallengeProgressRepository.createChallengeProgress(any)).thenAnswer((_) async => Future.value());
          when(mockChallengeProgressRepository.createGroupProgress(any)).thenAnswer((_) async => Future.value());
          when(mockChallengeProgressRepository.updateTaskState(any, any, any)).thenAnswer((_) async => Future.value());
          when(mockChallengeProgressRepository.incrementGroupProgress(any)).thenAnswer((_) async => Future.value());

          // --- Responses needed for the final system message step ---
          when(mockChallengeProgressRepository.watchChallengeProgress(any))
              .thenAnswer((_) => Stream.value(ChallengeProgressEntity(
            id: '${tUser1.id}_${tChallenge.id}',
            userId: tUser1.id,
            challengeId: tChallenge.id,
            startedAt: DateTime.now(),
            taskStates: {},
            inviteId: tInvite.id,
          )));

          when(mockChallengeProgressRepository.getGroupProgress(any))
              .thenAnswer((_) async => GroupChallengeProgressEntity(
            id: tInvite.id,
            challengeId: tChallenge.id,
            contextId: 'group1',
            participantIds: [tUser1.id, tUser2.id, tUser3.id],
            totalTasksRequired: 10,
            completedTasksCount: 0,
            unlockedMilestones: [],
            createdAt: DateTime.now(),
          ));

          when(mockGetChatUserByIdUseCase.call(userId: tUser1.id)).thenAnswer((_) async => tUser1);
          when(mockSendMessageUseCase.call(message: anyNamed('message'), contextId: anyNamed('contextId'), isGroupMessage: anyNamed('isGroupMessage')))
              .thenAnswer((_) async => Future.value());


          // ACT & ASSERT: Part 1 - Users 1 and 2 accept
          await acceptChallengeInviteUseCase(AcceptInviteParams(invite: tInvite, userId: tUser1.id, challenge: tChallenge));
          await acceptChallengeInviteUseCase(AcceptInviteParams(invite: tInvite, userId: tUser2.id, challenge: tChallenge));

          // Verify that the group progress has NOT been created yet
          verifyNever(mockChallengeProgressRepository.createGroupProgress(any));

          // ACT & ASSERT: Part 2 - User 3 accepts
          await acceptChallengeInviteUseCase(AcceptInviteParams(invite: tInvite, userId: tUser3.id, challenge: tChallenge));

          // Verify that the group progress was created exactly ONCE
          verify(mockChallengeProgressRepository.createGroupProgress(any)).called(1);

          // ACT & ASSERT: Part 3 - User 1 completes a task
          await updateTaskProgressUseCase(UpdateTaskProgressParams(
            progressId: '${tUser1.id}_${tChallenge.id}',
            taskIndex: 0,
            isCompleted: true,
          ));

          // FINAL VERIFICATION: Check if the SendMessageUseCase was called
          final verification = verify(mockSendMessageUseCase.call(
              message: captureAnyNamed('message'),
              contextId: 'group1',
              isGroupMessage: true
          ));

          verification.called(1);

          // Optional: Inspect the captured message to be sure it's a system message
          final capturedMessage = verification.captured.first as MessageEntity;
          expect(capturedMessage.type, MessageType.progressUpdate);
          expect(capturedMessage.fromId, 'system');
          expect(capturedMessage.msg, contains('Progress: [1/10]'));
        });
  });
}