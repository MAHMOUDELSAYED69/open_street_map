import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';
import 'package:open_street_map/presentation/widgets/loding_indicator.dart';
import 'package:provider/provider.dart';

import '../view_model/map_view_model.dart';

class FloatingSearchBarWidget extends StatelessWidget {
  const FloatingSearchBarWidget({super.key, required this.mapController});
  final MapController mapController;
  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<MapViewModel>(context);

    return SafeArea(
      child: SizedBox(
        child: FloatingSearchBar(
          hint: 'Search location...',
          scrollPadding: const EdgeInsets.only(top: 16),
          transitionDuration: const Duration(milliseconds: 800),
          transitionCurve: Curves.easeInOut,
          physics: const BouncingScrollPhysics(),
          onQueryChanged: (query) {
            if (query.isNotEmpty) {
              viewModel.searchLocation(query);
            }
          },
          builder: (context, transition) {
            final results = viewModel.searchResults;

            return Material(
              elevation: 4.0,
              borderRadius: BorderRadius.circular(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (viewModel.isSearching) const MyLinearLoadingIndicator(),
                  if (results.isEmpty && !viewModel.isSearching)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('No results found'),
                      ),
                    ),
                  if (results.isNotEmpty)
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final result = results[index];
                        return ListTile(
                          title: Text(result.displayName),
                          onTap: () {
                            final point = LatLng(result.lat, result.lon);
                            mapController.move(point, 16.0);
                            viewModel.getRoute(point);
                            FloatingSearchBar.of(context)?.close();
                          },
                        );
                      },
                    ),
                ],
              ),
            );
          },
          actions: [
            FloatingSearchBarAction.searchToClear(
              showIfClosed: false,
            ),
          ],
        ),
      ),
    );
  }
}
