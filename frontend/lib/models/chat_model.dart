class ChatMessageModel {
  final int id;
  final int sender;
  final String content;
  final bool isRead;
  final String createdAt;

  ChatMessageModel({
    required this.id,
    required this.sender,
    required this.content,
    required this.isRead,
    required this.createdAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'],
      sender: json['sender'],
      content: json['message'] ?? '',
      isRead: json['is_read'] ?? false,
      createdAt: json['created_at'],
    );
  }
}
