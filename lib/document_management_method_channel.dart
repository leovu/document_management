import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'document_management_platform_interface.dart';

/// An implementation of [DocumentManagementPlatform] that uses method channels.
class MethodChannelDocumentManagement extends DocumentManagementPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('document_management');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
