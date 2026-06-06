import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:diagnose_app/bar_graph.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WeeklyScanChart extends StatefulWidget {
  const WeeklyScanChart({super.key});

  @override
  State<WeeklyScanChart> createState() => _WeeklyScanChartState();
}

class _WeeklyScanChartState extends State<WeeklyScanChart> {
  List<int> weeklySummary = [0, 0, 0, 0, 0, 0, 0];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // This week's Sunday to Saturday
    final thisWeekSunday = today.subtract(Duration(days: today.weekday % 7));
    final thisWeekSaturday = thisWeekSunday.add(
      const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
    );

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('reports')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final counts = List<int>.filled(7, 0);

          for (final doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;

            // ✅ createdAt is nested inside 'request'
            final request = data['request'] as Map<String, dynamic>?;
            final raw = request?['createdAt'];

            if (raw is String) {
              final date = DateTime.tryParse(raw);
              if (date != null) {
                if (date.isAfter(thisWeekSunday.subtract(const Duration(seconds: 1))) &&
                    date.isBefore(thisWeekSaturday.add(const Duration(seconds: 1)))) {
                  final dayIndex = date.weekday % 7; // Sun=0, Mon=1 ... Sat=6
                  counts[dayIndex]++;
                }
              }
            }
          }

          weeklySummary = counts;
        }

        return BarGraph(weeklySummary: weeklySummary);
      },
    );
  }
}