import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:document_management/connection/document_connection.dart';
import 'package:document_management/localization/app_localization.dart';
import 'package:document_management/localization/lang_key.dart';
import 'package:document_management/model/staff.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ListUserScreen extends StatefulWidget {
  const ListUserScreen({Key? key}) : super(key: key);
  @override
  State<ListUserScreen> createState() => _ListUserScreenState();
}

class _ListUserScreenState extends State<ListUserScreen> {
  Staff? staffs;
  Staff? visibleStaffs;
  bool isCheckAll = false;
  bool isInitScreen = true;
  final _focusSearch = FocusNode();
  final _controllerSearch = TextEditingController();
  @override
  void initState() {
    super.initState();
    staffList();
  }
  void staffList() async {
    staffs = await DocumentConnection.staffList();
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
              if(visibleStaffs?.data!=null) {
                for (var e in visibleStaffs!.data!) {
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
          visibleStaffs == null ? Container() :
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: visibleStaffs?.data == null ? Container() : listView()
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
                  onTap: () {
                    if(staffs?.data != null) {
                      Staff? seletecedStaffs;
                      try{
                        seletecedStaffs = Staff();
                        seletecedStaffs.data = staffs!.data!.where((element) => element.isSelected == true).toList();
                      }catch(_){}
                      Navigator.of(context).pop(seletecedStaffs);
                    }
                    else {
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
      visibleStaffs = Staff();
      try {
        visibleStaffs?.data = <Data>[...staffs!.data!.toList()];
      }catch(_) {}
      visibleStaffs!.data = visibleStaffs!.data!.where((element) {
        try {
          if(
          (element.fullName!.toLowerCase()).contains(val)) {
            return true;
          }
          return false;
        }catch(e){
          return false;
        }
      }).toList();
    }
    else {
      visibleStaffs = Staff();
      try {
        visibleStaffs?.data = <Data>[...staffs!.data!.toList()];
      }catch(_) {}
    }
  }

  Widget listView() {
    return
      ListView(
        children: visibleStaffs!.data!.map((e) => Column(
          children: [
            Column(
              children: [
                Container(height: 8.0,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    e.staffAvatar == null ? CircleAvatar(
                      radius: 25.0,
                      child: Text(e.getAvatarName()),
                    ) : CircleAvatar(
                      radius: 25.0,
                      backgroundImage:
                      CachedNetworkImageProvider(e.staffAvatar!),
                      backgroundColor: Colors.transparent,
                    ),
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
                          if(e.phone != null) AutoSizeText(e.phone!),
                          if(e.phone != null) Container(height: 5.0,),
                          AutoSizeText(e.department?.departmentName ?? ''),
                          Container(height: 7.0,),
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
                )
              ],
            ),
            if(visibleStaffs!.data!.indexOf(e) != visibleStaffs!.data!.length-1) Container(height: 1.0,color: Colors.grey.shade300,)
          ],
        )).toList(),
      );
  }
  bool checkAllSelected() {
    bool check = true;
    for (var element in visibleStaffs!.data!) {
      if(element.isSelected == false) {
        check = false;
        break;
      }
    }
    return check;
  }
}