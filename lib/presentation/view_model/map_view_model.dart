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

  MapViewModel(this.mapsRepository, this.locationService,);

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
    _locationSubscription =
        locationService.onLocationChanged().listen((newLocation) {
      currentLocation = newLocation;
      updateDriverMarker(newLocation);

      if (destination != null) {
        getRoute(destination!);
      }
      notifyListeners();
    });
    isDriverMode = true;
    notifyListeners();
  }

  void stopDriverMode() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
    isDriverMode = false;
    notifyListeners();
  }

  void updateDriverMarker(LatLng newLocation) {
    markers.removeWhere((marker) =>
        marker.child is Image &&
        (marker.child as Image).image == AssetImage(ImageManager.car));
    markers.add(
      Marker(
        width: 50.0,
        height: 50.0,
        point: newLocation,
        child: Image.asset(ImageManager.car, width: 50, height: 50),
      ),
    );
    // startCameraUpdate();
  }

  // void startCameraUpdate() {
  //   Timer(const Duration(minutes: 1), () {
  //     if (isDriverMode && currentLocation != null ||
  //         isDriverMode != false && currentLocation != null) {
  //       mapController.move(currentLocation!, 16.0);
  //       startCameraUpdate();
  //     }
  //   });
  // }

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

    if (this.destination != destination) {
      this.destination = destination;

      markers.add(
        Marker(
          width: 40.0,
          height: 40.0,
          point: destination,
          child: Image.asset(ImageManager.searchedLocation),
        ),
      );
    }

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
    stopDriverMode();
    markers.clear();
    routePoints.clear();
    destination = null;

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
            Image.asset(ImageManager.currentLocation, width: 40, height: 40),
          ],
        ),
      ),
    );

    notifyListeners();
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

  void testDriverMode({bool increase = true, double step = 0.001}) {
    if (currentLocation == null) {
      debugPrint(
          "Current location is not set. Please fetch the current location first.");
      return;
    }

    stopDriverMode();

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!isDriverMode) {
        timer.cancel();
        return;
      }

      currentLocation = LatLng(
        currentLocation!.latitude + (increase ? step : -step),
        currentLocation!.longitude + (increase ? step : -step),
      );

      updateDriverMarker(currentLocation!);

      if (destination != null) {
        getRoute(destination!);
      }

      notifyListeners();
    });

    isDriverMode = true;
    notifyListeners();
  }
}
