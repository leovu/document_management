import 'dart:io';
import 'package:dio/dio.dart';
import 'package:document_management/connection/document_connection.dart';
import 'package:document_management/connection/http_connection.dart';
import 'package:document_management/document_screen/local_file_view_page.dart';
import 'package:document_management/document_screen/media_screen.dart';
import 'package:document_management/document_screen/photo_view.dart';
import 'package:document_management/localization/app_localization.dart';
import 'package:document_management/localization/lang_key.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:open_filex/open_filex.dart';
// ignore_for_file: depend_on_referenced_packages
import 'package:path_provider/path_provider.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:permission/permission.dart';
import 'dart:io' as io;
import 'package:gallery_saver/gallery_saver.dart';

class FileProcess {
  static Future<bool> upload(String fileName, String folderName, File file) async {
    try{
      ScaffoldMessenger.of(DocumentConnection.buildContext!).hideCurrentSnackBar();
    }catch(_){}
    try{
      ScaffoldMessenger.of(DocumentConnection.buildContext!).showSnackBar(SnackBar(
        content: Text(AppLocalizations.text(LangKey.uploadingFile)),duration: const Duration(days: 365),));
    }catch(_){}
    ResponseData responseData = await DocumentConnection.connection.upload('files/upload', file , body: {
      'file_name':fileName,
      'folder_name':folderName
    });
    try{
      ScaffoldMessenger.of(DocumentConnection.buildContext!).hideCurrentSnackBar();
    }catch(_){}
    if(responseData.isSuccess) {
      return true;
    }
    else {
      DocumentConnection.error(DocumentConnection.buildContext!, responseData.data['message']);
      return false;
    }
  }
  static Future<bool> replace(String filePath, File file) async {
    try{
      ScaffoldMessenger.of(DocumentConnection.buildContext!).hideCurrentSnackBar();
    }catch(_){}
    try{
      ScaffoldMessenger.of(DocumentConnection.buildContext!).showSnackBar(SnackBar(
        content: Text(AppLocalizations.text(LangKey.uploadingFile)),duration: const Duration(days: 365),));
    }catch(_){}
    ResponseData responseData = await DocumentConnection.connection.upload('files/replace', file , body: {
      'file_path':filePath
    });
    try{
      ScaffoldMessenger.of(DocumentConnection.buildContext!).hideCurrentSnackBar();
    }catch(_){}
    if(responseData.isSuccess) {
      try{
        ScaffoldMessenger.of(DocumentConnection.buildContext!).hideCurrentSnackBar();
      }catch(_){}
      try{
        ScaffoldMessenger.of(DocumentConnection.buildContext!).showSnackBar(SnackBar(
          content: Text(AppLocalizations.text(LangKey.uploadSuccess)),duration: const Duration(seconds: 1),));
      }catch(_){}
      return true;
    }
    else {
      DocumentConnection.error(DocumentConnection.buildContext!, responseData.data['message']);
      try{
        ScaffoldMessenger.of(DocumentConnection.buildContext!).hideCurrentSnackBar();
      }catch(_){}
      try{
        ScaffoldMessenger.of(DocumentConnection.buildContext!).showSnackBar(SnackBar(
          content: Text(AppLocalizations.text(LangKey.uploadFail)),duration: const Duration(seconds: 1),));
      }catch(_){}
      return false;
    }
  }
  static Future<String?> download(BuildContext context,String url,String filename) async {
    try {
      bool granted = false;
      if (Platform.isAndroid) {
        granted = await PermissionRequest.request(PermissionRequestType.STORAGE, () {
          showDialog(
            context: context,
            builder: (context) =>
                AlertDialog(
                  title: const Text('Request permissions'),
                  content: const Text(
                      'Select Settings, go to App info, tap Permissions, turn on permission and re-enter this screen to use permission'),
                  actions: [
                    ElevatedButton(
                        onPressed: () {
                          PermissionRequest.openSetting();
                        },
                        child: const Text('Open setting')),
                    ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel')),
                  ],
                ),
          );
        });
      }
      else {
        granted = true;
      }
      if(!granted) {
        return null;
      }
      Directory? directory;
      if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else if (Platform.isAndroid) {
        directory = await getTemporaryDirectory();
      }
      if (directory != null) {
        String urlPath = '${directory.path}/$filename';
        bool checkAvailable = await io.File(urlPath).exists();
        if(checkAvailable) {
          return urlPath;
        }
        await Dio().download(
          url,
          urlPath,
          options: Options(
            headers: {
              'brand-code' : HTTPConnection.brandCode,
              'Authorization':'Bearer ${DocumentConnection.account!.accessToken}'
            },
          ),
        );
        if (Platform.isAndroid) {
          final params = SaveFileDialogParams(
              sourceFilePath: urlPath);
          final filePath =
          await FlutterFileDialog.saveFile(params: params);
          saveGallery(filePath);
          return filePath;
        }
        else {
          saveGallery(urlPath);
          return urlPath;
        }
      }
      else {
        return null;
      }
    }catch(_) {
      return null;
    }
  }
  static void saveGallery(String? path) {
    if(path != null) {
      if(isImage(path)) {
        GallerySaver.saveImage(path).then((result) {
          if(result == true) {
            try{
              ScaffoldMessenger.of(DocumentConnection.buildContext!).hideCurrentSnackBar();
            }catch(_){}
            try{
              ScaffoldMessenger.of(DocumentConnection.buildContext!).showSnackBar(SnackBar(
                content: Text(AppLocalizations.text(LangKey.downloadSuccess)),duration: const Duration(seconds: 1),));
            }catch(_){}
          }
          else {
            try{
              ScaffoldMessenger.of(DocumentConnection.buildContext!).hideCurrentSnackBar();
            }catch(_){}
            try{
              ScaffoldMessenger.of(DocumentConnection.buildContext!).showSnackBar(SnackBar(
                content: Text(AppLocalizations.text(LangKey.downloadFailed)),duration: const Duration(seconds: 1),));
            }catch(_){}
          }
        });
      }
      else if(isVideo(path)) {
        GallerySaver.saveVideo(path).then((result) {
          if(result == true) {
            try{
              ScaffoldMessenger.of(DocumentConnection.buildContext!).hideCurrentSnackBar();
            }catch(_){}
            try{
              ScaffoldMessenger.of(DocumentConnection.buildContext!).showSnackBar(SnackBar(
                content: Text(AppLocalizations.text(LangKey.downloadSuccess)),duration: const Duration(seconds: 1),));
            }catch(_){}
          }
          else {
            try{
              ScaffoldMessenger.of(DocumentConnection.buildContext!).hideCurrentSnackBar();
            }catch(_){}
            try{
              ScaffoldMessenger.of(DocumentConnection.buildContext!).showSnackBar(SnackBar(
                content: Text(AppLocalizations.text(LangKey.downloadFailed)),duration: const Duration(seconds: 1),));
            }catch(_){}
          }
        });
      }
    }
  }
  static bool isImage(String path) {
    final mimeType = lookupMimeType(path) ?? '';
    return mimeType.startsWith('image/') || path == 'image/';
  }
  static bool isAudio(String path) {
    final mimeType = lookupMimeType(path) ?? '';
    return mimeType.startsWith('audio/');
  }
  static bool isVideo(String path) {
    final mimeType = lookupMimeType(path) ?? '';
    return mimeType.startsWith('video/');
  }
  static Future<void> openFile(String? result,BuildContext context,String fileName) async {
    if(result != null) {
      List<String> documentFilesType = ['docx', 'doc', 'xlsx', 'xls', 'pptx', 'ppt', 'pdf', 'txt'];
      final mimeType = fileName.split('.').last.toLowerCase();
      if(documentFilesType.contains(fileName)) {
        Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
          return LocalFileViewerPage(filePath: result,title: fileName,);
        }));
      }
      else if(isAudio(mimeType)) {
        Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
          return MediaScreen(filePath: result,title: fileName);
        }));
      }
      else if(isVideo(mimeType)) {
        await OpenFilex.open(result);
      }
      else if(isImage(mimeType)) {
        Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
          return PhotoScreen(imageViewed: result);
        }));
      }
      else {
        await OpenFilex.open(result);
      }
    }
    return;
  }
  static void openImage(BuildContext context, String url) {
    Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
      return PhotoScreen(imageViewed: url);
    }));
  }
}