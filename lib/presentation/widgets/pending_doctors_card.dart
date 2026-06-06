import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:diagnose_app/core/constants/app_colors.dart';
import 'package:diagnose_app/core/constants/app_strings.dart';
import 'package:diagnose_app/presentation/widgets/dashboard_card.dart';

class PendingDoctorsCard extends StatelessWidget {
  const PendingDoctorsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(AppStrings.usersCollection)
          .where(AppStrings.roleField, isEqualTo: AppStrings.doctorRole)
          .where(AppStrings.statusField, isEqualTo: AppStrings.pendingStatus)
          .snapshots(),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];
        return DashboardCard(
          height: 350,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    AppStrings.doctorsPendingApproval,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  const Spacer(),
                  _PendingBadge(count: docs.length),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 250,
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: docs.length,
                  itemBuilder: (_, i) => _DoctorTile(doc: docs[i]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PendingBadge extends StatelessWidget {
  final int count;
  const _PendingBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      height: 30,
      decoration: BoxDecoration(
        color: AppColors.pendingBadgeBg,
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
        '$count ${AppStrings.waiting}',
        style: const TextStyle(fontSize: 14, color: AppColors.pendingBadgeText),
      ),
    );
  }
}

class _DoctorTile extends StatelessWidget {
  final QueryDocumentSnapshot doc;
  const _DoctorTile({required this.doc});

  @override
  Widget build(BuildContext context) {
    final name = doc[AppStrings.nameField] ?? AppStrings.unknown;
    final email = doc[AppStrings.emailField] ?? AppStrings.unknown;
    return Column(
      children: [
        ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: const Color.fromARGB(255, 241, 225, 225),
            child: Text(
              name.isNotEmpty ? name[0] : '?',
              style: const TextStyle(color: AppColors.primary),
            ),
          ),
          title: Text(
            'Dr. $name',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          subtitle: Text(email),
        ),
        const Divider(),
      ],
    );
  }
}
