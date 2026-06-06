import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:diagnose_app/core/constants/app_colors.dart';
import 'package:diagnose_app/core/constants/app_strings.dart';
import 'package:diagnose_app/data/services/doctor_service.dart';
import 'package:diagnose_app/presentation/widgets/doctor_profile_dialog.dart';

class DoctorCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final String docId;
  final int scansDone;
  final int scansRemaining;

  const DoctorCard({
    super.key,
    required this.data,
    required this.docId,
    required this.scansDone,
    required this.scansRemaining,
  });

  String get _initials {
    final name = (data[AppStrings.nameField] ?? '') as String;
    return name
        .split(' ')
        .where((String w) => w.isNotEmpty)
        .take(2)
        .map((String w) => w[0].toUpperCase())
        .join();
  }

  String get _ratingDisplay {
    final total = scansDone + scansRemaining;
    return total > 0 ? '${(scansDone / total * 100).toStringAsFixed(0)}%' : '—';
  }

  String get _timeAgo {
    final raw = data[AppStrings.createdAtField];
    if (raw == null) return '';
    final diff = DateTime.now().difference((raw as Timestamp).toDate());
    if (diff.inDays > 0)
      return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
    if (diff.inHours > 0)
      return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
    return AppStrings.justNow;
  }

  ({Color color, String label}) get _statusStyle {
    switch (data[AppStrings.statusField] ?? '') {
      case 'approved':
        return (color: AppColors.activeColor, label: AppStrings.active);
      case 'pending':
        return (color: AppColors.pendingColor, label: AppStrings.pending);
      case 'suspended':
        return (color: AppColors.suspendedColor, label: AppStrings.suspended);
      default:
        return (color: Colors.grey, label: data[AppStrings.statusField] ?? '');
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = data[AppStrings.statusField] ?? '';
    final name = data[AppStrings.nameField] ?? AppStrings.noName;
    final location = data[AppStrings.locationField] ?? AppStrings.unknown;
    final yearsExp =
        int.tryParse(
          data[AppStrings.yearsOfExperienceField]?.toString() ?? '0',
        ) ??
        0;
    final licenseVerified = data[AppStrings.licenseVerifiedField] ?? false;
    final style = _statusStyle;
    final service = DoctorService();

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
          _CardHeader(
            initials: _initials,
            name: name,
            location: location,
            statusStyle: style,
          ),
          const SizedBox(height: 12),
          _StatsRow(
            yearsExp: yearsExp,
            scansDone: scansDone,
            ratingDisplay: _ratingDisplay,
          ),
          const SizedBox(height: 10),
          _AppliedRow(timeAgo: _timeAgo, licenseVerified: licenseVerified),
          _ActionButtons(
            status: status,
            docId: docId,
            doctorData: data,
            service: service,
          ),
        ],
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  final String initials;
  final String name;
  final String location;
  final ({Color color, String label}) statusStyle;

  const _CardHeader({
    required this.initials,
    required this.name,
    required this.location,
    required this.statusStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.avatarPurple,
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
                  color: AppColors.textDark,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 11,
                    color: AppColors.textGrey,
                  ),
                  const SizedBox(width: 2),
                  Flexible(
                    child: Text(
                      location,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textGrey,
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
            color: statusStyle.color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: statusStyle.color.withOpacity(0.4)),
          ),
          child: Text(
            statusStyle.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: statusStyle.color,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  final int yearsExp;
  final int scansDone;
  final String ratingDisplay;

  const _StatsRow({
    required this.yearsExp,
    required this.scansDone,
    required this.ratingDisplay,
  });

  Widget _item(String value, String label) => Expanded(
    child: Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
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
      Container(width: 1, height: 30, color: AppColors.cardBorder);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _item('$yearsExp', AppStrings.yearsExp),
        _divider(),
        _item('$scansDone', AppStrings.scansDone),
        _divider(),
        _item(ratingDisplay, AppStrings.doneRatio),
      ],
    );
  }
}

class _AppliedRow extends StatelessWidget {
  final String timeAgo;
  final bool licenseVerified;

  const _AppliedRow({required this.timeAgo, required this.licenseVerified});

  @override
  Widget build(BuildContext context) {
    if (timeAgo.isEmpty && !licenseVerified) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          if (timeAgo.isNotEmpty)
            Text(
              '${AppStrings.appliedPrefix}$timeAgo',
              style: const TextStyle(fontSize: 11, color: AppColors.textGrey),
            ),
          if (timeAgo.isNotEmpty && licenseVerified)
            const Text(
              ' · ',
              style: TextStyle(fontSize: 11, color: AppColors.textGrey),
            ),
          if (licenseVerified)
            const Text(
              AppStrings.licenseVerified,
              style: TextStyle(fontSize: 11, color: AppColors.textGrey),
            ),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final String status;
  final String docId;
  final Map<String, dynamic> doctorData;
  final DoctorService service;

  const _ActionButtons({
    required this.status,
    required this.docId,
    required this.doctorData,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => showDialog(
              context: context,
              builder: (_) => DoctorProfileDialog(data: doctorData),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.avatarPurple,
              side: const BorderSide(color: AppColors.cardBorder),
              padding: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              AppStrings.viewProfile,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        if (status == AppStrings.pendingStatus) ...[
          const SizedBox(width: 8),
          Expanded(
            child: _statusButton(
              context,
              AppStrings.approve,
              AppColors.avatarPurple,
              AppStrings.approvedStatus,
            ),
          ),
          const SizedBox(width: 8),
          _rejectButton(context),
        ],
        if (status == AppStrings.approvedStatus) ...[
          const SizedBox(width: 8),
          Expanded(
            child: _statusButton(
              context,
              AppStrings.suspend,
              AppColors.suspendedColor,
              AppStrings.suspendedStatus,
            ),
          ),
        ],
        if (status == AppStrings.suspendedStatus) ...[
          const SizedBox(width: 8),
          Expanded(
            child: _statusButton(
              context,
              AppStrings.reinstate,
              AppColors.activeColor,
              AppStrings.approvedStatus,
            ),
          ),
        ],
      ],
    );
  }

  Widget _statusButton(
    BuildContext context,
    String label,
    Color color,
    String newStatus,
  ) {
    return ElevatedButton(
      onPressed: () => service.updateStatus(docId, newStatus),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 8),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _rejectButton(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: OutlinedButton(
        onPressed: () =>
            service.updateStatus(docId, AppStrings.suspendedStatus),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.suspendedColor,
          side: const BorderSide(color: AppColors.rejectBorder),
          backgroundColor: AppColors.rejectBg,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Icon(Icons.close, size: 16),
      ),
    );
  }
}
