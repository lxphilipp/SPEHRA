import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart'; // Für ChatRemoteDataSourceImpl

import 'app.dart'; // Deine Haupt-App-Widget
import 'features/chat/domain/usecases/delete_group_usecase.dart';
import 'features/chat/domain/usecases/hide_chat_usecase.dart';
import 'features/chat/domain/usecases/set_chat_cleared_timestamp_usecase.dart';
import 'features/chat/domain/usecases/watch_chat_room_by_id_usecase.dart';
import 'features/introduction/data/datasources/intro_local_datasource.dart';
import 'features/introduction/data/repositories/intro_repository_impl.dart';
import 'features/introduction/domain/repositories/intro_repository.dart';
import 'features/introduction/domain/usecases/get_intro_pages_usecase.dart';
import 'firebase_options.dart';
import 'core/utils/app_logger.dart';

// --- AUTH FEATURE ---
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/get_auth_state_changes_usecase.dart';
import 'features/auth/domain/usecases/get_current_user_usecase.dart';
import 'features/auth/domain/usecases/register_user_usecase.dart';
import 'features/auth/domain/usecases/send_password_reset_email_usecase.dart';
import 'features/auth/domain/usecases/sign_in_user_usecase.dart';
import 'features/auth/domain/usecases/sign_out_user_usecase.dart';
import 'features/auth/presentation/providers/auth_provider.dart';

// --- PROFILE FEATURE ---
import 'features/profile/data/datasources/profile_remote_datasource.dart';
import 'features/profile/data/datasources/profile_stats_datasource.dart';
import 'features/profile/data/repositories/user_profile_repository_impl.dart';
import 'features/profile/domain/repositories/user_profile_repository.dart';
import 'features/profile/domain/usecases/get_profile_stats_pie_chart_usecase.dart';
import 'features/profile/domain/usecases/get_user_profile_usecase.dart';
import 'features/profile/domain/usecases/update_profile_data_usecase.dart';
import 'features/profile/domain/usecases/upload_profile_image_usecase.dart';
import 'features/profile/domain/usecases/watch_user_profile_usecase.dart';
import 'features/profile/presentation/providers/user_profile_provider.dart';

// --- CHALLENGES FEATURE ---
import 'features/challenges/data/datasources/challenge_remote_datasource.dart';
import 'features/challenges/data/repositories/challenge_repository_impl.dart';
import 'features/challenges/domain/repositories/challenge_repository.dart';
import 'features/challenges/domain/usecases/accept_challenge_usecase.dart';
import 'features/challenges/domain/usecases/complete_challenge_usecase.dart';
import 'features/challenges/domain/usecases/create_challenge_usecase.dart';
import 'features/challenges/domain/usecases/get_all_challenges_stream_usecase.dart';
import 'features/challenges/domain/usecases/get_challenge_by_id_usecase.dart';
import 'features/challenges/domain/usecases/remove_challenge_from_ongoing_usecase.dart';
import 'features/challenges/presentation/providers/challenge_provider.dart';

// --- SDG FEATURE ---
import 'features/sdg/data/datasources/sdg_local_datasource.dart';
import 'features/sdg/data/repositories/sdg_repository_impl.dart';
import 'features/sdg/domain/repositories/sdg_repository.dart';
import 'features/sdg/domain/usecases/get_all_sdg_list_items_usecase.dart';
import 'features/sdg/domain/usecases/get_sdg_detail_by_id_usecase.dart';
import 'features/sdg/presentation/providers/sdg_detail_provider.dart';
import 'features/sdg/presentation/providers/sdg_list_provider.dart';

// --- HOME FEATURE ---
import 'features/home/domain/usecases/get_completed_challenge_previews_usecase.dart';
import 'features/home/domain/usecases/get_ongoing_challenge_previews_usecase.dart';
import 'features/home/presentation/providers/home_provider.dart';

