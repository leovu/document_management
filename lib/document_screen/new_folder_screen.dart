import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:document_management/connection/document_connection.dart';
import 'package:document_management/document_screen/list_department_screen.dart';
import 'package:document_management/document_screen/list_user_screen.dart';
import 'package:document_management/localization/app_localization.dart';
import 'package:document_management/localization/lang_key.dart';
import 'package:document_management/model/staff.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class NewFolderScreen extends StatefulWidget {
  const NewFolderScreen({Key? key}) : super(key: key);
  @override
  State<NewFolderScreen> createState() => _NewFolderScreenState();
}

class _NewFolderScreenState extends State<NewFolderScreen> {
  String? folderType;
  String? folderTypeAccessName;
  Staff? selectedStaffs;
  bool? isSelectedDelete;
  final TextEditingController _folderNameController = TextEditingController();
  final TextEditingController _accessPermissionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _folderNameController.addListener(editFolderName);
  }

  @override
  void dispose() {
    _folderNameController.dispose();
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
            title: Text(AppLocalizations.text(LangKey.createFolder),style: const TextStyle(color: Colors.black),),
            actions: <Widget>[
              if(isSelectedDelete == true) InkWell(
                onTap: () {
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
          child: Column(
            children: [
              Expanded(child: ListView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                children: [
                  Container(height: 10.0,),
                  title('${AppLocalizations.text(LangKey.folderName)}:',isRequired: true),
                  Container(height: 10.0,),
                  Container(
                    height: 40.0,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(width: 0.5)
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Center(
                        child: TextField(
                          controller: _folderNameController,
                          decoration: InputDecoration.collapsed(
                              hintText: AppLocalizations.text(LangKey.inputFolderName)
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(height: 10.0,),
                  title('${AppLocalizations.text(LangKey.accessFolderPermission)}:',isRequired: true),
                  Container(height: 10.0,),
                  InkWell(
                    onTap: permissionSelection,
                    child: Container(
                      height: 40.0,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(width: 0.5)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        child: Row(
                          children: [
                            Expanded(child: Center(
                              child: TextField(
                                controller: _accessPermissionController,
                                decoration: InputDecoration.collapsed(
                                    hintText: AppLocalizations.text(LangKey.chooseAccessFolderPermission)
                                ),
                                enabled: false,
                              ),
                            )),
                            const Icon(Icons.arrow_drop_down)
                          ],
                        ),
                      ),
                    ),
                  ),
                  if(folderType != null && folderType == 'custom')
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Row(
                        children: [
                          Expanded(child: title('${AppLocalizations.text(LangKey.staffList)}:')),
                          InkWell(
                            onTap: () async {
                              int? targetType = await targetSelection();
                              if(targetType == null) return;
                              Staff? staffs;
                              if(!mounted) return;
                              if(targetType == 0) {
                                staffs = await Navigator.of(context).push(MaterialPageRoute( builder: (context) => const ListDepartmentScreen()));
                              }
                              else if(targetType == 1) {
                                staffs = await Navigator.of(context).push(MaterialPageRoute( builder: (context) => const ListUserScreen()));
                              }
                              if(staffs != null) {
                                if(selectedStaffs != null) {
                                  for (var e in selectedStaffs!.data!) {
                                    for (int i=0;i<=staffs.data!.length-1;i++) {
                                      final h = staffs.data![i];
                                      if(h.staffId == e.staffId) {
                                        staffs.data!.removeAt(i);
                                        break;
                                      }
                                    }
                                  }
                                  selectedStaffs!.data!.addAll(staffs.data!);
                                }
                                else {
                                  selectedStaffs = staffs;
                                }
                                setState(() {});
                              }
                            },
                            child: const SizedBox(
                              width: 40.0,
                              child: Padding(
                                padding: EdgeInsets.only(top: 8.0),
                                child: Icon(Icons.add,color: Colors.blueAccent,size: 20,),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  Container(height: 10.0,),
                  if(selectedStaffs != null) Column(
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
                            endActionPane: ActionPane(
                              motion: const ScrollMotion(),
                              children: [
                                SlidableAction(
                                  onPressed: (context){
                                    setState(() {
                                      selectedStaffs!.data!.remove(e);
                                    });
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
                                      e.staffAvatar == null ? CircleAvatar(
                                        radius: 15.0,
                                        child: Text(e.getAvatarName()),
                                      ) : CircleAvatar(
                                        radius: 15.0,
                                        backgroundImage:
                                        CachedNetworkImageProvider(e.staffAvatar!),
                                        backgroundColor: Colors.transparent,
                                      ),),
                                      Expanded(child:
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            AutoSizeText(e.fullName ?? '',style: const TextStyle(fontWeight: FontWeight.bold),),
                                            Container(height: 5.0,),
                                            if(e.email != null) AutoSizeText(e.email!),
                                            if(e.email != null) Container(height: 5.0,),
                                            // if(e.phone != null) AutoSizeText(e.phone!),
                                            // if(e.phone != null) Container(height: 5.0,),
                                            // AutoSizeText(e.department?.departmentName ?? ''),
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
                                                    if(e.permission == 'write_bucket' || e.permission == 'read_write_bucket') const Icon(Icons.edit_outlined,size: 15.0,),
                                                    Container(width: 2.0,),
                                                    if(e.permission == 'read_bucket' || e.permission == 'read_write_bucket') const Icon(Icons.remove_red_eye_outlined,size: 15.0,),
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
              )),
              Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
                child: Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width *0.9,
                    height: 45.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: checkAddVisible() ? const Color(0xff4fc4ca) : Colors.grey,
                    ),
                    child: InkWell(
                      onTap: () async {
                        bool check = checkAddVisible();
                        if(!check) return;
                        DocumentConnection.showLoading(context);
                        bool result = await DocumentConnection.createFolder(_folderNameController.text, folderType!, data: selectedStaffs?.data);
                        if(!mounted) return;
                        Navigator.of(context).pop();
                        Navigator.of(context).pop(result);
                      },
                      child: Center(
                        child: AutoSizeText(AppLocalizations.text(LangKey.add),style:
                        TextStyle(color: checkAddVisible() ? Colors.white :Colors.black,
                            fontWeight: FontWeight.bold),textScaleFactor: 1.5,),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        )
    );
  }

  editFolderName() {
    setState(() {
      checkAddVisible();
    });
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
  bool checkAddVisible() {
    if(_folderNameController.text.trim() == '') {
      return false;
    }
    if(folderType == null) {
      return false;
    }
    if(folderType == 'custom') {
      if (selectedStaffs?.data == null) {
        return false;
      }
      else {
        if(selectedStaffs!.data!.isEmpty) {
          return false;
        }
      }
    }
    return true;
  }

  void staffPermission(Data data) {
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

  void setStaffPermission(Data data, String permission) {
    setState(() {
      data.permission = permission;
    });
  }

  Future<int?> targetSelection() async {
    int? targetType;
    var result = await showModalActionSheet<String>(
      context: context,
      actions: [
        SheetAction(
          label: AppLocalizations.text(LangKey.department),
          key: 'Deparment',
        ),
        SheetAction(
          label: AppLocalizations.text(LangKey.staff),
          key: 'Staff',
        ),
      ],
    );
    if(result == 'Staff') {
      targetType = 1;
    } else if(result == 'Deparment') {
      targetType = 0;
    }
    return targetType;
  }
  void permissionSelection() {
    showModalActionSheet<String>(
      context: context,
      actions: [
        SheetAction(
          label: AppLocalizations.text(LangKey.public),
          key: 'Public',
        ),
        SheetAction(
          label: AppLocalizations.text(LangKey.private),
          key: 'Private',
        ),
        SheetAction(
          label: AppLocalizations.text(LangKey.targetOnly),
          key: 'Target Only',
        ),
      ],
    ).then((value) => value == 'Public'
        ? setFolderType('public')
        : value == 'Private'
        ? setFolderType('private')
        : value == 'Target Only'
        ? setFolderType('custom') : {});
  }
  void setFolderType(String type) {
    setState(() {
      folderType = type;
      switch (type) {
        case 'public':
          _accessPermissionController.text = AppLocalizations.text(LangKey.public);
          selectedStaffs = null;
          checkAddVisible();
          break;
        case 'private':
          _accessPermissionController.text = AppLocalizations.text(LangKey.private);
          selectedStaffs = null;
          checkAddVisible();
          break;
        case 'custom':
          _accessPermissionController.text = AppLocalizations.text(LangKey.targetOnly);
          checkAddVisible();
          break;
        default:
          break;
      }
    });
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