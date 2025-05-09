import 'package:chat_app/models/message_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chat_app/providers/chat_provider.dart';
import 'package:chat_app/screens/chat_screen.dart';

class FriendsListScreen extends StatefulWidget {
  const FriendsListScreen({super.key});

  @override
  State<FriendsListScreen> createState() => _FriendsListScreenState();
}

class _FriendsListScreenState extends State<FriendsListScreen> {
  final String userId = 'surya'; // Current user ID

  @override
  void initState() {
    super.initState();
    // Connect to WebSocket when app starts
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      await chatProvider.loadMessagesFromDatabase();
      chatProvider.connect(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final unreadCounts = _calculateUnreadCounts(chatProvider.allMessages);

    // Sample friends list
    final friends = [
      {'id': 'friend1', 'name': 'Alice'},
      {'id': 'friend2', 'name': 'Bob'},
      {'id': 'friend3', 'name': 'Charlie'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('My Friends')),
      body: ListView.builder(
        itemCount: friends.length,
        itemBuilder: (context, index) {
          final friend = friends[index];
          final unread = unreadCounts[friend['id']] ?? 0;

          return ListTile(
            title: Text(friend['name']!),
            trailing:
                unread > 0
                    ? CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.red,
                      child: Text(
                        unread.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    )
                    : null,
            onTap: () {
              // Mark messages as read when opening chat
              chatProvider.markMessagesAsRead(friend['id']!);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => ChatScreen(
                        friendId: friend['id']!,
                        friendName: friend['name']!,
                        userId: userId,
                      ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Map<String, int> _calculateUnreadCounts(List<Message> messages) {
    final counts = <String, int>{};
    for (final msg in messages) {
      if (msg.senderId != userId && !msg.isRead) {
        counts[msg.senderId] = (counts[msg.senderId] ?? 0) + 1;
      }
    }
    return counts;
  }
}
