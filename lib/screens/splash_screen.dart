import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quicksplit/providers/group_provider.dart';
import 'package:quicksplit/screens/mode_selector_screen.dart';
import 'package:quicksplit/utils/app_styles.dart';
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
              PageRouteBuilder(
                pageBuilder:
                    (context, animation, secondaryAnimation) =>
                        const OnboardingScreen(),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  final curved = CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOut,
                  );
                  return FadeTransition(
                    opacity: curved,
                    child: ScaleTransition(scale: curved, child: child),
                  );
                },
                transitionDuration: const Duration(milliseconds: 600),
              ),
            );
          } else {
            if (groupProvider.groups.isEmpty) {
              Navigator.of(context).pushReplacement(
                PageRouteBuilder(
                  pageBuilder:
                      (context, animation, secondaryAnimation) =>
                          const ModeSelectorScreen(),
                  transitionsBuilder: (
                    context,
                    animation,
                    secondaryAnimation,
                    child,
                  ) {
                    final curved = CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeInOut,
                    );
                    return FadeTransition(
                      opacity: curved,
                      child: ScaleTransition(scale: curved, child: child),
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 600),
                ),
              );
            } else {
              Navigator.of(context).pushReplacement(
                PageRouteBuilder(
                  pageBuilder:
                      (context, animation, secondaryAnimation) =>
                          const GroupListScreen(),
                  transitionsBuilder: (
                    context,
                    animation,
                    secondaryAnimation,
                    child,
                  ) {
                    final curved = CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeInOut,
                    );
                    return FadeTransition(
                      opacity: curved,
                      child: ScaleTransition(scale: curved, child: child),
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 600),
                ),
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
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4CAF90), Color(0xFF98FF98)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Center(
            child: AnimatedBuilder(
              animation: _opacityAnimation,
              builder:
                  (context, child) =>
                      Opacity(opacity: _opacityAnimation.value, child: child),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.group, size: 100, color: Colors.white),
                  SizedBox(height: 20),
                  Text(
                    'QuickSplit',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
