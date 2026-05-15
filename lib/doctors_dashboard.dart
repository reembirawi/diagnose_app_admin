import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'dart:async';
import 'package:diagnose_app/models/report.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:diagnose_app/weekly_scan_chart.dart';
import 'package:diagnose_app/filter_tabs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class DoctorsDashboard extends StatefulWidget {
  const DoctorsDashboard({super.key});

  @override
  State<DoctorsDashboard> createState() => _DoctorsDashboardState();
}

class _DoctorsDashboardState extends State<DoctorsDashboard> {

  final currentUserId = FirebaseAuth.instance.currentUser!.uid;
  List<Report> _reports = [];
  List<Report> _filteredReports = [];
  String filterTab = "All";
  String sortOption = "Name A–Z";

  final List<String> sortOptions = [
    "Name A–Z",
    "Name Z–A",
    "Rating High–Low",
    "Rating Low–High",
  ];

  Future<List<Report>> _getReports() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('reports').get();

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

  Stream<QuerySnapshot> _buildStream() {
    final base = FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'doctor');

    switch (filterTab) {
      case 'Active':
        return base.where('status', isEqualTo: 'approved').snapshots();
      case 'Pending':
        return base.where('status', isEqualTo: 'pending').snapshots();
      case 'Suspended':
        return base.where('status', isEqualTo: 'suspended').snapshots();
      default:
        return base.snapshots();
    }
  }

  String formatDate(DateTime? date) {
    if (date == null) return "Not set";
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }
  /// Rating = completed scans / (completed + remaining scans)
  double _computeRating(Map<String, dynamic> data) {
    final completed = (data['scans_done'] ?? 0) as num;
    final remaining = (data['scans_remaining'] ?? 0) as num;
    final total = completed + remaining;
    if (total == 0) return 0;
    return completed / total;
  }

  List<QueryDocumentSnapshot> _sortDoctors(List<QueryDocumentSnapshot> docs) {
    final sorted = List<QueryDocumentSnapshot>.from(docs);
    switch (sortOption) {
      case "Name A–Z":
        sorted.sort((a, b) {
          final aName = ((a.data() as Map<String, dynamic>)['name'] ?? '') as String;
          final bName = ((b.data() as Map<String, dynamic>)['name'] ?? '') as String;
          return aName.toLowerCase().compareTo(bName.toLowerCase());
        });
        break;
      case "Name Z–A":
        sorted.sort((a, b) {
          final aName = ((a.data() as Map<String, dynamic>)['name'] ?? '') as String;
          final bName = ((b.data() as Map<String, dynamic>)['name'] ?? '') as String;
          return bName.toLowerCase().compareTo(aName.toLowerCase());
        });
        break;
      case "Rating High–Low":
        sorted.sort((a, b) {
          final aR = _computeRating(a.data() as Map<String, dynamic>);
          final bR = _computeRating(b.data() as Map<String, dynamic>);
          return bR.compareTo(aR);
        });
        break;
      case "Rating Low–High":
        sorted.sort((a, b) {
          final aR = _computeRating(a.data() as Map<String, dynamic>);
          final bR = _computeRating(b.data() as Map<String, dynamic>);
          return aR.compareTo(bR);
        });
        break;
    }
    return sorted;
  }

  Widget _buildDoctorsGrid(List<QueryDocumentSnapshot> doctors) {
    final sorted = _sortDoctors(doctors);
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 20) / 3;
        return Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: sorted.map((doc) {
              final doctorData = doc.data() as Map<String, dynamic>;
              return SizedBox(
                width: cardWidth,
                child: _buildDoctorCard(doctorData, doc.id),
              );
            }).toList(),
          ),
        );
      },
    );
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
                'Doctors Dashboard',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const Text(
                "Manage all registered doctors and approvals",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 20),

              _buildRow4(),

              const SizedBox(height: 20),
              const Divider(
                color: Colors.black,
                thickness: 2,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  // Search bar
                  Flexible(
                    flex: 5,
                    child: SearchBar(
                      constraints: const BoxConstraints(
                        minHeight: 40,
                        maxHeight: 40,
                      ),
                      shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(
                            color: Color.fromARGB(255, 149, 152, 209),
                          ),
                        ),
                      ),
                      leading: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(
                          Icons.search,
                          color: Color(0xFF4D51A2),
                          size: 18,
                        ),
                      ),
                      backgroundColor: const WidgetStatePropertyAll<Color>(
                        Color.fromARGB(255, 255, 255, 255),
                      ),
                      shadowColor: const WidgetStatePropertyAll<Color>(
                        Color.fromARGB(46, 0, 0, 0),
                      ),
                      hintText: "Search doctors...",
                      hintStyle: const WidgetStatePropertyAll<TextStyle>(
                        TextStyle(
                          color: Color.fromARGB(174, 62, 57, 57),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Filter tabs
                  Flexible(
                    flex: 4,
                    child: FilterTabs(
                      selected: filterTab,
                      onChanged: (value) {
                        setState(() {
                          filterTab = value;
                        });
                      },
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Sort dropdown
                  Flexible(
                    flex: 2,
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color.fromARGB(255, 149, 152, 209),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: sortOption,
                          icon: const Icon(
                            Icons.unfold_more,
                            size: 16,
                            color: Color(0xFF4D51A2),
                          ),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1A1A2E),
                          ),
                          isExpanded: true,
                          items: sortOptions.map((option) {
                            return DropdownMenuItem<String>(
                              value: option,
                              child: Text(
                                option,
                                style: const TextStyle(fontSize: 12),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                sortOption = value;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              StreamBuilder<QuerySnapshot>(
                stream: _buildStream(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final doctors = snapshot.data!.docs;

                  if (doctors.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(
                        child: Text(
                          'No doctors found.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    );
                  }

                  return _buildDoctorsGrid(doctors);
                },
              ),
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
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where('role', isEqualTo: 'doctor')
                    .snapshots(),
                builder: (context, snapshot) {
                  final count = snapshot.data?.docs.length ?? 0;
                  return _buildStatCard("Total Doctors", count);
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
                  return _buildStatCard("Approved Doctors", count);
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
                  return _buildStatCard("Pending Approvals", count);
                },
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where('role', isEqualTo: 'doctor')
                    .where('status', isEqualTo: 'suspended')
                    .snapshots(),
                builder: (context, snapshot) {
                  final count = snapshot.data?.docs.length ?? 0;
                  return _buildStatCard("Suspended Doctors", count);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDoctorCard(Map<String, dynamic> doctorData, String docId) {
    final name = doctorData['name'] ?? 'No Name';
    final secondName = doctorData['secondName'] ?? '';
    final email = doctorData['email'] ?? 'No Email';
    final gender = doctorData['gender'] ?? 'No Gender';
    final birthDate = doctorData['birthDate'];
    final location = doctorData['location'] ?? 'Unknown';
    final status = doctorData['status'] ?? 'pending';
    final yearsExp = doctorData['years_experience'] ?? 0;
    final scansDone = (doctorData['scans_done'] ?? 0) as num;
    final scansRemaining = (doctorData['scans_remaining'] ?? 0) as num;
    final appliedAt = doctorData['created_at'] != null
        ? (doctorData['created_at'] as Timestamp).toDate()
        : null;
    final licenseVerified = doctorData['license_verified'] ?? false;
    final certificateUrl = doctorData['certificateUrl'];


    // Rating = completed / total
    final totalScans = scansDone + scansRemaining;
    final ratingValue = totalScans > 0 ? scansDone / totalScans : 0.0;
    final ratingDisplay = totalScans > 0
        ? '${(ratingValue * 100).toStringAsFixed(0)}%'
        : '—';

    final initials = name
        .split(' ')
        .where((String w) => w.isNotEmpty)
        .take(2)
        .map((String w) => w[0].toUpperCase())
        .join();

    Color statusColor;
    String statusLabel;
    switch (status) {
      case 'approved':
        statusColor = const Color(0xFF22C55E);
        statusLabel = 'Active';
        break;
      case 'pending':
        statusColor = const Color(0xFFF59E0B);
        statusLabel = 'Pending';
        break;
      case 'suspended':
        statusColor = const Color.fromARGB(255, 189, 54, 54);
        statusLabel = 'Suspended';
        break;
      default:
        statusColor = Colors.grey;
        statusLabel = status;
    }

    String timeAgo = '';
    if (appliedAt != null) {
      final diff = DateTime.now().difference(appliedAt);
      if (diff.inDays > 0) {
        timeAgo = '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
      } else if (diff.inHours > 0) {
        timeAgo = '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
      } else {
        timeAgo = 'Just now';
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E8F0), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header: Avatar + Name + Status badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A2E),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 11, color: Color(0xFF9CA3AF)),
                        const SizedBox(width: 2),
                        Flexible(
                          child: Text(
                            location,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF9CA3AF),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withOpacity(0.4)),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Stats row
          Row(
            children: [
              Expanded(child: _buildStatItem('$yearsExp', 'Years exp.')),
              Container(width: 1, height: 30, color: const Color(0xFFE8E8F0)),
              Expanded(child: _buildStatItem('$scansDone', 'Scans done')),
              Container(width: 1, height: 30, color: const Color(0xFFE8E8F0)),
              Expanded(child: _buildStatItem(ratingDisplay, 'Rating')),
            ],
          ),

          const SizedBox(height: 10),

          // Applied info
          if (timeAgo.isNotEmpty || licenseVerified)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  if (timeAgo.isNotEmpty)
                    Text(
                      'Applied $timeAgo',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  if (timeAgo.isNotEmpty && licenseVerified)
                    const Text(
                      ' · ',
                      style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                    ),
                  if (licenseVerified)
                    const Text(
                      'License verified',
                      style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                    ),
                ],
              ),
            ),

          // Action buttons
          Row(
            children: [
              // View profile — always visible
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return Dialog(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: 500,
                              maxHeight: 750,
                            ),
                            child: SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.all(18),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // CLOSE BUTTON
                                    Align(
                                      alignment: Alignment.topRight,
                                      child: IconButton(
                                        icon: const Icon(Icons.close),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                    ),

                                    // AVATAR
                                    Container(
                                      height: 110,
                                      width: 110,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF4D51A2),
                                            Color(0xFF7B7FC4),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      child: const Icon(
                                        Icons.person,
                                        size: 70,
                                        color: Colors.white,
                                      ),
                                    ),

                                    const SizedBox(height: 15),

                                    // NAME
                                    Text(
                                      '$name $secondName',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 6),

                                    // EMAIL
                                    Text(
                                      email,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),

                                    const SizedBox(height: 18),
                                    const Divider(),

                                    // INFO CARD
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(18),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(18),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.08),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        children: [
                                          _infoCard(Icons.wc, "Gender", gender),
                                          const Divider(
                                            height: 1,
                                            thickness: 1,
                                            color: Color(0xFFF0F0F8),
                                          ),
                                          _infoCard(
                                            Icons.cake,
                                            "Date of Birth",
                                            formatDate(
                                              (birthDate as Timestamp?)?.toDate(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 18),

                                    // CERTIFICATE SECTION
                                    if (certificateUrl != null &&
                                        certificateUrl.toString().isNotEmpty)
                                      GestureDetector(
                                        onTap: () {
                                          // FULLSCREEN VIEW
                                          showDialog(
                                            context: context,
                                            builder: (_) => Dialog(
                                              child: InteractiveViewer(
                                                child: Image.network(certificateUrl),
                                              ),
                                            ),
                                          );
                                        },
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Image.network(
                                            certificateUrl,
                                            height: 200,
                                            fit: BoxFit.contain,
                                            loadingBuilder:
                                                (context, child, progress) {
                                              if (progress == null) return child;
                                              return const Padding(
                                                padding: EdgeInsets.all(20),
                                                child: CircularProgressIndicator(),
                                              );
                                            },
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return const Text(
                                                "Failed to load certificate",
                                              );
                                            },
                                          ),
                                        ),
                                      )
                                    else
                                      const Text("No certificate uploaded"),
                                    const SizedBox(height: 18),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF6366F1),
                    side: const BorderSide(color: Color(0xFFE8E8F0)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'View profile',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              // Pending: Approve + Reject
              if (status == 'pending') ...[
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(docId)
                          .update({'status': 'approved'});
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Approve',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 36,
                  height: 36,
                  child: OutlinedButton(
                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(docId)
                          .update({'status': 'suspended'});
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFEF4444),
                      side: const BorderSide(color: Color(0xFFFFE4E4)),
                      backgroundColor: const Color(0xFFFFF5F5),
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Icon(Icons.close, size: 16),
                  ),
                ),
              ],

              // Approved: Suspend button
              if (status == 'approved') ...[
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(docId)
                          .update({'status': 'suspended'});
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Suspend',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],

              // Suspended: Reinstate button
              if (status == 'suspended') ...[
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(docId)
                          .update({'status': 'approved'});
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF22C55E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Reinstate',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _infoCard(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              gradient: LinearGradient(
                colors: [Color(0xFF4D51A2), Color(0xFF7B7FC4)],
              ),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text("$value", style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}
Widget _buildStatCard(String title, int count) {
  return Container(
    height: 150,
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