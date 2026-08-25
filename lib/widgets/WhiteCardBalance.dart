// ignore: file_names
import 'package:flutter/material.dart';

class WhiteCardBalance extends StatelessWidget {
  final double valueAllBalance;
  final double valueEntryBalance;
  final double valueExitBalance;

  const WhiteCardBalance({
    super.key,
    this.valueAllBalance = 0.0,
    this.valueEntryBalance = 0.0,
    this.valueExitBalance = 0.0,
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
      height: 135,
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [ 
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 4)
          )
        ]
      ),
      child: Column(
        children: [
          Transform.translate(
            offset: const Offset(20, 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Saldo: R\$ ${_formatMoney(valueAllBalance)}",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontFamily: 'DM Sans',
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Divider( indent: 0, endIndent: 35 ),
                Text(
                  "Entradas: R\$ ${_formatMoney(valueEntryBalance)}",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'DM Sans',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "Saidas: R\$ ${_formatMoney(valueExitBalance)}",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'DM Sans',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
