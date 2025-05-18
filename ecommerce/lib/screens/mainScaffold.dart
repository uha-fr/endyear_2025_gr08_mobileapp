import 'package:ecommerce/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'products_screen.dart';
import 'orders_screen.dart';


class MainScaffold extends StatefulWidget {
  @override
  _MainScaffoldState createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(), 
    ProductsScreen(),
    OrdersScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
           NavigationDestination(
            icon: Icon(Icons.sell),
            label: 'Products',
          ),
           NavigationDestination(
            icon: Icon(Icons.move_to_inbox),
            label: 'Orders',
          ),
        ],
      ),
    );
  }
}
