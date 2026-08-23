// lib/data/movement_repository.dart
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/movement.dart';

class MovementRepository {

  MovementRepository._internal();
  static final MovementRepository instance = MovementRepository._internal();
  
  static const String _storageKey = 'movements';
  final List<Movement> movements = [];
  
  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? jsonList = prefs.getStringList(_storageKey);

    movements.clear();
    if (jsonList != null) {
      movements.addAll(
        jsonList.map((jsonStr) => Movement.fromJson(jsonDecode(jsonStr))),
      );
    }
  }

  Future<void> add(Movement movement) async {
    movements.add(movement);
    await _saveStorage();
  }

  Future<void> remove(Movement movement) async {
    movements.remove(movement);
    await _saveStorage();
  }

  Future<void> _saveStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonList = movements.map((m) => jsonEncode(m.toJson())).toList();
    await prefs.setStringList(_storageKey, jsonList);
  }

}