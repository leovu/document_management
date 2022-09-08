import 'dart:io';
import 'package:document_management/connection/document_connection.dart';
import 'package:document_management/connection/http_connection.dart';
import 'package:document_management/document_screen/folder_management.dart';
import 'package:document_management/localization/app_localization.dart';
import 'package:document_management/localization/lang_key.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'document_management_platform_interface.dart';

class DocumentManagement {
  Future<String?> getPlatformVersion() {
    return DocumentManagementPlatform.instance.getPlatformVersion();
  }
  static open(BuildContext context, Locale locale,String token, {String? domain, String? brandCode}) async {
    DocumentConnection.showLoading(context);
    if(domain != null) {
      HTTPConnection.domain = domain;
    }
    if(brandCode != null) {
      HTTPConnection.brandCode = brandCode;
    }
    DocumentConnection.locale = locale;
    DocumentConnection.buildContext = context;
    await AppLocalizations(DocumentConnection.locale).load();
    bool result = await DocumentConnection.init(token,domain: domain);
    Navigator.of(DocumentConnection.buildContext!).pop();
    if(result) {
      await Navigator.of(DocumentConnection.buildContext!,rootNavigator: true).push(
          MaterialPageRoute(builder: (context) => const AppDocument(),settings: const RouteSettings(name: 'folder_management_screen')));
    }else {
      loginError(DocumentConnection.buildContext!);
    }
  }
  static void loginError(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.text(LangKey.warning)),
        content: Text(AppLocalizations.text(LangKey.accountLoginError)),
        actions: [
          ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(AppLocalizations.text(LangKey.accept)))
        ],
      ),
    );
  }
}

class AppDocument extends StatelessWidget {
  const AppDocument({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    if(Platform.isAndroid) {
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarBrightness: Brightness.dark,
      ));
    }
    return const FolderManagement();
  }
}