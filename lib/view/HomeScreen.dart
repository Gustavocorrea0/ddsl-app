// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:ddsl_app/widgets/GreenReactangle.dart';
import 'package:ddsl_app/widgets/WhiteCardBalance.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<double> valuesPay = [
      100.20,
      -200.50,
      304.03,
      500.00,
      -200.00,
      140.00,
      -160.00,
    ];
    const double headerHeight = 230;
    final double topInset = GreenRectangle.totalHeight(
      context,
      heightBlockTitle: headerHeight,
    );

    return Scaffold(
      body: Stack(
        children: [
          GreenRectangle(
            titlePage: "DDSL APP",
            heightBlockTitle: headerHeight,
            topTextTitle: 0,
          ),
          Transform.translate(
            offset: Offset(20, topInset - headerHeight + 160),
            child: WhiteCardBalance(
              valueAllBalance: 199.0,
              valueEntryBalance: 0.0,
              valueExitBalance: 0.0,
            ),
          ),
          Divider(height: 650, indent: 15, endIndent: 20),
          Transform.translate(
            offset: Offset(0, topInset - headerHeight + 330),
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 0, bottom: 350),
              itemCount: valuesPay.length,
              itemBuilder: (context, index) {
                return Center(
                  child: InkWell(
                    onTap: () {
                      // ignore: avoid_print
                      print('Selecionado: ${valuesPay[index]}');
                    },
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
                          Text(
                            "R\$ " + valuesPay[index].toStringAsPrecision(3),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'DM Sans',
                              fontWeight: FontWeight.w600,
                            ),
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
