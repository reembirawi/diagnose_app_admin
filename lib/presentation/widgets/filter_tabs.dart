import 'package:flutter/material.dart';

class FilterTabs extends StatelessWidget {
  final String selected;
  final Function(String) onChanged;

  FilterTabs({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final List<Map<String, dynamic>> tabs = const <Map<String, dynamic>>[
    {"title": "All", "count": 0},
    {"title": "Active", "count": 0},
    {"title": "Pending", "count": 0},
    {"title": "Suspended", "count": 0},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color.fromARGB(255, 149, 152, 209)),
      ),
      child: Row(
        children: tabs.map((tab) {
          final isSelected = selected == tab["title"];

          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(tab["title"]),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF4D51A2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    tab["title"],
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}