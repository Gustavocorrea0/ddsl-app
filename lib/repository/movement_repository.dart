// lib/data/movement_repository.dart
import '../models/movement.dart';

class MovementRepository {
  MovementRepository._internal();
  static final MovementRepository instance = MovementRepository._internal();

  final List<Movement> movements = [];

  void add(Movement movement) {
    movements.add(movement);
  }
}