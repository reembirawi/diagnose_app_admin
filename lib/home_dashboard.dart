import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:diagnose_app/weekly_scan_chart.dart';
import 'package:diagnose_app/models/diagnosis_stats_service.dart';

class DashboardHome extends StatefulWidget {
  const DashboardHome({super.key});

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> {
  final currentUserId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topLeft,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dashboard Overview',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
              ),
              Text(
                "${DateFormat('EEEE').format(DateTime.now())}, "
                "${DateFormat('MMMM d, y').format(DateTime.now())}",
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              _buildRow4(),
              const SizedBox(height: 20),
              _buildRow21(),
              const SizedBox(height: 20),
              _buildRow22(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ── Row 1: four stat cards ───────────────────────────────────────────────

  Widget _buildRow4() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 36) / 4;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: cardWidth,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('reports')
                    .snapshots(),
                builder: (context, snapshot) {
                  final count = snapshot.data?.docs.length ?? 0;
                  return _buildStatCard("Scans This Month", count, "🔬");
                },
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where('role', isEqualTo: 'doctor')
                    .where('status', isEqualTo: 'approved')
                    .snapshots(),
                builder: (context, snapshot) {
                  final count = snapshot.data?.docs.length ?? 0;
                  return _buildStatCard("Doctors", count, "🩺");
                },
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where('role', isEqualTo: 'user')
                    .snapshots(),
                builder: (context, snapshot) {
                  final count = snapshot.data?.docs.length ?? 0;
                  return _buildStatCard("Users", count, "👥");
                },
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where('role', isEqualTo: 'doctor')
                    .where('status', isEqualTo: 'pending')
                    .snapshots(),
                builder: (context, snapshot) {
                  final count = snapshot.data?.docs.length ?? 0;
                  return _buildStatCard("Pending Approvals", count, "⏳");
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // ── Row 2: weekly chart + live diagnosis breakdown ───────────────────────

  Widget _buildRow21() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          flex: 6,
          child: _buildCard(240, child: Center(child: WeeklyScanChart())),
        ),
        const SizedBox(width: 12),
        Flexible(
          flex: 3,
          child: _buildCard(
            240,
            child: StreamBuilder<DiagnosisStats>(
              stream: diagnosisStatsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF4D51A2),
                      strokeWidth: 2,
                    ),
                  );
                }

                final stats =
                    snapshot.data ??
                    const DiagnosisStats(
                      benign: 0,
                      malignant: 0,
                      notDiagnosed: 0,
                      total: 0,
                    );

                return Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'AI Diagnosis Breakdown',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2D2F6B),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _diagnosisBar(
                        label: 'Benign',
                        count: stats.benign,
                        ratio: stats.benignRatio,
                        total: stats.total,
                      ),
                      const SizedBox(height: 10),
                      _diagnosisBar(
                        label: 'Malignant',
                        count: stats.malignant,
                        ratio: stats.malignantRatio,
                        total: stats.total,
                        color: const Color(0xFFD85A30),
                        trackColor: const Color.fromARGB(255, 240, 200, 185),
                      ),
                      const SizedBox(height: 10),
                      _diagnosisBar(
                        label: 'Not diagnosed yet',
                        count: stats.notDiagnosed,
                        ratio: stats.notDiagnosedRatio,
                        total: stats.total,
                        color: const Color(0xFF888780),
                        trackColor: const Color.fromARGB(255, 210, 210, 205),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  /// One labelled progress bar row for the diagnosis breakdown panel.
  Widget _diagnosisBar({
    required String label,
    required int count,
    required double ratio,
    required int total,
    Color color = const Color(0xFF4D51A2),
    Color trackColor = const Color.fromARGB(255, 193, 194, 218),
  }) {
    final pct = total == 0 ? '—' : '${(ratio * 100).toStringAsFixed(1)}%';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              total == 0 ? '—' : '$count  ($pct)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LayoutBuilder(
          builder: (context, constraints) => Stack(
            children: [
              Container(
                height: 8,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: trackColor,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              Container(
                height: 8,
                width: constraints.maxWidth * ratio,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Row 3: pending doctors + recent users ────────────────────────────────

  Widget _buildRow22() {
    return Row(
      children: [
        Expanded(child: _buildPendingDoctorsCard()),
        const SizedBox(width: 12),
        Expanded(child: _buildRecentUsersCard()),
      ],
    );
  }

  Widget _buildPendingDoctorsCard() {
    return _buildCard(
      350,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'doctor')
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {
          final count = snapshot.data?.docs.length ?? 0;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    "Doctors Pending Approval",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    height: 30,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 236, 176, 161),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      "$count waiting",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color.fromARGB(255, 155, 64, 41),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 250,
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: count,
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    final name = doc['name'] ?? 'Unknown';
                    final email = doc['email'] ?? 'Unknown';
                    return Column(
                      children: [
                        ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: const Color.fromARGB(
                              255,
                              241,
                              225,
                              225,
                            ),
                            child: Text(
                              name.isNotEmpty ? name[0] : '?',
                              style: const TextStyle(color: Color(0xFF4D51A2)),
                            ),
                          ),
                          title: Text(
                            "Dr. $name",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          subtitle: Text(email),
                        ),
                        const Divider(),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRecentUsersCard() {
    return _buildCard(
      350,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'user')
            .snapshots(),
        builder: (context, snapshot) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Recent Users",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 250,
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: snapshot.data?.docs.length ?? 0,
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    final name = doc['name'] ?? 'Unknown';
                    final email = doc['email'] ?? 'Unknown';

                    return FutureBuilder<QuerySnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('reports')
                          .where('userId', isEqualTo: doc.id)
                          .get(),
                      builder: (context, reportSnapshot) {
                        final scanCount = reportSnapshot.data?.docs.length ?? 0;
                        return Column(
                          children: [
                            ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              minLeadingWidth: 40,
                              leading: CircleAvatar(
                                radius: 18,
                                backgroundColor: const Color.fromRGBO(
                                  221,
                                  221,
                                  255,
                                  1,
                                ),
                                child: Text(
                                  name.isNotEmpty ? name[0] : '?',
                                  style: const TextStyle(
                                    color: Color.fromRGBO(77, 81, 162, 100),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      name,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    "$scanCount scans",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color.fromRGBO(77, 81, 162, 1),
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Text(email),
                            ),
                            const Divider(),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Shared card shell ────────────────────────────────────────────────────

  Widget _buildCard(double height, {required Widget child}) {
    return Container(
      width: double.infinity,
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ── Top-level stat card (unchanged from original) ────────────────────────────

Widget _buildStatCard(String title, int count, String icon) {
  return Container(
    height: 200,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(4),
            height: 50,
            width: 50,
            decoration: const BoxDecoration(
              color: Color.from(alpha: 0.2, red: 1, green: 0.859, blue: 0.498),
            ),
            child: Text(icon, style: const TextStyle(fontSize: 20)),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color.fromRGBO(158, 158, 158, 0.8),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "$count",
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );
}
