import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geofence_tracker_app/core/utils/constants.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../core/utils/debouncer_timer.dart';
import '../../data/models/geofence_model.dart';
import '../viewmodels/geofence_viewmodel.dart';

class AddGeofenceScreen extends StatefulWidget {
  const AddGeofenceScreen({super.key});

  @override
  State<AddGeofenceScreen> createState() => _AddGeofenceScreenState();
}

class _AddGeofenceScreenState extends State<AddGeofenceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _radiusController = TextEditingController();
  LatLng? _selectedLocation;
  GoogleMapController? mapController;
  static const CameraPosition intialLocation = CameraPosition(target: LatLng(25.422945, 78.164702), zoom: 5, tilt: 30);
  GeofenceModel? doEditGeofence;
  var doEditUpdated = false;
  var showProgress = true;
  BitmapDescriptor? locationMarker;
  var zoomLocation = false;
  Circle? circle;
  final Debouncer _debouncer = Debouncer(milliseconds: 500);

  @override
  void initState() {
    getLocPermission();
    super.initState();
  }

  getLocPermission() async{
    LocationPermission permissionGranted;
    permissionGranted = await Geolocator.checkPermission();
    if (permissionGranted == LocationPermission.denied) {
      permissionGranted = await Geolocator.requestPermission();
      if (permissionGranted == LocationPermission.denied || permissionGranted == LocationPermission.deniedForever) {
        return;
      }
    }
    getLocation();
  }

  getLocation() async {
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high).then((Position position) {
      var userLocation = LatLng(position.latitude, position.longitude);
      animateCamera(userLocation);
    }).catchError((e) {
      print(e);
    });
  }

  void _onMapTap(LatLng position) {
    setState(() {
      _selectedLocation = position;
    });
    animateCamera(_selectedLocation);
    addRadiusOnMap(_selectedLocation,int.parse(_radiusController.text));
  }

  void _saveGeofence() {
    if (_formKey.currentState!.validate() && _selectedLocation != null) {
      final newGeofence = GeofenceModel(
        id: doEditGeofence != null ? doEditGeofence!.id : Uuid().v4(),
        title: _titleController.text.trim(),
        latitude: _selectedLocation!.latitude,
        longitude: _selectedLocation!.longitude,
        radius: double.tryParse(_radiusController.text.trim()) ?? 100, timestamp: DateTime.now(),
      );
      if(doEditGeofence == null){
        Provider.of<GeofenceViewModel>(context, listen: false).addGeofence(newGeofence);
      }else{
        Provider.of<GeofenceViewModel>(context, listen: false).editGeofence(newGeofence);
      }
      Navigator.pop(context);
    }
  }

  updateFields(){
    if(mapController != null && !doEditUpdated){
      doEditGeofence =  ModalRoute.of(context)?.settings.arguments as GeofenceModel?;
      if(doEditGeofence != null ){
        setState(() {
          doEditUpdated = true;
          _titleController.text = doEditGeofence!.title;
          _radiusController.text = doEditGeofence!.radius.toString();
          _selectedLocation = LatLng(doEditGeofence!.latitude, doEditGeofence!.longitude);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    updateFields();
    return Scaffold(
      appBar: AppBar(title: Text(doEditGeofence != null ? 'Edit Geofence' : 'Add Geofence')),
      body: Stack(
        children: [
          Column(
            children: [
              mapWidget(),
              fieldEntryWidget()
            ],
          ),
          if(showProgress) progressWidget()
        ],
      ),
    );
  }

  mapWidget(){
    return Expanded(
      flex: 2,
      child: GoogleMap(
        myLocationEnabled : true,
        initialCameraPosition: intialLocation,
        onMapCreated: (controller) {
          setState(() {
            mapController = controller;
            showProgress = false;
            zoomLocation = false;
          });
        },
        onTap: _onMapTap,
        markers: _selectedLocation == null ? {} : {
          Marker(
              markerId: const MarkerId("selected"),
              position: _selectedLocation!,
              icon: BitmapDescriptor.defaultMarker
          )
        },
        circles: circle != null ? {circle!} : {},
      ),
    );
  }

  progressWidget(){
    return Column(
      children: [
        Expanded(child: Container(color : Colors.black.withOpacity(0.5),child: Center(child: CircularProgressIndicator()))),
      ],
    );
  }

  fieldEntryWidget(){
    return Expanded(
      flex: 2,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12,20,12,12.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
                  validator: (value) => value!.isEmpty ? 'Please enter a title' : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _radiusController,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9]')),LengthLimitingTextInputFormatter(3)],
                  decoration: const InputDecoration(
                      labelText: 'Radius (meters)',
                      border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                  validator: (value) => value!.isEmpty ? 'Please enter the radius' : null,
                  onChanged: (value) {
                    _debouncer.run(() {
                      addRadiusOnMap(_selectedLocation!,int.parse(_radiusController.text));
                    });
                  },
                ),
                const SizedBox(height: 15),
                if(_selectedLocation != null) Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text('Selected Location: ${_selectedLocation!.latitude}, ${_selectedLocation!.longitude}', style: TextStyle(color: Colors.red)),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width : MediaQuery.of(context).size.width * 0.4,
                  height: 40,
                  child: TextButton(
                    style: ButtonStyle(backgroundColor: MaterialStateProperty.all(colorPrimary)),
                    onPressed: ()
                    {
                      if(_selectedLocation != null){
                        validateGeofenceLocation();
                      }else{
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please select a location to proceed!')),
                        );
                      }
                    },
                    child: const Text('Save Geofence',style: TextStyle(color: Colors.white),),
                  ),
                ),
                if(_selectedLocation == null)
                  const Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Text('Tap on the map to select a location.', style: TextStyle(color: Colors.red)),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  validateGeofenceLocation() async{
    List<GeofenceModel> _geofenceList = [];
    var canProceed = false;
    if(doEditGeofence == null){
      final prefs = await SharedPreferences.getInstance();
      final geofenceListString = prefs.getString('geofences');
      if (geofenceListString != null) {
        final List decoded = json.decode(geofenceListString);
        _geofenceList = decoded.map((e) => GeofenceModel.fromJson(e)).toList();
      }
      if(_geofenceList.isNotEmpty){
        for(var element in _geofenceList){
          double distance = Geolocator.distanceBetween(
            _selectedLocation!.latitude,
            _selectedLocation!.longitude,
            element.latitude,
            element.longitude,
          );
          if(distance <= 50)
          {
            canProceed = false;
            break;
          }else{
            canProceed = true;
          }
        }
      }
    }

    if (_geofenceList.isEmpty || canProceed) {
      showAlert(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your selected geofencing location is already available. Make sure to select location at least 50 meters away!')),
      );
    }
  }

  addRadiusOnMap(LatLng? centerLoc,int? radius){
    if(radius != null && centerLoc != null)
    {
      setState(() {
        circle = Circle(
          circleId: CircleId('radius_circle'),
          center: centerLoc,
          radius: radius.toDouble(),
          fillColor: Colors.blue.withOpacity(0.2),
          strokeColor: Colors.blue,
          strokeWidth: 2,
        );
      });
    }
  }

  void animateCamera(var location) {
    if(!zoomLocation){
      zoomLocation = true;
      mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: location,
            zoom: 19,
          ),
        ),
      );
    }
  }

  showAlert(BuildContext context) {
    var text = doEditGeofence != null ? "Are you sure to edit this geofence data?" : "Are you sure to add this geofence data to track your entry/exit location ?";
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(text,style: TextStyle(fontSize: 16),),
          actions: <Widget>[
            TextButton(
              child: Text("YES",style: TextStyle(color: Colors.black)),
              onPressed: () {
                _saveGeofence();
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
}
