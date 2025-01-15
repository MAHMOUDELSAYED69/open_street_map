import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';
import '../view_model/map_view_model.dart';
import '../widgets/floating_action_buttons.dart';
import '../widgets/floating_search_bar.dart';
import '../widgets/loading_indicator.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key, required this.mapController});
  final MapController mapController;
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  bool _isInitialized = false;

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
    final viewModel = Provider.of<MapViewModel>(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Consumer<MapViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.currentLocation == null) {
                return const Center(child: MyCircularLoadingIndicator());
              }

              return FlutterMap(
                mapController: widget.mapController,
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
              );
            },
          ),
          FloatingSearchBarWidget(
            mapController: widget.mapController,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButtonWidgets(
        viewModel: viewModel,
        mapController: widget.mapController,
      ),
    );
  }
}
