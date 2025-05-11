import 'package:chat_app/services/fcm_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chat_app/providers/chat_provider.dart';
import 'package:chat_app/screens/friends_list_screen.dart';
import 'package:chat_app/services/notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
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
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => ChatProvider())],
      child: MaterialApp(navigatorKey: navigatorKey, home: FriendsListScreen()),
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
