import 'package:diagnose_app/models/bar_data.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BarGraph extends StatelessWidget {
  const BarGraph({super.key, required this.weeklySummary});

  final List<int> weeklySummary;

  @override
  Widget build(BuildContext context) {
    BarData myBarData = BarData(
      sunAmount: weeklySummary[0],
      monAmount: weeklySummary[1],
      tueAmount: weeklySummary[2],
      wedAmount: weeklySummary[3],
      thurAmount: weeklySummary[4],
      friAmount: weeklySummary[5],
      satAmount: weeklySummary[6],
    );

    myBarData.initializeBarData();

    return BarChart(
      BarChartData(
        maxY: 30,
        minY: 0,
        barTouchData: BarTouchData(
          enabled: true,
          handleBuiltInTouches: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => const Color.from(
              alpha: 0.5,
              red: 0.404,
              green: 0.42,
              blue: 0.761,
            ),
            tooltipPadding: const EdgeInsets.all(8),
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: false,
            ), // 👈 hides the top numbers
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

                return Text(
                  days[value.toInt()],
                  style: const TextStyle(fontSize: 12),
                );
              },
            ),
          ),
        ),
        barGroups: myBarData.barData.map((data) {
          return BarChartGroupData(
            x: data.x,
            barRods: [
              BarChartRodData(
                toY: data.y.toDouble(),
                color: Color.fromRGBO(77, 81, 162, 100),
                width: 100,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
                borderSide: const BorderSide(
                  color: Color.fromRGBO(44, 46, 92, 0.612),
                  width: 2,
                ),
              ),
            ],
          );
        }).toList(),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 5,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.withOpacity(0.6),
            strokeWidth: 1,
            dashArray: [5, 5],
          ),
        ),
        borderData: FlBorderData(show: false),
      ), // BarChartData
    );
  }
}
