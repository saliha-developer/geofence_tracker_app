import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import '../../data/models/geofence_model.dart';
import '../../data/models/history_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GeofenceViewModel with ChangeNotifier {
  List<GeofenceModel> _geofences = [];
  List<HistoryModel> _history = [];

  List<GeofenceModel> get geofences => _geofences;
  List<HistoryModel> get history => _history;

  GeofenceViewModel() {
    _loadGeofenceData();
    _loadHistory();
    // _configureBackgroundGeolocation();
    // _addGeofenceListeners();
  }

  Future<void> _loadGeofenceData() async {
    final prefs = await SharedPreferences.getInstance();
    final geofenceListString = prefs.getString('geofences');

    if (geofenceListString != null) {
      final List decoded = json.decode(geofenceListString);
      _geofences = decoded.map((e) => GeofenceModel.fromJson(e)).toList();
      // _updateBackgroundGeofences();
      notifyListeners();
    }
  }

  Future<void> _saveGeofenceData() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = json.encode(_geofences.map((e) => e.toJson()).toList());
    await prefs.setString('geofences', encoded);
  }

  void addGeofence(GeofenceModel geofence) {
    _geofences.add(geofence);
    _saveGeofenceData();
    notifyListeners();
  }

  void editGeofence(GeofenceModel geofence) async{
    List<GeofenceModel> tmpGeofence = [];
    for(var element in geofences){
      if(element.id == geofence.id){
        element.title = geofence.title;
        element.latitude = geofence.latitude;
        element.longitude = geofence.longitude;
        element.radius = geofence.radius;
      }
      tmpGeofence.add(element);
    }
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
    final encoded = json.encode(tmpGeofence.map((e) => e.toJson()).toList());
    await prefs.setString('geofences', encoded);();
    notifyListeners();
  }

  void deleteGeofence(String id) {
    _geofences.removeWhere((g) => g.id == id);
    _saveGeofenceData();
    notifyListeners();
  }

  void updateGeofenceStatus(String id, bool isInside) {
    final index = _geofences.indexWhere((g) => g.id == id);
    if (index != -1) {
      _geofences[index].isInside = isInside;
      _saveGeofenceData();
      notifyListeners();
    }
  }

  // History Storage
  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyString = prefs.getString('history');
    if (historyString != null) {
      final List decoded = json.decode(historyString);
      _history = decoded.map((e) => HistoryModel.fromJson(e)).toList();
      notifyListeners();
    }
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = json.encode(_history.map((e) => e.toJson()).toList());
    await prefs.setString('history', encoded);
  }

  void logEvent(HistoryModel event) {
    _history.insert(0, event);
    _saveHistory();
    notifyListeners();
  }

  void clearHistory() async {
    _history.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('history');
    notifyListeners();
  }
}