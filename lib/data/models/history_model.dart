class HistoryModel {
  final String geofenceId;
  final String title;
  final bool entered;
  final DateTime timestamp;
  final double latitude;
  final double longitude;

  HistoryModel({
    required this.geofenceId,
    required this.title,
    required this.entered,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() => {
    'geofenceId': geofenceId,
    'title': title,
    'entered': entered,
    'timestamp': timestamp.toIso8601String(),
    'latitude': latitude,
    'longitude': longitude,
  };

  factory HistoryModel.fromJson(Map<String, dynamic> json) => HistoryModel(
    geofenceId: json['geofenceId'],
    title: json['title'],
    entered: json['entered'],
    timestamp: DateTime.parse(json['timestamp']),
    latitude: json['latitude'],
    longitude: json['longitude'],
  );
}
