// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:ddsl_app/models/movement.dart';
import 'package:ddsl_app/repository/movement_repository.dart';
import 'package:ddsl_app/widgets/GreenReactangle.dart';
import 'package:ddsl_app/widgets/WhiteCardBalance.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final void Function(Movement movement) onMovementTap;

  const HomeScreen({super.key, required this.onMovementTap});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const int _pageSize = 10;

  final ScrollController _historyScrollController = ScrollController();
  int _visibleCount = _pageSize;

  @override
  void initState() {
    super.initState();
    MovementRepository.instance.addListener(_onMovementsChanged);
    _historyScrollController.addListener(_onHistoryScroll);
  }

  @override
  void dispose() {
    MovementRepository.instance.removeListener(_onMovementsChanged);
    _historyScrollController.removeListener(_onHistoryScroll);
    _historyScrollController.dispose();
    super.dispose();
  }

  void _onMovementsChanged() {
    setState(() {});
  }

  void _onHistoryScroll() {
    final position = _historyScrollController.position;
    if (position.pixels < position.maxScrollExtent - 200) return;

    final total = MovementRepository.instance.movements.length;
    if (_visibleCount >= total) return;

    setState(() {
      _visibleCount = (_visibleCount + _pageSize).clamp(0, total);
    });
  }

  String _formatMoney(double value) {
    final bool isNegative = value < 0;
    final List<String> parts = value.abs().toStringAsFixed(2).split('.');
    final String integerPart = parts[0];
    final String decimalPart = parts[1];

    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < integerPart.length; i++) {
      final int posFromRight = integerPart.length - i;
      buffer.write(integerPart[i]);
      if (posFromRight > 1 && posFromRight % 3 == 1) {
        buffer.write('.');
      }
    }
    return '${isNegative ? '-' : ''}$buffer,$decimalPart';
  }

  @override
  Widget build(BuildContext context) {
    const double headerHeight = 230;
    final double topInset = GreenRectangle.totalHeight(
      context,
      heightBlockTitle: headerHeight,
    );
    final repository = MovementRepository.instance;
    final movements = repository.movementsSortedByDateDesc;
    final int visibleCount = _visibleCount.clamp(0, movements.length);
    final bool hasMore = visibleCount < movements.length;

    return Scaffold(
      body: Stack(
        children: [
          GreenRectangle(
            titlePage: "DDSL APP",
            heightBlockTitle: headerHeight,
            topTextTitle: -0.1,
            fontSizeTitle: 30,
          ),
          Transform.translate(
            offset: Offset(20, topInset - headerHeight + 160),
            child: WhiteCardBalance(
              valueAllBalance: repository.saldo,
              valueEntryBalance: repository.totalEntradas,
              valueExitBalance: repository.totalSaidas,
            ),
          ),
          Divider(height: 740, indent: 15, endIndent: 20),
          Transform.translate(
            offset: Offset(0, topInset - headerHeight + 330),
            child: ListView.builder(
              controller: _historyScrollController,
              padding: const EdgeInsets.only(top: 0, bottom: 450),
              itemCount: visibleCount + (hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= visibleCount) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  );
                }

                final movement = movements[index];
                return Center(
                  child: InkWell(
                    onTap: () => widget.onMovementTap(movement),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 370,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(24, 30, 33, 1.0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                movement.value < 0
                                    ? Icons.arrow_circle_down
                                    : Icons.arrow_circle_up,
                                color: movement.value < 0
                                    ? Colors.red
                                    : Colors.green,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "R\$ " + _formatMoney(movement.value),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontFamily: 'DM Sans',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
