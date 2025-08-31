import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';

// Entities
import '../../domain/entities/message_entity.dart';
import '../../domain/entities/chat_room_entity.dart';
import '../../domain/entities/chat_user_entity.dart';

// UseCases
import '../../domain/usecases/get_messages_stream_usecase.dart';
import '../../domain/usecases/send_message_usecase.dart';
import '../../domain/usecases/mark_message_as_read_usecase.dart';
import '../../domain/usecases/upload_chat_image_usecase.dart';
import '../../domain/usecases/watch_chat_room_by_id_usecase.dart';
import '../../domain/usecases/hide_chat_usecase.dart';
import '../../domain/usecases/set_chat_cleared_timestamp_usecase.dart';

// Auth Provider
import '../../../auth/presentation/providers/auth_provider.dart';

// Core
import '../../../../core/utils/app_logger.dart';

/// Manages the state for an individual chat screen.
///
/// This provider handles loading messages, sending new messages (text and image),
/// marking messages as read, hiding chats, clearing chat history, and managing
/// the real-time updates for chat room details and messages.
class IndividualChatProvider with ChangeNotifier {
  // --- UseCases ---
  final GetMessagesStreamUseCase _getMessagesStreamUseCase;
  final SendMessageUseCase _sendMessageUseCase;
  final MarkMessageAsReadUseCase _markMessageAsReadUseCase;
  final UploadChatImageUseCase _uploadChatImageUseCase;
  final WatchChatRoomByIdUseCase _watchChatRoomUseCase;
  final HideChatUseCase _hideChatUseCase;
  final SetChatClearedTimestampUseCase _setChatClearedTimestampUseCase;
  final AuthenticationProvider _authProvider;

  // --- Provider-Zustand ---
  /// The ID of the current chat room.
  final String roomId;
  /// The entity representing the chat partner.
  final ChatUserEntity chatPartner;

  /// Details of the current chat room, updated in real-time.
  ChatRoomEntity? _roomDetails;
  /// Stores ALL messages loaded from the stream, before any filtering.
  List<MessageEntity> _allMessages = [];
  /// Stores the messages that are currently visible in the UI after filtering (e.g., by `clearedAt` timestamp).
  List<MessageEntity> _visibleMessages = [];

  /// Indicates if initial data is being loaded.
  bool _isLoading = true;
  /// Indicates if a message is currently being sent.
  bool _isSendingMessage = false;
  /// Stores any error message that occurred.
  String? _error;
  /// Stores a preview of an image selected by the user for sending.
  File? _imagePreview;
  /// Flag to prevent concurrent marking of messages as read.
  bool _isMarkingAsRead = false;

  // --- Stream Subscriptions ---
  /// Subscription to the real-time updates of chat room details.
  StreamSubscription<ChatRoomEntity?>? _roomDetailsSubscription;
  /// Subscription to the real-time updates of messages in the chat room.
  StreamSubscription<List<MessageEntity>>? _messagesSubscription;

  // --- Konstruktor ---
  /// Creates an instance of [IndividualChatProvider].
  ///
  /// Requires various use cases for its operations and the [roomId] and [chatPartner]
  /// to identify the chat.
  IndividualChatProvider({
    required this.roomId,
    required this.chatPartner,
    required GetMessagesStreamUseCase getMessagesStreamUseCase,
    required SendMessageUseCase sendMessageUseCase,
    required MarkMessageAsReadUseCase markMessageAsReadUseCase,
    required UploadChatImageUseCase uploadChatImageUseCase,
    required WatchChatRoomByIdUseCase watchChatRoomUseCase,
    required HideChatUseCase hideChatUseCase,
    required SetChatClearedTimestampUseCase setChatClearedTimestampUseCase,
    required AuthenticationProvider authProvider,
  })  : _getMessagesStreamUseCase = getMessagesStreamUseCase,
        _sendMessageUseCase = sendMessageUseCase,
        _markMessageAsReadUseCase = markMessageAsReadUseCase,
        _uploadChatImageUseCase = uploadChatImageUseCase,
        _watchChatRoomUseCase = watchChatRoomUseCase,
        _hideChatUseCase = hideChatUseCase,
        _setChatClearedTimestampUseCase = setChatClearedTimestampUseCase,
        _authProvider = authProvider {
    AppLogger.debug("IndividualChatProvider for roomId: $roomId initialized.");
    _subscribeToRoomDetails();
  }

  // --- Getter für die UI ---
  /// The list of messages to be displayed in the UI.
  /// These are filtered based on the `clearedAt` timestamp.
  List<MessageEntity> get messages => _visibleMessages;
  /// True if the provider is currently loading initial chat data.
  bool get isLoading => _isLoading;
  /// True if a message is currently being sent.
  bool get isSendingMessage => _isSendingMessage;
  /// An error message string if an error has occurred, otherwise null.
  String? get error => _error;
  /// The image file selected by the user for preview before sending.
  File? get imagePreview => _imagePreview;
  /// The ID of the currently authenticated user.
  String get currentUserId => _authProvider.currentUserId ?? '';

