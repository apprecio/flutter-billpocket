//import 'dart:ffi';

import 'package:flutter_billpocket/reader.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'billpocket_method_channel.dart';

abstract class BillpocketPlatform extends PlatformInterface {
  /// Constructs a FlutterBillpocketPlatform.
  BillpocketPlatform() : super(token: _token);

  static final Object _token = Object();

  static BillpocketPlatform _instance = MethodChannelBillpocket();

  /// The default instance of [BillpocketPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterBillpocket].
  static BillpocketPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [BillpocketPlatform] when
  /// they register themselves.
  static set instance(BillpocketPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> config({
    required bool isProduction,
    required String token,
  }) {
    throw UnimplementedError('config() has not been implemented.');
  }

  Future<bool> getStatusSDK() {
    throw UnimplementedError('getStatusSDK() has not been implemented.');
  }

  Future<List<Reader>> getReaderList() {
    throw UnimplementedError('getReaderList() has not been implemented.');
  }

  Future<bool> connectReader({
    required int readerType,
    required String readerMacAddress,
    required String name,
  }) {
    throw UnimplementedError('connectReader() has not been implemented.');
  }

  Future<void> doTransaction({
    required String amount,
    required String tip,
    required double latitude,
    required double longitude,
    required String description,
  }) {
    throw UnimplementedError('doTransaction() has not been implemented.');
  }

  Stream<Map<dynamic, dynamic>> transactionStream() {
    throw UnimplementedError('transactionStream() has not been implemented.');
  }

  Future<void> continueWithMsi({
    required double commission,
    required int installments,
    required double minAmount,
  }) {
    throw UnimplementedError('continueWithMsi() has not been implemented.');
  }

  Future<String> getLogs() async {
    throw UnimplementedError( 'getLogs() has not been implemented.' );
  }
}
