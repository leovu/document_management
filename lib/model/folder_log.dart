import 'package:document_management/model/staff.dart';

class FolderLog {
  List<Data>? data;

  FolderLog({data});

  FolderLog.fromJson(Map<String, dynamic> json) {
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
  String? logDate;
  List<Detail>? detail;

  Data({logDate, detail});

  Data.fromJson(Map<String, dynamic> json) {
    logDate = json['log_date'];
    if (json['detail'] != null) {
      detail = <Detail>[];
      json['detail'].forEach((v) {
        detail!.add(Detail.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['log_date'] = logDate;
    if (detail != null) {
      data['detail'] = detail!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Detail {
  String? logName;
  String? event;
  String? description;
  Properties? properties;
  String? createdAt;
  String? updatedAt;
  Indentity? indentity;

  Detail(
      {logName,
        event,
        description,
        properties,
        createdAt,
        updatedAt,
        indentity});

  Detail.fromJson(Map<String, dynamic> json) {
    logName = json['log_name'];
    event = json['event'];
    description = json['description'];
    properties = json['properties'] != null && json['properties'] is Map<String,dynamic>
        ? Properties.fromJson(json['properties'])
        : null;
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    indentity = json['indentity'] != null
        ? Indentity.fromJson(json['indentity'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['log_name'] = logName;
    data['event'] = event;
    data['description'] = description;
    if (properties != null) {
      data['properties'] = properties!.toJson();
    }
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (indentity != null) {
      data['indentity'] = indentity!.toJson();
    }
    return data;
  }
}

class Properties {
  List<String>? file;

  Properties({file});

  Properties.fromJson(Map<String, dynamic> json) {
    if(json['file'] != null) {
      file = json['file'].cast<String>();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['file'] = file;
    return data;
  }
}
