import 'dart:convert';
import 'dart:io';
import 'package:document_management/connection/document_connection.dart';
import 'package:http/http.dart' as http;

class HTTPConnection {
  static String domain = 'http://qc.stag.epoints.vn/file/api/';
  static String brandCode = 'qc';
  Future<ResponseData> upload(String path, File file , {Map<String,dynamic>? body}) async {
    final uri = Uri.parse('$domain$path');
    var request = http.MultipartRequest('POST', uri);
    request.headers.addAll({'Content-Type': 'multipart/form-data','Authorization':'Bearer ${DocumentConnection.account!.accessToken}','brand-code':brandCode, 'lang': DocumentConnection.locale.languageCode});
    request.files.add(
      http.MultipartFile(
        'file',
        file.readAsBytes().asStream(),
        file.lengthSync(),
        filename: file.path.split("/").last,
      ),
    );
    if(body != null) {
      for (var key in body.keys) {
        request.fields[key] = body[key];
      }
    }
    //TODO: Log HTTP Connection
    print('***** Upload *****');
    print(uri);
    print(request.headers);
    print('***** Upload *****');
    var streamResponse = await request.send();
    var response = await http.Response.fromStream(streamResponse);
    if(response.statusCode == 200) {
      ResponseData data = ResponseData();
      data.isSuccess = true;
      try {
        String responseBody = response.body;
        data.data = jsonDecode(responseBody);
      }catch(_) {}
      return data;
    }
    else {
      ResponseData data = ResponseData();
      data.isSuccess = false;
      try {
        String responseBody = response.body;
        data.data = jsonDecode(responseBody);
      }catch(_) {}
      return data;
    }
  }
  Future<ResponseData>post(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('$domain$path');
    final headers = {'Content-Type': 'application/json','brand-code':brandCode, 'lang': DocumentConnection.locale.languageCode};
    if(DocumentConnection.account != null) {
      headers['Authorization'] = 'Bearer ${DocumentConnection.account!.accessToken}';
    }
    String jsonBody = json.encode(body);
    print('***** POST *****');
    print(uri);
    print(headers);
    print(jsonBody);
    print('***** POST *****');
    final encoding = Encoding.getByName('utf-8');
    http.Response response = await http.post(
      uri,
      headers: headers,
      body: jsonBody,
      encoding: encoding,
    );
    int statusCode = response.statusCode;
    if(statusCode == 200) {
      ResponseData data = ResponseData();
      data.isSuccess = true;
      try {
        String responseBody = response.body;
        data.data = jsonDecode(responseBody);
      }catch(_) {}
      return data;
    }
    else if( 201 <= statusCode && statusCode < 300) {
      ResponseData data = ResponseData();
      data.isSuccess = true;
      return data;
    }
    else {
      ResponseData data = ResponseData();
      data.isSuccess = false;
      try {
        String responseBody = response.body;
        data.data = jsonDecode(responseBody);
      }catch(_) {}
      return data;
    }
  }
  Future<ResponseData>delete(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('$domain$path');
    final headers = {'Content-Type': 'application/json','brand-code':brandCode, 'lang': DocumentConnection.locale.languageCode};
    if(DocumentConnection.account != null) {
      headers['Authorization'] = 'Bearer ${DocumentConnection.account!.accessToken}';
    }
    String jsonBody = json.encode(body);
    print('***** DELETE *****');
    print(uri);
    print(headers);
    print(jsonBody);
    print('***** DELETE *****');
    final encoding = Encoding.getByName('utf-8');
    http.Response response = await http.delete(
      uri,
      headers: headers,
      body: jsonBody,
      encoding: encoding,
    );
    int statusCode = response.statusCode;
    if(statusCode == 200) {
      String responseBody = response.body;
      ResponseData data = ResponseData();
      data.isSuccess = true;
      data.data = jsonDecode(responseBody);
      return data;
    }
    else if( 201 <= statusCode && statusCode < 300) {
      ResponseData data = ResponseData();
      data.isSuccess = true;
      return data;
    }
    else {
      ResponseData data = ResponseData();
      data.isSuccess = false;
      try {
        String responseBody = response.body;
        data.data = jsonDecode(responseBody);
      }catch(_) {}
      return data;
    }
  }
  Future<ResponseData>get(String path) async {
    final uri = Uri.parse('$domain$path');
    final headers = {'brand-code':brandCode, 'lang': DocumentConnection.locale.languageCode};
    if(DocumentConnection.account != null) {
      headers['Authorization'] = 'Bearer ${DocumentConnection.account!.accessToken}';
    }
    print('***** GET *****');
    print(uri);
    print(headers);
    print('***** GET *****');
    http.Response response = await http.get(
      uri,
      headers: headers,
    );
    int statusCode = response.statusCode;
    if(statusCode == 200) {
      String responseBody = response.body;
      ResponseData data = ResponseData();
      data.isSuccess = true;
      data.data = jsonDecode(responseBody);
      return data;
    }
    else {
      ResponseData data = ResponseData();
      data.isSuccess = false;
      try {
        String responseBody = response.body;
        data.data = jsonDecode(responseBody);
      }catch(_) {}
      return data;
    }
  }
}

class ResponseData {
  late bool isSuccess;
  late Map<String,dynamic> data;
}

