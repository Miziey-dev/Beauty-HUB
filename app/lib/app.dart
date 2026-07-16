import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'data/discovery_data_source.dart';
import 'data/discovery_repository.dart';
import 'features/location_permission/location_permission_screen.dart';
import 'location/location_controller.dart';

class BeautyHubApp extends StatelessWidget {
  const BeautyHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocationController()),
        Provider<DiscoveryRepository>(
          create: (_) => DiscoveryRepository(
            SupabaseDiscoveryDataSource(Supabase.instance.client),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Beauty HuB',
        theme: ThemeData(colorSchemeSeed: Colors.pink, useMaterial3: true),
        home: const LocationPermissionScreen(),
      ),
    );
  }
}
