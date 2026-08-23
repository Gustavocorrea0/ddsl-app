// ignore: file_names
import 'package:ddsl_app/models/movement.dart';
import 'package:ddsl_app/repository/movement_repository.dart';
import 'package:ddsl_app/widgets/GreenReactangle.dart';
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
    return '${buffer.toString()},$decimalPart';
  }
}

class MovementTypeConfig {
  final String categoryLabel;
  final List<String> categories;
  final String paymentLabel;
  final List<String> paymentMethods;
  final String dateLabel;
  final double sign;

  const MovementTypeConfig({
    required this.categoryLabel,
    required this.categories,
    required this.paymentLabel,
    required this.paymentMethods,
    required this.dateLabel,
    required this.sign,
  });
}

MovementTypeConfig movementTypeConfigFor(String? type) {
  if (type == "Saida") {
    return const MovementTypeConfig(
      categoryLabel: "Tipo Saida",
      categories: ['Alimentacao', 'Lazer', 'Transporte', 'Outro'],
      paymentLabel: "Forma de Saida",
      paymentMethods: [
        "Dinheiro",
        "Cartão de Credito",
        "Cartão de Debito",
        "PIX",
        "TED",
      ],
      dateLabel: "Data Saida",
      sign: -1,
    );
  }
  return const MovementTypeConfig(
    categoryLabel: "Tipo Entrada",
    categories: ['Salario', 'Bico', 'Outro'],
    paymentLabel: "Forma de Entrada",
    paymentMethods: ["Dinheiro", "PIX", "TED", "Transferencia Bancaria"],
    dateLabel: "Data Entrada",
    sign: 1,
  );
}

class NewMovementScreen extends StatefulWidget {
  const NewMovementScreen({super.key});
  @override
  State<NewMovementScreen> createState() => _NewMovementScreenState();
}

class _NewMovementScreenState extends State<NewMovementScreen> {
  final TextEditingController _valuePaymentController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String? _categorySelect;
  String? _typeSelect = "Entrada";
  String? _paymentSelect;
  String? _dateSelect;

  int _formResetCounter = 0;

  void _clearFields() {
    setState(() {
      _valuePaymentController.clear();
      _descriptionController.clear();
      _categorySelect = null;
      _typeSelect = "Entrada";
      _paymentSelect = null;
      _dateSelect = null;
      _formResetCounter++;
    });
  }

  Future<void> _saveLaunch() async {
    String valuePaymentText = _valuePaymentController.text;
    String description = _descriptionController.text;

    if (valuePaymentText.isEmpty ||
        _categorySelect == null ||
        _dateSelect == null) {
      //print("Preencha os campos obrigatórios: valor, categoria e data.");
      return;
    }

    final config = movementTypeConfigFor(_typeSelect);
    double valuePayment =
        (double.tryParse(
                  valuePaymentText.replaceAll('.', '').replaceAll(',', '.'),
                ) ??
                0.0)
            .abs() *
        config.sign;

    final movement = Movement(
      value: valuePayment,
      description: description,
      date: _dateSelect!,
      category: _categorySelect!,
      type: _typeSelect,
      paymentMethod: _paymentSelect,
    );

    await MovementRepository.instance.add(movement);

    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Sucesso"),
          content: const Text("Dados salvos com sucesso."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );

    if (!mounted) return;
    _clearFields();
  }

