import 'package:flutter_test/flutter_test.dart';
import 'package:document_management/document_management.dart';
import 'package:document_management/document_management_platform_interface.dart';
import 'package:document_management/document_management_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockDocumentManagementPlatform 
    with MockPlatformInterfaceMixin
    implements DocumentManagementPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final DocumentManagementPlatform initialPlatform = DocumentManagementPlatform.instance;

  test('$MethodChannelDocumentManagement is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelDocumentManagement>());
  });

  test('getPlatformVersion', () async {
    DocumentManagement documentManagementPlugin = DocumentManagement();
    MockDocumentManagementPlatform fakePlatform = MockDocumentManagementPlatform();
    DocumentManagementPlatform.instance = fakePlatform;
  
    expect(await documentManagementPlugin.getPlatformVersion(), '42');
  });
}
