// ignore: file_names
import 'package:flutter/material.dart';

class WhiteCardObjective extends StatelessWidget {
  final double initialValue;
  final double totalValue;

  const WhiteCardObjective({
    super.key,
    this.initialValue = 0.0,
    this.totalValue = 0.0,
  });

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
    return Container(
      width: 370,
      height: 115,
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 255, 255, 255),
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
        children: [
          Transform.translate(
            offset: const Offset(20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Total: R\$ ${_formatMoney(initialValue)}",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontFamily: 'DM Sans',
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Divider(indent: 0, endIndent: 35),
                Text(
                  "Meta: R\$ ${_formatMoney(totalValue)}",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontFamily: 'DM Sans',
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
