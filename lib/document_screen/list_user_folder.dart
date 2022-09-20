import 'dart:io';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:document_management/connection/document_connection.dart';
import 'package:document_management/document_screen/list_user_screen.dart';
import 'package:document_management/localization/app_localization.dart';
import 'package:document_management/localization/lang_key.dart';
import 'package:document_management/model/staff.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:document_management/model/folder.dart' as r;
import 'package:flutter_slidable/flutter_slidable.dart';

class ListUserFolderScreen extends StatefulWidget {
  final r.Data? data;
  const ListUserFolderScreen({Key? key,this.data}) : super(key: key);
  @override
  State<ListUserFolderScreen> createState() => _ListUserFolderScreenState();
}

class _ListUserFolderScreenState extends State<ListUserFolderScreen> {
  Staff? selectedStaffs;
  bool? isSelectedDelete;
  bool isInitScreen = true;

  @override
  void initState() {
    super.initState();
    getList();
  }

  void getList() async {
    selectedStaffs = await DocumentConnection.staffList(folderName: widget.data?.folderName);
    setState(() {
      isInitScreen = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
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
            title: Text(AppLocalizations.text(LangKey.userList),style: const TextStyle(color: Colors.black),),
            actions: <Widget>[
              if(widget.data?.owner == DocumentConnection.account?.user?.staff?.userName) InkWell(
                onTap: () async {
                  Staff? staffs = await Navigator.of(context).push(MaterialPageRoute( builder: (context) => const ListUserScreen()));
                  if(staffs != null) {
                    if(selectedStaffs != null) {
                      for (var e in selectedStaffs!.data!) {
                        for (int i=0;i<=staffs.data!.length-1;i++) {
                          final h = staffs.data![i];
                          if(h.staffId == e.indentity?.staff?.staffId) {
                            staffs.data!.removeAt(i);
                            break;
                          }
                        }
                      }
                      selectedStaffs!.data!.addAll(Staff.fromSelectedStaffJson(staffs.toJson()).data!);
                    }
                    else {
                      selectedStaffs = staffs;
                    }
                    setState(() {});
                    List<Map<String,dynamic>> list = [];
                    for (var e in selectedStaffs!.data!) {
                      list.add({
                        'user_name': e.indentity?.staff?.userName ?? '',
                        'permission': e.indentity?.permission
                      });
                    }
                    await DocumentConnection.addFolderPolicy(widget.data?.folderName ?? '', list);
                  }
                },
                child: const SizedBox(
                  height: 40.0,
                  width: 40.0,
                  child: Icon(Icons.add,color: Colors.blueAccent,),
                ),
              ),
              if(isSelectedDelete == true) InkWell(
                onTap: () async {
                  try {
                    List<Data> removeList = selectedStaffs!.data!.where((element) => element.isSelectedDelete != false).toList();
                    List<String> list = [];
                    for (var e in removeList) {
                      list.add(e.indentity?.staff?.userName ?? '');
                    }
                    if(list.isNotEmpty) {
                      DocumentConnection.deleteFolderPolicy(widget.data?.folderName ?? '', list);
                    }
                  }catch(_) {}
                  selectedStaffs!.data = selectedStaffs!.data!.where((element) => element.isSelectedDelete != true).toList();
                  isSelectedDelete = checkIsSelectedDelete();
                  setState(() {});
                },
                child: const SizedBox(
                  height: 40.0,
                  width: 40.0,
                  child: Icon(Icons.delete,color: Colors.red,),
                ),
              )
            ]
        ),
        body:
        Container(
          color: Colors.white,
          child: isInitScreen ? Center(child: Platform.isAndroid ? const CircularProgressIndicator() : const CupertinoActivityIndicator()) : ListView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            children: [
              Container(height: 10.0,),
              selectedStaffs?.data == null ? Container() :
              Column(
                children: selectedStaffs!.data!.map((e) => GestureDetector(
                  onLongPress: () {
                    if(e.isSelectedDelete) {
                      e.isSelectedDelete = false;
                    }
                    else {
                      e.isSelectedDelete = true;
                    }
                    isSelectedDelete = checkIsSelectedDelete();
                    setState(() {});
                  },
                  onTap: () {
                    if(isSelectedDelete == true) {
                      if(e.isSelectedDelete) {
                        e.isSelectedDelete = false;
                      }
                      else {
                        e.isSelectedDelete = true;
                      }
                      isSelectedDelete = checkIsSelectedDelete();
                      setState(() {});
                    }
                  },
                  child: Column(
                    children: [
                      Slidable(
                        enabled: widget.data?.owner == DocumentConnection.account?.user?.staff?.userName,
                        endActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (context) async {
                                DocumentConnection.deleteFolderPolicy(widget.data?.folderName ?? '', [e.indentity?.staff?.userName ?? '']);
                                selectedStaffs!.data!.remove(e);
                                setState(() {});
                              },
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              label: AppLocalizations.text(LangKey.delete),
                            ),
                          ],
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(width: 1.0,color: e.isSelectedDelete == true ? const Color(0xff4fc4ca).withAlpha(20) : Colors.white),
                              borderRadius: BorderRadius.circular(10),
                              color: e.isSelectedDelete == true ? const Color(0xff4fc4ca).withAlpha(20) : Colors.white
                          ),
                          child: Column(
                            children: [
                              Container(height: 8.0,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(padding: const EdgeInsets.only(bottom: 8.0),child: e.isSelectedDelete == true ?
                                  const CircleAvatar(
                                    radius: 15.0,
                                    backgroundColor: Color(0xff4fc4ca),
                                    child: Icon(Icons.check,color: Colors.white,size: 15,),
                                  ) :
                                  e.indentity?.staff?.staffAvatar == null ? CircleAvatar(
                                    radius: 15.0,
                                    child: Text(e.indentity?.staff?.getAvatarName() ?? ''),
                                  ) : CircleAvatar(
                                    radius: 15.0,
                                    backgroundImage:
                                    CachedNetworkImageProvider(e.indentity!.staff!.staffAvatar!),
                                    backgroundColor: Colors.transparent,
                                  ),),
                                  Expanded(child:
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        AutoSizeText(e.indentity?.staff?.fullName ?? '',style: const TextStyle(fontWeight: FontWeight.bold),),
                                        Container(height: 5.0,),
                                        if(e.indentity?.staff?.email != null) AutoSizeText(e.indentity!.staff!.email!),
                                        if(e.indentity?.staff?.email != null) Container(height: 5.0,),
                                        if(e.indentity?.staff?.phone != null) AutoSizeText(e.indentity!.staff!.phone!),
                                        if(e.indentity?.staff?.phone != null) Container(height: 5.0,),
                                        AutoSizeText(e.indentity?.staff?.department?.departmentName ?? ''),
                                        Container(height: 7.0,),
                                      ],
                                    ),
                                  )),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: InkWell(
                                      onTap: () {
                                        staffPermission(e);
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(bottom: 8.0),
                                        child: Center(
                                          child: SizedBox(
                                            height: 30,
                                            width: 33,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                if(e.indentity?.permission == 'write_bucket' || e.indentity?.permission == 'read_write_bucket') const Icon(Icons.edit_outlined,size: 15.0,),
                                                Container(width: 2.0,),
                                                if(e.indentity?.permission == 'read_bucket' || e.indentity?.permission == 'read_write_bucket') const Icon(Icons.remove_red_eye_outlined,size: 15.0,),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      if(selectedStaffs!.data!.indexOf(e) != selectedStaffs!.data!.length-1 && e.isSelectedDelete != true) Container(height: 1.0,color: Colors.grey.shade300,),
                      if (e.isSelectedDelete == true) Container(height: 5.0,)
                    ],
                  ),
                )).toList(),
              )
            ],
          ),
        )
    );
  }

  bool checkIsSelectedDelete() {
    bool check = false;
    if(selectedStaffs?.data != null) {
      if(selectedStaffs!.data!.isNotEmpty) {
        for (var e in selectedStaffs!.data!) {
          if(e.isSelectedDelete == true) {
            check = true;
            break;
          }
        }
      }
    }
    return check;
  }

  void staffPermission(Data data) {
    if(widget.data?.owner == DocumentConnection.account?.user?.staff?.userName) {
      showModalActionSheet<String>(
        context: context,
        actions: [
          SheetAction(
            label: AppLocalizations.text(LangKey.view),
            key: 'View',
          ),
          SheetAction(
            label: AppLocalizations.text(LangKey.edit),
            key: 'Edit',
          ),
          SheetAction(
            label: AppLocalizations.text(LangKey.fullPermission),
            key: 'Full Permission',
          ),
        ],
      ).then((value) => value == 'View'
          ? setStaffPermission(data,'read_bucket')
          : value == 'Edit'
          ? setStaffPermission(data,'write_bucket')
          : value == 'Full Permission'
          ? setStaffPermission(data,'read_write_bucket')
          : {});
    }
  }

  void setStaffPermission(Data data, String permission) async {
    setState(() {
      data.indentity?.permission = permission;
    });
    List<Map<String,dynamic>> list = [];
    list.add({
      'user_name': data.indentity?.staff?.userName ?? '',
      'permission': data.indentity?.permission
    });
    await DocumentConnection.addFolderPolicy(widget.data?.folderName ?? '', list);
  }

  Widget title(String title, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(top:8.0),
      child: AutoSizeText.rich(TextSpan(
          children: [
            TextSpan(text: title,style: const TextStyle(fontWeight: FontWeight.bold)),
            if(isRequired) const TextSpan(text: '*',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.red))
          ]
      )),
    );
  }
}