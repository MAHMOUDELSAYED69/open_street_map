class RouteResponse {
  final String type;
  final List<double> bbox;
  final List<Feature> features;

  RouteResponse({
    required this.type,
    required this.bbox,
    required this.features,
  });

  factory RouteResponse.fromJson(Map<String, dynamic> json) {
    return RouteResponse(
      type: json['type'],
      bbox: List<double>.from(json['bbox']),
      features: (json['features'] as List)
          .map((feature) => Feature.fromJson(feature))
          .toList(),
    );
  }
}

class Feature {
  final String type;
  final List<double> bbox;
  final Properties properties;
  final Geometry geometry;

  Feature({
    required this.type,
    required this.bbox,
    required this.properties,
    required this.geometry,
  });

  factory Feature.fromJson(Map<String, dynamic> json) {
    return Feature(
      type: json['type'],
      bbox: List<double>.from(json['bbox']),
      properties: Properties.fromJson(json['properties']),
      geometry: Geometry.fromJson(json['geometry']),
    );
  }
}

class Properties {
  final List<Segment> segments;
  final Summary summary;

  Properties({
    required this.segments,
    required this.summary,
  });

  factory Properties.fromJson(Map<String, dynamic> json) {
    return Properties(
      segments: (json['segments'] as List)
          .map((segment) => Segment.fromJson(segment))
          .toList(),
      summary: Summary.fromJson(json['summary']),
    );
  }
}

class Segment {
  final double distance;
  final double duration;
  final List<Step> steps;

  Segment({
    required this.distance,
    required this.duration,
    required this.steps,
  });

  factory Segment.fromJson(Map<String, dynamic> json) {
    return Segment(
      distance: json['distance'],
      duration: json['duration'],
      steps:
          (json['steps'] as List).map((step) => Step.fromJson(step)).toList(),
    );
  }
}

class Step {
  final double distance;
  final double duration;
  final int type;
  final String instruction;
  final String name;
  final List<int> wayPoints;

  Step({
    required this.distance,
    required this.duration,
    required this.type,
    required this.instruction,
    required this.name,
    required this.wayPoints,
  });

  factory Step.fromJson(Map<String, dynamic> json) {
    return Step(
      distance: json['distance'],
      duration: json['duration'],
      type: json['type'],
      instruction: json['instruction'],
      name: json['name'],
      wayPoints: List<int>.from(json['way_points']),
    );
  }
}

class Summary {
  final double distance;
  final double duration;

  Summary({
    required this.distance,
    required this.duration,
  });

  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      distance: json['distance'],
      duration: json['duration'],
    );
  }
}

class Geometry {
  final List<List<double>> coordinates;
  final String type;

  Geometry({
    required this.coordinates,
    required this.type,
  });

  factory Geometry.fromJson(Map<String, dynamic> json) {
    return Geometry(
      coordinates: (json['coordinates'] as List)
          .map((coord) => List<double>.from(coord))
          .toList(),
      type: json['type'],
    );
  }
}

class AddressDetails {
  final String placeId;
  final String displayName;
  final double lat;
  final double lon;
  final Address address;

  AddressDetails({
    required this.placeId,
    required this.displayName,
    required this.lat,
    required this.lon,
    required this.address,
  });

  factory AddressDetails.fromJson(Map<String, dynamic> json) {
    return AddressDetails(
      placeId: json['place_id'].toString(),
      displayName: json['display_name'],
      lat: double.parse(json['lat']), // Parse latitude
      lon: double.parse(json['lon']), // Parse longitude
      address: Address.fromJson(json['address']),
    );
  }
}

class Address {
  final String road;
  final String town;
  final String state;
  final String country;
  final String postcode;

  Address({
    required this.road,
    required this.town,
    required this.state,
    required this.country,
    required this.postcode,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      road: json['road'] ?? '',
      town: json['town'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      postcode: json['postcode'] ?? '',
    );
  }
}
