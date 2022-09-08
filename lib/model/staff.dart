class Staff {
  List<Data>? data;

  Staff({data});

  Staff.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Staff.fromSelectedJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromSelectedJson({'indentity':v},isSelectedDefault: true));
      });
    }
  }

  Staff.fromSelectedStaffJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromSelectedJson({'indentity': {
          'staff' : v
        }},isSelectedDefault: true));
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
  int? staffId;
  String? userName;
  String? fullName;
  String? phone;
  String? email;
  String? staffAvatar;
  Indentity? indentity;
  Department? department;
  bool? isSelected;
  bool isSelectedDelete = false;
  String permission = 'read_bucket';

  Data(
      {staffId,
        userName,
        fullName,
        phone,
        email,
        staffAvatar,
        indentity,
        department});

  Data.fromJson(Map<String, dynamic> json, {bool isSelectedDefault = false}) {
    staffId = json['staff_id'];
    userName = json['user_name'];
    fullName = json['full_name'];
    phone = json['phone'];
    email = json['email'];
    staffAvatar = json['staff_avatar'];
    indentity = json['indentity'] != null
        ? Indentity.fromJson(json['indentity'])
        : null;
    department = json['department'] != null
        ? Department.fromJson(json['department'])
        : null;
    isSelected = isSelectedDefault;
  }

  Data.fromSelectedJson(Map<String, dynamic> json, {bool isSelectedDefault = false}) {
    staffId = json['staff_id'];
    userName = json['user_name'];
    fullName = json['full_name'];
    phone = json['phone'];
    email = json['email'];
    staffAvatar = json['staff_avatar'];
    indentity = json['indentity'] != null
        ? Indentity.fromJson(json['indentity'])
        : null;
    department = json['department'] != null
        ? Department.fromJson(json['department'])
        : null;
    isSelected = isSelectedDefault;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['staff_id'] = staffId;
    data['user_name'] = userName;
    data['full_name'] = fullName;
    data['phone'] = phone;
    data['email'] = email;
    data['staff_avatar'] = staffAvatar;
    if (indentity != null) {
      data['indentity'] = indentity!.toJson();
    }
    if (department != null) {
      data['department'] = department!.toJson();
    }
    return data;
  }

  String getAvatarName() {
    String avatarName = '';
    if(fullName != null && fullName != '') {
      if(fullName!.contains(' ')) {
        final splits = fullName!.split(' ');
        avatarName += splits[0][0];
        final RegExp nameRegExp = RegExp('[a-zA-Z]');
        if(nameRegExp.hasMatch(splits[1][0])) {
          avatarName += splits[1][0];
        }
      }
      else {
        avatarName += fullName![0];
        avatarName += fullName![1];
      }
      avatarName = avatarName.toUpperCase();
    }
    return avatarName;
  }
}

class Indentity {
  String? accessKey;
  StaffData? staff;
  String permission = 'read_bucket';

  Indentity({accessKey, staff});

  Indentity.fromJson(Map<String, dynamic> json) {
    accessKey = json['access_key'];
    if(json['permission'] != null) {
      permission = json['permission'];
    }
    staff = json['staff'] != null ? StaffData.fromJson(json['staff']) : null;
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

class StaffData {
  int? staffId;
  String? userName;
  String? fullName;
  String? phone;
  String? email;
  String? staffAvatar;
  Department? department;

  StaffData(
      {this.staffId,
        this.userName,
        this.fullName,
        this.phone,
        this.email,
        this.staffAvatar,
        this.department});

  StaffData.fromJson(Map<String, dynamic> json) {
    staffId = json['staff_id'];
    userName = json['user_name'];
    fullName = json['full_name'];
    phone = json['phone'];
    email = json['email'];
    staffAvatar = json['staff_avatar'];
    department = json['department'] != null
        ? Department.fromJson(json['department'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['staff_id'] = staffId;
    data['user_name'] = userName;
    data['full_name'] = fullName;
    data['phone'] = phone;
    data['email'] = email;
    data['staff_avatar'] = staffAvatar;
    if (department != null) {
      data['department'] = department!.toJson();
    }
    return data;
  }

  String getAvatarName() {
    String avatarName = '';
    if(fullName != null && fullName != '') {
      if(fullName!.contains(' ')) {
        final splits = fullName!.split(' ');
        avatarName += splits[0][0];
        final RegExp nameRegExp = RegExp('[a-zA-Z]');
        if(nameRegExp.hasMatch(splits[1][0])) {
          avatarName += splits[1][0];
        }
      }
      else {
        avatarName += fullName![0];
        avatarName += fullName![1];
      }
      avatarName = avatarName.toUpperCase();
    }
    return avatarName;
  }
}

class Department {
  int? departmentId;
  String? departmentName;
  int? totalMember;

  Department({this.departmentId, this.departmentName, this.totalMember});

  Department.fromJson(Map<String, dynamic> json) {
    departmentId = json['department_id'];
    departmentName = json['department_name'];
    totalMember = json['total_member'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['department_id'] = departmentId;
    data['department_name'] = departmentName;
    data['total_member'] = totalMember;
    return data;
  }
}
