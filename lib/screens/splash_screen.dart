import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quicksplit/providers/group_provider.dart';
import 'package:quicksplit/screens/mode_selector_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'onboarding/onboarding_screen.dart';
import 'group_list_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(_controller);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final groupProvider = Provider.of<GroupProvider>(context, listen: false);
      await groupProvider.loadGroups();

      final prefs = await SharedPreferences.getInstance();
      final onboardingComplete = prefs.getBool('onboardingComplete') ?? false;

      Future.delayed(const Duration(seconds: 1), () {
        _controller.forward().then((_) {
          if (!onboardingComplete) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const OnboardingScreen()),
            );
          } else {
            if (groupProvider.groups.isEmpty) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const ModeSelectorScreen()),
              );
            } else {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const GroupListScreen()),
              );
            }
          }
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedBuilder(
          animation: _opacityAnimation,
          builder:
              (context, child) =>
                  Opacity(opacity: _opacityAnimation.value, child: child),
          child: const Text(
            'QuickSplit',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
