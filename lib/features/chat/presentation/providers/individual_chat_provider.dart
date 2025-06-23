import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';

// Entities
import '../../domain/entities/message_entity.dart';
import '../../domain/entities/chat_room_entity.dart'; // Wichtig für die Raumdetails
import '../../domain/entities/chat_user_entity.dart';

// UseCases
import '../../domain/usecases/get_messages_stream_usecase.dart';
import '../../domain/usecases/send_message_usecase.dart';
import '../../domain/usecases/mark_message_as_read_usecase.dart';
import '../../domain/usecases/upload_chat_image_usecase.dart';
// --- NEUE USECASES ---
import '../../domain/usecases/watch_chat_room_by_id_usecase.dart';
import '../../domain/usecases/hide_chat_usecase.dart';
import '../../domain/usecases/set_chat_cleared_timestamp_usecase.dart';

// Auth Provider
import '../../../auth/presentation/providers/auth_provider.dart';

// Core
import '../../../../core/utils/app_logger.dart';

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
  final String roomId;
  final ChatUserEntity chatPartner;

  ChatRoomEntity? _roomDetails;
  List<MessageEntity> _allMessages = []; // Speichert ALLE Nachrichten vom Stream
  List<MessageEntity> _visibleMessages = []; // Speichert die GEFILTERTEN Nachrichten für die UI

  bool _isLoading = true;
  bool _isSendingMessage = false;
  String? _error;
  File? _imagePreview;
  bool _isMarkingAsRead = false;

  // --- Stream Subscriptions ---
  StreamSubscription<ChatRoomEntity?>? _roomDetailsSubscription;
  StreamSubscription<List<MessageEntity>>? _messagesSubscription;

  // --- Konstruktor ---
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
  List<MessageEntity> get messages => _visibleMessages; // UI zeigt nur sichtbare Nachrichten
  bool get isLoading => _isLoading;
  bool get isSendingMessage => _isSendingMessage;
  String? get error => _error;
  File? get imagePreview => _imagePreview;
  String get currentUserId => _authProvider.currentUserId ?? '';

  // --- Kernlogik: Streams abonnieren und Daten verarbeiten ---

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

  /// Zentrale Methode, um Nachrichten zu filtern und die UI zu benachrichtigen.
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


  // --- Alte "als gelesen markieren"-Logik (unverändert) ---
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
      type: 'text',
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

  /// Setzt ein Bild für die Vorschau in der UI.
  void setImageForPreview(File? imageFile) {
    _imagePreview = imageFile;
    notifyListeners();
  }

  /// Lädt das ausgewählte Bild hoch und sendet es als Bildnachricht.
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
          type: 'image',
          createdAt: DateTime.now(),
        );

        await _sendMessageUseCase(
          message: message,
          contextId: roomId,
          isGroupMessage: false,
        );
        AppLogger.info("IndividualChatProvider: Image message sent to ${chatPartner.name}");
      } else {
        _error = "Bild-Upload fehlgeschlagen.";
      }
    } catch (e, stackTrace) {
      AppLogger.error("IndividualChatProvider: Error sending image message", e, stackTrace);
      _error = "Bildnachricht konnte nicht gesendet werden.";
    } finally {
      _isSendingMessage = false;
      notifyListeners();
    }
  }

  // --- Dispose ---
  @override
  void dispose() {
    AppLogger.debug("IndividualChatProvider for roomId: $roomId disposing...");
    _roomDetailsSubscription?.cancel();
    _messagesSubscription?.cancel();
    super.dispose();
  }
}