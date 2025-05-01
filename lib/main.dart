import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'providers/group_provider.dart';
import 'package:provider/provider.dart';

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
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const SplashScreen(), // Start at Splash!
      ),
    );
  }
}
