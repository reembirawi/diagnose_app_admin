import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:diagnose_app/core/constants/app_colors.dart';
import 'package:diagnose_app/core/constants/app_strings.dart';
import 'package:diagnose_app/presentation/widgets/dashboard_card.dart';

class RecentUsersCard extends StatelessWidget {
  const RecentUsersCard({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(AppStrings.usersCollection)
          .where(AppStrings.roleField, isEqualTo: AppStrings.userRole)
          .snapshots(),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];
        return DashboardCard(
          height: 350,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                AppStrings.recentUsers,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 250,
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: docs.length,
                  itemBuilder: (_, i) => _UserTile(doc: docs[i]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _UserTile extends StatelessWidget {
  final QueryDocumentSnapshot doc;
  const _UserTile({required this.doc});

  @override
  Widget build(BuildContext context) {
    final name = doc[AppStrings.nameField] ?? AppStrings.unknown;
    final email = doc[AppStrings.emailField] ?? AppStrings.unknown;

    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection(AppStrings.reportsCollection)
          .where(AppStrings.userIdField, isEqualTo: doc.id)
          .get(),
      builder: (_, reportSnapshot) {
        final scanCount = reportSnapshot.data?.docs.length ?? 0;
        return Column(
          children: [
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              minLeadingWidth: 40,
              leading: CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.avatarBg,
                child: Text(
                  name.isNotEmpty ? name[0] : '?',
                  style: const TextStyle(
                    color: AppColors.primary,
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
                    '$scanCount ${AppStrings.scans}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.primary,
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
  }
}
