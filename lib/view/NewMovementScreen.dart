// ignore: file_names
import 'package:ddsl_app/widgets/GreenReactangle.dart';
import 'package:flutter/material.dart';

class NewMovementScreen extends StatelessWidget {
  const NewMovementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Stack(
          children: [
            GreenRectangle(
              titlePage: "Lançamento",
              heightBlockTitle: 150,
              topTextTitle: 0.4,
            ),
            Positioned(
              top: 180,
              left: 20,
              right: 20,
              child: RadioSelectMovimentType(),
            ),
            Positioned(
              top: 250,
              left: 20,
              right: 20,
              child: SizedBox(
                width: 370,
                child: TextFormField(
                  keyboardType: TextInputType.numberWithOptions(),
                  decoration: const InputDecoration(
                    labelText: "Valor (R\$)",
                    hintText: "Insira a Valor do Lançamento",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Informe um valor";
                    }
                    final numero = double.tryParse(value.replaceAll(',', '.'));
                    if (numero == null || numero == 0) {
                      return "O valor deve ser diferente de R\$0,00";
                    }
                    return null;
                  },
                ),
              ),
            ),
            Positioned(
              top: 320,
              left: 20,
              right: 20,
              child: CustomDropdownListExit(),
            ),
            Positioned(
              top: 390,
              left: 20,
              right: 20,
              child: CustomDropdownListPayment(),
            ),
            Positioned(
              top: 460,
              left: 20,
              right: 20,
              child: CustomDateCalendar(),
            ),
            Positioned(
              top: 540,
              left: 20,
              right: 20,
              child: SizedBox(
                width: 370,
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Descrição',
                    hintText: "Insira a Descricao da Movimentação",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 120,
              left: 10,
              right: 20,
              child: Center(
                child: ElevatedButton(
                  onPressed: () {
                    print("Botão Clicado!");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    fixedSize: const Size(300, 55),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Salvar",
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
    );
  }
}

class RadioSelectMovimentType extends StatefulWidget {
  const RadioSelectMovimentType({super.key});
  @override
  State<RadioSelectMovimentType> createState() => _RadioMoviment();
}

class _RadioMoviment extends State<RadioSelectMovimentType> {
  String? selectField = "OP1";

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Tipo', // O título que fica na bordinha
        filled: true,
        border: InputBorder.none,
        fillColor: Color.fromARGB(0, 255, 255, 255),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 0,
        ), // Ajusta o espaço interno
      ),
      child: RadioGroup<String>(
        groupValue: selectField,
        onChanged: (String? value) {
          setState(() {
            selectField = value;
          });
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Row(
              children: [
                Radio<String>(value: "Entrada"),
                const Text("Entrada"),
              ],
            ),
            Row(
              children: [
                Radio<String>(value: "Saida"),
                const Text("Saida"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CustomDropdownListExit extends StatefulWidget {
  const CustomDropdownListExit({super.key});
  @override
  State<CustomDropdownListExit> createState() => _DropdownListExit();
}

class _DropdownListExit extends State<CustomDropdownListExit> {
  String? selectItem;

  final List<String> categorysList = [
    'Alimentacao',
    'Lazer',
    'Transporte',
    'Outro',
  ];

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: "Categoria",
        hintText: "Insira a Categoria da Lançamento",
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
      initialValue: selectItem,
      items: categorysList.map((String category) {
        return DropdownMenuItem<String>(value: category, child: Text(category));
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          selectItem = newValue;
        });
      },
    );
  }
}

class CustomDropdownListPayment extends StatefulWidget {
  const CustomDropdownListPayment({super.key});
  @override
  State<CustomDropdownListPayment> createState() => _DropListPayment();
}

class _DropListPayment extends State<CustomDropdownListPayment> {
  String? selectedPaymentForm;

  final List<String> paymentList = [
    "Dinheiro",
    "Cartão de Credito",
    "Cartão de Debito",
    "PIX",
  ];

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: "Forma de Pagamento",
        hintText: "Insira uma Forma de Pagamento",
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
      initialValue: selectedPaymentForm,
      items: paymentList.map((String payment) {
        return DropdownMenuItem<String>(value: payment, child: Text(payment));
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          selectedPaymentForm = newValue;
        });
      },
    );
  }
}

class CustomDateCalendar extends StatefulWidget {
  const CustomDateCalendar({super.key});
  @override
  State<CustomDateCalendar> createState() => _CustomDateCalendarState();
}

class _CustomDateCalendarState extends State<CustomDateCalendar> {
  final TextEditingController _dateController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? dateSelected = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (dateSelected != null) {
      setState(() {
        String day = dateSelected.day.toString().padLeft(2, '0');
        String month = dateSelected.month.toString().padLeft(2, '0');
        String year = dateSelected.year.toString();

        _dateController.text = "$day/$month/$year";
      });
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _dateController,
      readOnly: true,
      onTap: () => _selectDate(context),
      decoration: const InputDecoration(
        labelText: "Data",
        hintText: "Insira a Data da Lançamento",
        filled: true,
        fillColor: Colors.white,
        suffix: Icon(Icons.calendar_today),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Informe uma Data";
        }
        return null;
      },
    );
  }
}
