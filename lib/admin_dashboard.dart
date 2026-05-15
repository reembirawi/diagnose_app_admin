import 'package:flutter/material.dart';

import 'package:diagnose_app/users_dashboard.dart';
import 'package:diagnose_app/doctors_dashboard.dart';
import 'package:diagnose_app/home_dashboard.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int selectedIndex = 0;
  int hoveredIndex = -1;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    final items = [
      {"title": "Dashboard", "icon": Icons.dashboard},
      {"title": "Doctors", "icon": Icons.people},
      {"title": "Users", "icon": Icons.person},
    ];

    final List<Widget> pages = [
      const DashboardHome(),
      const DoctorsDashboard(),
      const UsersDashboard(),
    ];

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromRGBO(221, 221, 255, 1),
            Color.fromRGBO(255, 255, 255, 1),
            Color.fromRGBO(255, 238, 195, 1),
            Color.fromRGBO(255, 219, 127, 1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,

        appBar: AppBar(
          leadingWidth: screenWidth * 0.8,
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              onPressed: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => const ProfilePage(),
                //   ),
                // );
              },
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
            Container(
              width: 270,
              color: const Color(0xFF4D51A2),

              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 20,
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 10,
                        bottom: 10,
                      ),
                      child:  Text(
                        "Dermalayzer",
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight(100),
                          color: Color.fromRGBO(255, 255, 255, 1),
                        ),
                      ),
                    ),

                    const Divider(
                      color: Colors.white,
                      thickness: 1,
                    ),

                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                        itemCount: items.length,

                        itemBuilder: (context, index) {
                          final bool isSelected =
                              selectedIndex == index;

                          final bool isHovered =
                              hoveredIndex == index;

                          return MouseRegion(
                            onEnter: (_) {
                              setState(() {
                                hoveredIndex = index;
                              });
                            },

                            onExit: (_) {
                              setState(() {
                                hoveredIndex = -1;
                              });
                            },

                            child: AnimatedContainer(
                              duration: const Duration(
                                milliseconds: 200,
                              ),

                              margin: const EdgeInsets.symmetric(
                                vertical: 4,
                                horizontal: 6,
                              ),

                              transform:
                                  Matrix4.translationValues(
                                isSelected || isHovered ? 10 : 0,
                                0,
                                0,
                              ),

                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color.fromARGB(
                                        255,
                                        19,
                                        20,
                                        41,
                                      )
                                    : isHovered
                                        ? const Color.fromRGBO(
                                            35,
                                            37,
                                            73,
                                            0.4,
                                          )
                                        : Colors.transparent,

                                borderRadius:
                                    BorderRadius.circular(10),
                              ),

                              child: ListTile(
                                iconColor: Colors.white,
                                textColor: Colors.white,

                                leading: Icon(
                                  items[index]['icon']
                                      as IconData,
                                ),

                                title: Text(
                                  items[index]['title']
                                      as String,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),

                                onTap: () {
                                  setState(() {
                                    selectedIndex = index;
                                  });
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: pages[selectedIndex],
            ),
          ],
        ),
      ),
    );
  }
}