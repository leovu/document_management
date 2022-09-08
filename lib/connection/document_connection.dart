import 'dart:io';

import 'package:document_management/connection/http_connection.dart';
import 'package:document_management/localization/app_localization.dart';
import 'package:document_management/localization/lang_key.dart';
import 'package:document_management/model/comment.dart';
import 'package:document_management/model/department.dart';
import 'package:document_management/model/file.dart';
import 'package:document_management/model/file_log.dart';
import 'package:document_management/model/folder.dart';
import 'package:document_management/model/account.dart';
import 'package:document_management/model/folder_information.dart';
import 'package:document_management/model/folder_log.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:document_management/model/staff.dart' as staff;

class DocumentConnection {
  static late BuildContext? buildContext;
  static HTTPConnection connection = HTTPConnection();
  static Account? account;
  static late Locale locale;

  static Future<bool> init(String token, {String? domain}) async {
    if(domain != null) {
      HTTPConnection.domain = domain;
    }
    account = await login(token);
    if(account != null) {
      return true;
    }
    return false;
  }
  static Future<Account?> login(String token) async {
    ResponseData responseData = await connection.post('auth/login', {'epoints_token':token,'decode':1});
    if(responseData.isSuccess) {
      Account account = Account.fromJson(responseData.data);
      return account;
    }
    return null;
  }
  static Future<Folder?> folderList(String sortKeyName, String sortValue,{int? owner, String? fromDate, String? toDate}) async {
    String path = 'folder?sort_key=$sortKeyName&sort_value=$sortValue';
    if(owner != null) {
      path += '&owner=$owner';
    }
    if(fromDate != null && toDate != null) {
      path += '&from_date=$fromDate&to_date=$toDate';
    }
    ResponseData responseData = await connection.get(path);
    if(responseData.isSuccess) {
      Folder folders = Folder.fromJson(responseData.data);
      return folders;
    }
    return null;
  }
  static Future<Files?> fileList(String folderName, String sortKeyName, String sortValue,{int? owner, String? fromDate, String? toDate, String? password}) async {
    String path = 'files?folder_name=$folderName&sort_key=$sortKeyName&sort_value=$sortValue';
    if(owner != null) {
      path += '&owner=$owner';
    }
    if(fromDate != null && toDate != null) {
      path += '&from_date=$fromDate&to_date=$toDate';
    }
    if(password != null) {
      path += '&password=$password';
    }
    path+='&limit=1000';
    ResponseData responseData = await connection.get(path);
    if(responseData.isSuccess) {
      Files file = Files.fromJson(responseData.data);
      await file.checkDownloaded();
      return file;
    }
    return null;
  }
  static Future<FolderInformation?> folderInformation(String folderName) async {
    ResponseData responseData = await connection.get('folder/detail?name=$folderName');
    if(responseData.isSuccess) {
      FolderInformation folderInformation = FolderInformation.fromJson(responseData.data);
      return folderInformation;
    }
    return null;
  }
  static Future<FolderLog?> folderLog(String folderName) async {
    ResponseData responseData = await connection.get('folder/log-activity-group?name=$folderName');
    if(responseData.isSuccess) {
      FolderLog folderLog = FolderLog.fromJson(responseData.data);
      return folderLog;
    }
    return null;
  }
  static Future<Departments?> deparmentList() async {
    ResponseData responseData = await connection.get('department');
    if(responseData.isSuccess) {
      Departments departments = Departments.fromJson(responseData.data);
      return departments;
    }
    return null;
  }
  static Future<staff.Staff?> staffList({List<int?>? departments, String? folderName}) async {
    String path = 'user';
    if(departments!=null && departments.isNotEmpty) {
      path += '?';
      for(int i=0;i<=departments.length-1;i++) {
        var e = departments[i];
        if(i != 0) {
          path+= '&';
        }
        path += 'department_id[]=$e';
      }
    }
    if(folderName != null) {
      path = 'folder/${path}s?name=$folderName&limit=1000';
    }
    ResponseData responseData = await connection.get(path);
    if(responseData.isSuccess) {
      staff.Staff staffs;
      if(folderName != null) {
        staffs = staff.Staff.fromSelectedJson(responseData.data);
      }
      else {
        staffs = staff.Staff.fromJson(responseData.data);
      }
      return staffs;
    }
    return null;
  }
  static Future<bool> addFolderPolicy(String folderName, List<Map<String,dynamic>> policies) async {
    Map<String,dynamic> json = {
      'folder_name' : folderName,
      'users' : policies,
    };
    ResponseData responseData = await connection.post('folder/policy',json);
    if(responseData.isSuccess) {
      return true;
    }
    return false;
  }
  static Future<bool> createFolderPassword(String folderName,String password) async {
    ResponseData responseData = await connection.post('folder/create-password', {'name':folderName,'folder_password':password});
    if(responseData.isSuccess) {
      return true;
    }
    else {
      DocumentConnection.error(DocumentConnection.buildContext!, responseData.data['message']);
      return false;
    }
  }
  static Future<bool> checkFolderPassword(String folderName,String password) async {
    DocumentConnection.showLoading(DocumentConnection.buildContext!);
    ResponseData responseData = await connection.post('folder/check-password', {'folder_name':folderName,'password':password});
    Navigator.of(DocumentConnection.buildContext!).pop();
    if(responseData.isSuccess) {
      return true;
    }
    else {
      DocumentConnection.error(DocumentConnection.buildContext!, responseData.data['message']);
      return false;
    }
  }
  static Future<bool> updateFolderPassword(String folderName,String currentPassword, String newPassword) async {
    DocumentConnection.showLoading(DocumentConnection.buildContext!);
    ResponseData responseData = await connection.post('folder/update-password', {'name':folderName,'current_password':currentPassword,'new_password':newPassword});
    Navigator.of(DocumentConnection.buildContext!).pop();
    if(responseData.isSuccess) {
      return true;
    }
    else {
      DocumentConnection.error(DocumentConnection.buildContext!, responseData.data['message']);
    }
    return false;
  }
  static Future<bool> deleteFolderPassword(String folderName,String password) async {
    DocumentConnection.showLoading(DocumentConnection.buildContext!);
    ResponseData responseData = await connection.delete('folder/delete-password', {'name':folderName,'password':password});
    Navigator.of(DocumentConnection.buildContext!).pop();
    if(responseData.isSuccess) {
      return true;
    }
    else {
      DocumentConnection.error(DocumentConnection.buildContext!, responseData.data['message']);
      return false;
    }
  }
  static Future<bool> deleteFolder(String folderName) async {
    ResponseData responseData = await connection.delete('folder', {'name':folderName});
    if(responseData.isSuccess) {
      return true;
    }
    return false;
  }
  static Future<bool> deleteFolderPolicy(String folderName, List<String> userNames) async {
    Map<String,dynamic> json = {
      'folder_name' : folderName,
      'user_name' : userNames,
    };
    ResponseData responseData = await connection.delete('folder/policy',json);
    if(responseData.isSuccess) {
      return true;
    }
    return false;
  }
  static Future<bool> createFolder(String name,String permission,{List<staff.Data>? data}) async {
    List<Map<String,dynamic>> users = [];
    Map<String,dynamic> json = {
      'name':name,
      'permission':permission
    };
    if(data!=null) {
      for (var e in data) {
        users.add({
          'user_name':e.userName,
          'permission':e.permission,
        });
      }
      json['users'] = users;
    }
    ResponseData responseData = await connection.post('folder',json);
    if(responseData.isSuccess) {
      return true;
    }
    return false;
  }
  static Future<bool> changeFolderName(String oldFolderName, String newFolderName, {String password = ''}) async {
    Map<String,dynamic> json = {
      'old_folder_name' : oldFolderName,
      'new_folder_name' : newFolderName,
    };
    if(password != '') {
      json['password'] = password;
    }
    ResponseData responseData = await connection.post('folder/rename',json);
    if(responseData.isSuccess) {
      return true;
    }
    return false;
  }
  static Future<bool> changeFileName(String fileId, String newName) async {
    ResponseData responseData = await connection.post('files/rename', {
      'file_id': fileId,
      'new_name': newName
    });
    if(responseData.isSuccess) {
      return true;
    }
    return false;
  }
  static Future<bool> copyFile(String filePath, String folderName) async {
    ResponseData responseData = await connection.post('files/duplicate', {'file_path':filePath,'name':folderName});
    if(responseData.isSuccess) {
      return true;
    }
    return false;
  }
  static Future<bool> deleteFile(String fileId, {String? versionId}) async {
    String path = 'files?file_id=$fileId';
    if(versionId != null) {
      path += '&version_id=$versionId';
    }
    ResponseData responseData = await connection.delete(path, {});
    if(responseData.isSuccess) {
      return true;
    }
    return false;
  }
  static Future<bool> restoreVersion(String filePath, String versionId) async {
    ResponseData responseData = await connection.post('files/restore-version', {
      'file_path':filePath,
      'version_id':versionId
    });
    if(responseData.isSuccess) {
      return true;
    }
    return false;
  }
  static Future<bool> moveFileToFolder(String filePath, String folderName) async {
    ResponseData responseData = await connection.post('files/move', {
      'file_path':filePath,
      'folder_name':folderName
    });
    if(responseData.isSuccess) {
      return true;
    }
    else {
      DocumentConnection.error(DocumentConnection.buildContext!, responseData.data['message']);
      return false;
    }
  }
  static Future<Files?> versionFile(String filePath) async {
    ResponseData responseData = await connection.get('files/list-version?file_path=$filePath&limit=1000');
    if(responseData.isSuccess) {
      Files files = Files.fromJson(responseData.data);
      return files;
    }
    return null;
  }
  static Future<FileLog?> fileLog(String fileId) async {
    ResponseData responseData = await connection.get('files/log-activity?file_id=$fileId');
    if(responseData.isSuccess) {
      FileLog folderLog = FileLog.fromJson(responseData.data);
      return folderLog;
    }
    return null;
  }
  static Future<Comment?> commentList(String fileId) async {
    ResponseData responseData = await connection.get('files/comments?file_id=$fileId');
    if(responseData.isSuccess) {
      Comment comment = Comment.fromJson(responseData.data);
      return comment;
    }
    return null;
  }
  static Future<String?> shareFolder(String folderName, {String? expireTime}) async {
    String path = 'folder/share?folder_name=$folderName';
    if(expireTime != null) {
      path += '&expires_time=$expireTime';
    }
    ResponseData responseData = await connection.get(path);
    if(responseData.isSuccess) {
      String url = responseData.data['data']['url'];
      return url;
    }
    return null;
  }
  static Future<String?> shareFile(String filePath, {String? expireTime}) async {
    String path = 'files/share?file_path=$filePath';
    if(expireTime != null) {
      path += '&expires_time=$expireTime';
    }
    ResponseData responseData = await connection.get(path);
    if(responseData.isSuccess) {
      String url = responseData.data['data']['url'];
      return url;
    }
    return null;
  }
  static Future<bool> addComment(String fileId,String comment) async {
    ResponseData responseData = await connection.post('files/comments',{
      'file_id': fileId,
      'message': comment
    });
    if(responseData.isSuccess) {
      return true;
    }
    return false;
  }
  static Future showLoading(BuildContext context) async {
    return await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return SimpleDialog(
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            children: <Widget>[
              Center(
                child: Platform.isAndroid ? const CircularProgressIndicator() : const CupertinoActivityIndicator(),
              )
            ],
          );
        });
  }
  static void error(BuildContext context,String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.text(LangKey.warning)),
        content: Text(error),
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