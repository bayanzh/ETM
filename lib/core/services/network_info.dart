import 'dart:async';

import 'package:internet_connection_checker/internet_connection_checker.dart';

class NetworkInfo {
  /// The InternetConnectionChecker instance used to check connectivity.
  final InternetConnectionChecker _connectionChecker =
      InternetConnectionChecker();

  /// A private static instance of the NetworkInfoImpl class.
  static NetworkInfo? _instance;

  /// Private constructor for NetworkInfo.
  NetworkInfo._();

  factory NetworkInfo() {
    _instance ??= NetworkInfo._();
    return _instance!;
  }

  Future<bool> get isConnected => _connectionChecker.hasConnection;
}
