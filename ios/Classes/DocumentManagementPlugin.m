#import "DocumentManagementPlugin.h"
#if __has_include(<document_management/document_management-Swift.h>)
#import <document_management/document_management-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "document_management-Swift.h"
#endif

@implementation DocumentManagementPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftDocumentManagementPlugin registerWithRegistrar:registrar];
}
@end
