// // viewmodels/history_view_model.dart
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../models/history_model.dart';
//
// class HistoryViewModel with ChangeNotifier {
//   List<HistoryModel> _history = [];
//
//   List<HistoryModel> get history => _history;
//
//   HistoryViewModel() {
//     _loadHistory();
//   }
//
//   Future<void> _loadHistory() async {
//     final prefs = await SharedPreferences.getInstance();
//     final historyString = prefs.getString('history');
//     if (historyString != null) {
//       final List decoded = json.decode(historyString);
//       _history = decoded.map((e) => HistoryModel.fromJson(e)).toList();
//       notifyListeners();
//     }
//   }
//
//   Future<void> logEvent(HistoryModel event) async {
//     _history.insert(0, event);
//     final prefs = await SharedPreferences.getInstance();
//     final encoded = json.encode(_history.map((e) => e.toJson()).toList());
//     await prefs.setString('history', encoded);
//     notifyListeners();
//   }
//
//   Future<void> clearHistory() async {
//     _history.clear();
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('history');
//     notifyListeners();
//   }
// }