import 'package:ddsl_app/models/objective.dart';
import 'package:ddsl_app/repository/objective_repository.dart';
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

class NewObjectiveScreen extends StatefulWidget {
  final VoidCallback? onClose;
  const NewObjectiveScreen({super.key, this.onClose});
  @override
  State<NewObjectiveScreen> createState() => _NewObjectiveScreen();
}

class _NewObjectiveScreen extends State<NewObjectiveScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _totalValueController = TextEditingController();
  final TextEditingController _initialValueController =
      TextEditingController();
  String? _conclusionDate;
  int _formResetCounter = 0;

  double _parseCurrency(String text) {
    return double.tryParse(
          text.replaceAll('.', '').replaceAll(',', '.'),
        ) ??
        0.0;
  }

  void _clearFields() {
    setState(() {
      _titleController.clear();
      _totalValueController.clear();
      _initialValueController.clear();
      _conclusionDate = null;
      _formResetCounter++;
    });
  }

  Future<void> _saveObjective() async {
    String title = _titleController.text;
    String totalValueText = _totalValueController.text;
    String initialValueText = _initialValueController.text;

    if (title.isEmpty || _conclusionDate == null || totalValueText.isEmpty) {
      return;
    }

    final objective = Objective(
      nameObjective: title,
      dateConclusao: _conclusionDate!,
      completionDate: _conclusionDate!,
      totalValue: _parseCurrency(totalValueText),
      initialValue: _parseCurrency(initialValueText),
    );

    await ObjectiveRepository.instance.add(objective);

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
    _titleController.dispose();
    _totalValueController.dispose();
    _initialValueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            height: 480 + topInset,
            child: Stack(
              children: [
                GreenRectangle(
                  titlePage: "Novo Objetivo",
                  heightBlockTitle: headerHeight,
                  topTextTitle: -0.1,
                  fontSizeTitle: 30,
                ),
                if (widget.onClose != null)
                  Positioned(
                    top: MediaQuery.of(context).padding.top,
                    left: 4,
                    child: IconButton(
                      onPressed: widget.onClose,
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                Positioned(
                  top: topInset + 30,
                  left: 20,
                  right: 20,
                  child: SizedBox(
                    width: 370,
                    child: TextFormField(
                      controller: _titleController,
                      maxLength: 20,
                      decoration: const InputDecoration(
                        labelText: "Objetivo",
                        hintText: "Qual é o Seu Objetivo?",
                        counterText: "",
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
                  top: topInset + 100,
                  left: 20,
                  right: 20,
                  child: CustomDateCalendar(
                    key: ValueKey('date_$_formResetCounter'),
                    label: "Data de Conclusão",
                    hintText: "Qual a data de Conclusão?",
                    onChanged: (value) {
                      setState(() {
                        _conclusionDate = value;
                      });
                    },
                  ),
                ),
                Positioned(
                  top: topInset + 170,
                  left: 20,
                  right: 20,
                  child: SizedBox(
                    width: 370,
                    child: TextFormField(
                      controller: _totalValueController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [_CurrencyInputFormatter()],
                      decoration: const InputDecoration(
                        labelText: "Valor Total",
                        hintText: "Qual é o Valor Total?",
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
                  top: topInset + 240,
                  left: 20,
                  right: 20,
                  child: SizedBox(
                    width: 370,
                    child: TextFormField(
                      controller: _initialValueController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [_CurrencyInputFormatter()],
                      decoration: const InputDecoration(
                        labelText: "Valor Inicial",
                        hintText: "Qual e o Valor Inicial?",
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
                  top: topInset + 320,
                  left: 10,
                  right: 20,
                  child: Center(
                    child: ElevatedButton(
                      onPressed: () {
                        _saveObjective();
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

class CustomDateCalendar extends StatefulWidget {
  final String label;
  final String? hintText;
  final Function(String) onChanged;
  const CustomDateCalendar({
    super.key,
    required this.label,
    this.hintText,
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
    return SizedBox(
      width: 370,
      child: TextFormField(
        controller: _dateController,
        readOnly: true,
        onTap: () => _selectDate(context),
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hintText ?? "Insira a ${widget.label}",
          filled: true,
          fillColor: Colors.white,
          suffix: const Icon(Icons.calendar_today),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
        validator: (value) =>
            (value == null || value.isEmpty) ? "Informe uma Data" : null,
      ),
    );
  }
}
