import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class InternetService extends GetxService {
  final _connectivity = Connectivity();
  final isConnected = RxBool(false);

  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void onInit() {
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    super.onInit();
  }

  @override
  Future<void> onClose() async {
    _connectivitySubscription.cancel();
    super.onClose();
  }

  void _updateConnectionStatus(List<ConnectivityResult> result) {
    isConnected.value =
        result.isNotEmpty && !result.contains(ConnectivityResult.none);
  }
}
