import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'document_management_method_channel.dart';

abstract class DocumentManagementPlatform extends PlatformInterface {
  /// Constructs a DocumentManagementPlatform.
  DocumentManagementPlatform() : super(token: _token);

  static final Object _token = Object();

  static DocumentManagementPlatform _instance = MethodChannelDocumentManagement();

  /// The default instance of [DocumentManagementPlatform] to use.
  ///
  /// Defaults to [MethodChannelDocumentManagement].
  static DocumentManagementPlatform get instance => _instance;
  
  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [DocumentManagementPlatform] when
  /// they register themselves.
  static set instance(DocumentManagementPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