// --- CHAT FEATURE ---
import 'features/chat/data/datasources/chat_remote_data_source.dart';
import 'features/chat/data/repositories/chat_repository_impl.dart';
import 'features/chat/domain/repositories/chat_repository.dart';
// Chat UseCases
import 'features/chat/domain/usecases/create_or_get_chat_room_usecase.dart';
import 'features/chat/domain/usecases/get_chat_rooms_stream_usecase.dart';
import 'features/chat/domain/usecases/update_chat_room_with_message_usecase.dart';
import 'features/chat/domain/usecases/create_group_chat_usecase.dart';
import 'features/chat/domain/usecases/get_group_chats_stream_usecase.dart';
import 'features/chat/domain/usecases/update_group_chat_with_message_usecase.dart';
import 'features/chat/domain/usecases/watch_group_chat_by_id_usecase.dart';
import 'features/chat/domain/usecases/update_group_chat_details_usecase.dart';
import 'features/chat/domain/usecases/add_members_to_group_usecase.dart';
import 'features/chat/domain/usecases/remove_member_from_group_usecase.dart';
import 'features/chat/domain/usecases/send_message_usecase.dart';
import 'features/chat/domain/usecases/get_messages_stream_usecase.dart';
import 'features/chat/domain/usecases/get_group_messages_stream_usecase.dart';
import 'features/chat/domain/usecases/mark_message_as_read_usecase.dart';
import 'features/chat/domain/usecases/delete_message_usecase.dart';
import 'features/chat/domain/usecases/get_chat_user_by_id_usecase.dart';
import 'features/chat/domain/usecases/get_chat_users_stream_by_ids_usecase.dart';
import 'features/chat/domain/usecases/find_chat_users_by_name_prefix_usecase.dart';
import 'features/chat/domain/usecases/upload_chat_image_usecase.dart';

