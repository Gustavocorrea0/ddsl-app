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

  Map<String, dynamic> toJson() {
    return {
      "value": value,
      "description": description,
      "date": date,
      "category": category,
      "type": type,
      "paymentMethod": paymentMethod,
    };
  }

  factory Movement.fromJson(Map<String, dynamic> json) {
    return Movement(
      value: (json["value"] as num).toDouble(),
      description: json["description"] as String,
      date: json["date"] as String,
      category: json["category"] as String,
      type: json["type"] as String?,
      paymentMethod: json["paymentMethod"] as String?,
    );
  }

  @override
  String toString() {
    return "Movement(value: $value, description: $description, date: $date, "
        "category: $category, type: $type, paymentMethod: $paymentMethod)";
  }

  DateTime? get parsedDate {
    final parts = date.split('/');
    if (parts.length != 3) return null;
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;
    return DateTime(year, month, day);
  }
}
