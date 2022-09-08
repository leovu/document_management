class Comment {
  List<Data>? data;
  Meta? meta;

  Comment({data, meta});

  Comment.fromJson(Map<String, dynamic> json) {
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
}

class Data {
  String? commentDate;
  List<Detail>? detail;

  Data({commentDate, detail});

  Data.fromJson(Map<String, dynamic> json) {
    commentDate = json['comment_date'];
    if (json['detail'] != null) {
      detail = <Detail>[];
      json['detail'].forEach((v) {
        detail!.add(Detail.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['comment_date'] = commentDate;
    if (detail != null) {
      data['detail'] = detail!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Detail {
  String? message;
  Staff? staff;

  Detail({message, staff});

  Detail.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    staff = json['staff'] != null ? Staff.fromJson(json['staff']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
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
        totalPages});

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