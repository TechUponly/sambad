import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/login_screen.dart';
import 'services/graphql_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHiveForFlutter();
  runApp(GraphQLProvider(
    client: GraphQLService.initClient(),
    child: const SambadAdminApp(),
  ));
}


class SambadAdminApp extends StatefulWidget {
  const SambadAdminApp({super.key});

  @override
  State<SambadAdminApp> createState() => _SambadAdminAppState();
}

class _SambadAdminAppState extends State<SambadAdminApp> {
  @override
  Widget build(BuildContext context) {
    // Sky blue palette
    final skyBlue = const Color(0xFF4FC3F7); // Main sky blue
    final skyBlueDark = const Color(0xFF0288D1); // For sidebar, appbar
    final skyBlueLight = const Color(0xFFE1F5FE); // For backgrounds
    final accentBlue = const Color(0xFF039BE5); // For highlights
    final errorRed = const Color(0xFFFF5252);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sambad Admin',
      theme: ThemeData(
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: skyBlueDark,
          onPrimary: Colors.white,
          secondary: accentBlue,
          onSecondary: Colors.white,
          error: errorRed,
          onError: Colors.white,
          background: skyBlueLight,
          onBackground: Colors.black,
          surface: skyBlue,
          onSurface: Colors.black,
        ),
        scaffoldBackgroundColor: skyBlueLight,
        useMaterial3: true,
        textTheme: GoogleFonts.montserratTextTheme().copyWith(
          headlineMedium: GoogleFonts.montserrat(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: skyBlueDark,
            letterSpacing: 1.2,
          ),
          titleLarge: GoogleFonts.montserrat(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: skyBlueDark,
          ),
          titleMedium: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: accentBlue,
          ),
          bodyMedium: GoogleFonts.openSans(
            fontSize: 16,
            color: Colors.black87,
          ),
          bodySmall: GoogleFonts.openSans(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
        cardColor: skyBlue,
        drawerTheme: DrawerThemeData(
          backgroundColor: skyBlueDark,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: skyBlueDark,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const AdminLoginPage(),
    );
  }
}
