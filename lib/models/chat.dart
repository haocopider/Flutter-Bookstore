class ChatMessage {
  final int id;
  final int conversationId;
  final int senderId;
  final String content;
  final String messageType;
  final DateTime createdAt;
  final bool isAdmin;

  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.messageType,
    required this.createdAt,
    required this.isAdmin,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json, int currentUserId) {
    return ChatMessage(
      id: json['id'] ?? 0,
      conversationId: json['conversationId'] ?? 0,
      senderId: json['senderId'] ?? 0,
      content: json['content'] ?? '',
      messageType: json['messageType'] ?? 'Text',
      createdAt: DateTime.parse(json['createdAt']).toLocal(),
      isAdmin: json['isAdmin'],
    );
  }
}