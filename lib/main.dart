// lib/main.dart

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

import 'app.dart'; // Your main app widget
import 'features/challenges/domain/usecases/get_llm_feedback_usecase.dart';
import 'features/challenges/domain/usecases/search_location_usecase.dart';
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

// --- INTRODUCTION FEATURE ---
import 'features/introduction/data/datasources/intro_local_datasource.dart';
import 'features/introduction/data/repositories/intro_repository_impl.dart';
import 'features/introduction/domain/repositories/intro_repository.dart';
import 'features/introduction/domain/usecases/get_intro_pages_usecase.dart';

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
import 'features/chat/domain/usecases/delete_group_usecase.dart';
import 'features/chat/domain/usecases/hide_chat_usecase.dart';
import 'features/chat/domain/usecases/set_chat_cleared_timestamp_usecase.dart';
import 'features/chat/domain/usecases/watch_chat_room_by_id_usecase.dart';
// Chat UI State Providers
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
  AppLogger.info("Starting App initialization");

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await FirebaseAppCheck.instance.activate(
      webProvider: ReCaptchaV3Provider('6LcHiH8rAAAAAL4NOwsSwnGfXBUqOjeyRfQgKNHq'),
      androidProvider: AndroidProvider.debug,
      appleProvider: AppleProvider.appAttest,
    );
    AppLogger.info("Firebase initialized successfully");
  } catch (e, stackTrace) {
    AppLogger.fatal("Failed to initialize Firebase", e, stackTrace);
    return;
  }

  final fbAuth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;
  final appcheck = FirebaseAppCheck.instance;
  const uuid = Uuid();

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
        Provider<FirebaseAuth>.value(value: fbAuth),
        Provider<FirebaseFirestore>.value(value: firestore),
        Provider<FirebaseStorage>.value(value: storage),
        Provider<Uuid>.value(value: uuid),
        Provider<FirebaseAppCheck>.value(value: appcheck),

        // --- DATA & DOMAIN LAYER (By Feature) ---
        // AUTH
        Provider<AuthRemoteDataSource>(create: (context) => AuthRemoteDataSourceImpl(firebaseAuth: context.read(), firestore: context.read())),
        Provider<AuthRepository>(create: (context) => AuthRepositoryImpl(remoteDataSource: context.read())),
        Provider<GetAuthStateChangesUseCase>(create: (context) => GetAuthStateChangesUseCase(context.read())),
        Provider<GetCurrentUserUseCase>(create: (context) => GetCurrentUserUseCase(context.read())),
        Provider<SignInUserUseCase>(create: (context) => SignInUserUseCase(context.read())),
        Provider<RegisterUserUseCase>(create: (context) => RegisterUserUseCase(context.read())),
        Provider<SignOutUserUseCase>(create: (context) => SignOutUserUseCase(context.read())),
        Provider<SendPasswordResetEmailUseCase>(create: (context) => SendPasswordResetEmailUseCase(context.read())),

        // PROFILE
        Provider<ProfileRemoteDataSource>(create: (context) => ProfileRemoteDataSourceImpl(firestore: context.read(), storage: context.read())),
        Provider<ProfileStatsDataSource>(create: (context) => ProfileStatsDataSourceImpl(firestore: context.read())),
        Provider<UserProfileRepository>(create: (context) => UserProfileRepositoryImpl(remoteDataSource: context.read(), statsDataSource: context.read())),
        Provider<GetUserProfileUseCase>(create: (context) => GetUserProfileUseCase(context.read())),
        Provider<WatchUserProfileUseCase>(create: (context) => WatchUserProfileUseCase(context.read())),
        Provider<UpdateProfileDataUseCase>(create: (context) => UpdateProfileDataUseCase(context.read())),
        Provider<UploadProfileImageUseCase>(create: (context) => UploadProfileImageUseCase(context.read())),
        Provider<GetProfileStatsPieChartUseCase>(create: (context) => GetProfileStatsPieChartUseCase(context.read())),

        // CHALLENGES
        Provider<ChallengeRemoteDataSource>(create: (context) => ChallengeRemoteDataSourceImpl(firestore: context.read(), appCheck: context.read())),
        Provider<ChallengeRepository>(create: (context) => ChallengeRepositoryImpl(remoteDataSource: context.read())),
        Provider<GetAllChallengesStreamUseCase>(create: (context) => GetAllChallengesStreamUseCase(context.read())),
        Provider<GetChallengeByIdUseCase>(create: (context) => GetChallengeByIdUseCase(context.read())),
        Provider<CreateChallengeUseCase>(create: (context) => CreateChallengeUseCase(context.read())),
        Provider<AcceptChallengeUseCase>(create: (context) => AcceptChallengeUseCase(userProfileRepository: context.read())),
        Provider<CompleteChallengeUseCase>(create: (context) => CompleteChallengeUseCase(userProfileRepository: context.read(), challengeRepository: context.read())),
        Provider<RemoveChallengeFromOngoingUseCase>(create: (context) => RemoveChallengeFromOngoingUseCase(context.read())),
        Provider<SearchLocationUseCase>(create: (context) => SearchLocationUseCase(context.read())),
        Provider<GetLlmFeedbackUseCase>(create: (context) => GetLlmFeedbackUseCase(context.read())),

        // SDG
        Provider<SdgLocalDataSource>(create: (_) => SdgLocalDataSourceImpl()),
        Provider<SdgRepository>(create: (context) => SdgRepositoryImpl(localDataSource: context.read())),
        Provider<GetAllSdgListItemsUseCase>(create: (context) => GetAllSdgListItemsUseCase(context.read())),
        Provider<GetSdgDetailByIdUseCase>(create: (context) => GetSdgDetailByIdUseCase(context.read())),

        // HOME
        Provider<GetOngoingChallengePreviewsUseCase>(create: (context) => GetOngoingChallengePreviewsUseCase(context.read())),
        Provider<GetCompletedChallengePreviewsUseCase>(create: (context) => GetCompletedChallengePreviewsUseCase(context.read())),

        // INTRODUCTION
        Provider<IntroLocalDataSource>(create: (_) => IntroLocalDataSourceImpl()),
        Provider<IntroRepository>(create: (context) => IntroRepositoryImpl(localDataSource: context.read())),
        Provider<GetIntroPagesUseCase>(create: (context) => GetIntroPagesUseCase(context.read())),

        // CHAT
        Provider<ChatRemoteDataSource>(create: (context) => ChatRemoteDataSourceImpl(firestore: context.read(), firebaseStorage: context.read(), uuid: context.read())),
        Provider<ChatRepository>(create: (context) => ChatRepositoryImpl(remoteDataSource: context.read())),
        Provider<CreateOrGetChatRoomUseCase>(create: (context) => CreateOrGetChatRoomUseCase(context.read())),
        Provider<GetChatRoomsStreamUseCase>(create: (context) => GetChatRoomsStreamUseCase(context.read())),
        Provider<UpdateChatRoomWithMessageUseCase>(create: (context) => UpdateChatRoomWithMessageUseCase(context.read())),
        Provider<CreateGroupChatUseCase>(create: (context) => CreateGroupChatUseCase(context.read())),
        Provider<GetGroupChatsStreamUseCase>(create: (context) => GetGroupChatsStreamUseCase(context.read())),
        Provider<UpdateGroupChatWithMessageUseCase>(create: (context) => UpdateGroupChatWithMessageUseCase(context.read())),
        Provider<WatchGroupChatByIdUseCase>(create: (context) => WatchGroupChatByIdUseCase(context.read())),
        Provider<UpdateGroupChatDetailsUseCase>(create: (context) => UpdateGroupChatDetailsUseCase(context.read())),
        Provider<AddMembersToGroupUseCase>(create: (context) => AddMembersToGroupUseCase(context.read())),
        Provider<RemoveMemberFromGroupUseCase>(create: (context) => RemoveMemberFromGroupUseCase(context.read())),
        Provider<SendMessageUseCase>(create: (context) => SendMessageUseCase(context.read())),
        Provider<GetMessagesStreamUseCase>(create: (context) => GetMessagesStreamUseCase(context.read())),
        Provider<GetGroupMessagesStreamUseCase>(create: (context) => GetGroupMessagesStreamUseCase(context.read())),
        Provider<MarkMessageAsReadUseCase>(create: (context) => MarkMessageAsReadUseCase(context.read())),
        Provider<DeleteMessageUseCase>(create: (context) => DeleteMessageUseCase(context.read())),
        Provider<GetChatUserByIdUseCase>(create: (context) => GetChatUserByIdUseCase(context.read())),
        Provider<GetChatUsersStreamByIdsUseCase>(create: (context) => GetChatUsersStreamByIdsUseCase(context.read())),
        Provider<FindChatUsersByNamePrefixUseCase>(create: (context) => FindChatUsersByNamePrefixUseCase(context.read())),
        Provider<UploadChatImageUseCase>(create: (context) => UploadChatImageUseCase(context.read())),
        Provider<DeleteGroupUseCase>(create: (context) => DeleteGroupUseCase(context.read())),
        Provider<HideChatUseCase>(create: (context) => HideChatUseCase(context.read())),
        Provider<SetChatClearedTimestampUseCase>(create: (context) => SetChatClearedTimestampUseCase(context.read())),
        Provider<WatchChatRoomByIdUseCase>(create: (context) => WatchChatRoomByIdUseCase(context.read())),


        // --- PRESENTATION LAYER (ChangeNotifierProviders) ---
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

        ChangeNotifierProxyProvider<AuthenticationProvider, UserProfileProvider>(
          create: (context) => UserProfileProvider(
            getUserProfileUseCase: context.read<GetUserProfileUseCase>(),
            watchUserProfileUseCase: context.read<WatchUserProfileUseCase>(),
            updateProfileDataUseCase: context.read<UpdateProfileDataUseCase>(),
            uploadProfileImageUseCase: context.read<UploadProfileImageUseCase>(),
            getProfileStatsPieChartUseCase: context.read<GetProfileStatsPieChartUseCase>(),
          ),
          update: (context, auth, previous) => previous!..updateDependencies(auth),
        ),

        ChangeNotifierProxyProvider2<AuthenticationProvider, UserProfileProvider, ChallengeProvider>(
          create: (context) => ChallengeProvider(
            getAllChallengesStreamUseCase: context.read<GetAllChallengesStreamUseCase>(),
            getChallengeByIdUseCase: context.read<GetChallengeByIdUseCase>(),
            createChallengeUseCase: context.read<CreateChallengeUseCase>(),
            acceptChallengeUseCase: context.read<AcceptChallengeUseCase>(),
            completeChallengeUseCase: context.read<CompleteChallengeUseCase>(),
            removeChallengeFromOngoingUseCase: context.read<RemoveChallengeFromOngoingUseCase>(),
            searchLocationUseCase: context.read<SearchLocationUseCase>(),
            getLlmFeedbackUseCase: context.read<GetLlmFeedbackUseCase>(),
          ),
          update: (context, auth, profile, previous) => previous!..updateDependencies(auth, profile), // Assumes an `updateWith` method exists. Should be refactored.
        ),

        ChangeNotifierProvider<SdgListProvider>(create: (context) => SdgListProvider(getAllSdgListItemsUseCase: context.read<GetAllSdgListItemsUseCase>())),
        ChangeNotifierProvider<SdgDetailProvider>(create: (context) => SdgDetailProvider(getSdgDetailsByIdUseCase: context.read<GetSdgDetailByIdUseCase>())),

        ChangeNotifierProxyProvider4<AuthenticationProvider, UserProfileProvider, ChallengeProvider, SdgListProvider, HomeProvider>(
          create: (context) => HomeProvider(
            getOngoingChallengePreviewsUseCase: context.read<GetOngoingChallengePreviewsUseCase>(),
            getCompletedChallengePreviewsUseCase: context.read<GetCompletedChallengePreviewsUseCase>(),
          ),
          update: (context, auth, profile, challenges, sdgList, previous) => previous!..updateDependencies(auth, profile, challenges, sdgList), // Assumes an `updateWith` method exists. Should be refactored.
        ),

        // Refactored Chat providers
        ChangeNotifierProxyProvider<AuthenticationProvider, ChatRoomListProvider>(
          create: (context) => ChatRoomListProvider(
            getChatRoomsStreamUseCase: context.read<GetChatRoomsStreamUseCase>(),
            createOrGetChatRoomUseCase: context.read<CreateOrGetChatRoomUseCase>(),
            getChatUsersStreamByIdsUseCase: context.read<GetChatUsersStreamByIdsUseCase>(),
          ),
          update: (context, auth, previous) => previous!..updateDependencies(auth),
        ),

        ChangeNotifierProxyProvider<AuthenticationProvider, GroupChatListProvider>(
          create: (context) => GroupChatListProvider(
            getGroupChatsStreamUseCase: context.read<GetGroupChatsStreamUseCase>(),
            createGroupChatUseCase: context.read<CreateGroupChatUseCase>(),
          ),
          update: (context, auth, previous) => previous!..updateDependencies(auth),
        ),

        ChangeNotifierProxyProvider<AuthenticationProvider, UserSearchProvider>(
          create: (context) => UserSearchProvider(
            findUsersUseCase: context.read<FindChatUsersByNamePrefixUseCase>(),
          ),
          update: (context, auth, previous) => previous!..updateDependencies(auth),
        ),

        ChangeNotifierProxyProvider2<AuthenticationProvider, GroupChatListProvider, CreateGroupProvider>(
            create: (context) => CreateGroupProvider(
            ),
            update: (context, auth, groupList, previous) => previous!..updateDependencies(auth, groupList)
        ),

      ],
      child: const MyApp(),
    ),
  );
}