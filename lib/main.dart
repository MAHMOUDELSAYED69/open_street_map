import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';
import 'data/repository/map_repository.dart';
import 'data/services/apis/maps_api.dart';
import 'data/services/location/location_permission.dart';
import 'presentation/view/map.dart';
import 'presentation/view/splash.dart';
import 'presentation/view_model/map_view_model.dart';
import 'utils/constants/routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  final dio = Dio();
  final mapsApi = MapsApi(dio);
  final mapsRepository = MapsRepository(mapsApi);
  final locationService = LocationService();
  final mapController = MapController();

  runApp(MyApp(
    locationService: locationService,
    mapsRepository: mapsRepository,
    mapController: mapController,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.mapsRepository,
    required this.locationService,
    required this.mapController,
  });

  final MapsRepository mapsRepository;
  final LocationService locationService;
  final MapController mapController;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MapViewModel(
        mapsRepository,
        locationService,
        mapController,
      ),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Open Street Map',
        routes: {
          RouteManager.initial: (_) => const SplashScreen(),
          RouteManager.map: (_) => MapScreen(
                mapController: mapController,
              ),
          RouteManager.settings: (_) => const Scaffold(),
        },
        initialRoute: kIsWeb ? RouteManager.map : RouteManager.initial,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          appBarTheme: const AppBarTheme(
            color: Colors.blue,
          ),
          buttonTheme: const ButtonThemeData(
            buttonColor: Colors.blue,
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Colors.blue,
          ),
        ),
      ),
    );
  }
}