  // --- Kernlogik: Streams abonnieren und Daten verarbeiten ---

  /// Subscribes to real-time updates for the current chat room's details.
  ///
  /// On receiving new details, it updates [_roomDetails] and triggers message filtering.
  /// If it's the first time details are received, it also initiates message subscription.
  void _subscribeToRoomDetails() {
    _isLoading = true;
    notifyListeners();

    _roomDetailsSubscription?.cancel();
    _roomDetailsSubscription = _watchChatRoomUseCase(roomId: roomId).listen(
            (details) {
          _roomDetails = details;
          AppLogger.debug("Room details updated. ClearedAt: ${_roomDetails?.clearedAt[currentUserId]}");

          // Wenn Nachrichten bereits geladen sind, filtere sie neu.
          // Ansonsten warte, bis der Nachrichten-Stream Daten liefert.
          if (_messagesSubscription != null) {
            _filterAndNotifyMessages();
          } else {
            // Starte den Nachrichten-Stream, wenn wir zum ersten Mal Raumdetails haben.
            _subscribeToMessages();
          }
        },
        onError: (e, s) {
          AppLogger.error("Error watching room details", e, s);
          _isLoading = false;
          _error = "Could not load chat details.";
          notifyListeners();
        }
    );
  }

  /// Subscribes to the stream of messages for the current chat room.
  ///
  /// Stores all incoming messages in [_allMessages] and then calls
  /// [_filterAndNotifyMessages] to update the UI.
  void _subscribeToMessages() {
    _messagesSubscription?.cancel();
    _messagesSubscription = _getMessagesStreamUseCase(roomId: roomId).listen(
            (loadedMessages) {
          _allMessages = loadedMessages; // Speichere die ungefilterte Liste
          AppLogger.debug("Received ${_allMessages.length} total messages from stream.");
          _filterAndNotifyMessages();
        },
        onError: (e, s) {
          AppLogger.error("Error in messages stream", e, s);
          _isLoading = false;
          _error = "Could not load messages.";
          notifyListeners();
        }
    );
  }

  /// Filters the [_allMessages] list based on the current user's `clearedAt` timestamp
  /// from [_roomDetails] and updates [_visibleMessages].
  ///
  /// Notifies listeners and then marks the now visible messages as read.
  void _filterAndNotifyMessages() {
    final clearedAtTimestamp = _roomDetails?.clearedAt[currentUserId];

    if (clearedAtTimestamp != null) {
      // Filtere alle Nachrichten, die vor dem "cleared_at"-Zeitstempel liegen.
      _visibleMessages = _allMessages.where((msg) {
        // Wenn die Nachricht kein createdAt hat, zeige sie sicherheitshalber an.
        return msg.createdAt?.isAfter(clearedAtTimestamp) ?? true;
      }).toList();
    } else {
      // Wenn kein Zeitstempel gesetzt ist, zeige alle Nachrichten.
      _visibleMessages = List.from(_allMessages);
    }

    if (_isLoading) _isLoading = false;
    _error = null;

    AppLogger.debug("Filtering complete. Visible messages: ${_visibleMessages.length}");
    notifyListeners();

    // Markiere die jetzt sichtbaren Nachrichten als gelesen.
    _markReceivedMessagesAsRead(_visibleMessages);
  }

  /// Marks unread messages received from the chat partner as read.
  ///
  /// Only processes messages that are from the [chatPartner] and do not have a `readAt` timestamp.
  /// Sets [_isMarkingAsRead] to true during the operation to prevent concurrent calls.
  void _markReceivedMessagesAsRead(List<MessageEntity> receivedMessages) {
    if (_isMarkingAsRead || currentUserId.isEmpty) return;

    final messagesToMark = receivedMessages
        .where((msg) => msg.fromId == chatPartner.id && msg.readAt == null)
        .toList();

    if (messagesToMark.isEmpty) return;

    _isMarkingAsRead = true;
    Future.wait(messagesToMark.map((message) =>
        _markMessageAsReadUseCase(
          contextId: roomId,
          messageId: message.id,
          isGroupMessage: false,
          readerUserId: currentUserId,
        )
    )).whenComplete(() => _isMarkingAsRead = false);
  }

  // --- Aktions-Methoden für die UI ---

  /// Hides the current chat room for the current user.
  ///
  /// This typically means the chat will no longer appear in the user's chat list,
  /// but the messages are not deleted.
  Future<void> hideChat() async {
    if (currentUserId.isEmpty) return;
    AppLogger.info("Hiding chat room $roomId for user $currentUserId");
    try {
      await _hideChatUseCase(roomId: roomId, userId: currentUserId);
    } catch (e) {
      AppLogger.error("Failed to hide chat", e);
      _error = "Could not delete chat.";
      notifyListeners();
    }
  }

