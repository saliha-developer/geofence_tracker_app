class GeofenceModel {
  String id;
  String title;
  double latitude;
  double longitude;
  double radius;
  DateTime timestamp;
  bool isInside;

  GeofenceModel({
    required this.id,
    required this.title,
    required this.latitude,
    required this.longitude,
    required this.radius,
    required this.timestamp,
    this.isInside = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'latitude': latitude,
    'longitude': longitude,
    'radius': radius,
    'timestamp': timestamp.toIso8601String(),
    'isInside': isInside,
  };

  factory GeofenceModel.fromJson(Map<String, dynamic> json) => GeofenceModel(
    id: json['id'],
    title: json['title'],
    latitude: json['latitude'],
    longitude: json['longitude'],
    radius: json['radius'],
    timestamp: DateTime.parse(json['timestamp']),
    isInside: json['isInside'],
  );
}