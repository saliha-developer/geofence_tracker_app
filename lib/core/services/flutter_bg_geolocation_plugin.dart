//import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;

//flutter_background_geolocation.This plugin need license for working in Android.Only for debug build it will work.So not used for now.
// Future<void> _configureBackgroundGeolocation() async {
//   try{
//    // bg.BackgroundGeolocation.onLocation((bg.Location location) {
//    //    _logEvent("Location:", location);
//    //  });
//
//    bg.BackgroundGeolocation.onGeofence((bg.GeofenceEvent event) {
//       _logEvent("Geofence:", event);
//     });
//    await bg.BackgroundGeolocation.ready(bg.Config(
//        desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
//        distanceFilter: 10.0,
//        stopOnTerminate: false,
//        startOnBoot: true,
//        debug: true,
//        logLevel: bg.Config.LOG_LEVEL_VERBOSE,
//        enableHeadless: true,
//        forceReloadOnMotionChange: true,
//        forceReloadOnLocationChange: true,
//        deferTime: 120000 // 2 minutes in milliseconds
//    ));
//
//     await bg.BackgroundGeolocation.start();
//   } catch (e) {
//     // _logEvent("Geofence Error:");
//   }
// }

// void _addGeofenceListeners() {
//   bg.BackgroundGeolocation.onGeofence((bg.GeofenceEvent event) {
//     final index = _geofences.indexWhere((g) => g.id == event.identifier);
//     if (index != -1) {
//       _showGeofenceNotification(event);
//       updateGeofenceStatus(event.identifier, event.action == 'ENTER');
//     }
//     _logEvent('Geofence Event', event);
//   });
// }

// _showGeofenceNotification(bg.GeofenceEvent event){
//   final isInsideNow = event.action == 'ENTER';
//   NotificationService.showNotification(
//     isInsideNow ? "${event.extras!['title']} Entered Alert" : "${event.extras!['title']} Exited Alert",
//     "You have ${isInsideNow ? "entered to your '${event.extras!['title']}' location" : "exited from your '${event.extras!['title']}' location"}",
//   );
// }

// void _logEvent(String type, bg.GeofenceEvent event) {
//   final String eventString = '$type ${event.toString()}';
//   print(eventString);
//   final HistoryModel historyModel = HistoryModel(
//     timestamp: DateTime.now(),
//     geofenceId: event.identifier,
//     title: event.extras!.containsKey('title') ? event.extras!['title'] : '',
//     entered: event.action == 'ENTER',
//     latitude: event.location.coords.latitude,
//     longitude: event.location.coords.longitude,
//   );
//   logEvent(historyModel);
// }
//
// void _updateBackgroundGeofences() {
//   final List<bg.Geofence> geofences = [];
//   for (final GeofenceModel geofence in _geofences) {
//     geofences.add(bg.Geofence(
//       identifier: geofence.id,
//       radius: geofence.radius,
//       latitude: geofence.latitude,
//       longitude: geofence.longitude,
//       notifyOnEntry: true,
//       notifyOnExit: true,
//       extras: {'title': geofence.title},
//     ));
//   }
//   bg.BackgroundGeolocation.removeGeofences();
//   bg.BackgroundGeolocation.addGeofences(geofences);
// }