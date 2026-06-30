import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class NetworkMonitor extends ChangeNotifier {
  bool isConnected = true;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  NetworkMonitor() {
    _subscription = Connectivity().onConnectivityChanged.listen((results) {
      final connected = results.any((r) => r != ConnectivityResult.none);
      if (connected != isConnected) {
        isConnected = connected;
        notifyListeners();
      }
    });
    Connectivity().checkConnectivity().then((results) {
      isConnected = results.any((r) => r != ConnectivityResult.none);
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
