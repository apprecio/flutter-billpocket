/*
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_billpocket/billpocket_method_channel.dart';

void main() {
  MethodChannelBillpocket platform = MethodChannelBillpocket();
  const MethodChannel channel = MethodChannel('flutter_billpocket');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.config(isProduction: true, token: 'token'), '42');
  });
}
*/
