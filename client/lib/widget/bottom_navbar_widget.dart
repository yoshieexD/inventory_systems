import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNavbarWidget extends StatefulWidget {
  const BottomNavbarWidget(
      {super.key,
      required this.child,
      required this.location,
      required this.showNavbar});

  final Widget child;
  final String location;
  final bool showNavbar;

  @override
  State<BottomNavbarWidget> createState() => _BottomNavbarWidgetState();
}

class _BottomNavbarWidgetState extends State<BottomNavbarWidget> {
  int currentPageIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(child: widget.child),
        bottomNavigationBar: widget.showNavbar
            ? NavigationBar(
                onDestinationSelected: (int index) {
                  setState(() {
                    currentPageIndex = index;
                  });

                  switch (currentPageIndex) {
                    case 0:
                      {
                        GoRouter.of(context).push("/");
                      }
                      break;

                    case 1:
                      {
                        GoRouter.of(context).push("/material");
                      }
                      break;

                    case 2:
                      {
                        GoRouter.of(context).push("/profile");
                      }
                      break;
                  }
                },
                selectedIndex: currentPageIndex,
                destinations: const <Widget>[
                  NavigationDestination(
                    selectedIcon: Icon(Icons.inventory_2_rounded),
                    icon: Icon(Icons.inventory_2_outlined),
                    label: 'Inventory',
                  ),
                  NavigationDestination(
                    selectedIcon: Icon(Icons.request_page_rounded),
                    icon: Icon(Icons.request_page_outlined),
                    label: 'Material Request',
                  ),
                  NavigationDestination(
                    selectedIcon: Icon(Icons.account_circle),
                    icon: Icon(Icons.account_circle_outlined),
                    label: 'Profile',
                  ),
                ],
              )
            : null);
  }
}
