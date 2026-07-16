import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'data/auth_data_source.dart';
import 'data/booking_data_source.dart';
import 'data/booking_repository.dart';
import 'data/discovery_data_source.dart';
import 'data/discovery_repository.dart';
import 'data/payment_gateway.dart';
import 'data/photo_upload_service.dart';
import 'data/profile_data_source.dart';
import 'data/profile_repository.dart';
import 'data/review_data_source.dart';
import 'data/review_repository.dart';
import 'features/location_permission/location_permission_screen.dart';
import 'location/location_controller.dart';

class BeautyHubApp extends StatelessWidget {
  const BeautyHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    final client = Supabase.instance.client;
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocationController()),
        Provider<DiscoveryRepository>(
          create: (_) => DiscoveryRepository(SupabaseDiscoveryDataSource(client)),
        ),
        Provider<AuthDataSource>(create: (_) => SupabaseAuthDataSource(client)),
        Provider<BookingRepository>(
          create: (_) => BookingRepository(SupabaseBookingDataSource(client)),
        ),
        Provider<ReviewRepository>(
          create: (_) => ReviewRepository(SupabaseReviewDataSource(client)),
        ),
        Provider<ProfileRepository>(
          create: (_) => ProfileRepository(SupabaseProfileDataSource(client)),
        ),
        Provider<PhotoUploadService>(create: (_) => SupabasePhotoUploadService(client)),
        // Stubbed until a real Paystack public key + checkout are wired up
        // (see .env.example and data/payment_gateway.dart).
        Provider<PaymentGateway>(create: (_) => StubPaystackGateway()),
      ],
      child: MaterialApp(
        title: 'Beauty HuB',
        theme: ThemeData(colorSchemeSeed: Colors.pink, useMaterial3: true),
        home: const LocationPermissionScreen(),
      ),
    );
  }
}
