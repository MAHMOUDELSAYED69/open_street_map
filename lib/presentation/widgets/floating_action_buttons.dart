import 'package:flutter/foundation.dart';
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
    final buttonsVerticalSpacing = SizedBox(height: kIsWeb ? 10 : 5);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (kDebugMode)
          _buildTooltipSmallButton(
            name: "Test",
            heroTag: "test_mode",
            onPressed: () =>
                viewModel.testDriverMode(increase: false, step: 0.005),
            image: ImageManager.test,
          ),
        buttonsVerticalSpacing,
        _buildTooltipSmallButton(
          name: "Driver",
          heroTag: "driver_mode",
          onPressed: () => viewModel.toggleDriverMode(),
          image: ImageManager.car,
        ),
        buttonsVerticalSpacing,
        _buildSmallButton(
          heroTag: "search_location",
          onPressed: () {
            if (viewModel.destination != null) {
              _mapController.move(viewModel.destination!, 16.0);
            }
          },
          image: ImageManager.searchedLocation,
        ),
        buttonsVerticalSpacing,
        _buildSmallButton(
          heroTag: "current_location",
          onPressed: () {
            if (viewModel.currentLocation != null) {
              _mapController.move(viewModel.currentLocation!, 16.0);
            }
          },
          image: ImageManager.currentLocation,
        ),
        buttonsVerticalSpacing,
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

  Widget _buildTooltipSmallButton({
    required String name,
    required String heroTag,
    required VoidCallback onPressed,
    required String image,
  }) {
    return Tooltip(
      verticalOffset: -60,
      message:
          viewModel.isDriverMode ? "Disable $name Mode" : "Enable $name Mode",
      decoration: BoxDecoration(
        color: viewModel.isDriverMode ? Colors.red : Colors.green,
      ),
      child: FloatingActionButton.small(
        heroTag: heroTag,
        onPressed: onPressed,
        backgroundColor: viewModel.isDriverMode ? Colors.green : Colors.grey,
        child: Image.asset(
          image,
          width: 30,
          height: 30,
        ),
      ),
    );
  }

  Widget _buildSmallButton({
    required String heroTag,
    required VoidCallback onPressed,
    required String image,
  }) {
    return FloatingActionButton.small(
      heroTag: heroTag,
      onPressed: onPressed,
      child: Image.asset(
        image,
        color: Colors.black,
        width: 20,
        height: 20,
      ),
    );
  }
}
