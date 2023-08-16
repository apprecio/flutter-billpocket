/*
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_billpocket/billpocket.dart';
import 'package:flutter_billpocket/billpocket_platform_interface.dart';
import 'package:flutter_billpocket/billpocket_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterBillpocketPlatform
    with MockPlatformInterfaceMixin
    implements BillpocketPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final BillpocketPlatform initialPlatform = BillpocketPlatform.instance;

  test('$MethodChannelBillpocket is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelBillpocket>());
  });

  test('getPlatformVersion', () async {
    MockFlutterBillpocketPlatform fakePlatform = MockFlutterBillpocketPlatform();
    BillpocketPlatform.instance = fakePlatform;

    expect(await Billpocket.config(isProduction: isProduction, token: token));
  });
}
*/
