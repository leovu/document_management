class FolderInformation {
  Data? data;

  FolderInformation({data});

  FolderInformation.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  int? totalItem;
  int? size;
  String? sizeFormat;
  String? displayName;
  String? folderName;
  bool? folderPassword;
  String? createdDate;
  String? updatedDate;
  String? owner;
  String? ownerName;
  String? updatedByName;
  String? permission;
  UserPermission? userPermission;

  Data(
      {totalItem,
        size,
        sizeFormat,
        displayName,
        folderName,
        folderPassword,
        createdDate,
        updatedDate,
        owner,
        ownerName,
        updatedByName,
        permission,
        userPermission});

  Data.fromJson(Map<String, dynamic> json) {
    totalItem = json['total_item'];
    size = json['size'];
    sizeFormat = json['size_format'];
    displayName = json['display_name'];
    folderName = json['folder_name'];
    folderPassword = json['folder_password'];
    createdDate = json['created_date'];
    updatedDate = json['updated_date'];
    owner = json['owner'];
    ownerName = json['owner_name'];
    updatedByName = json['updated_by_name'];
    permission = json['permission'];
    userPermission = json['user_permission'] != null
        ? UserPermission.fromJson(json['user_permission'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_item'] = totalItem;
    data['size'] = size;
    data['size_format'] = sizeFormat;
    data['display_name'] = displayName;
    data['folder_name'] = folderName;
    data['folder_password'] = folderPassword;
    data['created_date'] = createdDate;
    data['updated_date'] = updatedDate;
    data['owner'] = owner;
    data['owner_name'] = ownerName;
    data['updated_by_name'] = updatedByName;
    data['permission'] = permission;
    if (userPermission != null) {
      data['user_permission'] = userPermission!.toJson();
    }
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