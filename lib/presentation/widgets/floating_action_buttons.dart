import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import '../../utils/constants/images.dart';
import '../view_model/map_view_model.dart';

class FloatingActionButtonWidgets extends StatelessWidget {
  const FloatingActionButtonWidgets({
    super.key,
    required this.viewModel,
    required MapController mapController,
  }) : _mapController = mapController;

  final MapViewModel viewModel;
  final MapController _mapController;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton.small(
          heroTag: "search_location",
          onPressed: () {
            if (viewModel.destination != null) {
              _mapController.move(viewModel.destination!, 16.0);
            }
          },
          child: Image.asset(
            ImageManager.searchedLocation,
            color: Colors.black,
            width: 20,
            height: 20,
          ),
        ),
        const SizedBox(height: 10),
        FloatingActionButton.small(
          heroTag: "current_location",
          onPressed: () {
            if (viewModel.currentLocation != null) {
              _mapController.move(viewModel.currentLocation!, 16.0);
            }
          },
          child: Image.asset(
            ImageManager.currentLocation,
            color: Colors.black,
            width: 20,
            height: 20,
          ),
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
    );
  }
}
