// lib/data/movement_repository.dart
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/movement.dart';

class MovementRepository extends ChangeNotifier {
  MovementRepository._internal();
  static final MovementRepository instance = MovementRepository._internal();

  static const String _storageKey = 'movements';
  final List<Movement> movements = [];

  double get totalEntradas =>
      movements.where((m) => m.value >= 0).fold(0.0, (sum, m) => sum + m.value);

  double get totalSaidas => movements
      .where((m) => m.value < 0)
      .fold(0.0, (sum, m) => sum + m.value.abs());

  double get saldo => totalEntradas - totalSaidas;

  List<Movement> get movementsSortedByDateDesc {
    final sorted = List<Movement>.from(movements);
    sorted.sort((a, b) {
      final dateA = a.parsedDate;
      final dateB = b.parsedDate;
      if (dateA == null && dateB == null) return 0;
      if (dateA == null) return 1;
      if (dateB == null) return -1;
      return dateB.compareTo(dateA);
    });
    return sorted;
  }

  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? jsonList = prefs.getStringList(_storageKey);

    movements.clear();
    if (jsonList != null) {
      movements.addAll(
        jsonList.map((jsonStr) => Movement.fromJson(jsonDecode(jsonStr))),
      );
    }
    notifyListeners();
  }

  Future<void> add(Movement movement) async {
    movements.add(movement);
    await _saveStorage();
    notifyListeners();
  }

  Future<void> remove(Movement movement) async {
    movements.remove(movement);
    await _saveStorage();
    notifyListeners();
  }

  Future<void> _saveStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonList = movements
        .map((m) => jsonEncode(m.toJson()))
        .toList();
    await prefs.setStringList(_storageKey, jsonList);
  }
}
