import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import 'cardsysstruct.dart';
import '../colors.dart';


class MoistureChart extends StatelessWidget {
  final List<MoistureEvent> history;
  const MoistureChart({Key? key, required this.history}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return const Center(
        child: Text(
          "No moisture history available.",
          style: TextStyle(color: ColorsMain.textOnGradSecondary),
        ),
      );
    }

    final sortedHistory = List<MoistureEvent>.from(history)..sort((a, b) => a.time.compareTo(b.time));

    final now = DateTime.now();
    final spots = sortedHistory.map((event) {
      final hoursAgo = double.parse((event.time.difference(now).inMinutes / 60.0).toStringAsFixed(1));
      return FlSpot(hoursAgo, event.moisture);
    }).toList();

    return LineChart(
      LineChartData(
        minX: -4.0,
        maxX: 0.0,
        minY: 0.0,
        maxY: 100.0,

        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 20,
          getDrawingHorizontalLine: (value) {
            return const FlLine(
              color: ColorsMain.borderGlass,
              strokeWidth: 1,
            );
          },
        ),

        borderData: FlBorderData(show: false),

        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                if (value != value.roundToDouble()) {
                  return const SizedBox.shrink();
                }

                if (value == 0) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text('Now', style: TextStyle(fontSize: 10, color: ColorsMain.textOnGradSecondary)),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text('${value.abs().toInt()}h', style: const TextStyle(fontSize: 10, color: ColorsMain.textOnGradSecondary)),
                );
              },
            ),
          ),

          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 25,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text('${value.toInt()}%', style: const TextStyle(fontSize: 10, color: ColorsMain.textOnGradSecondary));
              },
            ),
          ),
        ),

        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: ColorsMain.secondary,
            barWidth: 5, // Increased from 3
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),

            // Add a shadow to create depth against the background
            shadow: const Shadow(
              color: Colors.black45,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),

            belowBarData: BarAreaData(
              show: true,
              color: ColorsMain.secondary.withOpacity(0.3), // Slightly more opaque
            ),
          ),
        ],

      ),
    );
  }
}