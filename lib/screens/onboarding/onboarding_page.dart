import 'package:flutter/material.dart';

class OnboardingPage extends StatefulWidget {
  final String title;
  final String description;
  final String image;
  final VoidCallback onNext;
  final VoidCallback? onSkip;
  final int currentIndex;
  final int totalPages;

  const OnboardingPage({
    super.key,
    required this.title,
    required this.description,
    required this.image,
    required this.onNext,
    this.onSkip,
    required this.currentIndex,
    required this.totalPages,
    Color? titleColor,
    Color? descriptionColor,
  });

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 10,
              right: 10,
              child: TextButton(
                onPressed: widget.onSkip ?? widget.onNext,
                child: Text(
                  "Skip",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        widget.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF4CAF90),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      color: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(
                          color: Color(0xFF4CAF90),
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 200,
                              child: Image.asset(
                                widget.image,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.error_outline,
                                    size: 100,
                                    color: Colors.red,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              widget.description,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 32),
                            ElevatedButton(
                              onPressed: widget.onNext,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4CAF90),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 40,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('Next'),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
