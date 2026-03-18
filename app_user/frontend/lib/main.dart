import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:screen_protector/screen_protector.dart';
import 'package:firebase_core/firebase_core.dart';
// ...existing code...
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'services/chat_service.dart';
import 'screens/login_screen.dart';
import 'home_page.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('Firebase initialization error: $e');
  }

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
        svc.init();
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
      title: 'Private Sambad',
      theme: AppTheme.intuitiveTheme,
      home: isLoggedIn ? const HomePage() : const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
