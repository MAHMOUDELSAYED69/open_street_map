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
        _buildTooltipButton(
          message:
              viewModel.isDriverMode ? "Disable Test Mode" : "Enable Test Mode",
          color: viewModel.isDriverMode ? Colors.red : Colors.green,
          heroTag: "test_mode",
          onPressed: () =>
              viewModel.testDriverMode(increase: false, step: 0.005),
          backgroundColor: viewModel.isDriverMode ? Colors.green : Colors.grey,
          icon: Icons.arrow_circle_up_rounded,
        ),
        const SizedBox(height: 10),
        _buildTooltipButton(
          message: viewModel.isDriverMode
              ? "Disable Driver Mode"
              : "Enable Driver Mode",
          color: viewModel.isDriverMode ? Colors.red : Colors.green,
          heroTag: "driver_mode",
          onPressed: () => viewModel.toggleDriverMode(),
          backgroundColor: viewModel.isDriverMode ? Colors.green : Colors.grey,
          icon: Icons.drive_eta,
        ),
        const SizedBox(height: 10),
        _buildSmallButton(
          heroTag: "search_location",
          onPressed: () {
            if (viewModel.destination != null) {
              _mapController.move(viewModel.destination!, 16.0);
            }
          },
          asset: ImageManager.searchedLocation,
        ),
        const SizedBox(height: 10),
        _buildSmallButton(
          heroTag: "current_location",
          onPressed: () {
            if (viewModel.currentLocation != null) {
              _mapController.move(viewModel.currentLocation!, 16.0);
            }
          },
          asset: ImageManager.currentLocation,
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

  Widget _buildTooltipButton({
    required String message,
    required Color color,
    required String heroTag,
    required VoidCallback onPressed,
    required Color backgroundColor,
    required IconData icon,
  }) {
    return Tooltip(
      verticalOffset: -60,
      message: message,
      decoration: BoxDecoration(color: color),
      child: FloatingActionButton(
        heroTag: heroTag,
        onPressed: onPressed,
        backgroundColor: backgroundColor,
        child: Icon(icon),
      ),
    );
  }

  Widget _buildSmallButton({
    required String heroTag,
    required VoidCallback onPressed,
    required String asset,
  }) {
    return FloatingActionButton.small(
      heroTag: heroTag,
      onPressed: onPressed,
      child: Image.asset(
        asset,
        color: Colors.black,
        width: 20,
        height: 20,
      ),
    );
  }
}