  @override
  void dispose() {
    _valuePaymentController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = movementTypeConfigFor(_typeSelect);
    const double headerHeight = 150;
    final double topInset = GreenRectangle.totalHeight(
      context,
      heightBlockTitle: headerHeight,
    );
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SizedBox(
            height: 750 + topInset,
            child: Stack(
              children: [
                GreenRectangle(
                  titlePage: "Lançamento",
                  heightBlockTitle: headerHeight,
                  topTextTitle: 0.4,
                ),
                Positioned(
                  top: topInset + 30,
                  left: 20,
                  right: 20,
                  child: RadioSelectMovimentType(
                    key: ValueKey('type_$_formResetCounter'),
                    onChanged: (value) {
                      setState(() {
                        _typeSelect = value;
                        _categorySelect = null;
                        _paymentSelect = null;
                      });
                    },
                  ),
                ),
                Positioned(
                  top: topInset + 100,
                  left: 20,
                  right: 20,
                  child: SizedBox(
                    width: 370,
                    child: TextFormField(
                      controller: _valuePaymentController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [_CurrencyInputFormatter()],
                      decoration: const InputDecoration(
                        labelText: "Valor (R\$)",
                        hintText: "0,00",
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
                        final numero = double.tryParse(
                          value.replaceAll('.', '').replaceAll(',', '.'),
                        );
                        if (numero == null || numero == 0) {
                          return "O valor deve ser diferente de R\$0,00";
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                Positioned(
                  top: topInset + 170,
                  left: 20,
                  right: 20,
                  child: CustomDropdownListCategory(
                    key: ValueKey('${config.categoryLabel}_$_formResetCounter'),
                    label: config.categoryLabel,
                    items: config.categories,
                    onChanged: (value) {
                      setState(() {
                        _categorySelect = value;
                      });
                    },
                  ),
                ),
                Positioned(
                  top: topInset + 240,
                  left: 20,
                  right: 20,
                  child: CustomDropdownListPayment(
                    key: ValueKey('${config.paymentLabel}_$_formResetCounter'),
                    label: config.paymentLabel,
                    items: config.paymentMethods,
                    onChanged: (value) =>
                        setState(() => _paymentSelect = value),
                  ),
                ),
                Positioned(
                  top: topInset + 310,
                  left: 20,
                  right: 20,
                  child: CustomDateCalendar(
                    key: ValueKey('date_$_formResetCounter'),
                    label: config.dateLabel,
                    onChanged: (value) {
                      setState(() {
                        _dateSelect = value;
                      });
                    },
                  ),
                ),
                Positioned(
                  top: topInset + 390,
                  left: 20,
                  right: 20,
                  child: SizedBox(
                    width: 370,
                    child: TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Descrição',
                        hintText: "Insira a Descricao do Lancamento",
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
                  top: topInset + 460,
                  left: 10,
                  right: 20,
                  child: Center(
                    child: ElevatedButton(
                      onPressed: () {
                        _saveLaunch();
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
        ),
      ),
    );
  }
}

class RadioSelectMovimentType extends StatefulWidget {
  final Function(String?) onChanged;
  const RadioSelectMovimentType({super.key, required this.onChanged});
  @override
  State<RadioSelectMovimentType> createState() => _RadioMoviment();
}

class _RadioMoviment extends State<RadioSelectMovimentType> {
  String? selectField = "Entrada";

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Tipo',
        filled: true,
        border: InputBorder.none,
        fillColor: Color.fromARGB(0, 255, 255, 255),
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      ),
      child: RadioGroup<String>(
        groupValue: selectField,
        onChanged: (String? value) {
          setState(() {
            selectField = value;
          });
          widget.onChanged(value); 
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

class CustomDropdownListCategory extends StatefulWidget {
  final String label;
  final List<String> items;
  final Function(String?) onChanged;
  const CustomDropdownListCategory({
    super.key,
    required this.label,
    required this.items,
    required this.onChanged,
  });
  @override
  State<CustomDropdownListCategory> createState() => _DropdownListCategory();
}

class _DropdownListCategory extends State<CustomDropdownListCategory> {
  String? selectItem;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: "Selecione ${widget.label}",
        filled: true,
        fillColor: Colors.white,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
      initialValue: selectItem,
      items: widget.items.map((String category) {
        return DropdownMenuItem<String>(value: category, child: Text(category));
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          selectItem = newValue;
        });
        widget.onChanged(newValue);
      },
    );
  }
}

class CustomDropdownListPayment extends StatefulWidget {
  final String label;
  final List<String> items;
  final Function(String?) onChanged;
  const CustomDropdownListPayment({
    super.key,
    required this.label,
    required this.items,
    required this.onChanged,
  });
  @override
  State<CustomDropdownListPayment> createState() => _DropListPayment();
}

class _DropListPayment extends State<CustomDropdownListPayment> {
  String? selectedPaymentForm;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: "Selecione ${widget.label}",
        filled: true,
        fillColor: Colors.white,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
      initialValue: selectedPaymentForm,
      items: widget.items
          .map((p) => DropdownMenuItem(value: p, child: Text(p)))
          .toList(),
      onChanged: (String? newValue) {
        setState(() => selectedPaymentForm = newValue);
        widget.onChanged(newValue); 
      },
    );
  }
}

class CustomDateCalendar extends StatefulWidget {
  final String label;
  final Function(String) onChanged;
  const CustomDateCalendar({
    super.key,
    required this.label,
    required this.onChanged,
  });
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
      String day = dateSelected.day.toString().padLeft(2, '0');
      String month = dateSelected.month.toString().padLeft(2, '0');
      String year = dateSelected.year.toString();
      String formatted = "$day/$month/$year";
      setState(() => _dateController.text = formatted);
      widget.onChanged(formatted); 
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
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: "Insira a ${widget.label}",
        filled: true,
        fillColor: Colors.white,
        suffix: const Icon(Icons.calendar_today),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
      validator: (value) =>
          (value == null || value.isEmpty) ? "Informe uma Data" : null,
    );
  }
}
