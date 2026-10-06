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

    final double calculatedMinX = spots.isEmpty ? -4.0 : spots.first.x;
    final double range = calculatedMinX.abs();

    double dynamicInterval;
    if (range > 720) {
      dynamicInterval = 240.0;
    } else if (range > 168) {
      dynamicInterval = 120.0;
    } else if (range > 48) {
      dynamicInterval = 48.0;
    } else if (range > 12) {
      dynamicInterval = 6.0;
    } else {
      dynamicInterval = 1.0;
    }

    return LineChart(
      LineChartData(
        minX: calculatedMinX,
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
              interval: dynamicInterval,
              getTitlesWidget: (value, meta) {
                if (value == 0) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text('Now', style: TextStyle(fontSize: 10, color: ColorsMain.textOnGradSecondary)),
                  );
                }

                final hours = value.abs().round();
                final days = hours ~/ 24;
                final String label = days > 0 ? '${days}d' : '${hours}h';

                return Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(label, style: const TextStyle(fontSize: 10, color: ColorsMain.textOnGradSecondary)),
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
            preventCurveOverShooting: true,
            color: ColorsMain.secondary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: ColorsMain.secondary.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }
}