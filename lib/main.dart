import 'package:chat_app/services/fcm_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chat_app/providers/chat_provider.dart';
import 'package:chat_app/screens/friends_list_screen.dart';
import 'package:chat_app/services/notification_service.dart';
// First, make sure you have the firebase_messaging package imported
import 'package:firebase_messaging/firebase_messaging.dart';
// You might also need this for initializing Firebase
import 'package:firebase_core/firebase_core.dart';

// This function will handle the logic for getting the token
Future<String?> getFCMToken() async {
  // Ensure Firebase is initialized (this is usually done once, e.g., in your main function)
  // If you haven't initialized Firebase yet, you need to do it first:
  // WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();

  // Get an instance of FirebaseMessaging
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // --- Important for iOS and newer Android ---
  // Request notification permissions. This is crucial for receiving notifications.
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  print('User granted permission: ${settings.authorizationStatus}');

  // Now, get the FCM device token
  // This token is unique to the device and your app instance
  String? token = await messaging.getToken();

  // Print the token to the console so you can copy it for testing
  if (token != null) {
    print('FCM Device Token: $token');
  } else {
    print('Could not get FCM device token.');
  }

  // You would typically send this token to your backend server
  // so you can send targeted messages later.
  // For testing, you can just copy the output from the console.
  // sendTokenToServer(token); // Example function call

  return token;
}

// Example of how you might call this function (e.g., in a StatefulWidget's initState)
/*
@override
void initState() {
  super.initState();
  getFCMToken().then((token) {
    if (token != null) {
      // Do something with the token, e.g., display it or save it
      print('Successfully retrieved token in initState: $token');
    }
  });
}
*/

