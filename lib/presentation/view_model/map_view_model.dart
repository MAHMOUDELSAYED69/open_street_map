import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

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

  MapViewModel(this.mapsRepository, this.locationService);

  Future<void> fetchCurrentLocation() async {
    final location = await locationService.getCurrentLocation();
    if (location != null) {
      currentLocation = location;

      markers.add(
        Marker(
          width: 80.0,
          height: 80.0,
          point: currentLocation!,
          child: const Icon(
            Icons.my_location_rounded,
            color: Colors.blue,
            size: 40.0,
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
        width: 80.0,
        height: 80.0,
        point: destination,
        child: const Icon(
          Icons.location_on,
          color: Colors.red,
          size: 40.0,
        ),
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
        width: 80.0,
        height: 80.0,
        point: currentLocation!,
        child: const Icon(
          Icons.my_location_rounded,
          color: Colors.blue,
          size: 40.0,
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
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
