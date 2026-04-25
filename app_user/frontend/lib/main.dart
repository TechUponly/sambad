import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kReleaseMode;
import 'package:provider/provider.dart';
import 'package:screen_protector/screen_protector.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'services/chat_service.dart';
import 'services/theme_provider.dart';
import 'screens/login_screen.dart';
import 'home_page.dart';
import 'theme/app_colors.dart';

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

  final Set<String> shownNotificationIds = {};

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    debugPrint('FCM foreground message: ${message.notification?.title}');
    final msgId = message.messageId ?? '${message.notification?.title}_${message.sentTime}';
    if (shownNotificationIds.contains(msgId)) {
      debugPrint('[FCM] Duplicate notification suppressed: $msgId');
      return;
    }
    shownNotificationIds.add(msgId);
    Future.delayed(const Duration(seconds: 60), () => shownNotificationIds.remove(msgId));
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

  if (!kIsWeb && kReleaseMode) {
    try {
      await ScreenProtector.preventScreenshotOn();
      await ScreenProtector.protectDataLeakageOn();
    } catch (_) {}
  }
  
  final prefs = await SharedPreferences.getInstance();
  final hasPrefs = prefs.containsKey('firebase_token') && 
                   prefs.containsKey('current_user_phone');
  final firebaseUser = FirebaseAuth.instance.currentUser;
  final isLoggedIn = hasPrefs && firebaseUser != null;
  
  if (hasPrefs && firebaseUser == null) {
    debugPrint('[Main] Stale session detected — clearing prefs');
    await prefs.clear();
  }
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) {
          final svc = ChatService();
          if (isLoggedIn) {
            svc.init();
            svc.loginUser(
              firebaseUser!.phoneNumber ?? prefs.getString('current_user_phone') ?? '',
              name: prefs.getString('current_user_name'),
            );
          }
          return svc;
        }),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: MyApp(isLoggedIn: isLoggedIn),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Private Samvad',
      themeMode: themeProvider.themeMode,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: AppColors.primaryBlue,
        scaffoldBackgroundColor: AppColors.bgDark,
        cardColor: AppColors.bgCard,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primaryBlue,
          secondary: AppColors.accentGreen,
          surface: AppColors.bgCard,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.bgCard,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: AppColors.primaryBlue,
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.bgCard,
          selectedItemColor: AppColors.primaryBlue,
          unselectedItemColor: Colors.white54,
        ),
      ),
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: AppColors.primaryBlue,
        scaffoldBackgroundColor: AppColors.bgLight,
        cardColor: AppColors.bgCardLight,
        colorScheme: ColorScheme.light(
          primary: AppColors.primaryBlue,
          secondary: AppColors.accentGreen,
          surface: AppColors.bgCardLight,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.bgCardLight,
          foregroundColor: AppColors.textDark,
          elevation: 0,
          iconTheme: IconThemeData(color: AppColors.textDark),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: AppColors.primaryBlue,
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.bgCardLight,
          selectedItemColor: AppColors.primaryBlue,
          unselectedItemColor: Colors.grey,
        ),
      ),
      home: isLoggedIn ? const HomePage() : const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
