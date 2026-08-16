// ignore: file_names
import 'package:flutter/material.dart';

/// Widget que representa um retângulo verde.
/// Por ser um StatelessWidget, ele não guarda nenhum estado interno:
/// só recebe parâmetros (se houver) e desenha algo na tela.
class GreenRectangle extends StatelessWidget {

  final String titlePage;
  final double heightBlockTitle;
  final double topTextTitle;

  const GreenRectangle({
    super.key,
    this.titlePage = "",
    this.heightBlockTitle = 150,
    this.topTextTitle = 0.2
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // ocupa toda a largura disponível
      height: heightBlockTitle,            // altura fixa em pixels lógicos
      color: Color.fromRGBO(24, 30, 33, 1.0),  
      alignment: Alignment(-0.9, topTextTitle),
      child: Text(  
        titlePage,
        style: TextStyle(
          color: Colors.white, 
          fontSize: 27,
          fontFamily: 'DM Sans',
          fontWeight: FontWeight.w900
        ),
      )
    );
  }
}