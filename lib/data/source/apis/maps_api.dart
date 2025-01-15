import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/utils/constants/apis.dart';

abstract class MapsApiInterface {
  Future<Map<String, dynamic>?> getRoute(LatLng start, LatLng destination);
  Future<Map<String, dynamic>?> getPlaceDetails(LatLng point);
  Future<List<Map<String, dynamic>>> searchLocation(String query);
}

class MapsWebService implements MapsApiInterface {
  final Dio _dio;

  MapsWebService(this._dio);

  @override
  Future<Map<String, dynamic>?> getRoute(
      LatLng start, LatLng destination) async {
    try {
      final response = await _dio.get(
        '${ApiManager.directionsBaseUrl}/${ApiManager.directionsEndPoint}',
        queryParameters: {
          'api_key': ApiManager.apiKey,
          'start': '${start.longitude},${start.latitude}',
          'end': '${destination.longitude},${destination.latitude}',
        },
      );
      log("driving-car ${response.data}");

      if (response.statusCode == 200) {
        return response.data;
      } else {
        log('Failed to fetch route');
        return null;
      }
    } catch (e) {
      log('Error fetching route: $e');
      return null;
    }
  }

  @override
  Future<Map<String, dynamic>?> getPlaceDetails(LatLng point) async {
    try {
      final response = await _dio.get(
        '${ApiManager.placesBaseUrl}/${ApiManager.addressDetailsEndPoint}',
        queryParameters: {
          'lat': point.latitude,
          'lon': point.longitude,
          'format': 'json',
          'addressdetails': 1,
        },
      );
      log("addressdetails ${response.data}");

      if (response.statusCode == 200) {
        return response.data;
      } else {
        log('Failed to fetch place details');
        return null;
      }
    } catch (e) {
      log('Error fetching place details: $e');
      return null;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> searchLocation(String query) async {
    try {
      final response = await _dio.get(
        '${ApiManager.placesBaseUrl}/${ApiManager.searchEndPoint}',
        queryParameters: {
          'q': '$query,Egypt',
          'format': 'json',
          'addressdetails': 1,
          'limit': 5,
        },
      );
      log("search ${response.data}");

      if (response.statusCode == 200) {
        return (response.data as List).cast<Map<String, dynamic>>();
      } else {
        log('Failed to search location');
        return [];
      }
    } catch (e) {
      log('Error searching location: $e');
      return [];
    }
  }
}
