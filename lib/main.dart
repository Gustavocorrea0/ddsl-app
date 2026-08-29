// ignore_for_file: prefer_interpolation_to_compose_strings
import 'package:ddsl_app/models/movement.dart';
import 'package:ddsl_app/models/objective.dart';
import 'package:ddsl_app/repository/movement_repository.dart';
import 'package:ddsl_app/repository/objective_repository.dart';
import 'package:ddsl_app/view/DetailMovementScreen.dart';
import 'package:ddsl_app/view/DetailObjectiveScreen.dart';
import 'package:ddsl_app/view/HomeScreen.dart';
import 'package:ddsl_app/view/NewMovementScreen.dart';
import 'package:ddsl_app/view/NewObjectiveScreen.dart';
import 'package:ddsl_app/view/ObjectiveScreen.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MovementRepository.instance.loadFromStorage();
  await ObjectiveRepository.instance.loadFromStorage();
  runApp(const DDSLApp());
}

class DDSLApp extends StatefulWidget {
  const DDSLApp({super.key});
  @override
  State<DDSLApp> createState() => _DDSLAppState();
}

class _DDSLAppState extends State<DDSLApp> {
  List<IconData> iconsList = [Icons.home, Icons.add, Icons.rocket_launch];
  List<String> iconsNames = ["Home", "Novo", "Metas"];
  int indexSelectTab = 0;
  Movement? _selectedMovement;
  Objective? _selectedObjective;
  bool _isCreatingObjective = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            IndexedStack(
              index: indexSelectTab,
              children: [
                HomeScreen(
                  onMovementTap: (movement) {
                    setState(() {
                      _selectedMovement = movement;
                    });
                  },
                ),
                const NewMovementScreen(),
                ObjectiveScreen(
                  onNewObjective: () =>
                      setState(() => _isCreatingObjective = true),
                  onObjectiveTap: (objective) {
                    setState(() {
                      _selectedObjective = objective;
                    });
                  },
                ),
              ],
            ),
            if (_selectedMovement != null)
              Positioned.fill(
                child: DetailMovementScreen(
                  movement: _selectedMovement!,
                  onClose: () => setState(() => _selectedMovement = null),
                ),
              ),
            if (_selectedObjective != null)
              Positioned.fill(
                child: DetailObjectiveScreen(
                  objective: _selectedObjective!,
                  onClose: () => setState(() => _selectedObjective = null),
                ),
              ),
            if (_isCreatingObjective)
              Positioned.fill(
                child: NewObjectiveScreen(
                  onClose: () => setState(() => _isCreatingObjective = false),
                ),
              ),
            Align(alignment: Alignment.bottomCenter, child: _navBar()),
          ],
        ),
      ),
    );
  }

  Widget _navBar() {
    return Container(
      height: 65,
      width: 300,
      margin: const EdgeInsets.only(right: 24, left: 24, bottom: 24),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 20,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: iconsList.map((icon) {
          int index = iconsList.indexOf(icon);
          bool isSelected = indexSelectTab == index;
          return Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  indexSelectTab = index;
                  _selectedMovement = null;
                  _selectedObjective = null;
                  _isCreatingObjective = false;
                });
              },
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(
                      top: 15,
                      bottom: 0,
                      left: 35,
                      right: 35,
                    ),
                    child: Icon(
                      icon,
                      color: isSelected ? Colors.green : Colors.white,
                    ),
                  ),
                  Text(
                    iconsNames[index],
                    style: TextStyle(
                      color: isSelected ? Colors.green : Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
