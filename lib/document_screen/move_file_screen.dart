import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:document_management/connection/document_connection.dart';
import 'package:document_management/document_screen/file_management.dart';
import 'package:document_management/localization/app_localization.dart';
import 'package:document_management/localization/lang_key.dart';
import 'package:document_management/model/folder.dart' as folder;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:document_management/model/file.dart' as file;
import 'package:intl/intl.dart';

class MoveFileScreen extends StatefulWidget {
  final file.Data fileData;
  final folder.Data folderData;
  const MoveFileScreen({Key? key, required this.fileData, required this.folderData}) : super(key: key);
  @override
  State<MoveFileScreen> createState() => _MoveFileScreenState();
}

class _MoveFileScreenState extends State<MoveFileScreen> {
  folder.Folder? folders;
  final format1 = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z");
  final format2 = DateFormat("dd/MM/yyyy");
  final format3 = DateFormat("yyyy-MM-dd");
  bool isInitScreen = true;
  @override
  void initState() {
    super.initState();
    folderList();
  }
  void folderList() async {
    setState(() {
      isInitScreen = true;
    });
    folders = await DocumentConnection.folderList('date','desc');
    if(folders?.data!=null) {
      List<folder.Data> arr = [];
      for (var e in folders!.data!) {
        if(e.folderName != widget.folderData.folderName) {
          if(e.userPermission?.writeBucket == true || e.userPermission?.readWriteBucket == true) {
            arr.add(e);
          }
        }
      }
      folders!.data = arr;
    }
    setState(() {
      isInitScreen = false;
    });
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
        iconTheme: const IconThemeData(
        color: Colors.black,
    ),
      backgroundColor: Colors.white,
      title: Text(AppLocalizations.text(LangKey.moveFile),style: const TextStyle(color: Colors.black),),),
      body:
      isInitScreen ? Center(child: Platform.isAndroid ? const CircularProgressIndicator() : const CupertinoActivityIndicator()) :
      folders?.data == null ? Container() : listView(),
    );
  }
  Widget listView() {
    return
      Container(
        color: Colors.white,
        child: ListView(
          padding: const EdgeInsets.only(top: 10.0),
          children: folders!.data!.map((e) => InkWell(
            onTap: () {
              if(e.folderPassword == true) {
                showPasswordInputDialog(e);
              }
              else {
                moveFileToFolder(e,null);
              }
            },
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0)
              ),
              child: Column(
                children: [
                  Container(height: 5.0,),
                  Row(
                    children: [
                      Padding(padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: SizedBox(height: 45.0,width: 45.0,
                          child: Image.asset(e.folderPassword == false ? 'assets/ico/ico-folder.png' : 'assets/ico/ico-lock-folder.png',package: 'document_management',)
                          ,),),
                      Expanded(child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AutoSizeText(e.folderDisplayName ?? '',overflow: TextOverflow.ellipsis,style: const TextStyle(fontWeight: FontWeight.bold),),
                            Container(height: 3.0),
                            AutoSizeText('${format2.format(format1.parse(e.updatedDate!, true))} - ${e.totalItem ?? '0'} ${e.totalItem == null || (e.totalItem ?? 0) <= 1 ? AppLocalizations.text(LangKey.file) : AppLocalizations.text(LangKey.files)}',),
                          ],
                        ),
                      )),
                      const Padding(padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: SizedBox(height: 40.0,width: 40.0,
                          child: Icon(Icons.navigate_next,color: Colors.grey,)
                          ,),),
                    ],
                  ),
                  Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Container(height: 1.0,color: Colors.grey.shade300,width: MediaQuery.of(context).size.width*0.9,))
                ],
              ),
            ),
          ),
          ).toList(),
        ),
      );
  }
  void moveFileToFolder(folder.Data folderData, String? password) async {
    DocumentConnection.showLoading(context);
    bool result = await DocumentConnection.moveFileToFolder(context,widget.fileData.key??'', folderData.folderName??'', password);
    if(!mounted) return;
    Navigator.of(context).pop();
    if(result) {
      showDialog(
        context: context,
        builder: (cxt) => AlertDialog(
          title: Text(AppLocalizations.text(LangKey.warning)),
          content: Text(AppLocalizations.text(LangKey.moveFileSuccess)),
          actions: [
            ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.of(context).pop(true);
                  Navigator.of(context).push(MaterialPageRoute( builder: (context) => FileManagement(data: folderData,password: password,)));
                },
                child: Text(AppLocalizations.text(LangKey.accept)))
          ],
        ),
      );
    }
  }
  Future<void> checkFolderPassword(folder.Data data, String? password) async {
    if(password == '') {
      DocumentConnection.error(context, AppLocalizations.text(LangKey.emptyPasswordFolder));
      return;
    }
    bool result = await DocumentConnection.checkFolderPassword(context,data.folderName!, password!);
    if(result) {
      moveFileToFolder(data, password);
    }
  }
  void showPasswordInputDialog(folder.Data data) async {
    showDialog<bool>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          content: Card(
            color: Colors.transparent,
            elevation: 0.0,
            child: Column(
              children: <Widget>[
                if(data.folderPassword == true) TextField(
                  controller: data.passwordController,
                  decoration: InputDecoration(
                      labelText: AppLocalizations.text(LangKey.inputPassword),
                      filled: true,
                      fillColor: Colors.grey.shade50
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: SizedBox(
                      height: 40.0,
                      width: 160.0,
                      child: MaterialButton(
                        color: const Color(0xff4fc4ca),
                        child: Center(child: AutoSizeText(AppLocalizations.text(LangKey.accept),style: const TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),),
                        onPressed: () async {
                          checkFolderPassword(data, data.passwordController.text);
                          Navigator.of(context).pop();
                          data.passwordController.text = '';
                        },
                      )),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}