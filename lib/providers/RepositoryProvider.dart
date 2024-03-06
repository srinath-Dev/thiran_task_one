import 'dart:convert';
import 'dart:ffi';
import 'dart:isolate';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/DatabaseHelper.dart';
import '../main.dart';
import '../models/Repository.dart';
import 'package:http/http.dart' as http;
class RepositoryProvider extends ChangeNotifier {
  List<Repository> _repositories = [];

  List<Repository> get repositories => _repositories;

  Future<void> fetchAndSaveRepositories(bool isDate) async {
    final currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    try {
      final response = await http.get(
        Uri.parse(
            'https://api.github.com/search/repositories?q=created:%3E${isDate ==true ?currentDate:'2022-04-29'}&sort=stars&order=desc.',
        ),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['items'];
        final List<Repository> repositories =
        data.map((json) => Repository.fromJson(json)).toList();
        debugPrint(repositories.length.toString());
        if(repositories.length != 0)
         {
         //  _repositories = repositories;
           await DatabaseHelper.insertRepositories(repositories);
            _repositories = await DatabaseHelper.getRepositories();
         }
        notifyListeners();
        // Save repositories to the local database
      } else {
        throw Exception('Failed to fetch repositories');
      }
    } catch (e) {
      print('Error fetching repositories: $e');
      throw e;
    }
  }

  // Method to refresh repositories
  Future<void> refreshRepositories() async {
    try {
      await fetchAndSaveRepositories(true);
      // Inform the user about data refresh
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        SnackBar(content: Text('Data Refreshed')),
      );
    } catch (e) {
      // Handle errors
      print('Error refreshing repositories: $e');
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        SnackBar(content: Text('Error refreshing repositories')),
      );
    }
  }

  // Method to refresh repositories by calling API in a background isolate
  // Future<void> refreshRepositories() async {
  //   ReceivePort receivePort = ReceivePort();
  //   await Isolate.spawn(_refreshDataInIsolate, receivePort.sendPort);
  //   await for (var message in receivePort) {
  //     if (message is List<Repository>) {
  //       _repositories = message;
  //       notifyListeners();
  //       // Inform the user about data refresh
  //       ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
  //         SnackBar(content: Text('Data Refreshed')),
  //       );
  //     } else if (message is String) {
  //       // Handle error message
  //       print('Error occurred during refresh: $message');
  //       // Show error message to the user if needed
  //       ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
  //         SnackBar(content: Text('Error occurred during refresh: $message')),
  //       );
  //       notifyListeners();
  //     }
  //   }
  // }

  // Method to perform API call and data insertion in a background isolate
  static void _refreshDataInIsolate(SendPort sendPort) async {
    try {
      // Get the current date and format it as yyyy-MM-dd
      String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

      final response = await http.get(Uri.parse(
          'https://api.github.com/search/repositories?q=created:>$currentDate&sort=stars&order=desc'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['items'];
        final List<Repository> repositories =
        data.map((json) => Repository.fromJson(json)).toList();
        await DatabaseHelper.insertRepositories(repositories);
        sendPort.send(repositories);
      } else {
        // Send an error message
        sendPort.send('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in isolate: $e');
      // Send an error message
      sendPort.send('Error: $e');
    }
  }
}