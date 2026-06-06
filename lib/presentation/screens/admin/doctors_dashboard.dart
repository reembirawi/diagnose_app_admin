import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:diagnose_app/core/constants/app_colors.dart';
import 'package:diagnose_app/core/constants/app_strings.dart';
import 'package:diagnose_app/data/models/report.dart';
import 'package:diagnose_app/data/services/doctor_service.dart';
import 'package:diagnose_app/presentation/widgets/doctor_card.dart';
import 'package:diagnose_app/presentation/widgets/filter_tabs.dart';
import 'package:diagnose_app/presentation/widgets/state_card.dart';

class DoctorsDashboard extends StatefulWidget {
  const DoctorsDashboard({super.key});

  @override
  State<DoctorsDashboard> createState() => _DoctorsDashboardState();
}

class _DoctorsDashboardState extends State<DoctorsDashboard> {
  final _service = DoctorService();
  List<Report> _reports = [];
  String _filter = 'All';
  String _sort = AppStrings.sortNameAZ;
  bool _reportsLoaded = false;

  final _sortOptions = [
    AppStrings.sortNameAZ,
    AppStrings.sortNameZA,
    AppStrings.sortRatingHL,
    AppStrings.sortRatingLH,
  ];

  @override
  void initState() {
    super.initState();
    _service.fetchReports().then((reports) {
      if (!mounted) return;
      setState(() {
        _reports = reports;
        _reportsLoaded = true;
      });
    });
  }

  List<QueryDocumentSnapshot> _sorted(List<QueryDocumentSnapshot> docs) {
    final list = List<QueryDocumentSnapshot>.from(docs);
    double rating(QueryDocumentSnapshot d) {
      final data = d.data() as Map<String, dynamic>;
      final done = (data[AppStrings.scansDoneField] ?? 0) as num;
      final rem = (data[AppStrings.scansRemainingField] ?? 0) as num;
      final total = done + rem;
      return total == 0 ? 0 : done / total;
    }

    switch (_sort) {
      case 'Name A–Z':
        list.sort(
          (a, b) => ((a.data() as Map)[AppStrings.nameField] ?? '')
              .toLowerCase()
              .compareTo(
                ((b.data() as Map)[AppStrings.nameField] ?? '').toLowerCase(),
              ),
        );
        break;
      case 'Name Z–A':
        list.sort(
          (a, b) => ((b.data() as Map)[AppStrings.nameField] ?? '')
              .toLowerCase()
              .compareTo(
                ((a.data() as Map)[AppStrings.nameField] ?? '').toLowerCase(),
              ),
        );
        break;
      case 'Rating High–Low':
        list.sort((a, b) => rating(b).compareTo(rating(a)));
        break;
      case 'Rating Low–High':
        list.sort((a, b) => rating(a).compareTo(rating(b)));
        break;
    }
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
            AppStrings.doctorsDashboard,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
          ),
          const Text(
            AppStrings.doctorsSubtitle,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 20),
          _StateCards(service: _service),
          const SizedBox(height: 20),
          const Divider(color: Colors.black, thickness: 2),
          const SizedBox(height: 10),
          _Toolbar(
            filter: _filter,
            sort: _sort,
            sortOptions: _sortOptions,
            onFilterChanged: (v) => setState(() => _filter = v),
            onSortChanged: (v) => setState(() => _sort = v),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: _service.doctorsStream(_filter),
            builder: (_, snapshot) {
              if (!snapshot.hasData || !_reportsLoaded) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              final doctors = _sorted(snapshot.data!.docs);
              if (doctors.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Text(
                      AppStrings.noDoctorsFound,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              }
              return LayoutBuilder(
                builder: (_, constraints) {
                  final w = (constraints.maxWidth - 20) / 3;
                  return Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: doctors.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return SizedBox(
                          width: w,
                          child: DoctorCard(
                            data: data,
                            docId: doc.id,
                            scansDone: _reports
                                .where(
                                  (r) =>
                                      r.doctorId == doc.id && r.submit == true,
                                )
                                .length,
                            scansRemaining: _reports
                                .where(
                                  (r) =>
                                      r.doctorId == doc.id && r.submit == false,
                                )
                                .length,
                          ),
                        );
                      }).toList(),
                    ),
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

class _StateCards extends StatelessWidget {
  final DoctorService service;
  const _StateCards({required this.service});

  @override
  Widget build(BuildContext context) {
    final filters = [
      (AppStrings.totalDoctors, null),
      (AppStrings.approvedDoctors, AppStrings.approvedStatus),
      (AppStrings.pendingApprovals, AppStrings.pendingStatus),
      (AppStrings.suspendedDoctors, AppStrings.suspendedStatus),
    ];
    return LayoutBuilder(
      builder: (_, constraints) {
        final w = (constraints.maxWidth - 36) / 4;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: filters
              .map(
                (f) => SizedBox(
                  width: w,
                  child: StreamBuilder<QuerySnapshot>(
                    stream: service.doctorsStream(
                      f.$2 == null ? 'All' : _statusToFilter(f.$2!),
                    ),
                    builder: (_, snap) => StateCard(
                      title: f.$1,
                      count: snap.data?.docs.length ?? 0,
                      icon: '🩺',
                    ),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }

  String _statusToFilter(String status) {
    switch (status) {
      case 'approved':
        return 'Active';
      case 'pending':
        return 'Pending';
      case 'suspended':
        return 'Suspended';
      default:
        return 'All';
    }
  }
}

class _Toolbar extends StatelessWidget {
  final String filter;
  final String sort;
  final List<String> sortOptions;
  final ValueChanged<String> onFilterChanged;
  final ValueChanged<String> onSortChanged;

  const _Toolbar({
    required this.filter,
    required this.sort,
    required this.sortOptions,
    required this.onFilterChanged,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          flex: 5,
          child: SearchBar(
            constraints: const BoxConstraints(minHeight: 40, maxHeight: 40),
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
            hintText: AppStrings.searchDoctors,
            hintStyle: const WidgetStatePropertyAll(
              TextStyle(color: Color.fromARGB(174, 62, 57, 57), fontSize: 13),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          flex: 4,
          child: FilterTabs(selected: filter, onChanged: onFilterChanged),
        ),
        const SizedBox(width: 12),
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
                value: sort,
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
                items: sortOptions
                    .map(
                      (o) => DropdownMenuItem(
                        value: o,
                        child: Text(o, style: const TextStyle(fontSize: 12)),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) onSortChanged(v);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
