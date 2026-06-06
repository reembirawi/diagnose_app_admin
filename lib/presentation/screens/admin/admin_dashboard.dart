import 'package:flutter/material.dart';
import 'package:diagnose_app/core/constants/app_colors.dart';
import 'package:diagnose_app/presentation/screens/home/home_dashboard.dart';
import 'package:diagnose_app/presentation/screens/admin/doctors_dashboard.dart';
import 'package:diagnose_app/presentation/screens/admin/users_dashboard.dart';
import 'package:diagnose_app/presentation/screens/profile/profile_page.dart';
import 'package:diagnose_app/presentation/widgets/sidebar.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  final _pages = const [DashboardHome(), DoctorsDashboard(), UsersDashboard()];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.gradientStart,
            AppColors.gradientMid1,
            AppColors.gradientMid2,
            AppColors.gradientEnd2,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leadingWidth: MediaQuery.of(context).size.width * 0.8,
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              ),
              icon: const Icon(
                Icons.person_rounded,
                size: 40,
                color: Colors.black,
              ),
            ),
          ],
        ),
        body: Row(
          children: [
            AppSidebar(
              selectedIndex: _selectedIndex,
              onItemSelected: (i) => setState(() => _selectedIndex = i),
            ),
            Expanded(child: _pages[_selectedIndex]),
          ],
        ),
      ),
    );
  }
}