  /// Clears the chat history for the current user in this chat room.
  ///
  /// This sets a `clearedAt` timestamp for the user, causing messages sent
  /// before this time to be filtered out by [_filterAndNotifyMessages].
  Future<void> clearHistory() async {
    if (currentUserId.isEmpty) return;
    AppLogger.info("Clearing chat history for room $roomId");
    try {
      await _setChatClearedTimestampUseCase(roomId: roomId, userId: currentUserId);
      // Der reaktive Stream wird die UI automatisch aktualisieren.
    } catch (e) {
      AppLogger.error("Failed to clear chat history", e);
      _error = "Could not clear chat history.";
      notifyListeners();
    }
  }

  /// Sends a text message to the chat partner.
  ///
  /// Validates that the [text] is not empty and the [currentUserId] is available.
  /// Sets [_isSendingMessage] to true during the operation.
  /// On success, the message is sent via [_sendMessageUseCase].
  /// On failure, an error message is set.
  Future<void> sendTextMessage(String text) async {
    // Grundlegende Validierung
    if (text.trim().isEmpty || currentUserId.isEmpty) {
      return;
    }

    _isSendingMessage = true;
    _error = null; // Sendefehler sind separat von Ladefehlern
    notifyListeners();

    // Erstelle die Message-Entity
    final message = MessageEntity(
      id: '', // Wird im Repository/DataSource generiert
      fromId: currentUserId,
      toId: chatPartner.id, // Wichtig für 1-zu-1-Chats
      msg: text.trim(),
      type: MessageType.text,
      createdAt: DateTime.now(), // Client-Zeit, wird in DS ggf. durch Server-Zeit ersetzt
    );

    try {
      // Rufe den UseCase auf.
      // Dieser ruft intern die sendMessage-Methode auf, die wiederum den Chat "unhidet".
      await _sendMessageUseCase(
        message: message,
        contextId: roomId,
        isGroupMessage: false,
      );
      AppLogger.info("IndividualChatProvider: Text message sent to ${chatPartner.name}");
    } catch (e, stackTrace) {
      AppLogger.error("IndividualChatProvider: Error sending text message", e, stackTrace);
      _error = "Nachricht konnte nicht gesendet werden.";
    } finally {
      // Setze den Ladezustand zurück, egal was passiert.
      _isSendingMessage = false;
      notifyListeners();
    }
  }

  /// Sets an image file for preview in the UI before sending.
  ///
  /// Updates [_imagePreview] and notifies listeners.
  void setImageForPreview(File? imageFile) {
    _imagePreview = imageFile;
    notifyListeners();
  }

  /// Uploads the selected image and sends it as an image message.
  ///
  /// Validates that an image is selected ([_imagePreview] is not null) and
  /// [currentUserId] is available.
  /// First, uploads the image using [_uploadChatImageUseCase].
  /// If successful, sends a message with the image URL via [_sendMessageUseCase].
  /// Clears the [_imagePreview] and sets [_isSendingMessage] during the operation.
  Future<void> sendSelectedImage() async {
    // Grundlegende Validierung
    if (_imagePreview == null || currentUserId.isEmpty) {
      return;
    }

    _isSendingMessage = true;
    _error = null;
    File imageToSend = _imagePreview!;
    // Entferne die Vorschau sofort, während gesendet wird.
    setImageForPreview(null);
    notifyListeners(); // UI sofort aktualisieren

    try {
      AppLogger.debug("IndividualChatProvider: Uploading image for chat with ${chatPartner.name}");
      // 1. Bild hochladen und URL erhalten
      final imageUrl = await _uploadChatImageUseCase(
        imageFile: imageToSend,
        contextId: roomId,
        uploaderUserId: currentUserId,
      );

      // 2. Wenn der Upload erfolgreich war, sende die Bild-Nachricht
      if (imageUrl != null) {
        final message = MessageEntity(
          id: '',
          fromId: currentUserId,
          toId: chatPartner.id,
          msg: imageUrl, // Die URL ist der Inhalt der Nachricht
          type: MessageType.image,
          createdAt: DateTime.now(),
        );

        await _sendMessageUseCase(
          message: message,
          contextId: roomId,
          isGroupMessage: false,
        );
        AppLogger.info("IndividualChatProvider: Image message sent to ${chatPartner.name}");
      } else {
        _error = "Image upload failed";
      }
    } catch (e, stackTrace) {
      AppLogger.error("IndividualChatProvider: Error sending image message", e, stackTrace);
      _error = "Image Message could not be sent.";
    } finally {
      _isSendingMessage = false;
      notifyListeners();
    }
  }

  // --- Dispose ---
  /// Cleans up resources when the provider is disposed.
  ///
  /// Cancels any active stream subscriptions.
  @override
  void dispose() {
    AppLogger.debug("IndividualChatProvider for roomId: $roomId disposing...");
    _roomDetailsSubscription?.cancel();
    _messagesSubscription?.cancel();
    super.dispose();
  }
}
