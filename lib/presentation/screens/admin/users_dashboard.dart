import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:diagnose_app/core/constants/app_colors.dart';
import 'package:diagnose_app/core/constants/app_strings.dart';
import 'package:diagnose_app/data/models/report.dart';
import 'package:diagnose_app/data/services/user_service.dart';
import 'package:diagnose_app/presentation/widgets/user_card.dart';
import 'package:diagnose_app/presentation/widgets/user_state_card.dart';

class UsersDashboard extends StatefulWidget {
  const UsersDashboard({super.key});

  @override
  State<UsersDashboard> createState() => _UsersDashboardState();
}

class _UsersDashboardState extends State<UsersDashboard> {
  final _service = UserService();
  final _searchController = TextEditingController();

  List<Report> _allReports = [];
  String _searchQuery = '';
  String _sortOption = AppStrings.sortNameAZ;

  @override
  void initState() {
    super.initState();
    _service.fetchReports().then((reports) {
      if (!mounted) return;
      setState(() => _allReports = reports);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<QueryDocumentSnapshot> _filterAndSort(List<QueryDocumentSnapshot> docs) {
    var list = docs.where((doc) {
      if (_searchQuery.isEmpty) return true;
      final data = doc.data() as Map<String, dynamic>;
      final name = (data[AppStrings.nameField] ?? '').toString().toLowerCase();
      final email = (data[AppStrings.emailField] ?? '')
          .toString()
          .toLowerCase();
      return name.contains(_searchQuery) || email.contains(_searchQuery);
    }).toList();

    list.sort((a, b) {
      final aName = ((a.data() as Map)[AppStrings.nameField] ?? '') as String;
      final bName = ((b.data() as Map)[AppStrings.nameField] ?? '') as String;
      return _sortOption == AppStrings.sortNameAZ
          ? aName.toLowerCase().compareTo(bName.toLowerCase())
          : bName.toLowerCase().compareTo(aName.toLowerCase());
    });

    return list;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            AppStrings.usersDashboard,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
          ),
          const Text(
            AppStrings.usersSubtitle,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 20),
          _StatsRow(service: _service),
          const SizedBox(height: 20),
          const Divider(color: Colors.black, thickness: 2),
          const SizedBox(height: 10),
          _Toolbar(
            controller: _searchController,
            sortOption: _sortOption,
            onSearch: (v) => setState(() => _searchQuery = v.toLowerCase()),
            onSort: (v) => setState(() => _sortOption = v),
          ),
          const SizedBox(height: 16),
          StreamBuilder<QuerySnapshot>(
            stream: _service.usersStream(),
            builder: (_, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              final filtered = _filterAndSort(snapshot.data!.docs);
              if (filtered.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Text(
                      AppStrings.noUsersFound,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              }
              return LayoutBuilder(
                builder: (_, constraints) {
                  final w = (constraints.maxWidth - 20) / 3;
                  return Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: filtered.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return SizedBox(
                        width: w,
                        child: UserCard(
                          data: data,
                          userId: doc.id,
                          allReports: _allReports,
                          age: _service.calculateAge(
                            data[AppStrings.birthDateField],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final UserService service;
  const _StatsRow({required this.service});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final w = (constraints.maxWidth - 24) / 3;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: w,
              child: StreamBuilder<QuerySnapshot>(
                stream: service.usersStream(),
                builder: (_, s) => UserStatCard(
                  title: AppStrings.totalUsers,
                  count: s.data?.docs.length ?? 0,
                  icon: Icons.people_outline,
                  color: AppColors.avatarPurple,
                ),
              ),
            ),
            SizedBox(
              width: w,
              child: StreamBuilder<QuerySnapshot>(
                stream: service.totalScansStream(),
                builder: (_, s) => UserStatCard(
                  title: AppStrings.totalScans,
                  count: s.data?.docs.length ?? 0,
                  icon: Icons.document_scanner_outlined,
                  color: AppColors.scanBlue,
                ),
              ),
            ),
            SizedBox(
              width: w,
              child: StreamBuilder<QuerySnapshot>(
                stream: service.diagnosedScansStream(),
                builder: (_, s) => UserStatCard(
                  title: AppStrings.diagnosedScans,
                  count: s.data?.docs.length ?? 0,
                  icon: Icons.check_circle_outline,
                  color: AppColors.activeColor,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Toolbar extends StatelessWidget {
  final TextEditingController controller;
  final String sortOption;
  final ValueChanged<String> onSearch;
  final ValueChanged<String> onSort;

  const _Toolbar({
    required this.controller,
    required this.sortOption,
    required this.onSearch,
    required this.onSort,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          flex: 5,
          child: SearchBar(
            controller: controller,
            constraints: const BoxConstraints(minHeight: 44, maxHeight: 44),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(
                  color: Color.fromARGB(255, 149, 152, 209),
                ),
              ),
            ),
            leading: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Icon(Icons.search, color: AppColors.primary, size: 18),
            ),
            backgroundColor: const WidgetStatePropertyAll(Colors.white),
            shadowColor: const WidgetStatePropertyAll(
              Color.fromARGB(46, 0, 0, 0),
            ),
            hintText: AppStrings.searchUsers,
            hintStyle: const WidgetStatePropertyAll(
              TextStyle(color: Color.fromARGB(174, 62, 57, 57), fontSize: 13),
            ),
            onChanged: onSearch,
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
                  color: AppColors.primary,
                ),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
                isExpanded: true,
                items: [AppStrings.sortNameAZ, AppStrings.sortNameZA]
                    .map(
                      (o) => DropdownMenuItem(
                        value: o,
                        child: Text(o, style: const TextStyle(fontSize: 12)),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) onSort(v);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
