import 'package:flutter/cupertino.dart';

class Folder {
  List<Data>? data;

  Folder({data});

  Folder.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? folderDisplayName;
  String? folderName;
  bool? folderPassword;
  String? createdDate;
  String? updatedDate;
  String? owner;
  String? permission;
  UserPermission? userPermission;
  int? totalItem;
  FocusNode nameFocus = FocusNode();
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Data(
      {folderDisplayName,
        folderName,
        folderPassword,
        createdDate,
        updatedDate,
        owner,
        permission,
        userPermission,
        totalItem});

  Data.fromJson(Map<String, dynamic> json) {
    folderDisplayName = json['folder_display_name'];
    folderName = json['folder_name'];
    folderPassword = json['folder_password'];
    createdDate = json['created_date'];
    updatedDate = json['updated_date'];
    owner = json['owner'];
    permission = json['permission'];
    userPermission = json['user_permission'] != null
        ? UserPermission.fromJson(json['user_permission'])
        : null;
    totalItem = json['total_item'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['folder_display_name'] = folderDisplayName;
    data['folder_name'] = folderName;
    data['folder_password'] = folderPassword;
    data['created_date'] = createdDate;
    data['updated_date'] = updatedDate;
    data['owner'] = owner;
    data['permission'] = permission;
    if (userPermission != null) {
      data['user_permission'] = userPermission!.toJson();
    }
    data['total_item'] = totalItem;
    return data;
  }
}

class UserPermission {
  bool? writeBucket;
  bool? readBucket;
  bool? readWriteBucket;

  UserPermission({writeBucket, readBucket, readWriteBucket});

  UserPermission.fromJson(Map<String, dynamic> json) {
    writeBucket = json['write_bucket'];
    readBucket = json['read_bucket'];
    readWriteBucket = json['read_write_bucket'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['write_bucket'] = writeBucket;
    data['read_bucket'] = readBucket;
    data['read_write_bucket'] = readWriteBucket;
    return data;
  }
}