import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chat_app/providers/chat_provider.dart';
import 'package:chat_app/widgets/message_bubble.dart';

class ChatScreen extends StatelessWidget {
  final String friendId;
  final String friendName;
  final String userId;

  const ChatScreen({
    super.key,
    required this.friendId,
    required this.friendName,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final messages = chatProvider.getMessagesForUser(friendId);
    final TextEditingController messageController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text(friendName),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[messages.length - 1 - index];
                return MessageBubble(
                  message: message,
                  isMe: message.senderId == userId,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    if (messageController.text.isNotEmpty) {
                      chatProvider.sendMessage(
                        senderId: userId,
                        receiverId: friendId,
                        content: messageController.text,
                      );
                      messageController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}