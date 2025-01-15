import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

class LocationService {
  final Location _location = Location();

  Future<LatLng?> getCurrentLocation() async {
    try {
      var permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        throw Exception('Location permission not granted');
      }

      var userLocation = await _location.getLocation();
      return LatLng(userLocation.latitude!, userLocation.longitude!);
    } catch (e) {
      return null;
    }
  }

  Stream<LatLng> onLocationChanged() {
    return _location.onLocationChanged.map(
      (newLocation) => LatLng(newLocation.latitude!, newLocation.longitude!),
    );
  }
}
