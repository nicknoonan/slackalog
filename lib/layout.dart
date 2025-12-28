import 'package:slackalog/apiClient.dart';
import 'package:slackalog/measurePage.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:slackalog/slackSetupRepository.dart';



class AppLayout extends StatefulWidget {
  final String title;
  final List<NavItem> navItems;
  
  const AppLayout({super.key, required this.title, required this.navItems});

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  int _selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: widget.navItems.elementAt(_selectedIndex).body,
      bottomNavigationBar: BottomNavigationBar(
        items: widget.navItems
            .map(
              (navItem) => BottomNavigationBarItem(
                icon: Icon(navItem.icon),
                label: navItem.label,
              ),
            )
            .toList(),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}

class NavItem {
  final String label;
  final IconData icon;
  final Widget body;

  NavItem({required this.label, required this.icon, required this.body});
}
