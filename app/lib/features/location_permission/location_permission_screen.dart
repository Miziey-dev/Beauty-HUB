import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/strings.dart';
import '../../location/location_controller.dart';
import '../../location/suburbs.dart';
import '../shell/main_shell.dart';

/// Screen 1 -- Location permission (docs/consumer-flow.md).
class LocationPermissionScreen extends StatefulWidget {
  const LocationPermissionScreen({super.key});

  @override
  State<LocationPermissionScreen> createState() =>
      _LocationPermissionScreenState();
}

class _LocationPermissionScreenState extends State<LocationPermissionScreen> {
  bool _requesting = false;

  Future<void> _useMyLocation() async {
    setState(() => _requesting = true);
    final controller = context.read<LocationController>();
    final resolved = await controller.useGps();
    if (!mounted) return;
    setState(() => _requesting = false);
    if (resolved) {
      _goHome();
    } else {
      _showSuburbPicker();
    }
  }

  void _showSuburbPicker() {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => ListView(
        shrinkWrap: true,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(Strings.enterYourSuburb, style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          for (final suburb in seededSuburbs)
            ListTile(
              title: Text(suburb.name),
              onTap: () {
                context.read<LocationController>().setSuburb(suburb);
                Navigator.of(sheetContext).pop();
                _goHome();
              },
            ),
        ],
      ),
    );
  }

  void _goHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.location_on, size: 72),
              const SizedBox(height: 24),
              const Text(
                Strings.locationExplainer,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _requesting ? null : _useMyLocation,
                child: _requesting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(Strings.useMyLocation),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _showSuburbPicker,
                child: const Text(Strings.enterYourSuburb),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
