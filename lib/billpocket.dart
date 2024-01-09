import 'package:flutter_billpocket/reader.dart';

import 'billpocket_platform_interface.dart';

class Billpocket {
  const Billpocket._();

  static BillpocketPlatform get _billpocket => BillpocketPlatform.instance;

  static Future<void> config({
    required bool isProduction,
    required String token,
  }) {
    return _billpocket.config(isProduction: isProduction, token: token);
  }

  static Future<bool> getStatusSDK() {
    return _billpocket.getStatusSDK();
  }

  static Future<List<Reader>> getReaders() {
    return _billpocket.getReaderList();
  }

  static Future<bool> connectReader({
    required int readerType,
    required String readerMacAddress,
    required String name,
  }) {
    return _billpocket.connectReader(
        readerType: readerType, readerMacAddress: readerMacAddress, name: name);
  }

  static Future<void> doTransaction(
      {required String amount,
      required String tip,
      required double latitude,
      required double longitude,
      required String description}) {
    return _billpocket.doTransaction(
        amount: amount,
        tip: tip,
        latitude: latitude,
        longitude: longitude,
        description: description);
  }

  static Stream<Map> transactionStream() {
    return _billpocket.transactionStream();
  }

  static Future<void> continueWithMsi(
      {required double commission,
      required int installments,
      required double minAmount}) {
    return _billpocket.continueWithMsi(
        commission: commission,
        installments: installments,
        minAmount: minAmount);
  }

  static Future<String> getLogs() async {
    return await _billpocket.getLogs();
  }
}
