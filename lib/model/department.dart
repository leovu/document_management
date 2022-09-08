class Departments {
  List<Data>? data;

  Departments({data});

  Departments.fromJson(Map<String, dynamic> json) {
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
  int? departmentId;
  String? departmentName;
  int? totalMember;
  bool? isSelected;

  Data({departmentId, departmentName, totalMember});

  Data.fromJson(Map<String, dynamic> json) {
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