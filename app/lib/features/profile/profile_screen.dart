import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/auth_data_source.dart';
import '../../data/profile_repository.dart';
import '../../models/salon_search_result.dart';
import '../../models/user_profile.dart';
import '../location_permission/location_permission_screen.dart';
import '../salon_profile/salon_profile_screen.dart';

/// Screen 8 -- Profile / Settings, kept thin for MVP (docs/consumer-flow.md).
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile? _profile;
  List<SalonSearchResult> _favourites = [];
  bool _loading = true;
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();

  String get _userId => context.read<AuthDataSource>().currentUserId!;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final repo = context.read<ProfileRepository>();
    final results = await Future.wait([repo.fetchProfile(_userId), repo.fetchFavourites(_userId)]);
    if (!mounted) return;
    setState(() {
      _profile = results[0] as UserProfile;
      _favourites = results[1] as List<SalonSearchResult>;
      _nameController.text = _profile!.fullName ?? '';
      _loading = false;
    });
  }

  Future<void> _saveName() async {
    await context.read<ProfileRepository>().updateName(_userId, _nameController.text.trim());
    await _load();
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved')));
  }

  Future<void> _addAddress() async {
    final address = _addressController.text.trim();
    if (address.isEmpty) return;
    final updated = [..._profile!.savedAddresses, address];
    await context.read<ProfileRepository>().updateSavedAddresses(_userId, updated);
    _addressController.clear();
    await _load();
  }

  Future<void> _removeAddress(String address) async {
    final updated = _profile!.savedAddresses.where((a) => a != address).toList();
    await context.read<ProfileRepository>().updateSavedAddresses(_userId, updated);
    await _load();
  }

  Future<void> _togglePush(bool value) async {
    await context.read<ProfileRepository>().updatePushNotificationsEnabled(_userId, value);
    await _load();
  }

  Future<void> _removeFavourite(String salonId) async {
    await context.read<ProfileRepository>().removeFavourite(_userId, salonId);
    await _load();
  }

  Future<void> _signOut() async {
    await context.read<AuthDataSource>().signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LocationPermissionScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final profile = _profile!;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(profile.phone ?? '', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Name',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(icon: const Icon(Icons.check), onPressed: _saveName),
            ),
          ),
          const Divider(height: 32),
          const Text('Saved addresses', style: TextStyle(fontWeight: FontWeight.bold)),
          for (final address in profile.savedAddresses)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(address),
              trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => _removeAddress(address)),
            ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _addressController,
                  decoration: const InputDecoration(hintText: 'Add an address'),
                ),
              ),
              IconButton(icon: const Icon(Icons.add), onPressed: _addAddress),
            ],
          ),
          const Divider(height: 32),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Push notifications'),
            subtitle: const Text('Booking confirmations and reminders'),
            value: profile.pushNotificationsEnabled,
            onChanged: _togglePush,
          ),
          const Divider(height: 32),
          const Text('Favourite salons', style: TextStyle(fontWeight: FontWeight.bold)),
          if (_favourites.isEmpty) const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('None yet'))
          else
            for (final favourite in _favourites)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(favourite.name),
                trailing: IconButton(icon: const Icon(Icons.favorite), onPressed: () => _removeFavourite(favourite.id)),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => SalonProfileScreen(salonId: favourite.id)),
                ),
              ),
          const Divider(height: 32),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.help_outline),
            title: const Text('Help & contact'),
            onTap: () => launchUrl(Uri.parse('mailto:support@beautyhub.app')),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.description_outlined),
            title: const Text('Terms & Conditions'),
            onTap: () => showDialog(
              context: context,
              builder: (dialogContext) => AlertDialog(
                title: const Text('Terms & Conditions'),
                content: const SingleChildScrollView(child: Text('Placeholder terms for the MVP.')),
                actions: [TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Close'))],
              ),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton(onPressed: _signOut, child: const Text('Sign out')),
        ],
      ),
    );
  }
}
