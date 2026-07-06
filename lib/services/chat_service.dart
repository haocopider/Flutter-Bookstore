import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signalr_netcore/signalr_client.dart';
import '../models/chat.dart';
import 'api_service.dart';
import 'di_service.dart';

class ChatService {
  final ApiService _apiService = getIt<ApiService>();
  final String _endpoint = "chat";

  HubConnection? _hubConnection;

  // Khai báo các callback để UI lắng nghe sự kiện
  Function(ChatMessage)? onMessageReceived;
  Function(HubConnectionState)? onConnectionStateChanged;

  // 1. Lấy hoặc tạo phòng chat
  Future<int?> getOrCreateConversation() async {
    final response = await _apiService.getOneAsync<Map<String, dynamic>>(
      endpoint: "$_endpoint/my-conversation",
      fromJson: (json) => json,
    );

    if (response != null && response.containsKey('id')) {
      return response['id'] as int;
    }
    return null;
  }

  // 2. Lấy lịch sử tin nhắn
  Future<List<ChatMessage>> getChatHistory(int conversationId, int currentUserId) async {
    final history = await _apiService.getListAsync<ChatMessage>(
      endpoint: "$_endpoint/$conversationId/messages",
      fromJson: (json) => ChatMessage.fromJson(json, currentUserId),
    );

    return history ?? [];
  }

  // 3. Khởi tạo và quản lý kết nối SignalR
  Future<void> initSignalR(int conversationId, int currentUserId) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token') ?? "";

    // Sử dụng chung baseUrl từ ApiService để tránh hardcode IP nhiều nơi
    final serverUrl = _apiService.baseUrl;

    _hubConnection = HubConnectionBuilder()
        .withUrl("$serverUrl/chathub",
        options: HttpConnectionOptions(
          accessTokenFactory: () async => token,
        ))
        .withAutomaticReconnect()
        .build();

    // Lắng nghe tin nhắn từ Server
    _hubConnection!.on("ReceiveMessage", (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        var payload = arguments[0];
        String jsonStr = jsonEncode(payload);
        Map<String, dynamic> msgMap = jsonDecode(jsonStr);

        ChatMessage newMsg = ChatMessage.fromJson(msgMap, currentUserId);

        // Báo cho UI biết có tin nhắn mới
        if (onMessageReceived != null) {
          onMessageReceived!(newMsg);
        }
      }
    });

    // Bắt các sự kiện thay đổi trạng thái kết nối
    _hubConnection!.onclose(({error}) {
      if (onConnectionStateChanged != null) {
        onConnectionStateChanged!(HubConnectionState.Disconnected);
      }
    });

    _hubConnection!.onreconnected(({connectionId}) {
      if (onConnectionStateChanged != null) {
        onConnectionStateChanged!(HubConnectionState.Connected);
      }
    });

    try {
      await _hubConnection!.start();

      if (onConnectionStateChanged != null && _hubConnection!.state != null) {
        onConnectionStateChanged!(_hubConnection!.state!);
      }

      // Tham gia phòng chat nếu kết nối thành công
      if (_hubConnection!.state == HubConnectionState.Connected && conversationId > 0) {
        await _hubConnection!.invoke("JoinConversation", args: [conversationId]);
      }
    } catch (e) {
      print("🚨 Lỗi khởi tạo SignalR: $e");
    }
  }

  // 4. Gửi tin nhắn
  Future<void> sendMessage(int conversationId, String text) async {
    if (_hubConnection?.state == HubConnectionState.Connected) {
      await _hubConnection!.invoke("SendMessage", args: [conversationId, text, "Text"]);
    }
  }

  // 5. Rời phòng và đóng kết nối
  Future<void> disconnect(int conversationId) async {
    if (_hubConnection?.state == HubConnectionState.Connected && conversationId > 0) {
      await _hubConnection!.invoke("LeaveConversation", args: [conversationId]);
    }
    await _hubConnection?.stop();
    _hubConnection = null;
  }

  bool get isConnected => _hubConnection?.state == HubConnectionState.Connected;
}