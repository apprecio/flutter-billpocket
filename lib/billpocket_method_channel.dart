import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_billpocket/reader.dart';

import 'billpocket_platform_interface.dart';

class MethodChannelBillpocket extends BillpocketPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('billpocket/operation');

  @visibleForTesting
  final eventChannel = const EventChannel('billpocket/transaction');

  @override
  Future<void> config(
      {required bool isProduction, required String token}) async {
    try {
      await methodChannel.invokeMethod('config', {
        'isProduction': isProduction,
        'token': token,
      });
    } on PlatformException catch (exception) {
      print(exception);
    }
  }

  @override
  Future<bool> getStatusSDK() async {
    return await methodChannel.invokeMethod('getStatusSDK');
  }

  @override
  Future<List<Reader>> getReaderList() async {
    String data = await methodChannel.invokeMethod('getReaderList');
    List<Reader> readers =
        List<Reader>.from(json.decode(data).map((x) => Reader.fromJson(x)));
    return readers;
  }

  @override
  Future<bool> connectReader(
      {required int readerType,
      required String readerMacAddress,
      required String name}) async {
    return await methodChannel.invokeMethod('connectReader', {
      'readerType': readerType,
      'readerMacAddress': readerMacAddress,
      'name': name,
    });
  }

  @override
  Future<void> doTransaction(
      {required String amount,
      required String tip,
      required double latitude,
      required double longitude,
      required String description}) async {
    try {
      await methodChannel.invokeMethod('doTransaction', {
        'amount': amount,
        'tip': tip,
        'latitude': latitude,
        'longitude': longitude,
        'description': description,
      });
    } on PlatformException catch (exception) {
      print(exception);
    }
  }

  @override
  Stream<Map> transactionStream() {
    return eventChannel
        .receiveBroadcastStream()
        .map((event) => event as Map<dynamic, dynamic>);
  }

  @override
  Future<void> continueWithMsi(
      {required double commission,
      required int installments,
      required double minAmount}) async {
    try {
      await methodChannel.invokeMethod('continueWithMsi', {
        'commission': commission,
        'installments': installments,
        'minAmount': minAmount,
      });
    } on PlatformException catch (exception) {
      print(exception);
    }
  }

  @override
  Future<void> getLogs() async {
    try {
      await methodChannel.invokeMethod('logs');
    } on PlatformException catch (exception) {
      print(exception);
    }
  }
}
