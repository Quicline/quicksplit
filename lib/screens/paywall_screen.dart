import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../providers/group_provider.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({Key? key}) : super(key: key);

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  int _selectedIndex = 0; // 0: Weekly, 1: Yearly

  final List<String> _options = ['Weekly', 'Yearly'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Pricing details
    String priceText;
    if (_selectedIndex == 0) {
      priceText = "\$2.99/week - Cancel anytime";
    } else {
      priceText = "\$29.99/year - Save 40%";
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: theme.iconTheme,
        automaticallyImplyLeading: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Card container for toggle and pricing with shadow
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                shadowColor: theme.colorScheme.primary.withOpacity(0.4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 24.0,
                    horizontal: 16,
                  ),
                  child: Column(
                    children: [
                      // Segmented Toggle
                      ToggleButtons(
                        isSelected: [_selectedIndex == 0, _selectedIndex == 1],
                        onPressed: (int index) {
                          setState(() {
                            _selectedIndex = index;
                          });
                        },
                        borderRadius: BorderRadius.circular(12.0),
                        selectedColor: theme.colorScheme.onPrimary,
                        color: theme.textTheme.bodyLarge?.color,
                        fillColor: theme.colorScheme.primary,
                        borderWidth: 2,
                        borderColor: theme.colorScheme.primary.withOpacity(0.5),
                        selectedBorderColor: theme.colorScheme.primary,
                        constraints: const BoxConstraints(
                          minHeight: 44,
                          minWidth: 120,
                        ),
                        children: [
                          Text(
                            'Weekly',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Yearly',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Pricing details
                      Text(
                        priceText,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Includes free 3-day trial. Cancel anytime.",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(
                            0.7,
                          ),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // CTA Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final scaffold = ScaffoldMessenger.of(context);
                    scaffold.showSnackBar(
                      const SnackBar(content: Text('Subscribing...')),
                    );

                    await Future.delayed(
                      const Duration(seconds: 2),
                    ); // Simulate purchase delay

                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('isProUser', true);

                    await Provider.of<GroupProvider>(
                      context,
                      listen: false,
                    ).refreshProStatus();

                    scaffold.showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Subscription activated! Welcome to Pro 🎉',
                        ),
                      ),
                    );

                    Navigator.pop(context); // Close the paywall screen
                  },
                  icon: const Icon(Icons.arrow_forward),
                  label: Text(
                    'Start Free Trial',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Restore Purchases
              Center(
                child: TextButton(
                  onPressed: () {
                    // TODO: Implement restore logic
                  },
                  child: const Text('Restore Purchases'),
                ),
              ),
              const SizedBox(height: 40),
              // Premium Features
              Text(
                'Premium Features',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              _featureRow(
                context,
                icon: Icons.group,
                text: 'Unlimited Groups & Expenses',
              ),
              const SizedBox(height: 20),
              _featureRow(
                context,
                icon: Icons.block,
                text: 'Ad-Free Experience',
              ),
              const SizedBox(height: 20),
              _featureRow(
                context,
                icon: Icons.support_agent,
                text: 'Priority Support',
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _featureRow(
    BuildContext context, {
    required IconData icon,
    required String text,
  }) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 28),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: theme.textTheme.bodyLarge)),
      ],
    );
  }
}
