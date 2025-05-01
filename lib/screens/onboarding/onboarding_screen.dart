import 'package:flutter/material.dart';
import 'package:quicksplit/screens/group_list_screen.dart';
import 'onboarding_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> onboardingData = [
    {
      "title": "Bill Splitting Shouldn’t Be Stressful.",
      "description":
          "Stop fighting over who owes what. QuickSplit makes it easy.",
      "image": "assets/images/friends1.png",
    },
    {
      "title": "Split, Track, and Settle — In Seconds.",
      "description": "Fairness, speed, and simplicity — all in your pocket.",
      "image": "assets/images/friends2.png",
    },
    {
      "title": "Ready to Split Smarter?",
      "description": "Create your first group in under 10 seconds.",
      "image": "assets/images/friends3.png",
    },
  ];

  Future<void> _nextPage() async {
    if (_currentPage < onboardingData.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboardingComplete', true);

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const GroupListScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _controller,
        itemCount: onboardingData.length,
        onPageChanged: (index) => setState(() => _currentPage = index),
        itemBuilder: (context, index) {
          final item = onboardingData[index];
          return OnboardingPage(
            title: item['title']!,
            description: item['description']!,
            image: item['image']!,
            onNext: _nextPage,
          );
        },
      ),
    );
  }
}
