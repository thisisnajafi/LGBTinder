import 'package:mockito/mockito.dart';
import 'package:lgbtinder/services/api_services/chat_api_service.dart';
import 'package:lgbtinder/models/api_models/chat_models.dart';

class MockChatApiService extends Mock implements ChatApiService {
  @override
  Future<MessageResponse> sendMessage(MessageRequest request) async {
    return super.noSuchMethod(
      Invocation.method(#sendMessage, [request]),
      returnValue: MessageResponse(
        success: true,
        message: 'Message sent successfully',
        data: MessageData(
          messageId: 1,
          senderId: request.senderId,
          receiverId: request.receiverId,
          message: request.message,
          messageType: request.messageType,
          sentAt: DateTime.now().toIso8601String(),
          isRead: false,
        ),
      ),
    );
  }

  @override
  Future<ChatHistoryResponse> getChatHistory(ChatHistoryRequest request) async {
    return super.noSuchMethod(
      Invocation.method(#getChatHistory, [request]),
      returnValue: ChatHistoryResponse(
        success: true,
        data: ChatHistoryResponseData(
          messages: [],
          pagination: PaginationData(
            currentPage: 1,
            totalPages: 1,
            totalItems: 0,
            itemsPerPage: 20,
          ),
        ),
      ),
    );
  }

  @override
  Future<void> markMessagesAsRead(MarkMessagesAsReadRequest request) async {
    return super.noSuchMethod(
      Invocation.method(#markMessagesAsRead, [request]),
      returnValue: null,
    );
  }

  @override
  Future<void> deleteMessage(DeleteMessageRequest request) async {
    return super.noSuchMethod(
      Invocation.method(#deleteMessage, [request]),
      returnValue: null,
    );
  }

  @override
  Future<MessageResponse> editMessage(EditMessageRequest request) async {
    return super.noSuchMethod(
      Invocation.method(#editMessage, [request]),
      returnValue: MessageResponse(
        success: true,
        message: 'Message edited successfully',
        data: MessageData(
          messageId: request.messageId,
          senderId: 1,
          receiverId: 2,
          message: request.newMessage,
          messageType: MessageType.text,
          sentAt: DateTime.now().toIso8601String(),
          isRead: false,
        ),
      ),
    );
  }
}
