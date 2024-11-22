import 'package:latlong2/latlong.dart';
import '../model/maps_models.dart';
import '../services/apis/maps_api.dart';

abstract class MapsRepositoryInterface {
  Future<RouteResponse?> fetchRoute(LatLng start, LatLng destination);
  Future<AddressDetails?> fetchPlaceDetails(LatLng point);
  Future<List<AddressDetails>> searchLocation(String query);
}


class MapsRepository implements MapsRepositoryInterface {
  final MapsApiInterface mapsApi;

  MapsRepository(this.mapsApi);

  @override
  Future<RouteResponse?> fetchRoute(LatLng start, LatLng destination) async {
    final rawData = await mapsApi.getRoute(start, destination);
    if (rawData != null) {
      return RouteResponse.fromJson(rawData);
    }
    return null;
  }

  @override
  Future<AddressDetails?> fetchPlaceDetails(LatLng point) async {
    final rawData = await mapsApi.getPlaceDetails(point);
    if (rawData != null) {
      return AddressDetails.fromJson(rawData);
    }
    return null;
  }

  @override
  Future<List<AddressDetails>> searchLocation(String query) async {
    final rawDataList = await mapsApi.searchLocation(query);
    return rawDataList.map((data) => AddressDetails.fromJson(data)).toList();
  }
}