// Chat UI State Provider
import 'features/chat/presentation/providers/chat_room_list_provider.dart';
import 'features/chat/presentation/providers/group_chat_list_provider.dart';
import 'features/chat/presentation/providers/user_search_provider.dart';
import 'features/chat/presentation/providers/create_group_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kDebugMode) {
    Logger.level = Level.debug;
  } else {
    Logger.level = Level.warning;
  }
  AppLogger.info("Starting SDG App initialization");

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    AppLogger.info("Firebase initialized successfully");
  } catch (e, stackTrace) {
    AppLogger.fatal("Failed to initialize Firebase", e, stackTrace);
    rethrow;
  }

  final fbAuth = fb_auth.FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;
  const uuid = Uuid(); // const, da Uuid keine internen Zustände hat, die sich ändern

  FlutterError.onError = (FlutterErrorDetails details) {
    AppLogger.fatal('Flutter Error: ${details.exception}', details.exception, details.stack);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    AppLogger.fatal('Platform Error: $error', error, stack);
    return true;
  };

  AppLogger.info("Starting app with providers configuration");

  runApp(
    MultiProvider(
      providers: [
        // --- EXTERNAL / GLOBAL ---
        Provider<fb_auth.FirebaseAuth>.value(value: fbAuth),
        Provider<FirebaseFirestore>.value(value: firestore),
        Provider<FirebaseStorage>.value(value: storage),
        Provider<Uuid>.value(value: uuid),


        // --- AUTH FEATURE ---
        Provider<AuthRemoteDataSource>(create: (context) => AuthRemoteDataSourceImpl(
            firebaseAuth: context.read<fb_auth.FirebaseAuth>(),
            firestore: context.read<FirebaseFirestore>())
        ),
        Provider<AuthRepository>(
          create: (context) => AuthRepositoryImpl(remoteDataSource: context.read<AuthRemoteDataSource>()),
        ),
        Provider<GetAuthStateChangesUseCase>(create: (context) => GetAuthStateChangesUseCase(context.read<AuthRepository>())),
        Provider<GetCurrentUserUseCase>(create: (context) => GetCurrentUserUseCase(context.read<AuthRepository>())),
        Provider<SignInUserUseCase>(create: (context) => SignInUserUseCase(context.read<AuthRepository>())),
        Provider<RegisterUserUseCase>(create: (context) => RegisterUserUseCase(context.read<AuthRepository>())),
        Provider<SignOutUserUseCase>(create: (context) => SignOutUserUseCase(context.read<AuthRepository>())),
        Provider<SendPasswordResetEmailUseCase>(create: (context) => SendPasswordResetEmailUseCase(context.read<AuthRepository>())),
        ChangeNotifierProvider<AuthenticationProvider>(
          create: (context) => AuthenticationProvider(
            getAuthStateChangesUseCase: context.read<GetAuthStateChangesUseCase>(),
            getCurrentUserUseCase: context.read<GetCurrentUserUseCase>(),
            signInUserUseCase: context.read<SignInUserUseCase>(),
            registerUserUseCase: context.read<RegisterUserUseCase>(),
            signOutUserUseCase: context.read<SignOutUserUseCase>(),
            sendPasswordResetEmailUseCase: context.read<SendPasswordResetEmailUseCase>(),
          ),
        ),

        // --- PROFILE FEATURE ---
        Provider<ProfileRemoteDataSource>(create: (context) => ProfileRemoteDataSourceImpl(
            firestore: context.read<FirebaseFirestore>(),
            storage: context.read<FirebaseStorage>())
        ),
        Provider<ProfileStatsDataSource>(create: (context) => ProfileStatsDataSourceImpl(firestore: context.read<FirebaseFirestore>())),
        Provider<UserProfileRepository>(
          create: (context) => UserProfileRepositoryImpl(
            remoteDataSource: context.read<ProfileRemoteDataSource>(),
            statsDataSource: context.read<ProfileStatsDataSource>(),
          ),
        ),
        Provider<GetUserProfileUseCase>(create: (context) => GetUserProfileUseCase(context.read<UserProfileRepository>())),
        Provider<WatchUserProfileUseCase>(create: (context) => WatchUserProfileUseCase(context.read<UserProfileRepository>())),
        Provider<UpdateProfileDataUseCase>(create: (context) => UpdateProfileDataUseCase(context.read<UserProfileRepository>())),
        Provider<UploadProfileImageUseCase>(create: (context) => UploadProfileImageUseCase(context.read<UserProfileRepository>())),
        Provider<GetProfileStatsPieChartUseCase>(create: (context) => GetProfileStatsPieChartUseCase(context.read<UserProfileRepository>())),
        ChangeNotifierProxyProvider<AuthenticationProvider, UserProfileProvider>(
          create: (context) => UserProfileProvider( /* ... wie zuvor ... */
            getUserProfileUseCase: context.read<GetUserProfileUseCase>(),
            watchUserProfileUseCase: context.read<WatchUserProfileUseCase>(),
            updateProfileDataUseCase: context.read<UpdateProfileDataUseCase>(),
            uploadProfileImageUseCase: context.read<UploadProfileImageUseCase>(),
            getProfileStatsPieChartUseCase: context.read<GetProfileStatsPieChartUseCase>(),
            authProvider: context.read<AuthenticationProvider>(),
          ),
          update: (context, auth, previous) => UserProfileProvider( /* ... wie zuvor ... */
            getUserProfileUseCase: context.read<GetUserProfileUseCase>(),
            watchUserProfileUseCase: context.read<WatchUserProfileUseCase>(),
            updateProfileDataUseCase: context.read<UpdateProfileDataUseCase>(),
            uploadProfileImageUseCase: context.read<UploadProfileImageUseCase>(),
            getProfileStatsPieChartUseCase: context.read<GetProfileStatsPieChartUseCase>(),
            authProvider: auth,
          ),
        ),

        // --- CHALLENGES FEATURE ---
        Provider<ChallengeRemoteDataSource>(create: (context) => ChallengeRemoteDataSourceImpl(firestore: context.read<FirebaseFirestore>())),
        Provider<ChallengeRepository>(create: (context) => ChallengeRepositoryImpl(remoteDataSource: context.read<ChallengeRemoteDataSource>())),
        Provider<GetAllChallengesStreamUseCase>(create: (context) => GetAllChallengesStreamUseCase(context.read<ChallengeRepository>())),
        Provider<GetChallengeByIdUseCase>(create: (context) => GetChallengeByIdUseCase(context.read<ChallengeRepository>())),
        Provider<CreateChallengeUseCase>(create: (context) => CreateChallengeUseCase(context.read<ChallengeRepository>())),
        Provider<AcceptChallengeUseCase>(create: (context) => AcceptChallengeUseCase(userProfileRepository: context.read<UserProfileRepository>())),
        Provider<CompleteChallengeUseCase>(create: (context) => CompleteChallengeUseCase(userProfileRepository: context.read<UserProfileRepository>(), challengeRepository: context.read<ChallengeRepository>())),
        Provider<RemoveChallengeFromOngoingUseCase>(create: (context) => RemoveChallengeFromOngoingUseCase(context.read<UserProfileRepository>())),
        ChangeNotifierProxyProvider2<AuthenticationProvider, UserProfileProvider, ChallengeProvider>(
          create: (context) => ChallengeProvider( /* ... wie zuvor ... */
            getAllChallengesStreamUseCase: context.read<GetAllChallengesStreamUseCase>(),
            getChallengeByIdUseCase: context.read<GetChallengeByIdUseCase>(),
            createChallengeUseCase: context.read<CreateChallengeUseCase>(),
            acceptChallengeUseCase: context.read<AcceptChallengeUseCase>(),
            completeChallengeUseCase: context.read<CompleteChallengeUseCase>(),
            removeChallengeFromOngoingUseCase: context.read<RemoveChallengeFromOngoingUseCase>(),
            authProvider: context.read<AuthenticationProvider>(),
            userProfileProvider: context.read<UserProfileProvider>(),
          ),
          update: (context, auth, profile, previous) => ChallengeProvider( /* ... wie zuvor ... */
            getAllChallengesStreamUseCase: context.read<GetAllChallengesStreamUseCase>(),
            getChallengeByIdUseCase: context.read<GetChallengeByIdUseCase>(),
            createChallengeUseCase: context.read<CreateChallengeUseCase>(),
            acceptChallengeUseCase: context.read<AcceptChallengeUseCase>(),
            completeChallengeUseCase: context.read<CompleteChallengeUseCase>(),
            removeChallengeFromOngoingUseCase: context.read<RemoveChallengeFromOngoingUseCase>(),
            authProvider: auth,
            userProfileProvider: profile,
          ),
        ),

        // --- SDG FEATURE ---
        Provider<SdgLocalDataSource>(create: (_) => SdgLocalDataSourceImpl()),
        Provider<SdgRepository>(create: (context) => SdgRepositoryImpl(localDataSource: context.read<SdgLocalDataSource>())),
        Provider<GetAllSdgListItemsUseCase>(create: (context) => GetAllSdgListItemsUseCase(context.read<SdgRepository>())),
        Provider<GetSdgDetailByIdUseCase>(create: (context) => GetSdgDetailByIdUseCase(context.read<SdgRepository>())),
        ChangeNotifierProvider<SdgListProvider>(create: (context) => SdgListProvider(getAllSdgListItemsUseCase: context.read<GetAllSdgListItemsUseCase>())),
        ChangeNotifierProvider<SdgDetailProvider>(create: (context) => SdgDetailProvider(getSdgDetailsByIdUseCase: context.read<GetSdgDetailByIdUseCase>())),

        // --- HOME FEATURE ---
        Provider<GetOngoingChallengePreviewsUseCase>(create: (context) => GetOngoingChallengePreviewsUseCase(context.read<GetChallengeByIdUseCase>())),
        Provider<GetCompletedChallengePreviewsUseCase>(create: (context) => GetCompletedChallengePreviewsUseCase(context.read<GetChallengeByIdUseCase>())),
        ChangeNotifierProxyProvider4<AuthenticationProvider, UserProfileProvider, ChallengeProvider, SdgListProvider, HomeProvider>(
          create: (context) => HomeProvider( /* ... wie zuvor ... */
            getOngoingChallengePreviewsUseCase: context.read<GetOngoingChallengePreviewsUseCase>(),
            getCompletedChallengePreviewsUseCase: context.read<GetCompletedChallengePreviewsUseCase>(),
            authProvider: context.read<AuthenticationProvider>(),
            userProfileProvider: context.read<UserProfileProvider>(),
            challengeProvider: context.read<ChallengeProvider>(),
            sdgListProvider: context.read<SdgListProvider>(),
          ),
          update: (context, auth, profile, challenges, sdgList, previous) => HomeProvider( /* ... wie zuvor ... */
            getOngoingChallengePreviewsUseCase: context.read<GetOngoingChallengePreviewsUseCase>(),
            getCompletedChallengePreviewsUseCase: context.read<GetCompletedChallengePreviewsUseCase>(),
            authProvider: auth,
            userProfileProvider: profile,
            challengeProvider: challenges,
            sdgListProvider: sdgList,
          ),
        ),

        // --- INTRODUCTION FEATURE --- //
        Provider<IntroLocalDataSource>(create: (_) => IntroLocalDataSourceImpl()),
        Provider<IntroRepository>(create: (context) => IntroRepositoryImpl(localDataSource: context.read<IntroLocalDataSource>())),
        Provider<GetIntroPagesUseCase>(create: (context) => GetIntroPagesUseCase(context.read<IntroRepository>())),

        // --- CHAT FEATURE ---
        // DataSources
        Provider<ChatRemoteDataSource>(
          create: (context) => ChatRemoteDataSourceImpl(
            firestore: context.read<FirebaseFirestore>(),
            firebaseStorage: context.read<FirebaseStorage>(),
            uuid: context.read<Uuid>(),
          ),
        ),
        // Repositories
        Provider<ChatRepository>(
          create: (context) => ChatRepositoryImpl(
            remoteDataSource: context.read<ChatRemoteDataSource>(),
          ),
        ),
        // UseCases
        Provider<CreateOrGetChatRoomUseCase>(create: (context) => CreateOrGetChatRoomUseCase(context.read<ChatRepository>())),
        Provider<GetChatRoomsStreamUseCase>(create: (context) => GetChatRoomsStreamUseCase(context.read<ChatRepository>())),
        Provider<UpdateChatRoomWithMessageUseCase>(create: (context) => UpdateChatRoomWithMessageUseCase(context.read<ChatRepository>())),
        Provider<CreateGroupChatUseCase>(create: (context) => CreateGroupChatUseCase(context.read<ChatRepository>())),
        Provider<GetGroupChatsStreamUseCase>(create: (context) => GetGroupChatsStreamUseCase(context.read<ChatRepository>())),
        Provider<UpdateGroupChatWithMessageUseCase>(create: (context) => UpdateGroupChatWithMessageUseCase(context.read<ChatRepository>())),
        Provider<WatchGroupChatByIdUseCase>(create: (context) => WatchGroupChatByIdUseCase(context.read<ChatRepository>())),
        Provider<UpdateGroupChatDetailsUseCase>(create: (context) => UpdateGroupChatDetailsUseCase(context.read<ChatRepository>())),
        Provider<AddMembersToGroupUseCase>(create: (context) => AddMembersToGroupUseCase(context.read<ChatRepository>())),
        Provider<RemoveMemberFromGroupUseCase>(create: (context) => RemoveMemberFromGroupUseCase(context.read<ChatRepository>())),
        Provider<SendMessageUseCase>(create: (context) => SendMessageUseCase(context.read<ChatRepository>())),
        Provider<GetMessagesStreamUseCase>(create: (context) => GetMessagesStreamUseCase(context.read<ChatRepository>())),
        Provider<GetGroupMessagesStreamUseCase>(create: (context) => GetGroupMessagesStreamUseCase(context.read<ChatRepository>())),
        Provider<MarkMessageAsReadUseCase>(create: (context) => MarkMessageAsReadUseCase(context.read<ChatRepository>())),
        Provider<DeleteMessageUseCase>(create: (context) => DeleteMessageUseCase(context.read<ChatRepository>())), // Falls implementiert
        Provider<GetChatUserByIdUseCase>(create: (context) => GetChatUserByIdUseCase(context.read<ChatRepository>())),
        Provider<GetChatUsersStreamByIdsUseCase>(create: (context) => GetChatUsersStreamByIdsUseCase(context.read<ChatRepository>())),
        Provider<FindChatUsersByNamePrefixUseCase>(create: (context) => FindChatUsersByNamePrefixUseCase(context.read<ChatRepository>())),
        Provider<UploadChatImageUseCase>(create: (context) => UploadChatImageUseCase(context.read<ChatRepository>())),
        Provider<UpdateGroupChatDetailsUseCase>(create: (context) => UpdateGroupChatDetailsUseCase(context.read<ChatRepository>())),
        Provider<AddMembersToGroupUseCase>(create: (context) => AddMembersToGroupUseCase(context.read<ChatRepository>())),
        Provider<RemoveMemberFromGroupUseCase>(create: (context) => RemoveMemberFromGroupUseCase(context.read<ChatRepository>())),
        Provider<DeleteGroupUseCase>(create: (context) => DeleteGroupUseCase(context.read<ChatRepository>())),
        Provider<HideChatUseCase>(create: (context) => HideChatUseCase(context.read<ChatRepository>())),
        Provider<SetChatClearedTimestampUseCase>(create: (context) => SetChatClearedTimestampUseCase(context.read<ChatRepository>())),
        Provider<WatchChatRoomByIdUseCase>(create: (context) => WatchChatRoomByIdUseCase(context.read<ChatRepository>())),
        // UI State Provider für Chat-Listen und User-Suche (global verfügbar)
        ChangeNotifierProvider<ChatRoomListProvider>(
          create: (context) => ChatRoomListProvider(
            getChatRoomsStreamUseCase: context.read<GetChatRoomsStreamUseCase>(),
            createOrGetChatRoomUseCase: context.read<CreateOrGetChatRoomUseCase>(),
            authProvider: context.read<AuthenticationProvider>(),
            getChatUsersStreamByIdsUseCase: context.read<GetChatUsersStreamByIdsUseCase>(),
          ),
        ),
        ChangeNotifierProvider<GroupChatListProvider>(
          create: (context) => GroupChatListProvider(
            getGroupChatsStreamUseCase: context.read<GetGroupChatsStreamUseCase>(),
            createGroupChatUseCase: context.read<CreateGroupChatUseCase>(),
            authProvider: context.read<AuthenticationProvider>(),

          ),
        ),
        ChangeNotifierProvider<UserSearchProvider>(
          create: (context) => UserSearchProvider(
            findUsersUseCase: context.read<FindChatUsersByNamePrefixUseCase>(),
            authProvider: context.read<AuthenticationProvider>(),
          ),
        ),
        // CreateGroupProvider wird dynamisch im CreateGroupScreen erstellt,
        // aber wenn er Abhängigkeiten zu anderen globalen Providern hätte, die nicht
        // AuthenticationProvider oder GroupChatListProvider sind, müsste man ihn hier als ProxyProvider erstellen.
        // Für den Moment ist es okay, ihn im Screen zu erstellen, da seine Abhängigkeiten
        // (GroupChatListProvider, AuthenticationProvider) bereits global sind.
        // Alternativ:
        ChangeNotifierProxyProvider2<AuthenticationProvider, GroupChatListProvider, CreateGroupProvider>(
          create: (context) => CreateGroupProvider(
            groupChatListProvider: context.read<GroupChatListProvider>(),
            authProvider: context.read<AuthenticationProvider>(),
            // uploadGroupImageUseCase: context.read<UploadGroupImageUseCase>(), // Wenn vorhanden
          ),
          update: (context, auth, groupList, previous) => CreateGroupProvider(
            groupChatListProvider: groupList,
            authProvider: auth,
            // uploadGroupImageUseCase: context.read<UploadGroupImageUseCase>(),
          ),
        ),
        // IndividualChatProvider und GroupChatProvider werden dynamisch in ihren jeweiligen Screens erstellt.

      ],
      child: const MyApp(),
    ),
  );
}