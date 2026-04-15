import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kReleaseMode;
import 'package:provider/provider.dart';
import 'package:screen_protector/screen_protector.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
// ...existing code...
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'services/chat_service.dart';
import 'services/theme_provider.dart';
import 'screens/login_screen.dart';
import 'home_page.dart';
import 'theme/app_colors.dart';

// Global navigator key for showing snackbars from FCM handler
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    if (!kIsWeb) {
      await FirebaseAuth.instance.setSettings(appVerificationDisabledForTesting: true);
    }
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

  // Dedup set to prevent duplicate notifications
  final Set<String> shownNotificationIds = {};

  // Handle foreground messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    debugPrint('FCM foreground message: ${message.notification?.title}');
    
    // Deduplicate by messageId
    final msgId = message.messageId ?? '${message.notification?.title}_${message.sentTime}';
    if (shownNotificationIds.contains(msgId)) {
      debugPrint('[FCM] Duplicate notification suppressed: $msgId');
      return;
    }
    shownNotificationIds.add(msgId);
    // Clean up old IDs after 60s to prevent memory leak
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

  // Screen protector only works on mobile
  // NOTE: protectDataLeakageOn() adds FLAG_SECURE which can block text input on emulators
  if (!kIsWeb && kReleaseMode) {
    try {
      await ScreenProtector.preventScreenshotOn();
      await ScreenProtector.protectDataLeakageOn();
    } catch (_) {}
  }
  
  final prefs = await SharedPreferences.getInstance();
  // Check BOTH prefs AND Firebase auth state for reliable login detection
  final hasPrefs = prefs.containsKey('firebase_token') && 
                   prefs.containsKey('current_user_phone');
  final firebaseUser = FirebaseAuth.instance.currentUser;
  final isLoggedIn = hasPrefs && firebaseUser != null;
  
  // If prefs say logged in but Firebase says no, clean up stale prefs
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
            // Re-connect WebSocket for returning users
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
      // ── Dark Theme ──
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
      // ── Light Theme ──
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
