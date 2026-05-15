import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'dart:async';
import 'package:diagnose_app/models/report.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:diagnose_app/weekly_scan_chart.dart';

class DashboardHome extends StatefulWidget {
  const DashboardHome({super.key});

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> {


  final currentUserId = FirebaseAuth.instance.currentUser!.uid;
  List<Report> _reports = [];
  List<Report> _filteredReports = [];
  final List<Map<String, dynamic>> results = [
    {'name': 'Medium', 'value': 0.55},
    {'name': 'Normal', 'value': 0.25},
    {'name': 'Risky', 'value': 0.05},
    {'name': 'Not diagnosed yet', 'value': 0.15},
  ];
  Future<List<Report>> _getReports() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('reports').get();

      print("FOUND: ${snapshot.docs.length}");

      return snapshot.docs
          .map((doc) => Report.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      print("ERROR FETCHING REPORTS: $e");
      return [];
    }
  }

  @override
  void initState() {
    super.initState();

    _getReports().then((doc) {
      if (!mounted) return;
      setState(() {
        _reports = doc;
        _filteredReports = doc;
      });
    });
  }

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
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
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

              // _buildRow1(),
            ],
          ),
        ),
      ),
    );
  }

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
                stream: FirebaseFirestore.instance.collection('reports').snapshots(),
                builder: (context, snapshot) {
                  final count = snapshot.data?.docs.length ?? 0;
                  return _buildStatCard("Scans This Month", count, "🔬");
                },
              ),
            ),

            SizedBox(
              width: cardWidth,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('users')
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
                stream: FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'user').snapshots(),
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

  Widget _buildRow21() {
    return Row(
      children: [
        Flexible(
          flex: 6,
          child: _buildCard(
            240,
            child: Center(
              child: WeeklyScanChart(),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          flex: 3,
          child: Center(
            child: _buildCard(
              240,
              child: ListView.builder(
                padding: EdgeInsets.all(10),
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final result = results[index];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Row(
                          children: [
                            Text(
                              result['name'] as String,
                                style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Spacer(),
                            Text(
                                (100.0 * result['value']  as double).toStringAsFixed(1) + "%",
                                style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Stack(
                          children: [
                            Container(
                              height: 8,
                              width: 500,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 193, 194, 218),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),

                            Container(
                              height: 8,
                              width: 500 * result['value'] as double,
                              decoration: BoxDecoration(
                                color: const Color(0xFF4D51A2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                      ],
                    );
                  },
                ),
              )
          ),
        ),
      ],
    );
  }

  Widget _buildRow22() {
    return Row(
      children: [
        Expanded(child: 
          _buildCard(
            350,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users')
              .where('role', isEqualTo: 'doctor')
              .where('status', isEqualTo: 'pending')
              .snapshots(),
              builder: (context, snapshot) {
                final count = snapshot.data?.docs.length ?? 0;
                return Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          "Doctors Pending Approval",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                        ),
                        Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          alignment: Alignment.center,
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
                              "${count} waiting",
                              style: TextStyle(fontSize: 14, color: const Color.fromARGB(255, 155, 64, 41)),
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 20),
                      Container(
                        height: 250,
                        padding: const EdgeInsets.all(0),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: ListView.builder(
                            padding: EdgeInsets.zero, // ✅ removes default padding
                            itemCount: snapshot.data?.docs.length ?? 0,
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
                                      backgroundColor: const Color.fromARGB(255, 241, 225, 225),
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
                      )
                    ],
                  );
                }
              ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: 
          _buildCard(
            350,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'user').snapshots(),
              builder: (context, snapshot) {
                return Column(
                  mainAxisAlignment:MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      Text(
                        "Recent Users",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                      ),
                      SizedBox(height: 20),
                      Container(
                        height: 250,
                        padding: const EdgeInsets.all(0),
                        child: Align(
                          alignment: Alignment.topLeft,
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

                                  int scanCount = 0;

                                  if (reportSnapshot.hasData) {
                                    scanCount = reportSnapshot.data!.docs.length;
                                  }

                                  return Column(
                                    children: [
                                      ListTile(
                                        dense: true,
                                        contentPadding: EdgeInsets.zero,
                                        minLeadingWidth: 40,

                                        leading: CircleAvatar(
                                          radius: 18,
                                          backgroundColor:
                                              const Color.fromRGBO(221, 221, 255, 1),

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
                                                color: Color.from(alpha: 1, red: 0.302, green: 0.318, blue: 0.635),
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
                      )
                    ],
                  );
                }
              ),
          ),
        ),
      ],
    );
  }

  // Widget _buildRow1() {
  //   return Row(
  //     children: [
  //       Expanded(child: _buildCard(
  //         230,
  //         child: Text(
  //           "Card 1",
  //           style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
  //         ),
  //       )),
  //     ],
  //   );
  // }

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
            child: Text(
              icon,
              style: const TextStyle(fontSize: 20),
            ),
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
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}