// Make sure your main function initializes Firebase if you haven't already:
/*
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}
*/

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notificationsF
  await NotificationService.initialize();
  // await getFCMToken();
    await FCMService.initialize();
  runApp(
    ChangeNotifierProvider(
      create: (context) => ChatProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Chat',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const FriendsListScreen(),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';
// import 'package:provider/provider.dart';
// import 'dart:convert';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// // Initialize notifications
// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // Initialize notifications
//   const AndroidInitializationSettings initializationSettingsAndroid =
//       AndroidInitializationSettings('@mipmap/ic_launcher');
//   const InitializationSettings initializationSettings = InitializationSettings(
//     android: initializationSettingsAndroid,
//   );
//   await flutterLocalNotificationsPlugin.initialize(initializationSettings);

//   runApp(
//     ChangeNotifierProvider(
//       create: (context) => ChatProvider(),
//       child: const MyApp(),
//     ),
//   );
// }

// class ChatProvider with ChangeNotifier {
//   late WebSocketChannel _channel;
//   final List<Map<String, dynamic>> _allMessages = [];
//   bool _isConnected = false;

//   List<Map<String, dynamic>> get allMessages => _allMessages;
//   bool get isConnected => _isConnected;

//   void connect(String userId) {
//     _channel = WebSocketChannel.connect(Uri.parse('ws://10.0.2.2:3000'));

//     // Register user
//     _channel.sink.add(jsonEncode({'type': 'register', 'userId': userId}));

//     _channel.stream.listen(
//       (message) {
//         final data = jsonDecode(message);

//         if (data['type'] == 'message') {
//           _handleIncomingMessage(data);
//         } else if (data['type'] == 'status') {
//           _updateMessageStatus(data);
//         }
//       },
//       onError: (error) {
//         print('WebSocket error: $error');
//         _isConnected = false;
//         notifyListeners();
//       },
//       onDone: () {
//         print('WebSocket connection closed');
//         _isConnected = false;
//         notifyListeners();
//       },
//     );

//     _isConnected = true;
//     notifyListeners();
//   }

//   void _handleIncomingMessage(Map<String, dynamic> data) {
//     final message = {
//       'senderId': data['senderId'],
//       'content': data['content'],
//       'timestamp': data['timestamp'],
//       'status': data['status'],
//       'isRead': false, // Mark as unread initially
//     };

//     _allMessages.add(message);
//     notifyListeners();
//     print('_showNotification');
//     // Show notification if app is in background
//     _showNotification(
//       title: 'New message from ${data['senderId']}',
//       body: data['content'],
//     );
//   }

//   void _updateMessageStatus(Map<String, dynamic> data) {
//     // Find the message and update its status
//     for (var i = 0; i < _allMessages.length; i++) {
//       if (_allMessages[i]['messageId'] == data['messageId']) {
//         _allMessages[i]['status'] = data['status'];
//         notifyListeners();
//         break;
//       }
//     }
//   }

//   Future<void> _showNotification({
//     required String title,
//     required String body,
//   }) async {
//     const AndroidNotificationDetails androidPlatformChannelSpecifics =
//         AndroidNotificationDetails(
//           'your_channel_id',
//           'your_channel_name',
//           importance: Importance.max,
//           priority: Priority.high,
//           showWhen: false,
//         );
//     print('Future<void> _showNotification');
//     const NotificationDetails platformChannelSpecifics = NotificationDetails(
//       android: androidPlatformChannelSpecifics,
//     );
//     await flutterLocalNotificationsPlugin.show(
//       0,
//       title,
//       body,
//       platformChannelSpecifics,
//     );
//   }

//   void markMessagesAsRead(String senderId) {
//     for (var i = 0; i < _allMessages.length; i++) {
//       if (_allMessages[i]['senderId'] == senderId) {
//         _allMessages[i]['isRead'] = true;
//       }
//     }
//     notifyListeners();
//   }

//   List<Map<String, dynamic>> getMessagesForUser(String userId) {
//     return _allMessages
//         .where(
//           (msg) => msg['senderId'] == userId || msg['receiverId'] == userId,
//         )
//         .toList();
//   }

//   void sendMessage({
//     required String senderId,
//     required String receiverId,
//     required String content,
//   }) {
//     final messageId = DateTime.now().millisecondsSinceEpoch;
//     final message = {
//       'type': 'message',
//       'senderId': senderId,
//       'receiverId': receiverId,
//       'content': content,
//       'messageId': messageId,
//     };

//     // Add to local messages immediately with 'sending' status
//     _allMessages.add({
//       'senderId': senderId,
//       'receiverId': receiverId,
//       'content': content,
//       'timestamp': DateTime.now().toIso8601String(),
//       'status': 'sending',
//       'messageId': messageId,
//       'isRead': true,
//     });
//     notifyListeners();

//     // Send to WebSocket
//     _channel.sink.add(jsonEncode(message));
//   }

//   void disconnect() {
//     _channel.sink.close();
//     _isConnected = false;
//     notifyListeners();
//   }
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Simple Chat',
//       theme: ThemeData(primarySwatch: Colors.blue),
//       home: const FriendsListScreen(),
//     );
//   }
// }

// class FriendsListScreen extends StatefulWidget {
//   const FriendsListScreen({super.key});

//   @override
//   State<FriendsListScreen> createState() => _FriendsListScreenState();
// }

// class _FriendsListScreenState extends State<FriendsListScreen> {
//   final String userId = 'surya'; // Current user ID

//   @override
//   void initState() {
//     super.initState();
//     // Connect to WebSocket when app starts
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Provider.of<ChatProvider>(context, listen: false).connect(userId);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final chatProvider = Provider.of<ChatProvider>(context);
//     final unreadCounts = _calculateUnreadCounts(chatProvider.allMessages);

//     // Sample friends list
//     final friends = [
//       {'id': 'friend1', 'name': 'Alice'},
//       {'id': 'friend2', 'name': 'Bob'},
//       {'id': 'friend3', 'name': 'Charlie'},
//     ];

//     return Scaffold(
//       appBar: AppBar(title: const Text('My Friends')),
//       body: ListView.builder(
//         itemCount: friends.length,
//         itemBuilder: (context, index) {
//           final friend = friends[index];
//           final unread = unreadCounts[friend['id']] ?? 0;

//           return ListTile(
//             title: Text(friend['name']!),
//             trailing:
//                 unread > 0
//                     ? CircleAvatar(
//                       radius: 12,
//                       backgroundColor: Colors.red,
//                       child: Text(
//                         unread.toString(),
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 12,
//                         ),
//                       ),
//                     )
//                     : null,
//             onTap: () {
//               // Mark messages as read when opening chat
//               chatProvider.markMessagesAsRead(friend['id']!);
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder:
//                       (context) => ChatScreen(
//                         friendId: friend['id']!,
//                         friendName: friend['name']!,
//                         userId: userId,
//                       ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }

//   Map<String, int> _calculateUnreadCounts(List<Map<String, dynamic>> messages) {
//     final counts = <String, int>{};
//     for (final msg in messages) {
//       if (msg['senderId'] != userId && !msg['isRead']) {
//         counts[msg['senderId']] = (counts[msg['senderId']] ?? 0) + 1;
//       }
//     }
//     return counts;
//   }
// }

// class ChatScreen extends StatelessWidget {
//   final String friendId;
//   final String friendName;
//   final String userId;

//   const ChatScreen({
//     super.key,
//     required this.friendId,
//     required this.friendName,
//     required this.userId,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final chatProvider = Provider.of<ChatProvider>(context);
//     final messages = chatProvider.getMessagesForUser(friendId);
//     final TextEditingController messageController = TextEditingController();

//     return Scaffold(
//       appBar: AppBar(title: Text(friendName)),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               reverse: true,
//               itemCount: messages.length,
//               itemBuilder: (context, index) {
//                 final message = messages[messages.length - 1 - index];
//                 final isMe = message['senderId'] == userId;

//                 return Align(
//                   alignment:
//                       isMe ? Alignment.centerRight : Alignment.centerLeft,
//                   child: Container(
//                     margin: const EdgeInsets.symmetric(
//                       vertical: 4,
//                       horizontal: 8,
//                     ),
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: isMe ? Colors.blue : Colors.grey,
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           message['content'],
//                           style: TextStyle(
//                             color: isMe ? Colors.white : Colors.black,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           message['status'],
//                           style: TextStyle(
//                             color: isMe ? Colors.white70 : Colors.black54,
//                             fontSize: 10,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: messageController,
//                     decoration: const InputDecoration(
//                       hintText: 'Type a message...',
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.send),
//                   onPressed: () {
//                     if (messageController.text.isNotEmpty) {
//                       chatProvider.sendMessage(
//                         senderId: userId,
//                         receiverId: friendId,
//                         content: messageController.text,
//                       );
//                       messageController.clear();
//                     }
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
