import 'package:beauty_hub/data/discovery_repository.dart';
import 'package:beauty_hub/location/location_controller.dart';
import 'package:beauty_hub/location/suburbs.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Wraps a screen with the same providers app.dart supplies, minus the
/// Supabase initialization, so widget tests can drive real screens against
/// a [FakeDiscoveryDataSource]-backed repository.
Widget wrapWithProviders(
  Widget child, {
  required DiscoveryRepository repository,
  LocationController? locationController,
}) {
  final location = locationController ?? (LocationController()..setSuburb(seededSuburbs.first));
  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: location),
      Provider<DiscoveryRepository>.value(value: repository),
    ],
    child: MaterialApp(home: child),
  );
}
