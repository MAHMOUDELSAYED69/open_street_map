import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:provider/provider.dart';

import '../view_model/map_view_model.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late MapController _mapController;
  late TextEditingController _searchController;
  bool _isInitialized = false;
  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _mapController = MapController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInitialized) {
      Provider.of<MapViewModel>(context, listen: false).fetchCurrentLocation();
      _isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<MapViewModel>(context, listen: false);
    return Scaffold(
      body: Consumer<MapViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.currentLocation == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: viewModel.currentLocation!,
                  initialZoom: 16.0,
                  onTap: (tapPosition, point) => viewModel.getRoute(point),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    userAgentPackageName: 'flutter_map',
                    subdomains: const ['a', 'b', 'c'],
                  ),
                  MarkerLayer(
                    markers: viewModel.markers,
                  ),
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: viewModel.routePoints,
                        strokeWidth: 4.0,
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ],
              ),
              Positioned(
                top: 50.0,
                left: 10.0,
                right: 10.0,
                child: Card(
                  child: ListTile(
                    leading: const Icon(Icons.search),
                    title: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search location',
                        border: InputBorder.none,
                      ),
                      onChanged: (value) => viewModel.searchLocation(value),
                    ),
                    trailing: viewModel.isSearching
                        ? const CircularProgressIndicator()
                        : IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              viewModel.searchLocation('');
                            },
                          ),
                  ),
                ),
              ),
              if (viewModel.searchResults.isNotEmpty)
                Positioned(
                  top: 90.0,
                  left: 10.0,
                  right: 10.0,
                  child: Card(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: viewModel.searchResults.length,
                      itemBuilder: (context, index) {
                        final result = viewModel.searchResults[index];
                        return ListTile(
                          title: Text(result.displayName),
                          onTap: () {
                            final point = LatLng(result.lat, result.lon);
                            _mapController.move(point, 16.0);
                            viewModel.getRoute(point);
                            viewModel.searchLocation('');
                            _searchController.clear();
                          },
                        );
                      },
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: "search_location",
            onPressed: () {
              if (viewModel.destination != null) {
                _mapController.move(viewModel.destination!, 16.0);
              }
            },
            child: const Icon(Icons.search),
          ),
          const SizedBox(height: 10),
          FloatingActionButton.small(
            heroTag: "current_location",
            onPressed: () {
              if (viewModel.currentLocation != null) {
                _mapController.move(viewModel.currentLocation!, 16.0);
              }
            },
            child: const Icon(Icons.my_location),
          ),
          const SizedBox(height: 10),
          FloatingActionButton.small(
            heroTag: "reset",
            onPressed: () {
              viewModel.resetMap();
              _mapController.move(viewModel.currentLocation!, 10.0);
            },
            child: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }
}
