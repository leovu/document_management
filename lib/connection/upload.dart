import 'dart:io';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:document_management/localization/app_localization.dart';
import 'package:document_management/localization/lang_key.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission/permission.dart';
import 'package:document_management/model/file.dart';

typedef UploadFile = Future<void> Function(File file,String fileName);
typedef ReplaceFile = Future<void> Function(File file, Data data);

void upload(BuildContext context, UploadFile uploadFile) {
  showModalActionSheet<String>(
    context: context,
    actions: _attachmentSheetAction(),
  ).then((value) => value == 'Photo Gallery'
      ? _handleImageSelection(context,ImageSource.gallery,uploadFile,null)
      : value == "Photo Camera"
      ? _handleImageSelection(context,ImageSource.camera,uploadFile,null)
      : value == 'Video'
      ? _handelVideoSelection(context,uploadFile,null)
      : value == 'File'
      ? _handleFileSelection(context,uploadFile,null)
      : {});
}
void replace(BuildContext context, ReplaceFile replaceFile, Data data) {
  showModalActionSheet<String>(
    context: context,
    actions: _attachmentSheetAction(),
  ).then((value) => value == 'Photo Gallery'
      ? _handleImageSelection(context,ImageSource.gallery,null,replaceFile,data: data)
      : value == "Photo Camera"
      ? _handleImageSelection(context,ImageSource.camera,null,replaceFile,data: data)
      : value == 'Video'
      ? _handelVideoSelection(context,null,replaceFile,data: data)
      : value == 'File'
      ? _handleFileSelection(context,null,replaceFile,data: data)
      : {});
}
List<SheetAction<String>> _attachmentSheetAction() {
  List<SheetAction<String>> list = [];
  list.add(SheetAction(
    icon: Icons.camera_alt_outlined,
    label: AppLocalizations.text(LangKey.photoGallery),
    key: 'Photo Gallery',
  ));
  list.add(SheetAction(
    icon: Icons.browse_gallery,
    label: AppLocalizations.text(LangKey.photoCamera),
    key: 'Photo Camera',
  ));
  list.add(SheetAction(
    icon: Icons.video_collection_sharp,
    label: AppLocalizations.text(LangKey.video),
    key: 'Video',
  ));
  list.add(SheetAction(
    icon: Icons.file_copy,
    label: AppLocalizations.text(LangKey.file),
    key: 'File',
  ));
  if(Platform.isAndroid) {
    list.add(SheetAction(
        icon: Icons.cancel,
        label: AppLocalizations.text(LangKey.cancel),
        key: 'Cancel',
        isDestructiveAction: true
    ));
  }
  return list;
}
void _handleFileSelection(BuildContext context, UploadFile? uploadFile, ReplaceFile? replaceFile, {Data? data}) async {
  bool permission = await PermissionRequest.request(PermissionRequestType.STORAGE, (){
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.text(LangKey.requestPermission)),
        content: Text(AppLocalizations.text(LangKey.requestNote)),
        actions: [
          ElevatedButton(
              onPressed: () {
                PermissionRequest.openSetting();
              },
              child: Text(AppLocalizations.text(LangKey.openSetting))),
          ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(AppLocalizations.text(LangKey.cancel))),
        ],
      ),
    );
  });
  if(!permission) {
    return;
  }
  try {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowCompression: false,
      withData: false,
    );
    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      if(uploadFile!=null) {
        uploadFile(file,result.files.single.name);
      }
      else {
        if(replaceFile!=null) {
          replaceFile(file,data!);
        }
      }
    }
  }catch(_){
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.text(LangKey.warning)),
        content: Text(AppLocalizations.text(LangKey.accept)),
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
void _handelVideoSelection(BuildContext context, UploadFile? uploadFile, ReplaceFile? replaceFile, {Data? data}) async {
  bool permission = await PermissionRequest.request(PermissionRequestType.STORAGE, (){
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.text(LangKey.requestPermission)),
        content: Text(AppLocalizations.text(LangKey.requestNote)),
        actions: [
          ElevatedButton(
              onPressed: () {
                PermissionRequest.openSetting();
              },
              child: Text(AppLocalizations.text(LangKey.openSetting))),
          ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(AppLocalizations.text(LangKey.cancel))),
        ],
      ),
    );
  });
  if(!permission) {
    return;
  }
  final result = await ImagePicker().pickVideo(
    source: ImageSource.gallery,
  );
  if (result != null) {
    File file = File(result.path);
    if(uploadFile!=null) {
      uploadFile(file,result.name);
    }
    else {
      if(replaceFile!=null) {
        replaceFile(file,data!);
      }
    }
  }
}
void _handleImageSelection(BuildContext context, ImageSource source, UploadFile? uploadFile, ReplaceFile? replaceFile, {Data? data}) async {
  bool permission = await PermissionRequest.request(PermissionRequestType.STORAGE, (){
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.text(LangKey.requestPermission)),
        content: Text(AppLocalizations.text(LangKey.requestNote)),
        actions: [
          ElevatedButton(
              onPressed: () {
                PermissionRequest.openSetting();
              },
              child: Text(AppLocalizations.text(LangKey.openSetting))),
          ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(AppLocalizations.text(LangKey.cancel))),
        ],
      ),
    );
  });
  if(!permission) {
    return;
  }
  final result = await ImagePicker().pickImage(
      imageQuality: 70,
      maxWidth: 1440,
      maxHeight: 1440, source: source
  );
  if (result != null) {
    File file = File(result.path);
    if(uploadFile!=null) {
      uploadFile(file,result.name);
    }
    else {
      if(replaceFile!=null) {
        replaceFile(file,data!);
      }
    }
  }
}