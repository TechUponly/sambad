import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:screen_protector/screen_protector.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
// ...existing code...
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'services/chat_service.dart';
import 'screens/login_screen.dart';
import 'home_page.dart';
import 'theme/app_theme.dart';

// Global navigator key for showing snackbars from FCM handler
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }

  // Request notification permission
  if (!kIsWeb) {
    try {
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      debugPrint('FCM permission granted');
    } catch (e) {
      debugPrint('FCM permission error: $e');
    }
  }

  // Handle foreground messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    debugPrint('FCM foreground message: ${message.notification?.title}');
    final ctx = navigatorKey.currentContext;
    if (ctx != null && message.notification != null) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message.notification!.title ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
              if (message.notification!.body != null) Text(message.notification!.body!),
            ],
          ),
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  });

  // Disable App Check temporarily to prevent crashes
  // if (!kIsWeb) {
  //   try {
  //     await FirebaseAppCheck.instance.activate(
  //       androidProvider: AndroidProvider.debug,
  //     );
  //   } catch (e) {
  //     print('App Check activation failed: $e');
  //   }
  // }
  
  // Screen protector only works on mobile
  if (!kIsWeb) {
    try {
      await ScreenProtector.preventScreenshotOn();
      await ScreenProtector.protectDataLeakageOn();
    } catch (_) {}
  }
  
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.containsKey('firebase_token') && 
                     prefs.containsKey('current_user_phone');
  
  runApp(
    ChangeNotifierProvider(
      create: (_) {
        final svc = ChatService();
        svc.init(); // Async init — loads contacts, messages, keys in background
        return svc;
      },
      child: MyApp(isLoggedIn: isLoggedIn),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Private Sambad',
      theme: AppTheme.intuitiveTheme,
      home: isLoggedIn ? const HomePage() : const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
