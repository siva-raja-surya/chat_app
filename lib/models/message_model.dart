class Message {
  final String senderId;
  final String? receiverId;
  final String content;
  final String timestamp;
  final String status;
  final bool isRead;
  final int? messageId;

  Message({
    required this.senderId,
    this.receiverId,
    required this.content,
    required this.timestamp,
    required this.status,
    this.isRead = false,
    this.messageId,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      content: json['content'],
      timestamp: json['timestamp'],
      status: json['status'],
      isRead: json['isRead'] ?? false,
      messageId: json['messageId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'timestamp': timestamp,
      'status': status,
      'isRead': isRead,
      'messageId': messageId,
    };
  }
}