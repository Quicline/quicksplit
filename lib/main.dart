import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'providers/group_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'utils/app_styles.dart';

void main() {
  runApp(const QuickSplitApp());
}

class QuickSplitApp extends StatelessWidget {
  const QuickSplitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GroupProvider(),
      child: MaterialApp(
        title: 'QuickSplit – Smart Bill Sharing',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF3EB489), // Mint Green
            surface: Color(0xFFFFFFFF), // White
            onPrimary: Colors.white,
            onSurface: Color(0xFF2C2C2C),
          ),
          scaffoldBackgroundColor: const Color(0xFFFFFFFF),
          textTheme: const TextTheme(
            bodyMedium: AppTextStyles.body,
            titleMedium: AppTextStyles.heading,
          ),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF30A57D), // Darker Mint
            surface: Color(0xFF121212),
            onPrimary: Colors.white,
            onSurface: Color(0xFFE0E0E0),
          ),
          scaffoldBackgroundColor: const Color(0xFF121212),
          textTheme: const TextTheme(
            bodyMedium: AppTextStyles.body,
            titleMedium: AppTextStyles.heading,
          ),
          useMaterial3: true,
        ),
        themeMode: ThemeMode.system,
        home: const SplashScreen(), // Start at Splash!
      ),
    );
  }
}
