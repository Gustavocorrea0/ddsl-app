class Movement {
  final double value;
  final String description;
  final String date;
  final String category;
  final String? type;
  final String? paymentMethod;

  Movement({
    required this.value,
    required this.description,
    required this.date,
    required this.category,
    this.type,
    this.paymentMethod,
  });

  @override
  String toString() {
    return 'Movement(value: $value, description: $description, date: $date, '
        'category: $category, type: $type, paymentMethod: $paymentMethod)';
  }
}