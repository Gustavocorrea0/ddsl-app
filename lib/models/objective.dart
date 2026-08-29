import 'objective_movement.dart';

class Objective {
  final String nameObjective;
  final String dateConclusao;
  final String completionDate;
  final double totalValue;
  double initialValue;
  final List<ObjectiveMovement> movements;

  Objective({
    required this.nameObjective,
    required this.dateConclusao,
    required this.completionDate,
    required this.totalValue,
    required this.initialValue,
    List<ObjectiveMovement>? movements,
  }) : movements = movements ?? [];

  void addMovement(ObjectiveMovement movement) {
    movements.add(movement);
    initialValue += movement.signedValue;
  }

  void removeMovement(ObjectiveMovement movement) {
    movements.remove(movement);
    initialValue -= movement.signedValue;
  }

  Map<String, dynamic> toJson() {
    return {
      "nameObjective": nameObjective,
      "dateConclusao": dateConclusao,
      "completionDate": completionDate,
      "totalValue": totalValue,
      "initialValue": initialValue,
      "movements": movements.map((m) => m.toJson()).toList(),
    };
  }

  factory Objective.fromJson(Map<String, dynamic> json) {
    return Objective(
      nameObjective: json["nameObjective"] as String,
      dateConclusao: json["dateConclusao"] as String,
      completionDate: json["completionDate"] as String,
      totalValue: (json["totalValue"]).toDouble(),
      initialValue: (json["initialValue"]).toDouble(),
      movements: (json["movements"] as List<dynamic>?)
          ?.map((m) => ObjectiveMovement.fromJson(m as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  String toString() {
    return "Objective(nameObjective: $initialValue, dateConclusao: $dateConclusao, completionDate: $completionDate,"
        "totalValue: $totalValue, initialValue: $initialValue)";
  }

  DateTime? get parsedDate {
    final parts = dateConclusao.split('/');
    if (parts.length != 3) return null;
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;
    return DateTime(year, month, day);
  }
}