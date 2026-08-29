class ObjectiveMovement {
  final double value;
  final String type;
  final String date;

  ObjectiveMovement({
    required this.value,
    required this.type,
    required this.date,
  });

  double get signedValue => type == "Saida" ? -value : value;

  Map<String, dynamic> toJson() {
    return {"value": value, "type": type, "date": date};
  }

  factory ObjectiveMovement.fromJson(Map<String, dynamic> json) {
    return ObjectiveMovement(
      value: (json["value"] as num).toDouble(),
      type: json["type"] as String,
      date: json["date"] as String,
    );
  }
}
