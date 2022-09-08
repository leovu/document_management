import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:document_management/connection/document_connection.dart';
import 'package:document_management/localization/app_localization.dart';
import 'package:document_management/localization/lang_key.dart';
import 'package:document_management/model/department.dart';
import 'package:document_management/model/staff.dart' as staff;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ListDepartmentScreen extends StatefulWidget {
  const ListDepartmentScreen({Key? key}) : super(key: key);
  @override
  State<ListDepartmentScreen> createState() => _ListDepartmentScreenState();
}

class _ListDepartmentScreenState extends State<ListDepartmentScreen> {
  Departments? departments;
  Departments? visibleDepartments;
  bool isCheckAll = false;
  bool isInitScreen = true;
  final _focusSearch = FocusNode();
  final _controllerSearch = TextEditingController();
  @override
  void initState() {
    super.initState();
    deparmentList();
  }
  void deparmentList() async {
    departments = await DocumentConnection.deparmentList();
    _getVisible();
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
          title: Text(AppLocalizations.text(LangKey.staffList),style: const TextStyle(color: Colors.black),),
          actions: <Widget>[
              Checkbox(value: isCheckAll, onChanged: (value) {
                if(visibleDepartments?.data!=null) {
                  for (var e in visibleDepartments!.data!) {
                    e.isSelected = value;
                  }
                  setState(() {
                    isCheckAll = value!;
                  });
                }
              })
            ],
        ),
        body: isInitScreen ? Center(child: Platform.isAndroid ? const CircularProgressIndicator() : const CupertinoActivityIndicator()) : Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0,vertical: 10.0),
              child: Container(
                width: double.infinity,
                height: 40,
                decoration: BoxDecoration(
                    color: const Color(0xFFE7EAEF), borderRadius: BorderRadius.circular(5)),
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Center(
                        child: Icon(
                          Icons.search,
                        ),
                      ),
                    ),
                    Expanded(child: TextField(
                      focusNode: _focusSearch,
                      controller: _controllerSearch,
                      onChanged: (_) {
                        setState(() {
                          _getVisible();
                        });
                      },
                      decoration: InputDecoration.collapsed(
                        hintText: AppLocalizations.text(LangKey.search),
                      ),
                    )),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(5),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Center(
                            child: Icon(
                              Icons.close,
                            ),
                          ),
                        ),
                        onTap: (){
                          _controllerSearch.text = '';
                          setState(() {
                            _getVisible();
                          });
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
            Expanded(child:
            visibleDepartments == null ? Container() :
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: visibleDepartments?.data == null ? Container() : listView()
            )),
            Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width *0.9,
                  height: 45.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: const Color(0xff4fc4ca),
                  ),
                  child: InkWell(
                    onTap: () async {
                      List<int?>? selectedDepartment;
                      if(departments?.data != null) {
                        selectedDepartment = [];
                        for (var e in departments!.data!) {
                          if(e.isSelected == true) {
                            selectedDepartment.add(e.departmentId);
                          }
                        }
                      }
                      if(selectedDepartment != null && selectedDepartment.isNotEmpty) {
                        DocumentConnection.showLoading(context);
                        staff.Staff? staffs = await DocumentConnection.staffList(departments: selectedDepartment);
                        if(!mounted) return;
                        Navigator.of(context).pop();
                        Navigator.of(context).pop(staffs);
                      }
                      else {
                        if(!mounted) return;
                        Navigator.of(context).pop();
                      }
                    },
                    child: Center(
                      child: AutoSizeText(AppLocalizations.text(LangKey.save),style: const TextStyle(color: Colors.white,fontWeight: FontWeight.bold),textScaleFactor: 1.5,),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
    );
  }

  _getVisible() {
    String val = _controllerSearch.value.text.toLowerCase();
    if(val != '') {
      visibleDepartments = Departments();
      try {
        visibleDepartments?.data = <Data>[...departments!.data!.toList()];
      }catch(_) {}
      visibleDepartments!.data = visibleDepartments!.data!.where((element) {
        try {
          if(
          (element.departmentName!.toLowerCase()).contains(val)) {
            return true;
          }
          return false;
        }catch(e){
          return false;
        }
      }).toList();
    }
    else {
      visibleDepartments = Departments();
      try {
        visibleDepartments?.data = <Data>[...departments!.data!.toList()];
      }catch(_) {}
    }
  }

  Widget listView() {
    return
      ListView(
        children: visibleDepartments!.data!.map((e) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child:
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AutoSizeText(e.departmentName ?? '',style: const TextStyle(fontWeight: FontWeight.bold),),
                        Container(height: 5.0,),
                        AutoSizeText('${e.totalMember ?? 0} ${e.totalMember == null || (e.totalMember ?? 0) <= 1 ? AppLocalizations.text(LangKey.member) : AppLocalizations.text(LangKey.members)}'),
                      ],
                    ),
                  )),
                  Checkbox(value: e.isSelected ?? false, onChanged: (value) {
                    setState(() {
                      e.isSelected = value;
                      isCheckAll = checkAllSelected();
                    });
                  })
                ],
              ),
              if(visibleDepartments!.data!.indexOf(e) != visibleDepartments!.data!.length-1) Container(height: 1.0,color: Colors.grey.shade300,)
            ],
          ),
        )).toList(),
      );
  }
  bool checkAllSelected() {
    bool check = true;
    for (var element in visibleDepartments!.data!) {
      if(element.isSelected == false) {
        check = false;
        break;
      }
    }
    return check;
  }
}