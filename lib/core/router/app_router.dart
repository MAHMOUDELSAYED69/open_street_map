import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:open_street_map/presentation/view/map.dart';
import 'package:provider/provider.dart';
import '../../presentation/view/splash.dart';
import '../../presentation/view_model/map_view_model.dart';
import '../utils/constants/routes.dart';
import '../../data/repository/map_repository.dart';
import '../../data/source/apis/maps_api.dart';
import '../services/location/location_permission.dart';
import 'page_transition.dart';

class AppRouter {
  const AppRouter._();
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteManager.initial:
        return PageTransitionManager.fadeTransition(const SplashScreen());
      case RouteManager.map:
        final dio = Dio();
        final mapsApi = MapsApi(dio);
        final mapsRepository = MapsRepository(mapsApi);
        final locationService = LocationService();
        final mapController = MapController();

        return PageTransitionManager.fadeTransition(
          ChangeNotifierProvider(
            create: (_) => MapViewModel(
              mapsRepository,
              locationService,
            ),
            child: MapScreen(
              mapController: mapController,
            ),
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
