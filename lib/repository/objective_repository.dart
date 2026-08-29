// lib/data/objective_repository.dart
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/objective.dart';

class ObjectiveRepository extends ChangeNotifier {
  ObjectiveRepository._internal();
  static final ObjectiveRepository instance = ObjectiveRepository._internal();

  static const String _storageKey = 'objectives';
  final List<Objective> objectives = [];

  List<Objective> get objectivesSortedByDateDesc {
    final sorted = List<Objective>.from(objectives);
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

    objectives.clear();
    if (jsonList != null) {
      objectives.addAll(
        jsonList.map((jsonStr) => Objective.fromJson(jsonDecode(jsonStr))),
      );
    }
    notifyListeners();
  }

  Future<void> add(Objective objective) async {
    objectives.add(objective);
    await _saveStorage();
    notifyListeners();
  }

  Future<void> remove(Objective objective) async {
    objectives.remove(objective);
    await _saveStorage();
    notifyListeners();
  }

  Future<void> update(Objective objective) async {
    await _saveStorage();
    notifyListeners();
  }

  Future<void> _saveStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonList = objectives
        .map((o) => jsonEncode(o.toJson()))
        .toList();
    await prefs.setStringList(_storageKey, jsonList);
  }
}
