import 'package:ddsl_app/models/objective.dart';
import 'package:ddsl_app/models/objective_movement.dart';
import 'package:ddsl_app/repository/objective_repository.dart';
import 'package:ddsl_app/widgets/GreenReactangle.dart';
import 'package:ddsl_app/widgets/WhiteCardObjective.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class _CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    digitsOnly = digitsOnly.replaceFirst(RegExp(r'^0+(?=\d)'), '');
    if (digitsOnly.isEmpty) {
      digitsOnly = '0';
    }

    final double value = int.parse(digitsOnly) / 100;
    final String formatted = _formatCurrency(value);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _formatCurrency(double value) {
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
}

class DetailObjectiveScreen extends StatefulWidget {
  final Objective objective;
  final VoidCallback? onClose;

  const DetailObjectiveScreen({
    super.key,
    required this.objective,
    this.onClose,
  });

  @override
  State<DetailObjectiveScreen> createState() => _DetailObjectiveScreenState();
}

class _DetailObjectiveScreenState extends State<DetailObjectiveScreen> {
  final TextEditingController _valueController = TextEditingController();

  bool _showMovimentarCard = false;
  String _selectedType = "Entrada";

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
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

  Future<void> _saveMovement() async {
    final double value =
        double.tryParse(
          _valueController.text.replaceAll('.', '').replaceAll(',', '.'),
        ) ??
        0.0;
    if (value <= 0) return;

    final DateTime now = DateTime.now();
    final String date =
        "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";

    widget.objective.addMovement(
      ObjectiveMovement(value: value, type: _selectedType, date: date),
    );
    await ObjectiveRepository.instance.update(widget.objective);

    setState(() {
      _valueController.clear();
      _selectedType = "Entrada";
      _showMovimentarCard = false;
    });
  }

  Future<void> _removeMovement(ObjectiveMovement movement) async {
    widget.objective.removeMovement(movement);
    await ObjectiveRepository.instance.update(widget.objective);
    setState(() {});
  }

  Future<void> _confirmDeleteObjective(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Excluir objetivo"),
          content: const Text(
            "Tem certeza que deseja excluir este objetivo e todas as movimentações registradas? Essa ação não pode ser desfeita.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text("Excluir", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await ObjectiveRepository.instance.remove(widget.objective);
      widget.onClose?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    const double headerHeight = 150;
    final double topInset = GreenRectangle.totalHeight(
      context,
      heightBlockTitle: headerHeight,
    );
    final movements = widget.objective.movements.reversed.toList();

    return Material(
      child: SafeArea(
        top: false,
        child: Stack(
          children: [
            SingleChildScrollView(
              child: SizedBox(
                height: 750 + topInset,
                child: Stack(
                  children: [
                    GreenRectangle(
                      titlePage: widget.objective.nameObjective,
                      heightBlockTitle: headerHeight + 50,
                      topTextTitle: 0,
                      fontSizeTitle: 30,
                    ),
                    if (widget.onClose != null)
                      Positioned(
                        top: MediaQuery.of(context).padding.top,
                        left: 4,
                        child: IconButton(
                          onPressed: widget.onClose,
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    Positioned(
                      top: MediaQuery.of(context).padding.top,
                      right: 4,
                      child: IconButton(
                        onPressed: () => _confirmDeleteObjective(context),
                        icon: const Icon(
                          Icons.delete_forever_sharp,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ),
                    Transform.translate(
                      offset: Offset(20, topInset + 10),
                      child: WhiteCardObjective(
                        initialValue: widget.objective.initialValue,
                        totalValue: widget.objective.totalValue,
                      ),
                    ),
                    Positioned(
                      top: topInset + 140,
                      left: 20,
                      right: 20,
                      child: const Divider(indent: 15, endIndent: 20),
                    ),
                    Positioned(
                      top: topInset + 130,
                      left: 20,
                      right: 20,
                      bottom: 200,
                      child: movements.isEmpty
                          ? const Center(
                              child: Text(
                                "Nenhuma movimentação registrada.",
                                style: TextStyle(color: Colors.white70),
                              ),
                            )
                          : ListView.builder(
                              itemCount: movements.length,
                              itemBuilder: (context, index) {
                                final movement = movements[index];
                                final bool isSaida = movement.type == "Saida";
                                return Container(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color.fromRGBO(
                                      24,
                                      30,
                                      33,
                                      1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            isSaida
                                                ? Icons.arrow_circle_down
                                                : Icons.arrow_circle_up,
                                            color: isSaida
                                                ? Colors.red
                                                : Colors.green,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            "R\$ ${_formatMoney(movement.value)}",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      IconButton(
                                        onPressed: () =>
                                            _removeMovement(movement),
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                    Positioned(
                      bottom: 180,
                      left: 10,
                      right: 20,
                      child: Center(
                        child: ElevatedButton(
                          onPressed: () =>
                              setState(() => _showMovimentarCard = true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            fixedSize: const Size(300, 55),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadiusGeometry.circular(8),
                            ),
                          ),
                          child: const Text(
                            "Movimentar",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_showMovimentarCard)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => setState(() => _showMovimentarCard = false),
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.5),
                    child: Center(
                      child: GestureDetector(
                        onTap: () {},
                        child: Container(
                          width: 350,
                          height: 300,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 8,
                                spreadRadius: 1,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Movimentar",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => setState(
                                      () => _showMovimentarCard = false,
                                    ),
                                    icon: const Icon(
                                      Icons.close_rounded,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              RadioGroup<String>(
                                groupValue: _selectedType,
                                onChanged: (value) => setState(
                                  () => _selectedType = value ?? "Entrada",
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: const [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Radio<String>(value: "Entrada"),
                                        Text("Entrada"),
                                      ],
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Radio<String>(value: "Saida"),
                                        Text("Saida"),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _valueController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [_CurrencyInputFormatter()],
                                decoration: const InputDecoration(
                                  labelText: "Valor (R\$)",
                                  hintText: "0,00",
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _saveMovement,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  fixedSize: const Size(150, 45),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadiusGeometry.circular(
                                      8,
                                    ),
                                  ),
                                ),
                                child: const Text(
                                  "Salvar",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
