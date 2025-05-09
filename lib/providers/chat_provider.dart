import 'dart:convert';
import 'package:chat_app/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:chat_app/models/message_model.dart';
import 'package:chat_app/services/notification_service.dart';

class ChatProvider with ChangeNotifier {
  late WebSocketChannel _channel;
  List<Message> _allMessages = [];
  bool _isConnected = false;

  List<Message> get allMessages => _allMessages;
  bool get isConnected => _isConnected;

  void connect(String userId) async {
    _channel = WebSocketChannel.connect(Uri.parse('ws://10.0.2.2:3000'));

    // Register user
    _channel.sink.add(jsonEncode({'type': 'register', 'userId': userId}));

    _channel.stream.listen(
      (message) {
        final data = jsonDecode(message);

        if (data['type'] == 'message') {
          _handleIncomingMessage(data);
        } else if (data['type'] == 'status') {
          _updateMessageStatus(data);
        }
      },
      onError: (error) {
        print('WebSocket error: $error');
        _isConnected = false;
        notifyListeners();
      },
      onDone: () {
        print('WebSocket connection closed');
        _isConnected = false;
        notifyListeners();
      },
    );

    _isConnected = true;
    notifyListeners();
  }

  Future<void> loadMessagesFromDatabase() async {
    _allMessages = await DatabaseService.instance.getAllMessages();
    notifyListeners();
  }

  void _handleIncomingMessage(Map<String, dynamic> data) async {
    final message = Message(
      senderId: data['senderId'],
      content: data['content'],
      timestamp: data['timestamp'],
      status: data['status'],
      isRead: false,
    );

    _allMessages.add(message);
    await DatabaseService.instance.insertMessage(message);
    notifyListeners();

    // Show notification
    NotificationService.showNotification(
      title: 'New message from ${data['senderId']}',
      body: data['content'],
    );
  }

  void _updateMessageStatus(Map<String, dynamic> data) async {
    final index = _allMessages.indexWhere(
      (msg) => msg.messageId == data['messageId'],
    );

    if (index != -1) {
      _allMessages[index] = _allMessages[index].copyWith(
        status: data['status'],
      );
      await DatabaseService.instance.updateMessageStatus(
        data['messageId'],
        data['status'],
      );
      notifyListeners();
    }
  }

  Future<void> markMessagesAsRead(String senderId) async {
    for (var i = 0; i < _allMessages.length; i++) {
      if (_allMessages[i].senderId == senderId) {
        _allMessages[i] = _allMessages[i].copyWith(isRead: true);
      }
    }
    await DatabaseService.instance.markMessagesAsRead(senderId);
    notifyListeners();
  }

  List<Message> getMessagesForUser(String userId) {
    return _allMessages
        .where((msg) => msg.senderId == userId || msg.receiverId == userId)
        .toList();
  }

  Future<void> sendMessage({
    required String senderId,
    required String receiverId,
    required String content,
  }) async {
    final messageId = DateTime.now().millisecondsSinceEpoch;
    final message = Message(
      senderId: senderId,
      receiverId: receiverId,
      content: content,
      timestamp: DateTime.now().toIso8601String(),
      status: 'sending',
      isRead: true,
      messageId: messageId,
    );

    _allMessages.add(message);
    await DatabaseService.instance.insertMessage(message);
    notifyListeners();

    // Send to WebSocket
    _channel.sink.add(
      jsonEncode({
        'type': 'message',
        'senderId': senderId,
        'receiverId': receiverId,
        'content': content,
        'messageId': messageId,
      }),
    );
  }

  void disconnect() {
    _channel.sink.close();
    _isConnected = false;
    notifyListeners();
  }
}

extension MessageCopyWith on Message {
  Message copyWith({
    String? senderId,
    String? receiverId,
    String? content,
    String? timestamp,
    String? status,
    bool? isRead,
    int? messageId,
  }) {
    return Message(
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      isRead: isRead ?? this.isRead,
      messageId: messageId ?? this.messageId,
    );
  }
}
