import 'package:flutter/material.dart';
import 'package:geofence_tracker_app/ui/viewmodels/geofence_viewmodel.dart';
import 'package:geofence_tracker_app/ui/views/add_geofence_view.dart';
import 'package:geofence_tracker_app/ui/views/history_view.dart';
import 'package:geofence_tracker_app/ui/views/home_view.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';

import 'core/services/notification_service.dart';
import 'core/utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _handlePermissions();
  await NotificationService.init();
  runApp(const GeofenceTrackerApp());
}

Future<void> _handlePermissions() async {
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    await Geolocator.requestPermission();
  }
}

class GeofenceTrackerApp extends StatelessWidget {
  const GeofenceTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GeofenceViewModel(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Geofence Tracker',
        theme: ThemeData(
          useMaterial3: false,
          primarySwatch: appColor,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const HomeScreen(),
          '/add': (context) => AddGeofenceScreen(),
          '/history': (context) => const HistoryScreen(),
        },
      ),
    );
  }
}