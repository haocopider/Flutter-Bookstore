import 'package:bookstore/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:intl/intl.dart';

import '../models/chat.dart';
import '../services/chat_service.dart';
import '../services/di_service.dart'; // Nơi chứa getIt

class CustomerChatScreen extends StatefulWidget {
  const CustomerChatScreen({super.key});

  @override
  _CustomerChatScreenState createState() => _CustomerChatScreenState();
}

class _CustomerChatScreenState extends State<CustomerChatScreen> {
  final ChatService _chatService = getIt<ChatService>();
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final AuthController authController = Get.find<AuthController>();

  List<ChatMessage> _messages = [];
  int _conversationId = 0;
  bool _isConnected = false;
  bool _isLoading = true;


  @override
  void initState() {
    super.initState();
    _initChatData();
  }

  Future<void> _initChatData() async {
    try {
      int? _currentUserId = authController.currentUser?.id;
      // 1. Lấy hoặc tạo phòng chat
      int? convId = await _chatService.getOrCreateConversation();
      if (convId != null) {
        _conversationId = convId;

        // 2. Tải lịch sử tin nhắn cũ
        _messages = await _chatService.getChatHistory(_conversationId, _currentUserId!);
      }

      // 3. Đăng ký các hàm lắng nghe sự kiện từ ChatService
      _chatService.onMessageReceived = _handleIncomingMessage;

      _chatService.onConnectionStateChanged = (state) {
        setState(() {
          _isConnected = state == HubConnectionState.Connected;
        });
      };

      // 4. Khởi tạo SignalR real-time
      await _chatService.initSignalR(_conversationId, _currentUserId!);

      setState(() {
        _isLoading = false;
      });
      _scrollToBottom();

    } catch (e) {
      print("Lỗi tải giao diện chat: $e");
      setState(() => _isLoading = false);
    }
  }

  // Hàm xử lý khi có tin nhắn mới đẩy về từ Service
  void _handleIncomingMessage(ChatMessage newMsg) {
    if (newMsg.conversationId == _conversationId) {
      setState(() {
        _messages.add(newMsg);
      });
      _scrollToBottom();
    }
  }

  Future<void> _sendMessage() async {
    String text = _msgController.text.trim();
    if (text.isEmpty || !_chatService.isConnected) return;

    _msgController.clear();

    // Gọi lệnh gửi thông qua Service
    await _chatService.sendMessage(_conversationId, text);
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _chatService.disconnect(_conversationId);
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage('assets/images/logo.png'), // Logo shop
              radius: 18,
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("CSKH Bookstore", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text("Luôn trực tuyến", style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.white70)),
              ],
            )
          ],
        ),
        backgroundColor: Colors.blue[700],
        elevation: 1,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildMessageBubble(msg);
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: msg.isAdmin ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (msg.isAdmin) ...[
            const CircleAvatar(
              backgroundImage: AssetImage('assets/images/logo.png'),
              radius: 14,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: msg.isAdmin ? Colors.white : Colors.blue[700],
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(msg.isAdmin ? 4 : 16),
                  bottomRight: Radius.circular(msg.isAdmin ? 16 : 4),
                ),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))
                ],
              ),
              child: Column(
                crossAxisAlignment: msg.isAdmin ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    msg.content,
                    style: TextStyle(color: msg.isAdmin ? Colors.black87 : Colors.white, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('HH:mm').format(msg.createdAt),
                    style: TextStyle(color: msg.isAdmin ? Colors.black45 : Colors.white70, fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 4, offset: const Offset(0, -1))],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _msgController,
                enabled: _isConnected,
                decoration: InputDecoration(
                  hintText: _isConnected ? "Nhập tin nhắn..." : "Đang kết nối...",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: _isConnected ? Colors.blue[700] : Colors.grey,
              radius: 22,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 20),
                onPressed: _isConnected ? _sendMessage : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}