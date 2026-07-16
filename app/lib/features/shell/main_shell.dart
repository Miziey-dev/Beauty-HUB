import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/auth_data_source.dart';
import '../../features/auth/phone_auth_screen.dart';
import '../../l10n/strings.dart';
import '../home/home_screen.dart';
import '../my_bookings/my_bookings_screen.dart';
import '../profile/profile_screen.dart';

/// Reachable top-level destinations once a location is resolved: Style
/// Feed (Screen 2), My Bookings (Screen 6), and Profile (Screen 8). Not
/// part of the spec's screen-by-screen flow itself, just how a user gets
/// between those top-level screens.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  Future<void> _onTap(int index) async {
    if (index != 0 && !context.read<AuthDataSource>().isSignedIn) {
      final signedIn = await ensureSignedIn(context);
      if (!signedIn) return;
    }
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [HomeScreen(), MyBookingsScreen(), ProfileScreen()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _onTap,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.style_outlined), selectedIcon: Icon(Icons.style), label: Strings.navDiscover),
          NavigationDestination(icon: Icon(Icons.event_note_outlined), selectedIcon: Icon(Icons.event_note), label: Strings.navBookings),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: Strings.navProfile),
        ],
      ),
    );
  }
}
