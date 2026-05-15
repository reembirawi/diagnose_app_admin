import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:diagnose_app/models/report.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UsersDashboard extends StatefulWidget {
  const UsersDashboard({super.key});

  @override
  State<UsersDashboard> createState() => _UsersDashboardState();
}

class _UsersDashboardState extends State<UsersDashboard> {
  final currentUserId = FirebaseAuth.instance.currentUser!.uid;

  List<Report> _allReports = [];
  String _searchQuery = '';
  String _sortOption = "Name A–Z";

  final TextEditingController _searchController = TextEditingController();

  // ─── Age calculator ──────────────────────────────────────────────────────────

  int _calculateAge(dynamic birthDate) {
    if (birthDate == null) return 0;
    if (birthDate is! Timestamp) return 0;
    final dob = birthDate.toDate();
    final today = DateTime.now();
    int age = today.year - dob.year;
    if (today.month < dob.month ||
        (today.month == dob.month && today.day < dob.day)) {
      age--;
    }
    return age;
  }

  // ─── Stream ──────────────────────────────────────────────────────────────────

  Stream<QuerySnapshot> _usersStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'user')
        .snapshots();
  }

  // ─── Init ────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _fetchReports();
  }

  Future<void> _fetchReports() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('reports').get();

      List<Report> reports = [];

      for (var doc in snapshot.docs) {
        try {
          final report = Report.fromMap(doc.id, doc.data());

          reports.add(report);
        } catch (e) {
          print('FAILED DOC ID: ${doc.id}');
          print('DATA: ${doc.data()}');
          print('ERROR: $e');
        }
      }

      if (!mounted) return;

      setState(() {
        _allReports = reports;
      });
    } catch (e) {
      debugPrint('ERROR FETCHING REPORTS: $e');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────────

  List<Report> _reportsForUser(String userId) =>
      _allReports.where((r) => r.userId == userId).toList();

  int _pendingScansForUser(String userId) =>
      _reportsForUser(userId).where((r) => r.submit == false).length;

  int _doneScansForUser(String userId) =>
      _reportsForUser(userId).where((r) => r.submit == true).length;
  
  String formatDate(DateTime? date) {
    if (date == null) return "Not set";
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }
  // ─── Build ───────────────────────────────────────────────────────────────────

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
              // ── Title ──
              const Text(
                'Users Dashboard',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
              ),
              const Text(
                'Manage all registered users and their scans',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),

              const SizedBox(height: 20),
              _buildStatsRow(),
              const SizedBox(height: 20),
              const Divider(color: Colors.black, thickness: 2),
              const SizedBox(height: 10),

              // ── Search + Sort ──
              Row(
                children: [
                  Flexible(
                    flex: 5,
                    child: SearchBar(
                      controller: _searchController,
                      constraints: const BoxConstraints(
                          minHeight: 44, maxHeight: 44),
                      shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(
                              color: Color.fromARGB(255, 149, 152, 209)),
                        ),
                      ),
                      leading: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(Icons.search,
                            color: Color(0xFF4D51A2), size: 18),
                      ),
                      backgroundColor:
                          const WidgetStatePropertyAll<Color>(Colors.white),
                      shadowColor: const WidgetStatePropertyAll<Color>(
                          Color.fromARGB(46, 0, 0, 0)),
                      hintText: 'Search users...',
                      hintStyle: const WidgetStatePropertyAll<TextStyle>(
                        TextStyle(
                            color: Color.fromARGB(174, 62, 57, 57),
                            fontSize: 13),
                      ),
                      onChanged: (value) =>
                          setState(() => _searchQuery = value.toLowerCase()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    flex: 2,
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: const Color.fromARGB(255, 149, 152, 209)),
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
                          value: _sortOption,
                          icon: const Icon(Icons.unfold_more,
                              size: 16, color: Color(0xFF4D51A2)),
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF1A1A2E)),
                          isExpanded: true,
                          items: const [
                            DropdownMenuItem(
                                value: 'Name A–Z',
                                child: Text('Name A–Z',
                                    style: TextStyle(fontSize: 12))),
                            DropdownMenuItem(
                                value: 'Name Z–A',
                                child: Text('Name Z–A',
                                    style: TextStyle(fontSize: 12))),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _sortOption = value);
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── User grid ──
              StreamBuilder<QuerySnapshot>(
                stream: _usersStream(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                        child: Padding(
                            padding: EdgeInsets.all(40),
                            child: CircularProgressIndicator()));
                  }

                  var docs = snapshot.data!.docs;

                  if (_searchQuery.isNotEmpty) {
                    docs = docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final name =
                          (data['name'] ?? '').toString().toLowerCase();
                      final email =
                          (data['email'] ?? '').toString().toLowerCase();
                      return name.contains(_searchQuery) ||
                          email.contains(_searchQuery);
                    }).toList();
                  }

                  if (docs.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(
                        child: Text('No users found.',
                            style: TextStyle(color: Colors.grey)),
                      ),
                    );
                  }

                  final sorted = List<QueryDocumentSnapshot>.from(docs);
                  sorted.sort((a, b) {
                    final aName =
                        ((a.data() as Map<String, dynamic>)['name'] ?? '')
                            as String;
                    final bName =
                        ((b.data() as Map<String, dynamic>)['name'] ?? '')
                            as String;
                    return _sortOption == 'Name A–Z'
                        ? aName.toLowerCase().compareTo(bName.toLowerCase())
                        : bName.toLowerCase().compareTo(aName.toLowerCase());
                  });

                  return _buildUsersGrid(sorted);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Stats row ───────────────────────────────────────────────────────────────

  Widget _buildStatsRow() {
    return LayoutBuilder(builder: (context, constraints) {
      final cardW = (constraints.maxWidth - 24) / 3;
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          SizedBox(
            width: cardW,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('role', isEqualTo: 'user')
                  .snapshots(),
              builder: (context, snapshot) {
                final count = snapshot.data?.docs.length ?? 0;
                return _buildStatCard('Total Users', count,
                    icon: Icons.people_outline,
                    color: const Color(0xFF6366F1));
              },
            ),
          ),
          SizedBox(
            width: cardW,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('reports')
                  .snapshots(),
              builder: (context, snapshot) {
                final count = snapshot.data?.docs.length ?? 0;
                return _buildStatCard('Total Scans', count,
                    icon: Icons.document_scanner_outlined,
                    color: const Color(0xFF0EA5E9));
              },
            ),
          ),
          SizedBox(
            width: cardW,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('reports')
                  .where('submit', isEqualTo: true)
                  .snapshots(),
              builder: (context, snapshot) {
                final count = snapshot.data?.docs.length ?? 0;
                return _buildStatCard('Diagnosed Scans', count,
                    icon: Icons.check_circle_outline,
                    color: const Color(0xFF22C55E));
              },
            ),
          ),
        ],
      );
    });
  }

  // ─── 3-column grid ───────────────────────────────────────────────────────────

  Widget _buildUsersGrid(List<QueryDocumentSnapshot> users) {
    return LayoutBuilder(builder: (context, constraints) {
      final cardW = (constraints.maxWidth - 20) / 3;
      return Wrap(
        spacing: 10,
        runSpacing: 10,
        children: users.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return SizedBox(
            width: cardW,
            child: _buildUserCard(data, doc.id),
          );
        }).toList(),
      );
    });
  }

  // ─── Single user card ────────────────────────────────────────────────────────

  Widget _buildUserCard(Map<String, dynamic> data, String userId) {
    final name = data['name'] ?? 'No Name';
    final email = data['email'] ?? '';
    final gender = (data['gender'] ?? '—') as String;
    final age = _calculateAge(data['birthDate']);

    // ── Doctor from nested map in user doc ──
    final doctorMap = data['doctor'] as Map<String, dynamic>?;
    final doctorName = doctorMap?['name'] as String?;

    final totalScans = _reportsForUser(userId).length;
    final doneScans = _doneScansForUser(userId);       // ✅ submit == true
    final pendingScans = _pendingScansForUser(userId); // ✅ submit == false

    final initials = name
        .split(' ')
        .where((String w) => w.isNotEmpty)
        .take(2)
        .map((String w) => w[0].toUpperCase())
        .join();

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
          // ── Avatar + name + email + gender/age ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
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
                          color: Color(0xFF1A1A2E)),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      email,
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF9CA3AF)),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '$gender · ${age > 0 ? '$age yrs' : '—'}',
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF9CA3AF)),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const SizedBox(height: 12),

          // ── Scan stats ──
          Row(
            children: [
              Expanded(
                  child: _miniStat(
                      '$totalScans', 'Total Scans', const Color(0xFF6366F1))),
              Container(
                  width: 1, height: 32, color: const Color(0xFFE8E8F0)),
              Expanded(
                  child: _miniStat(
                      '$doneScans', 'Done Scans', const Color(0xFF22C55E))),
              Container(
                  width: 1, height: 32, color: const Color(0xFFE8E8F0)),
              Expanded(
                  child: _miniStat(
                      '$pendingScans', 'Pending Scans', const Color(0xFFF59E0B))),
            ],
          ),

          const SizedBox(height: 12),
          const SizedBox(height: 10),

          // ── Doctor chip ──
          Row(
            children: [
              Icon(
                Icons.medical_services_outlined,
                size: 13,
                color: doctorName != null
                    ? const Color(0xFF6366F1)
                    : const Color(0xFF9CA3AF),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  doctorName != null ? 'Dr. $doctorName' : 'No doctor selected',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: doctorName != null
                        ? const Color(0xFF6366F1)
                        : const Color(0xFF9CA3AF),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────

  Widget _miniStat(String value, String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w800, color: color)),
        Text(label,
            style:
                const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
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

  Widget _buildStatCard(String title, int count,
      {required IconData icon, required Color color}) {
    return Container(
      height: 130,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 8),
          Text('$count',
              style: const TextStyle(
                  fontSize: 28, fontWeight: FontWeight.bold)),
          Text(title,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}