import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:document_management/document_management_method_channel.dart';

void main() {
  MethodChannelDocumentManagement platform = MethodChannelDocumentManagement();
  const MethodChannel channel = MethodChannel('document_management');

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
    expect(await platform.getPlatformVersion(), '42');
  });
}
