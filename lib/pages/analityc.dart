import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/task_model.dart';

class AnalitycPage extends StatefulWidget {
  const AnalitycPage({super.key});

  @override
  State<AnalitycPage> createState() => _AnalitycPageState();
}

class _AnalitycPageState extends State<AnalitycPage> {
  Map<String, double> categoryData = {};
  int? touchedIndex;

  @override
  void initState() {
    super.initState();
    _loadCategoryData();
  }

  void _loadCategoryData() {
    final taskBox = Hive.box<TaskModel>('tasksBox');
    final tasks = taskBox.values.toList();

    Map<String, double> tempMap = {};
    for (var task in tasks) {
      tempMap[task.category] = (tempMap[task.category] ?? 0) + 1;
    }

    setState(() {
      categoryData = tempMap;
    });
  }

  @override
  Widget build(BuildContext context) {
    double totalValue = categoryData.values.fold(0, (a, b) => a + b);

    final List<PieChartSectionData> pieChartData =
        categoryData.entries.map((entry) {
      final index = categoryData.keys.toList().indexOf(entry.key);
      final isTouched = index == touchedIndex;
      final opacity = isTouched ? 1.0 : 0.6;
      final percentage = (entry.value / totalValue * 100).toStringAsFixed(1);
      final colors = [
        Colors.blue,
        Colors.green,
        Colors.orange,
        Colors.purple,
        Colors.red,
        Colors.cyan,
        Colors.brown,
      ];

      return PieChartSectionData(
        value: entry.value,
        title: isTouched ? '${entry.key}\n$percentage%' : entry.key,
        color: colors[index % colors.length].withOpacity(opacity),
        radius: isTouched ? 70 : 60,
        titleStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Breakdown',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: categoryData.isEmpty
          ? const Center(child: Text("Belum ada data aktivitas!"))
          : Center(
              child: PieChart(
                PieChartData(
                  sections: pieChartData,
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 0,
                  centerSpaceRadius: 40,
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (pieTouchResponse != null &&
                            pieTouchResponse.touchedSection
                                is! FlPointerExitEvent &&
                            pieTouchResponse.touchedSection
                                is! PointerUpEvent) {
                          touchedIndex = pieTouchResponse
                              .touchedSection!.touchedSectionIndex;
                        } else {
                          touchedIndex = null;
                        }
                      });
                    },
                  ),
                ),
              ),
            ),
    );
  }
}
