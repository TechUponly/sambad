import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_protector/screen_protector.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'services/chat_service.dart';
import 'screens/login_screen.dart';
import 'home_page.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  try {
    await ScreenProtector.preventScreenshotOn();
    await ScreenProtector.protectDataLeakageOn();
  } catch (_) {
    // Protection not available on this platform
  }
  
  // Check if user is already logged in
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
      title: 'Sambad',
      theme: AppTheme.intuitiveTheme,
      // WhatsApp-style: Skip login if already logged in
      home: isLoggedIn ? const HomePage() : const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
