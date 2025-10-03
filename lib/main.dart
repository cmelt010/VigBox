import 'package:flutter/material.dart';

void main() {
  runApp(const VigBoxApp());
}

class VigBoxApp extends StatelessWidget {
  const VigBoxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VigBox',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const VigBoxHomePage(),
    );
  }
}

class VigBoxHomePage extends StatefulWidget {
  const VigBoxHomePage({super.key});

  @override
  State<VigBoxHomePage> createState() => _VigBoxHomePageState();
}

class _VigBoxHomePageState extends State<VigBoxHomePage> {
  bool isBonusBet = false;
  bool isPlayerProp = false;
  double stakeAmount = 0;
  final TextEditingController stakeController = TextEditingController();
  int? sideAOdds;
  int? sideBOdds;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),

            // 👇 Odds Cards with Floating Vig % and Checkboxes
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Odds entry cards in a row
                  Row(
                    children: [
                      Expanded(
                        child: OddsInputCard(
                          sideLabel: 'Side A',
                          isEnabled: true,
                          stakeAmount: stakeAmount,
                          isBonusBet: isBonusBet,
                          onOddsChanged: (odds, _) {
                            setState(() {
                              sideAOdds = odds;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OddsInputCard(
                          sideLabel: 'Side B',
                          isEnabled: !isPlayerProp,
                          stakeAmount: stakeAmount,
                          isBonusBet: isBonusBet,
                          onOddsChanged: (odds, _) {
                            setState(() {
                              sideBOdds = odds;
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  // Floating Vig + Checkboxes + Footer inside one shaded box
                  Positioned(
                    top: 16,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(20),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Vig Box
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade400),
                            ),
                            child: Builder(
                              builder: (_) {
                                if (isPlayerProp ||
                                    sideAOdds == null ||
                                    sideBOdds == null) {
                                  return const Text(
                                    'Vig: —',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                }

                                double probA = sideAOdds! > 0
                                    ? 100 / (sideAOdds! + 100)
                                    : sideAOdds!.abs() /
                                          (sideAOdds!.abs() + 100);
                                double probB = sideBOdds! > 0
                                    ? 100 / (sideBOdds! + 100)
                                    : sideBOdds!.abs() /
                                          (sideBOdds!.abs() + 100);

                                final vigPercent = (probA + probB - 1) * 100;

                                return Text(
                                  'Vig: ${vigPercent.toStringAsFixed(2)}%',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Checkboxes
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: isBonusBet,
                                    onChanged: (value) {
                                      setState(() {
                                        isBonusBet = value ?? false;
                                      });
                                    },
                                  ),
                                  const Text('Bonus Bet'),
                                ],
                              ),
                              Row(
                                children: [
                                  Checkbox(
                                    value: isPlayerProp,
                                    onChanged: (value) {
                                      setState(() {
                                        isPlayerProp = value ?? false;
                                      });
                                    },
                                  ),
                                  const Text('Player Prop'),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Footer: Logo + Name
                          Column(
                            children: [
                              SizedBox(
                                height: 60,
                                width: 60,
                                child: Image.asset(
                                  'assets/vigbox_logo.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'VigBox',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OddsInputCard extends StatefulWidget {
  final String sideLabel;
  final Function(int, String)? onOddsChanged;
  final bool isEnabled;
  final double stakeAmount;
  final bool isBonusBet;

  const OddsInputCard({
    super.key,
    required this.sideLabel,
    this.onOddsChanged,
    this.isEnabled = true,
    this.stakeAmount = 0,
    this.isBonusBet = false,
  });

  @override
  State<OddsInputCard> createState() => _OddsInputCardState();
}

class _OddsInputCardState extends State<OddsInputCard> {
  final TextEditingController stakeController = TextEditingController();

  String _calculatePayout() {
    final input = oddsController.text;
    final stake = double.tryParse(stakeController.text) ?? 0;

    if (input.isEmpty || impliedProbability == null || stake == 0) return '—';

    final odds = int.tryParse(input);
    if (odds == null || odds <= 0) return '—';

    final adjustedOdds = selectedSign == '+' ? odds : -odds;

    double winAmount;
    if (adjustedOdds > 0) {
      winAmount = stake * (adjustedOdds / 100);
    } else {
      winAmount = stake * (100 / adjustedOdds.abs());
    }

    return '\$${winAmount.toStringAsFixed(2)}';
  }

  // ignore: unused_element
  String _calculateTotal() {
    final stake = double.tryParse(stakeController.text) ?? 0;
    final profitText = _calculatePayout();
    if (profitText == '—') return '—';

    final profit = double.tryParse(
      profitText.replaceAll(RegExp(r'[^\d.]'), ''),
    );
    if (profit == null) return '—';

    final total = stake + profit;
    return '\$${total.toStringAsFixed(2)}';
  }

  // ignore: avoid_init_to_null
  String? selectedSign = null;

  final TextEditingController oddsController = TextEditingController();
  double? impliedProbability;

  void _calculateImpliedProbability() {
    final input = oddsController.text;
    if (input.isEmpty || selectedSign == null) {
      setState(() => impliedProbability = null);
      return;
    }

    final odds = int.tryParse(input);
    if (odds == null || odds <= 0) {
      setState(() => impliedProbability = null);
      return;
    }

    final adjustedOdds = selectedSign == '+' ? odds : -odds;

    final probability = adjustedOdds > 0
        ? 100 / (adjustedOdds + 100)
        : (adjustedOdds.abs()) / (adjustedOdds.abs() + 100);

    setState(() => impliedProbability = probability);

    // Call back to parent
    if (widget.onOddsChanged != null) {
      widget.onOddsChanged!(adjustedOdds, widget.sideLabel);
    }
  }

  @override
  void initState() {
    super.initState();
    oddsController.addListener(_calculateImpliedProbability);
  }

  @override
  void dispose() {
    stakeController.dispose();
    oddsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: widget.isEnabled ? 1.0 : 0.4,
      child: IgnorePointer(
        ignoring: !widget.isEnabled,
        child: Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.sideLabel,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 100,
                      child: TextField(
                        controller: oddsController,
                        enabled: widget.isEnabled,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          labelText: 'Odds',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 8,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButton<String>(
                      value: selectedSign,
                      hint: const Text('±', style: TextStyle(fontSize: 18)),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedSign = newValue!;
                          _calculateImpliedProbability();
                        });
                      },
                      items: ['+', '-']
                          .map(
                            (value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          )
                          .toList(),
                      style: const TextStyle(fontSize: 16),
                      alignment: Alignment.center,
                      isDense: true,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  impliedProbability != null
                      ? 'Implied Probability: ${(impliedProbability! * 100).toStringAsFixed(2)}%'
                      : 'Implied Probability: —',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 100,
                      child: TextField(
                        controller: stakeController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          labelText: 'Stake',
                          prefixText: '\$',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 8,
                          ),
                        ),
                        onChanged: (_) {
                          setState(() {});
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Stake: \$${(double.tryParse(stakeController.text) ?? 0).toStringAsFixed(2)}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  'Profit: ${_calculatePayout()}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (!widget.isBonusBet)
                  Text(
                    'Total: ${_calculateTotal()}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
