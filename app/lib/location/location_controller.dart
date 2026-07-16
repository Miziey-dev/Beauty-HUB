import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import 'suburbs.dart';

/// Where the app thinks the user is right now. Set once on Screen 1
/// (location permission) and changeable anytime via the home header's
/// location pill (docs/consumer-flow.md, Screens 1-2).
class LocationController extends ChangeNotifier {
  double? _lat;
  double? _lng;
  String _label = seededSuburbs.first.name;

  double? get lat => _lat;
  double? get lng => _lng;
  String get label => _label;
  bool get isResolved => _lat != null && _lng != null;

  void setSuburb(Suburb suburb) {
    _lat = suburb.lat;
    _lng = suburb.lng;
    _label = suburb.name;
    notifyListeners();
  }

  /// Attempts GPS; returns false (never throws) if permission is denied or
  /// location services are off so the UI can fall back to manual suburb
  /// entry -- "never dead-end on a denied permission".
  Future<bool> useGps() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return false;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return false;
      }

      final position = await Geolocator.getCurrentPosition();
      _lat = position.latitude;
      _lng = position.longitude;
      _label = 'Current location';
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }
}
