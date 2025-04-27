import 'dart:async';
import 'package:geofence_tracker_app/ui/viewmodels/geofence_viewmodel.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/history_model.dart';
import 'notification_service.dart';

class GeofenceService {
  Timer? _timer;

  void startTracking(BuildContext context) {
    //change to 2 minutes
    _timer = Timer.periodic(const Duration(minutes: 2), (_) {
      _checkGeofences(context);
    });
  }

  void stopTracking() {
    _timer?.cancel();
  }

  Future<void> _checkGeofences(BuildContext context) async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    final provider = Provider.of<GeofenceViewModel>(context, listen: false);
    for (var geofence in provider.geofences) {
      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        geofence.latitude,
        geofence.longitude,
      );

      final isInsideNow = distance <= geofence.radius;
      if (isInsideNow != geofence.isInside) {
        provider.updateGeofenceStatus(geofence.id, isInsideNow);
        var currentLocationModel = HistoryModel(
          geofenceId: geofence.id,
          title: geofence.title,
          entered: isInsideNow,
          timestamp: DateTime.now(),
          latitude: geofence.latitude,
          longitude : geofence.longitude,
        );
        print("Logging event ::: ${currentLocationModel.toJson()}");
        provider.logEvent(currentLocationModel);
        NotificationService.showNotification(
          isInsideNow ? "${geofence.title} Entered Alert" : "${geofence.title} Exited Alert",
          "You have ${isInsideNow ? "entered to your '${geofence.title}' location" : "exited from your '${geofence.title}' location"}",
        );
      }

      // void _resetIdleTimer() {
      //   _idleTimer?.cancel();
      //   _idleTimer = Timer(const Duration(minutes: 2), () {
      //     // If idle for 2 minutes, we can pause tracking
      //     _isIdle = true;
      //     notifyListeners();
      //
      //     _logEvent("Idle", "User is idle for 2 minutes");
      //     stopTracking();
      //   });
      // }
    }
  }
}
