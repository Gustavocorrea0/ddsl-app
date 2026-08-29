import 'package:ddsl_app/models/objective.dart';
import 'package:ddsl_app/repository/objective_repository.dart';
import 'package:ddsl_app/widgets/GreenReactangle.dart';
import 'package:flutter/material.dart';

class ObjectiveScreen extends StatefulWidget {
  final VoidCallback onNewObjective;
  final void Function(Objective objective) onObjectiveTap;

  const ObjectiveScreen({
    super.key,
    required this.onNewObjective,
    required this.onObjectiveTap,
  });

  @override
  State<ObjectiveScreen> createState() => _ObjectiveScreen();
}

class _ObjectiveScreen extends State<ObjectiveScreen> {
  static const int _pageSize = 10;

  final ScrollController _historyScrollController = ScrollController();
  int _visibleCount = _pageSize;

  @override
  void initState() {
    super.initState();
    ObjectiveRepository.instance.addListener(_onObjectivesChanged);
    _historyScrollController.addListener(_onHistoryScroll);
  }

  @override
  void dispose() {
    ObjectiveRepository.instance.removeListener(_onObjectivesChanged);
    _historyScrollController.removeListener(_onHistoryScroll);
    _historyScrollController.dispose();
    super.dispose();
  }

  void _onObjectivesChanged() {
    setState(() {});
  }

  void _onHistoryScroll() {
    final position = _historyScrollController.position;
    if (position.pixels < position.maxScrollExtent - 200) return;

    final total = ObjectiveRepository.instance.objectives.length;
    if (_visibleCount >= total) return;

    setState(() {
      _visibleCount = (_visibleCount + _pageSize).clamp(0, total);
    });
  }

  String _formatMoney(double value) {
    final List<String> parts = value.toStringAsFixed(2).split('.');
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
    return '$buffer,$decimalPart';
  }

  @override
  Widget build(BuildContext context) {
    const double headerHeight = 150;
    final double topInset = GreenRectangle.totalHeight(
      context,
      heightBlockTitle: headerHeight,
    );
    final objectives = ObjectiveRepository.instance.objectivesSortedByDateDesc;
    final int visibleCount = _visibleCount.clamp(0, objectives.length);
    final bool hasMore = visibleCount < objectives.length;

    return Scaffold(
      body: Stack(
        children: [
          GreenRectangle(
            titlePage: "Objetivos",
            heightBlockTitle: headerHeight,
            topTextTitle: -0.1,
            fontSizeTitle: 30,
          ),
          Positioned(
            top: topInset + 24,
            left: 20,
            right: 20,
            child: Center(
              child: ElevatedButton(
                onPressed: widget.onNewObjective,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF367646),
                  fixedSize: const Size(305, 65),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(8),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.add_box_outlined, color: Colors.white, size: 34),
                    SizedBox(width: 8),
                    Text(
                      "Novo Objetivo",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: topInset + 105,
            left: 20,
            right: 20,
            child: const Divider(indent: 15, endIndent: 20),
          ),
          Transform.translate(
            offset: Offset(0, topInset + 120),
            child: ListView.builder(
              controller: _historyScrollController,
              padding: const EdgeInsets.only(top: 0, bottom: 450),
              itemCount: objectives.isEmpty
                  ? 1
                  : visibleCount + (hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (objectives.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text("Nenhum objetivo cadastrado."),
                    ),
                  );
                }

                if (index >= visibleCount) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  );
                }

                final objective = objectives[index];
                return Center(
                  child: InkWell(
                    onTap: () => widget.onObjectiveTap(objective),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 370,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(24, 30, 33, 1.0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  objective.nameObjective,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Meta: R\$ ${_formatMoney(objective.totalValue)}",
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  "Conclusão: ${objective.dateConclusao}",
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.flag, color: Colors.green, size: 20),
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
