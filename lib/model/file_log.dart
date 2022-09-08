class FileLog {
  List<Data>? data;

  FileLog({data});

  FileLog.fromJson(Map<String, dynamic> json) {
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
  String? logName;
  String? event;
  String? description;
  Properties? properties;
  String? createdAt;
  String? updatedAt;
  Indentity? indentity;

  Data(
      {logName,
        event,
        description,
        properties,
        createdAt,
        updatedAt,
        indentity});

  Data.fromJson(Map<String, dynamic> json) {
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

class Indentity {
  String? accessKey;
  Staff? staff;

  Indentity({accessKey, staff});

  Indentity.fromJson(Map<String, dynamic> json) {
    accessKey = json['access_key'];
    staff = json['staff'] != null ? Staff.fromJson(json['staff']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['access_key'] = accessKey;
    if (staff != null) {
      data['staff'] = staff!.toJson();
    }
    return data;
  }
}

class Staff {
  int? staffId;
  String? userName;
  String? fullName;
  String? phone;
  String? email;
  String? staffAvatar;

  Staff(
      {staffId,
        userName,
        fullName,
        phone,
        email,
        staffAvatar});

  Staff.fromJson(Map<String, dynamic> json) {
    staffId = json['staff_id'];
    userName = json['user_name'];
    fullName = json['full_name'];
    phone = json['phone'];
    email = json['email'];
    staffAvatar = json['staff_avatar'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['staff_id'] = staffId;
    data['user_name'] = userName;
    data['full_name'] = fullName;
    data['phone'] = phone;
    data['email'] = email;
    data['staff_avatar'] = staffAvatar;
    return data;
  }
}

class Properties {
  List<String>? file;

  Properties({file});

  Properties.fromJson(Map<String, dynamic> json) {
    if(json['file'] != null) {
      if(json['file'] is String) {
        file = [json['file']];
      }
      else {
        file = json['file'].cast<String>();
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['file'] = file;
    return data;
  }
}
