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
    return Scaffold(
      appBar: AppBar(title: const Text('Quick Split')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter Bill Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _totalController,
              decoration: const InputDecoration(
                labelText: 'Total Amount',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 24),
            const Text(
              'Preferences',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
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
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedTip,
              decoration: const InputDecoration(
                labelText: 'Tip Percentage',
                border: OutlineInputBorder(),
              ),
              items:
                  ['10%', '15%', '18%', '20%', 'Other'].map((value) {
                    return DropdownMenuItem(value: value, child: Text(value));
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedTip = value!;
                });
              },
            ),
            if (_selectedTip == 'Other') ...[
              const SizedBox(height: 20),
              TextField(
                controller: _tipController,
                decoration: const InputDecoration(
                  labelText: 'Custom Tip %',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
            ],
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _calculateSplit,
              child: const Text('Calculate'),
            ),
            if (_result != null &&
                _totalWithTip != null &&
                _tipPerPerson != null) ...[
              const Divider(height: 32),
              const Text(
                'Split Result',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'Total with tip: \$${_totalWithTip!.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tip per person: \$${_tipPerPerson!.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 8),
              Text(
                'Each person pays: \$${_result!.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_excess != null && _excess!.abs() > 0.01)
                Text(
                  'There\'s going to be an exceed of \$${_excess!.abs().toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.copy),
                label: const Text('Copy Summary'),
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
              ),
            ],
          ],
        ),
      ),
    );
  }
}
