import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:open_street_map/utils/constants/images.dart';

import '../../data/model/maps_models.dart';
import '../../data/repository/map_repository.dart';
import '../../data/services/location/location_permission.dart';

class MapViewModel extends ChangeNotifier {
  final MapsRepositoryInterface mapsRepository;
  final LocationService locationService;

  LatLng? currentLocation;
  LatLng? destination;
  List<LatLng> routePoints = [];
  List<AddressDetails> searchResults = [];
  List<Marker> markers = [];
  bool isSearching = false;
  bool isLoading = false;
  bool isDriverMode = false;
  StreamSubscription<LatLng>? _locationSubscription;

  MapViewModel(this.mapsRepository, this.locationService);

  void toggleDriverMode() {
    isDriverMode = !isDriverMode;
    if (isDriverMode) {
      startDriverMode();
    } else {
      stopDriverMode();
    }
    notifyListeners();
  }

  void startDriverMode() {
    locationService.onLocationChanged().listen((newLocation) {
      currentLocation = newLocation;
      updateDriverMarker(newLocation);
      notifyListeners();
    });
  }

  void stopDriverMode() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
    markers.removeWhere((marker) => marker.point == currentLocation);
    isDriverMode = false;

    notifyListeners();
  }

  void updateDriverMarker(LatLng newLocation) {
    markers.removeWhere((marker) => marker.point == currentLocation);
    markers.add(
      Marker(
        width: 50.0,
        height: 50.0,
        point: newLocation,
        child: const Icon(Icons.directions_car, size: 30, color: Colors.green),
      ),
    );
  }

  Future<void> fetchCurrentLocation() async {
    final location = await locationService.getCurrentLocation();
    if (location != null) {
      currentLocation = location;

      markers.add(
        Marker(
          width: 200.0,
          height: 200.0,
          point: currentLocation!,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.transparent,
                    border: Border.all(
                      color: Colors.blueAccent,
                      width: 2.0,
                    )),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.blue.withOpacity(0.3),
                ),
              ),
              Image.asset(ImageManager.currentLocation, width: 40, height: 40)
            ],
          ),
        ),
      );
      notifyListeners();
    }

    locationService.onLocationChanged().listen((newLocation) {
      currentLocation = newLocation;
      notifyListeners();
    });
  }

  Future<void> getRoute(LatLng destination) async {
    if (currentLocation == null) return;

    isLoading = true;
    notifyListeners();

    final routeResponse = await mapsRepository.fetchRoute(
      currentLocation!,
      destination,
    );

    if (routeResponse != null) {
      routePoints = routeResponse.features.first.geometry.coordinates
          .map((coord) => LatLng(coord[1], coord[0]))
          .toList();
    }

    this.destination = destination;

    markers.add(
      Marker(
        width: 40.0,
        height: 40.0,
        point: destination,
        child: Image.asset(ImageManager.searchedLocation),
      ),
    );

    isLoading = false;
    notifyListeners();
  }

  Future<void> getPlaceDetails(LatLng point, BuildContext context) async {
    final details = await mapsRepository.fetchPlaceDetails(point);
    if (details != null) {
      final content = '''
        Place: ${details.displayName}
        Country: ${details.address.country}
        State: ${details.address.state}
        City: ${details.address.town}
        Road: ${details.address.road}
      ''';
      _showDetailsDialog(context, content);
    }
  }

  Future<void> searchLocation(String query) async {
    if (query.isEmpty) {
      searchResults = [];
      notifyListeners();
      return;
    }

    isSearching = true;
    notifyListeners();

    searchResults = await mapsRepository.searchLocation(query);

    isSearching = false;
    notifyListeners();
  }

  void resetMap() {
    final currentLocationMarker = markers.firstWhere(
      (marker) => marker.point == currentLocation,
      orElse: () => Marker(
        width: 200.0,
        height: 200.0,
        point: currentLocation!,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent,
                  border: Border.all(
                    color: Colors.blue,
                    width: 2.0,
                  )),
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blue.withOpacity(0.3),
              ),
            ),
            Image.asset(ImageManager.currentLocation, width: 40, height: 40)
          ],
        ),
      ),
    );

    routePoints.clear();
    destination = null;
    markers.clear();

    markers.add(currentLocationMarker);
    notifyListeners();
  }
}

void _showDetailsDialog(BuildContext context, String content) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Place Details'),
        content: Text(content),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      );
    },
  );
}
