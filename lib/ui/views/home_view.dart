import 'package:flutter/material.dart';
import 'package:geofence_tracker_app/core/utils/constants.dart';
import 'package:geofence_tracker_app/ui/viewmodels/geofence_viewmodel.dart';
import 'package:provider/provider.dart';

import '../../core/services/geofence_service.dart';
import '../widgets/geofence_card_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _geofenceService = GeofenceService();

  @override
  void initState() {
    super.initState();
    _geofenceService.startTracking(context);
  }

  @override
  Widget build(BuildContext context) {
    final geofenceData = context.watch<GeofenceViewModel>().geofences;

    return Scaffold(
      backgroundColor: appBgColor,
      appBar: AppBar(
        backgroundColor: appBgColor,
        title: const Text('Geofence Tracker',style: TextStyle(color: appColor),),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history,color: appColor,),
            onPressed: () => Navigator.pushNamed(context, '/history'),
          )
        ],
      ),
      body: geofenceData.isEmpty
          ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('No geofence data available!',style : TextStyle(fontSize: 14,color : Colors.black)),
                SizedBox(height: 8,),
                SizedBox(width: MediaQuery.of(context).size.width * 0.7,child: Text('Press + button to add new geofence to track your entry/exit location',style: TextStyle(color: Colors.black, fontSize: 14),textAlign: TextAlign.center,)),
              ],
            ),
          )
          : ListView.builder(
        itemCount: geofenceData.length,
        itemBuilder: (context, index) {
          final geofence = geofenceData[index];
          return GeofenceCard(
            geofence: geofence,
            onDelete: () {
              showDeleteAlert(context, geofence);
            },
            onEdit: () {
              Navigator.pushNamed(context, '/add', arguments: geofence);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add'),
        child: const Icon(Icons.add),
      ),
    );
  }

  showDeleteAlert(BuildContext context,var geofence) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Text("Are you sure to delete ?",style: TextStyle(fontSize: 16),),
          actions: <Widget>[
            TextButton(
              child: Text("YES",style: TextStyle(color: Colors.black)),
              onPressed: () {
                context.read<GeofenceViewModel>().deleteGeofence(geofence.id);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("NO",style: TextStyle(color: Colors.black)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _geofenceService.stopTracking();
    super.dispose();
  }

}
