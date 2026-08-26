// ignore: file_names
import 'package:ddsl_app/models/movement.dart';
import 'package:ddsl_app/repository/movement_repository.dart';
import 'package:ddsl_app/view/NewMovementScreen.dart'
    show movementTypeConfigFor;
import 'package:ddsl_app/widgets/GreenReactangle.dart';
import 'package:flutter/material.dart';

class DetailMovement extends StatelessWidget {
  final Movement movement;
  final VoidCallback? onClose;

  const DetailMovement({super.key, required this.movement, this.onClose});

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

  Future<void> _confirmDelete(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Excluir movimentação"),
          content: const Text(
            "Tem certeza que deseja excluir esta movimentação? Essa ação não pode ser desfeita.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text(
                "Excluir",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await MovementRepository.instance.remove(movement);
      onClose?.call();
    }
  }

  Widget _readOnlyField({
    required String label,
    required String value,
    Widget? suffix,
    int maxLines = 1,
  }) {
    return SizedBox(
      width: 370,
      child: TextFormField(
        initialValue: value,
        readOnly: true,
        showCursor: false,
        maxLines: maxLines,
        mouseCursor: SystemMouseCursors.basic,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          suffix: suffix,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = movementTypeConfigFor(movement.type);
    const double headerHeight = 150;
    final double topInset = GreenRectangle.totalHeight(
      context,
      heightBlockTitle: headerHeight,
    );

    return Material(
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: SizedBox(
            height: 750 + topInset,
            child: Stack(
              children: [
                GreenRectangle(
                  titlePage: movement.type ?? "Entrada",
                  heightBlockTitle: headerHeight + 50,
                  topTextTitle: 0,
                  fontSizeTitle: 30,
                ),
                if (onClose != null)
                  Positioned(
                    top: MediaQuery.of(context).padding.top,
                    left: 4,
                    child: IconButton(
                      onPressed: onClose,
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                Positioned(
                  top: topInset + 5,
                  left: 20,
                  right: 20,
                  child: Center(
                    child: Container(
                      width: 370,
                      padding: const EdgeInsets.symmetric(vertical: 24),
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
                      child: Center(
                        child: Text(
                          "R\$ ${_formatMoney(movement.value)}",
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 28,
                            fontFamily: 'DM Sans',
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: topInset + 140,
                  left: 20,
                  right: 20,
                  child: _readOnlyField(
                    label: config.categoryLabel,
                    value: movement.category,
                  ),
                ),
                Positioned(
                  top: topInset + 210,
                  left: 20,
                  right: 20,
                  child: _readOnlyField(
                    label: config.paymentLabel,
                    value: movement.paymentMethod ?? "",
                  ),
                ),
                Positioned(
                  top: topInset + 280,
                  left: 20,
                  right: 20,
                  child: _readOnlyField(
                    label: config.dateLabel,
                    value: movement.date,
                    suffix: const Icon(Icons.calendar_today),
                  ),
                ),
                Positioned(
                  top: topInset + 350,
                  left: 20,
                  right: 20,
                  child: _readOnlyField(
                    label: "Descrição",
                    value: movement.description,
                    maxLines: 3,
                  ),
                ),
                Positioned(
                  top: topInset + 500,
                  left: 10,
                  right: 20,
                  child: Center(
                    child: ElevatedButton(
                      onPressed: () => _confirmDelete(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        fixedSize: const Size(300, 55),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Excluir",
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
      ),
    );
  }
}
