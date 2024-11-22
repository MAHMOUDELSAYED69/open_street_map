import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  runApp(MyApp(
    locationService: locationService,
    mapsRepository: mapsRepository,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.mapsRepository,
    required this.locationService,
  });

  final MapsRepository mapsRepository;
  final LocationService locationService;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MapViewModel(mapsRepository, locationService),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        routes: {
          RouteManager.initial: (BuildContext context) => const SplashScreen(),
          RouteManager.map: (BuildContext context) => const MapScreen(),
          RouteManager.settings: (BuildContext context) => const Scaffold(),
        },
        initialRoute: RouteManager.initial,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
      ),
    );
  }
}
