import 'package:flutter/material.dart';
import 'package:quicksplit/screens/group_list_screen.dart';
import 'package:quicksplit/screens/mode_selector_screen.dart';
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
        MaterialPageRoute(builder: (_) => const ModeSelectorScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          PageView.builder(
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
                onSkip: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('onboardingComplete', true);
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => const ModeSelectorScreen(),
                    ),
                  );
                },
                currentIndex: _currentPage,
                totalPages: onboardingData.length,
                titleColor: Theme.of(context).textTheme.headlineSmall?.color,
                descriptionColor: Theme.of(context).textTheme.bodyMedium?.color,
              );
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(onboardingData.length, (index) {
                  return GestureDetector(
                    onTap: () {
                      _controller.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Container(
                      width: 10,
                      height: 10,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            _currentPage == index
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
