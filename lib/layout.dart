import 'package:flutter/material.dart';

class AppLayout extends StatefulWidget {
  final List<NavItem> navItems;

  const AppLayout({super.key, required this.navItems});

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    var selected = widget.navItems.elementAt(_selectedIndex);
    return Scaffold(
      appBar: selected.title != null
          ? AppBar(title: Text(selected.title!))
          : null,
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
  final String? title;

  NavItem({
    required this.label,
    required this.icon,
    required this.body,
    this.title,
  });
}
