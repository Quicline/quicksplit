import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QuickSplitScreen extends StatefulWidget {
  const QuickSplitScreen({super.key});

  @override
  State<QuickSplitScreen> createState() => _QuickSplitScreenState();
}

class _QuickSplitScreenState extends State<QuickSplitScreen> {
  final _totalController = TextEditingController();
  int _selectedPeople = 2;
  double? _result;
  double? _totalWithTip;
  double? _tipPerPerson;
  double? _excess;
  final _tipController = TextEditingController();
  String _selectedTip = '15%';
  List<String> _recentSummaries = [];

  void _calculateSplit() {
    final total = double.tryParse(_totalController.text) ?? 0;
    final people = _selectedPeople;

    double tipPercent;
    if (_selectedTip == 'Other') {
      tipPercent = double.tryParse(_tipController.text) ?? 0;
    } else {
      tipPercent = double.parse(_selectedTip.replaceAll('%', ''));
    }

    final tipAmount = total * (tipPercent / 100);
    final totalWithTip = total + tipAmount;

    final rawPerPerson = totalWithTip / people;
    final roundedPerPerson = double.parse(rawPerPerson.toStringAsFixed(2));
    final roundedTotal = roundedPerPerson * people;

    final excess = roundedTotal - totalWithTip;

    setState(() {
      _totalWithTip = totalWithTip;
      _tipPerPerson = tipAmount / people;
      _result = roundedPerPerson;

      // Only show excess if people are overpaying
      _excess = excess > 0.01 ? excess : null;

      final now = DateTime.now();
      final formattedDate =
          '${now.month}/${now.day}/${now.year} ${now.hour}:${now.minute.toString().padLeft(2, '0')}';
      _recentSummaries.insert(
        0,
        '[$formattedDate] Total: \$${totalWithTip.toStringAsFixed(2)} | $people people | Each: \$${roundedPerPerson.toStringAsFixed(2)}',
      );
      if (_recentSummaries.length > 5) _recentSummaries.removeLast();
    });
  }

  @override
  void dispose() {
    _totalController.dispose();
    _tipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final iconColor = Theme.of(context).iconTheme.color?.withOpacity(0.7);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        iconTheme: IconThemeData(color: colorScheme.primary),
        title: Text(
          'Quick Split',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _totalController,
              decoration: const InputDecoration(
                labelText: 'Total Amount',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _selectedPeople,
              decoration: const InputDecoration(
                labelText: 'Number of People',
                border: OutlineInputBorder(),
              ),
              items:
                  List.generate(20, (index) => index + 1).map((value) {
                    return DropdownMenuItem(
                      value: value,
                      child: Text(value.toString()),
                    );
                  }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedPeople = value;
                  });
                }
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedTip,
              decoration: const InputDecoration(
                labelText: 'Tip Percentage',
                border: OutlineInputBorder(),
              ),
              items:
                  ['0%', '10%', '15%', '18%', '20%', 'Other'].map((value) {
                    return DropdownMenuItem(value: value, child: Text(value));
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedTip = value!;
                });
              },
            ),
            if (_selectedTip == 'Other') ...[
              const SizedBox(height: 12),
              TextField(
                controller: _tipController,
                decoration: const InputDecoration(
                  labelText: 'Custom Tip %',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
            ],
            if (_selectedTip != 'Other') ...[
              const SizedBox(height: 12),
              Text('Smart Tip Suggestions:', style: textTheme.labelLarge),
              ..._calculateRoundedSmartTips(
                double.tryParse(_totalController.text) ?? 0,
                _selectedPeople,
              ).entries.map(
                (entry) => Text(
                  '${entry.key} → Tip per person: \$${entry.value.toStringAsFixed(2)}',
                ),
              ),
            ],
            const SizedBox(height: 12),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              onPressed: _calculateSplit,
              child: const Text(
                'Calculate',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            if (_result != null &&
                _totalWithTip != null &&
                _tipPerPerson != null) ...[
              const Divider(height: 32),
              Text('Split Result', style: textTheme.titleLarge),
              const SizedBox(height: 12),
              Text(
                'Total with tip: \$${_totalWithTip!.toStringAsFixed(2)}',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tip per person: \$${_tipPerPerson!.toStringAsFixed(2)}',
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Each person pays: \$${_result!.toStringAsFixed(2)}',
                style: textTheme.titleLarge,
              ),
              if (_excess != null && _excess!.abs() > 0.01)
                Text(
                  'There\'s going to be an exceed of \$${_excess!.abs().toStringAsFixed(2)}',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                onPressed: () {
                  final summary = '''
QuickSplit Summary:
Total (with tip): \$${_totalWithTip!.toStringAsFixed(2)}
People: $_selectedPeople
Tip per person: \$${_tipPerPerson!.toStringAsFixed(2)}
Each pays: \$${_result!.toStringAsFixed(2)}
''';
                  Clipboard.setData(ClipboardData(text: summary));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Copied to clipboard')),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.copy, size: 20, color: colorScheme.onPrimary),
                    const SizedBox(width: 8),
                    Text(
                      'Copy Summary',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            if (_recentSummaries.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text('Recent Splits:', style: textTheme.labelLarge),
                  const SizedBox(height: 8),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _recentSummaries.length,
                    separatorBuilder: (_, __) => const Divider(height: 8),
                    itemBuilder: (context, index) {
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          Icons.history,
                          size: 20,
                          color: iconColor,
                        ),
                        title: Text(_recentSummaries[index]),
                        dense: true,
                      );
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

Map<String, double> _calculateRoundedSmartTips(double total, int people) {
  final suggestions = <String, double>{};
  final realisticPercents = [0, 10, 12, 15, 18, 20, 22, 25];

  for (var percent in realisticPercents) {
    final tipAmount = total * (percent / 100);
    final totalWithTip = total + tipAmount;
    final perPerson = totalWithTip / people;

    // Round to the nearest 0.50
    final roundedPerPerson = (perPerson * 2).ceil() / 2;
    final roundedTotal = roundedPerPerson * people;
    final adjustedTip = roundedTotal - total;

    if ((roundedPerPerson * 100) % 50 == 0) {
      suggestions['$percent%'] = adjustedTip / people;
    }

    if (suggestions.length >= 3) break;
  }

  return suggestions;
}
