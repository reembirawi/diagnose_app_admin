import 'package:flutter/material.dart';
import 'package:diagnose_app/core/constants/app_colors.dart';
import 'package:diagnose_app/core/constants/app_strings.dart';
import 'package:diagnose_app/data/models/report.dart';

class UserCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final String userId;
  final List<Report> allReports;
  final int age;

  const UserCard({
    super.key,
    required this.data,
    required this.userId,
    required this.allReports,
    required this.age,
  });

  List<Report> get _userReports =>
      allReports.where((r) => r.userId == userId).toList();
  int get _totalScans => _userReports.length;
  int get _doneScans => _userReports.where((r) => r.submit == true).length;
  int get _pendingScans => _userReports.where((r) => r.submit == false).length;

  String get _initials {
    final name = (data[AppStrings.nameField] ?? '') as String;
    return name
        .split(' ')
        .where((String w) => w.isNotEmpty)
        .take(2)
        .map((String w) => w[0].toUpperCase())
        .join();
  }

  @override
  Widget build(BuildContext context) {
    final name = data[AppStrings.nameField] ?? AppStrings.noName;
    final email = data[AppStrings.emailField] ?? '';
    final gender = (data[AppStrings.genderField] ?? '—') as String;
    final doctorName =
        (data[AppStrings.doctorField]
                as Map<String, dynamic>?)?[AppStrings.nameField]
            as String?;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 1.5),
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
          _UserHeader(
            initials: _initials,
            name: name,
            email: email,
            gender: gender,
            age: age,
          ),
          const SizedBox(height: 14),
          _ScanStats(
            total: _totalScans,
            done: _doneScans,
            pending: _pendingScans,
          ),
          const SizedBox(height: 12),
          _DoctorChip(doctorName: doctorName),
        ],
      ),
    );
  }
}

class _UserHeader extends StatelessWidget {
  final String initials;
  final String name;
  final String email;
  final String gender;
  final int age;

  const _UserHeader({
    required this.initials,
    required this.name,
    required this.email,
    required this.gender,
    required this.age,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.avatarPurple,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            initials,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
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
                  color: AppColors.textDark,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                email,
                style: const TextStyle(fontSize: 11, color: AppColors.textGrey),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '$gender · ${age > 0 ? '$age yrs' : '—'}',
                style: const TextStyle(fontSize: 11, color: AppColors.textGrey),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ScanStats extends StatelessWidget {
  final int total;
  final int done;
  final int pending;

  const _ScanStats({
    required this.total,
    required this.done,
    required this.pending,
  });

  Widget _stat(String value, String label, Color color) => Expanded(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.textGrey),
        ),
      ],
    ),
  );

  Widget _divider() =>
      Container(width: 1, height: 32, color: AppColors.cardBorder);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _stat('$total', AppStrings.totalScansLabel, AppColors.avatarPurple),
        _divider(),
        _stat('$done', AppStrings.doneScansLabel, AppColors.activeColor),
        _divider(),
        _stat('$pending', AppStrings.pendingScansLabel, AppColors.pendingColor),
      ],
    );
  }
}

class _DoctorChip extends StatelessWidget {
  final String? doctorName;
  const _DoctorChip({this.doctorName});

  @override
  Widget build(BuildContext context) {
    final hasDoctor = doctorName != null;
    final color = hasDoctor ? AppColors.avatarPurple : AppColors.textGrey;
    return Row(
      children: [
        Icon(Icons.medical_services_outlined, size: 13, color: color),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            hasDoctor
                ? '${AppStrings.doctorPrefix}$doctorName'
                : AppStrings.noDoctor,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
