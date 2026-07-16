import 'package:beauty_hub/data/auth_data_source.dart';
import 'package:beauty_hub/data/booking_repository.dart';
import 'package:beauty_hub/data/discovery_repository.dart';
import 'package:beauty_hub/data/payment_gateway.dart';
import 'package:beauty_hub/data/photo_upload_service.dart';
import 'package:beauty_hub/data/profile_repository.dart';
import 'package:beauty_hub/data/review_repository.dart';
import 'package:beauty_hub/location/location_controller.dart';
import 'package:beauty_hub/location/suburbs.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'fakes/fake_auth_data_source.dart';
import 'fakes/fake_booking_data_source.dart';
import 'fakes/fake_discovery_data_source.dart';
import 'fakes/fake_payment_gateway.dart';
import 'fakes/fake_photo_upload_service.dart';
import 'fakes/fake_profile_data_source.dart';
import 'fakes/fake_review_data_source.dart';

/// Wraps a screen with the same providers app.dart supplies, minus the
/// Supabase initialization, so widget tests can drive real screens against
/// fakes shaped like the real Supabase responses. Every provider has a
/// working default so a test only needs to override the ones it cares about.
Widget wrapWithProviders(
  Widget child, {
  DiscoveryRepository? repository,
  LocationController? locationController,
  AuthDataSource? authDataSource,
  BookingRepository? bookingRepository,
  ReviewRepository? reviewRepository,
  ProfileRepository? profileRepository,
  PhotoUploadService? photoUploadService,
  PaymentGateway? paymentGateway,
}) {
  final location = locationController ?? (LocationController()..setSuburb(seededSuburbs.first));
  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: location),
      Provider<DiscoveryRepository>.value(
        value: repository ?? DiscoveryRepository(FakeDiscoveryDataSource()),
      ),
      Provider<AuthDataSource>.value(value: authDataSource ?? FakeAuthDataSource()),
      Provider<BookingRepository>.value(
        value: bookingRepository ?? BookingRepository(FakeBookingDataSource()),
      ),
      Provider<ReviewRepository>.value(
        value: reviewRepository ?? ReviewRepository(FakeReviewDataSource()),
      ),
      Provider<ProfileRepository>.value(
        value: profileRepository ?? ProfileRepository(FakeProfileDataSource()),
      ),
      Provider<PhotoUploadService>.value(value: photoUploadService ?? FakePhotoUploadService()),
      Provider<PaymentGateway>.value(value: paymentGateway ?? FakePaymentGateway()),
    ],
    child: MaterialApp(home: child),
  );
}
