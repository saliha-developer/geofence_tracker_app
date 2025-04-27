import 'package:flutter/material.dart';
import 'package:geofence_tracker_app/core/utils/constants.dart';
import 'package:geofence_tracker_app/ui/viewmodels/geofence_viewmodel.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../data/models/HistoryTabModel.dart';
import '../../data/models/geofence_model.dart';
import '../../data/models/history_model.dart';
import 'package:intl/intl.dart';


class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final Map<String, Polyline> _polylines = {};
  final Map<String, Color> _geofenceColors = {};
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};

  @override
  Widget build(BuildContext context) {
    final historyModel = context.watch<GeofenceViewModel>();
    final history = historyModel.history;
    final geofences = historyModel.geofences;
    _plotHistoryOnMap(history, geofences);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Movement History'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'List', icon: Icon(Icons.list)),
              Tab(text: 'Map', icon: Icon(Icons.route)),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                if(historyModel.history.isNotEmpty)
                {
                  showAlert(context,historyModel);
                } else{
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No history to clear')),
                  );
                }
              },
            ),
          ],
        ),
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildListView(history),
            _buildMapView(history),
          ],
        ),
      ),
    );
  }

  Widget _buildListView(List<HistoryModel> history) {
    return history.isEmpty
        ? const Center(child: Text('No history yet.'))
        : Column(
      children: [
        Expanded(
          child: ListView.separated(
            itemCount: history.length,
            shrinkWrap: false,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = history[index];
              var modelItem = HistoryTabModel(
                title: item.title,
                dateTime: item.timestamp,
                geofenceData: history.where((element) => element.timestamp.day == item.timestamp.day && element.timestamp.month == item.timestamp.month && element.timestamp.year == item.timestamp.year).toList(),
              );
              return historyContainer(modelItem);
            },
          ),
        ),
      ],
    );
  }

  historyContainer(HistoryTabModel historyData){
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(backgroundColor : Color(0xFFeaeafb),child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.location_on,color: appColor,size: 18,),
          )),
          SizedBox(width : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${historyData.title!} ( ${convertTimeStampToDate(historyData.dateTime!.millisecondsSinceEpoch,"dd-MM-yyyy")} )',style : TextStyle(color: Colors.black,fontWeight: FontWeight.w500,fontSize: 16)),
                SizedBox(height : 8),
                ListView.builder(
                    itemCount: historyData.geofenceData!.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (BuildContext context, int position) {
                      final item = historyData.geofenceData![position];
                      return SizedBox(
                        height : 35,
                        child: Column(
                          children: [
                            Row(
                                children : [
                                  Icon(
                                    item.entered ? Icons.call_made : Icons.call_received,
                                    color: item.entered ? Colors.green : Colors.red,size: 12,
                                  ),
                                  SizedBox(width : 5),
                                  Text(
                                    '${convertTimeStampToDate(item.timestamp.millisecondsSinceEpoch,"hh:mm a")}',
                                  )
                                ]
                            )
                          ],
                        ),
                      );
                    }
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapView(List<HistoryModel> history) {
    if (history.isEmpty) {
      return const Center(child: Text('No location points to show.'));
    }
    final first = history.first;
    final initialPos = CameraPosition(
      target: LatLng(first.latitude, first.longitude),
      zoom: 14,
    );

    for (var item in history)
    {
      var marker = Marker(
        markerId: MarkerId('${item.timestamp}-${item.entered}'),
        position: LatLng(item.latitude, item.longitude),
        infoWindow: InfoWindow(
          title: item.title,
          snippet: '${item.entered ? "Entered " : "Exited"} at ${convertTimeStampToDate(item.timestamp.millisecondsSinceEpoch,"dd-MM-yyyy hh:mm a")}',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          item.entered ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueRed,
        ),
      );
      _markers.add(marker);
    }


    return GoogleMap(
      initialCameraPosition: initialPos,
      markers: _markers,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      polylines: Set<Polyline>.of(_polylines.values),
      onMapCreated: (GoogleMapController controller) {
        _mapController = controller;
      },
    );
  }

  convertTimeStampToDate(int timeInMillis, String format) {
    String formattedDate = "";
    var date = DateTime.fromMillisecondsSinceEpoch(timeInMillis);
    DateFormat formatter = DateFormat(format);
    formattedDate = formatter.format(date);
    return formattedDate;
  }

  void _plotHistoryOnMap(List<HistoryModel> history, List<GeofenceModel> geofences) {
    _polylines.clear();
    _markers.clear();

    for (final geofence in geofences) {
      _geofenceColors[geofence.id] = _geofenceColors[geofence.id] ?? _getRandomColor(geofence.id);
    }

    Map<String, List<LatLng>> geofencePaths = {};
    for (final historyItem in history) {
      String geofenceId = geofences
          .where((geofence) => Geolocator.distanceBetween(
          historyItem.latitude,
          historyItem.longitude,
          geofence.latitude,
          geofence.longitude) <= geofence.radius)
          .map((geofence) => geofence.id)
          .firstOrNull ??
          "outside_geofences"; // Default to "outside_geofences" if not in any geofence

      if (!geofencePaths.containsKey(geofenceId)) {
        geofencePaths[geofenceId] = [];
      }
      geofencePaths[geofenceId]!.add(LatLng(historyItem.latitude, historyItem.longitude));

      _markers.add(
        Marker(
          markerId: MarkerId('${historyItem.timestamp.millisecondsSinceEpoch}'),
          position: LatLng(historyItem.latitude, historyItem.longitude),
          infoWindow: InfoWindow(
            title: historyItem.title ?? "",
            snippet: '${historyItem.entered ? "Entered " : "Exited"} at ${convertTimeStampToDate(historyItem.timestamp.millisecondsSinceEpoch,"dd-MM-yyyy hh:mm a")}',
          ),
        ),
      );
    }

    geofencePaths.forEach((geofenceId, path) {
      _polylines[geofenceId] = Polyline(
        polylineId: PolylineId(geofenceId),
        points: path,
        color: _geofenceColors[geofenceId] ?? Colors.black,
        width: 5,
      );
    });

    setState(() {});
  }

  Color _getRandomColor(geofenceId) {
    return Color((DateTime.now().millisecondsSinceEpoch * (geofenceId.hashCode % 100000000)) % 0xFFFFFF).withOpacity(1.0);
  }

  showAlert(BuildContext context,GeofenceViewModel historyModel) {
    var text = "Are you sure to clear the history?";
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(text,style: TextStyle(fontSize: 16),),
          actions: <Widget>[
            TextButton(
              child: Text("YES",style: TextStyle(color: Colors.black)),
              onPressed: () {
                historyModel.clearHistory();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('History cleared')),
                );
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
    _mapController?.dispose();
    super.dispose();
  }
}
