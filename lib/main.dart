import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'ui/screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF091220),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const CallBridgeApp());
}

class CallBridgeApp extends StatelessWidget {
  const CallBridgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CallBridge',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFBBF24), // Vibrant gold accent
          onPrimary: Colors.black,
          secondary: Color(0xFF10B981), // Emerald green
          onSecondary: Colors.white,
          surface: Color(0xFF0F172A),
          onSurface: Colors.white,
          error: Color(0xFFEF4444),
          onError: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFF091220),
        fontFamily: 'Roboto',
      ),
      home: const HomeScreen(),
    );
  }
}
