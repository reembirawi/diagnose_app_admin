import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:diagnose_app/core/constants/app_colors.dart';
import 'package:diagnose_app/core/constants/app_strings.dart';
import 'package:diagnose_app/data/services/diagnosis_stats_service.dart';
import 'package:diagnose_app/presentation/widgets/state_card.dart';
import 'package:diagnose_app/presentation/widgets/diagnosis_bar.dart';
import 'package:diagnose_app/presentation/widgets/dashboard_card.dart';
import 'package:diagnose_app/presentation/widgets/pending_doctors_card.dart';
import 'package:diagnose_app/presentation/widgets/recent_users_card.dart';
import 'package:diagnose_app/presentation/widgets/weekly_scan_chart.dart';

class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            AppStrings.dashboardOverview,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
          ),
          Text(
            '${DateFormat('EEEE').format(DateTime.now())}, '
            '${DateFormat('MMMM d, y').format(DateTime.now())}',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 20),
          _StatCardsRow(),
          const SizedBox(height: 20),
          _ChartsRow(),
          const SizedBox(height: 20),
          const Row(
            children: [
              Expanded(child: PendingDoctorsCard()),
              SizedBox(width: 12),
              Expanded(child: RecentUsersCard()),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _StatCardsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final streams = [
      (
        AppStrings.scansThisMonth,
        '🔬',
        FirebaseFirestore.instance
            .collection(AppStrings.reportsCollection)
            .snapshots(),
      ),
      (
        AppStrings.doctors,
        '🩺',
        FirebaseFirestore.instance
            .collection(AppStrings.usersCollection)
            .where(AppStrings.roleField, isEqualTo: AppStrings.doctorRole)
            .where(AppStrings.statusField, isEqualTo: AppStrings.approvedStatus)
            .snapshots(),
      ),
      (
        AppStrings.users,
        '👥',
        FirebaseFirestore.instance
            .collection(AppStrings.usersCollection)
            .where(AppStrings.roleField, isEqualTo: AppStrings.userRole)
            .snapshots(),
      ),
      (
        AppStrings.pendingApprovals,
        '⏳',
        FirebaseFirestore.instance
            .collection(AppStrings.usersCollection)
            .where(AppStrings.roleField, isEqualTo: AppStrings.doctorRole)
            .where(AppStrings.statusField, isEqualTo: AppStrings.pendingStatus)
            .snapshots(),
      ),
    ];

    return LayoutBuilder(
      builder: (_, constraints) {
        final cardWidth = (constraints.maxWidth - 36) / 4;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: streams
              .map(
                (s) => SizedBox(
                  width: cardWidth,
                  child: StreamBuilder<QuerySnapshot>(
                    stream: s.$3,
                    builder: (_, snapshot) => StateCard(
                      title: s.$1,
                      count: snapshot.data?.docs.length ?? 0,
                      icon: s.$2,
                    ),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _ChartsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          flex: 6,
          child: DashboardCard(
            height: 240,
            child: Center(child: WeeklyScanChart()),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(flex: 3, child: _DiagnosisBreakdownCard()),
      ],
    );
  }
}

class _DiagnosisBreakdownCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      height: 240,
      child: StreamBuilder<DiagnosisStats>(
        stream: diagnosisStatsStream(),
        builder: (_, snapshot) {
          final stats =
              snapshot.data ??
              const DiagnosisStats(
                benign: 0,
                malignant: 0,
                notDiagnosed: 0,
                total: 0,
              );

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2,
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  AppStrings.aiDiagnosisBreakdown,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 12),
                DiagnosisBar(
                  label: AppStrings.benign,
                  count: stats.benign,
                  ratio: stats.benignRatio,
                  total: stats.total,
                ),
                const SizedBox(height: 10),
                DiagnosisBar(
                  label: AppStrings.malignant,
                  count: stats.malignant,
                  ratio: stats.malignantRatio,
                  total: stats.total,
                  color: AppColors.malignantColor,
                  trackColor: AppColors.malignantTrack,
                ),
                const SizedBox(height: 10),
                DiagnosisBar(
                  label: AppStrings.notDiagnosedYet,
                  count: stats.notDiagnosed,
                  ratio: stats.notDiagnosedRatio,
                  total: stats.total,
                  color: AppColors.neutralColor,
                  trackColor: AppColors.neutralTrack,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
