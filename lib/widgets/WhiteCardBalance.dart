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
            offset: const Offset(10, 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Saldo: R\$ $valueAllBalance",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontFamily: 'DM Sans',
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Divider( indent: 0, endIndent: 20 ),
                Text(
                  "Entradas: R\$ $valueEntryBalance",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'DM Sans',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "Saidas: R\$ $valueExitBalance",
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
