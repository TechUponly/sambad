import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_protector/screen_protector.dart';
import 'services/chat_service.dart';
import 'profile_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Best-effort protection against screenshots and background snapshots
  // on Android and iOS. This does not prevent someone from taking a
  // photo of the screen with another device, but it blocks OS-level
  // screenshots and app-switcher previews.
  try {
    await ScreenProtector.preventScreenshotOn();
    await ScreenProtector.protectDataLeakageOn();
  } catch (_) {
    // If protection cannot be enabled (e.g., unsupported platform),
    // continue without failing the app.
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) {
        final svc = ChatService();
        svc.init();
        return svc;
      },
      child: const LifecycleWatcher(child: MyApp()),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Private',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF00FFC2), // Neon mint accent
          brightness: Brightness.dark,
          primary: Color(0xFF00FFC2), // Neon mint
          secondary: Color(0xFF7C3AED), // Vibrant purple
          background: Colors.black,
          surface: Color(0xFF18181B), // Deep dark
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Color(0xFF00FFC2),
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 1.2,
          ),
          iconTheme: IconThemeData(color: Color(0xFF7C3AED)),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(
            color: Colors.white,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w500,
            fontSize: 18,
          ),
          bodyMedium: TextStyle(
            color: Color(0xFFB3B3B3),
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w400,
            fontSize: 16,
          ),
          titleLarge: TextStyle(
            color: Color(0xFF00FFC2),
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF18181B),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide(color: Color(0xFF00FFC2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide(color: Color(0xFF7C3AED), width: 2),
          ),
          labelStyle: TextStyle(color: Color(0xFF00FFC2)),
        ),
        buttonTheme: const ButtonThemeData(
          buttonColor: Color(0xFF00FFC2),
          shape: StadiumBorder(),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF7C3AED),
          foregroundColor: Colors.black,
        ),
      ),
      home: const LoginPage(),
    );
  }
}

class LifecycleWatcher extends StatefulWidget {
  final Widget child;
  const LifecycleWatcher({required this.child, super.key});

  @override
  State<LifecycleWatcher> createState() => _LifecycleWatcherState();
}

class _LifecycleWatcherState extends State<LifecycleWatcher> with WidgetsBindingObserver {
  ChatService? _svc;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // service will be available after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _svc = context.read<ChatService>();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    _svc?.handleAppLifecycle(state);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
