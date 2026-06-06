import 'package:flutter/material.dart';
import 'package:diagnose_app/core/constants/app_colors.dart';
import 'package:diagnose_app/core/constants/app_strings.dart';

class AppSidebar extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const AppSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  State<AppSidebar> createState() => _AppSidebarState();
}

class _AppSidebarState extends State<AppSidebar> {
  int _hoveredIndex = -1;

  static const _items = [
    {'title': AppStrings.navDashboard, 'icon': Icons.dashboard},
    {'title': AppStrings.navDoctors, 'icon': Icons.people},
    {'title': AppStrings.navUsers, 'icon': Icons.person},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 270,
      color: AppColors.sidebarBg,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 10, bottom: 10),
            child: Text(
              AppStrings.appName,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w100,
                color: Colors.white,
              ),
            ),
          ),
          const Divider(color: Colors.white, thickness: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
              itemCount: _items.length,
              itemBuilder: (_, index) => _SidebarItem(
                title: _items[index]['title'] as String,
                icon: _items[index]['icon'] as IconData,
                isSelected: widget.selectedIndex == index,
                isHovered: _hoveredIndex == index,
                onTap: () => widget.onItemSelected(index),
                onEnter: () => setState(() => _hoveredIndex = index),
                onExit: () => setState(() => _hoveredIndex = -1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final bool isHovered;
  final VoidCallback onTap;
  final VoidCallback onEnter;
  final VoidCallback onExit;

  const _SidebarItem({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.isHovered,
    required this.onTap,
    required this.onEnter,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => onEnter(),
      onExit: (_) => onExit(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
        transform: Matrix4.translationValues(
          isSelected || isHovered ? 10 : 0,
          0,
          0,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.sidebarSelected
              : isHovered
              ? AppColors.sidebarHovered
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListTile(
          iconColor: Colors.white,
          textColor: Colors.white,
          leading: Icon(icon),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
