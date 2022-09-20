import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:io' as io;
// ignore_for_file: depend_on_referenced_packages
import 'package:path_provider/path_provider.dart';

class Files {
  List<Data>? data;
  Meta? meta;

  Files({data, meta});

  Files.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
    meta = json['meta'] != null ? Meta.fromJson(json['meta']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    if (meta != null) {
      data['meta'] = meta!.toJson();
    }
    return data;
  }
  Future<void> checkDownloaded() async {
    if(data!=null && data!.isNotEmpty){
      for (var e in data!) {
        await e.checkDownloaded();
      }
    }
  }
}

class Data {
  String? fileName;
  String? key;
  int? size;
  String? sizeFormat;
  String? lastModified;
  Info? info;
  int? version;
  String? versionId;
  String? createdDate;
  String? fileId;
  String? owner;
  String? ownerName;
  String? ownerAvatar;
  String? updatedBy;
  String? updatedName;
  String? updatedAvatar;
  String? avatar;
  String? previewMobile;
  String? folderDisplayName;
  FocusNode nameFocus = FocusNode();
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isDownloading = false;
  bool isDownloaded = false;

  Data(
      {fileName,
        key,
        size,
        sizeFormat,
        lastModified,
        info,
        version,
        versionId,
        createdDate,
        fileId,
        owner,
        ownerName,
        ownerAvatar,
        updatedBy,
        updatedName,
        updatedAvatar,
        avatar,
        previewMobile,
        folderDisplayName});

  Data.fromJson(Map<String, dynamic> json) {
    fileName = json['file_name'];
    key = json['key'];
      sizeFormat = json['size_format'];
    if(json['size'] is int) {
      size = json['size'];
    }
    else {
      sizeFormat = json['size'];
    }
    lastModified = json['last_modified'];
    info = json['info'] != null ? Info.fromJson(json['info']) : null;
    version = json['version'];
    versionId = json['version_id'];
    createdDate = json['created_date'];
    fileId = json['file_id'];
    owner = json['owner'];
    ownerName = json['owner_name'];
    ownerAvatar = json['owner_avatar'];
    updatedBy = json['updated_by'];
    updatedName = json['updated_name'];
    updatedAvatar = json['updated_avatar'];
    avatar = json['avatar'];
    previewMobile = json['preview_mobile'];
    folderDisplayName = json['folder_display_name'];
  }

  Future<void> checkDownloaded() async {
    Directory? directory;
    if (Platform.isIOS) {
      directory = await getApplicationDocumentsDirectory();
    } else if (Platform.isAndroid) {
      directory = await getTemporaryDirectory();
    }
    String urlPath = '${directory?.path}/${createdDate}_$fileName';
    isDownloaded = await io.File(urlPath).exists();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['file_name'] = fileName;
    data['key'] = key;
    data['size'] = size;
    data['size_format'] = sizeFormat;
    data['last_modified'] = lastModified;
    if (info != null) {
      data['info'] = info!.toJson();
    }
    data['version'] = version;
    data['version_id'] = versionId;
    data['created_date'] = createdDate;
    data['file_id'] = fileId;
    data['owner'] = owner;
    data['owner_name'] = ownerName;
    data['owner_avatar'] = ownerAvatar;
    data['updated_by'] = updatedBy;
    data['updated_name'] = updatedName;
    data['updated_avatar'] = updatedAvatar;
    data['avatar'] = avatar;
    data['preview_mobile'] = previewMobile;
    data['folder_display_name'] = folderDisplayName;
    return data;
  }

  String getAvatarName() {
    String avatarName = '';
    if(ownerName != null && ownerName != '') {
      if(ownerName!.contains(' ')) {
        final splits = ownerName!.split(' ');
        avatarName += splits[0][0];
        final RegExp nameRegExp = RegExp('[a-zA-Z]');
        if(nameRegExp.hasMatch(splits[1][0])) {
          avatarName += splits[1][0];
        }
      }
      else {
        avatarName += ownerName![0];
        avatarName += ownerName![1];
      }
      avatarName = avatarName.toUpperCase();
    }
    return avatarName;
  }

  String getAvatarVersionName() {
    String avatarName = '';
    if(updatedName != null && updatedName != '') {
      if(updatedName!.contains(' ')) {
        final splits = updatedName!.split(' ');
        avatarName += splits[0][0];
        final RegExp nameRegExp = RegExp('[a-zA-Z]');
        if(nameRegExp.hasMatch(splits[1][0])) {
          avatarName += splits[1][0];
        }
      }
      else {
        avatarName += updatedName![0];
        avatarName += updatedName![1];
      }
      avatarName = avatarName.toUpperCase();
    }
    return avatarName;
  }
}

class Info {
  String? ext;
  String? thumbnail;

  Info({ext, thumbnail});

  Info.fromJson(Map<String, dynamic> json) {
    ext = json['ext'];
    thumbnail = json['thumbnail'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ext'] = ext;
    data['thumbnail'] = thumbnail;
    return data;
  }
}

class Meta {
  Pagination? pagination;

  Meta({pagination});

  Meta.fromJson(Map<String, dynamic> json) {
    pagination = json['pagination'] != null
        ? Pagination.fromJson(json['pagination'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (pagination != null) {
      data['pagination'] = pagination!.toJson();
    }
    return data;
  }
}

class Pagination {
  int? total;
  int? count;
  int? perPage;
  int? currentPage;
  int? totalPages;

  Pagination(
      {total,
        count,
        perPage,
        currentPage,
        totalPages,
        links});

  Pagination.fromJson(Map<String, dynamic> json) {
    total = json['total'];
    count = json['count'];
    perPage = json['per_page'];
    currentPage = json['current_page'];
    totalPages = json['total_pages'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total'] = total;
    data['count'] = count;
    data['per_page'] = perPage;
    data['current_page'] = currentPage;
    data['total_pages'] = totalPages;
    return data;
  }
}