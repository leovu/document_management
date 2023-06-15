import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:document_management/connection/document_connection.dart';
import 'package:document_management/document_screen/file_management.dart';
import 'package:document_management/document_screen/folder_information_screen.dart';
import 'package:document_management/document_screen/list_user_folder.dart';
import 'package:document_management/document_screen/new_folder_screen.dart';
import 'package:document_management/document_screen/password_folder_screen.dart';
import 'package:document_management/document_screen/share_screen.dart';
import 'package:document_management/localization/app_localization.dart';
import 'package:document_management/localization/lang_key.dart';
import 'package:document_management/model/folder.dart';
import 'package:document_management/widget/menu_item_option_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:focused_menu/modals.dart';
import 'package:intl/intl.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class FolderManagement extends StatefulWidget {
  const FolderManagement({Key? key}) : super(key: key);
  @override
  State<FolderManagement> createState() => _FolderManagementState();
}

class _FolderManagementState extends State<FolderManagement> {
  Folder? folders;
  Folder? visibleFolders;
  final _focusSearch = FocusNode();
  final _controllerSearch = TextEditingController();
  bool isInitScreen = true;
  final format1 = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z");
  final format2 = DateFormat("dd/MM/yyyy");
  final format3 = DateFormat("yyyy-MM-dd");
  int? type = 0;
  Data? selectedFolder;

  String sortTypeKey = 'date';
  String sortTypeValue = 'desc';
  bool? isOwner;
  String? fromDate;
  String? toDate;

  bool isShowDropDownOptionMenu = false;

  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  void _onRefresh() async{
    await Future.delayed(const Duration(milliseconds: 1000));
    await folderList();
    _refreshController.refreshCompleted();
  }

  void _onLoading() async{
    await Future.delayed(const Duration(milliseconds: 1000));
    await folderList();
    _refreshController.loadComplete();
  }

  @override
  void initState() {
    super.initState();
    folderList();
  }

  Future<void> folderList() async {
    setState(() {
      isInitScreen = true;
    });
    folders = await DocumentConnection.folderList(sortTypeKey,sortTypeValue,owner: isOwner == null ? null : isOwner == true ? 1 : 0,fromDate: fromDate,toDate: toDate);
    _getVisible();
    setState(() {
      isInitScreen = false;
    });
  }

  _getVisible() {
    String val = _controllerSearch.value.text.toLowerCase();
    if(val != '') {
      visibleFolders = Folder();
      try {
        visibleFolders?.data = <Data>[...folders!.data!.toList()];
      }catch(_) {}
      visibleFolders!.data = visibleFolders!.data!.where((element) {
        try {
          if(
          (element.folderDisplayName!.toLowerCase()).contains(val)) {
            return true;
          }
          return false;
        }catch(e){
          return false;
        }
      }).toList();
    }
    else {
      visibleFolders = Folder();
      try {
        visibleFolders?.data = <Data>[...folders!.data!.toList()];
      }catch(_) {}
    }
  }

  List<Widget> _arrOptionMenuItemDropDown() {
    List<Widget> arr = [];
    arr.add(buildItemDropDown(OptionMenuItem(text: AppLocalizations.text(LangKey.createFolder), icon: Icons.create_new_folder_outlined, key: 'createFolder', action:  () async {
      bool? result = await Navigator.of(context).push(MaterialPageRoute( builder: (context) => const NewFolderScreen()));
      if(result == true) {
        folderList();
      }
    })));
    arr.add(buildItemDropDown(OptionMenuItem(text: AppLocalizations.text(LangKey.icons), icon: Icons.category_outlined, key: 'icons',isSelected: type == 1 ? true : false, action: () {
      if(type != 1) {
        setState(() {
          type = 1;
        });
      }
    })));
    arr.add(buildItemDropDown(OptionMenuItem(text: AppLocalizations.text(LangKey.list), key: 'list', icon: Icons.list_outlined, isSelected: type == 0 ? true : false, action: () {
      if(type != 0) {
        setState(() {
          type = 0;
        });
      }
    })));
    arr.add(buildItemDropDown(OptionMenuItem(text: AppLocalizations.text(LangKey.customDate),isSelected: !(fromDate == null && toDate == null), key: 'customDate', action: () async {
      if(fromDate == null && toDate == null) {
        List<DateTime?>? results = await showCalendarDatePicker2Dialog(
          context: context,
          config: CalendarDatePicker2WithActionButtonsConfig(
            calendarType: CalendarDatePicker2Type.range,
            okButton: AutoSizeText(AppLocalizations.text(LangKey.accept),style: const TextStyle(color: Colors.blue,fontWeight: FontWeight.bold),),
            cancelButton: InkWell(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: AutoSizeText(AppLocalizations.text(LangKey.cancel),style: const TextStyle(color: Colors.blue,fontWeight: FontWeight.bold),),
            ),
          ),
          dialogSize: const Size(325, 400),
          initialValue: [],
          borderRadius: BorderRadius.circular(15),
        );
        if(results != null && results.length == 2) {
          fromDate = format3.format(results[0]!);
          toDate = format3.format(results[1]!);
          folderList();
        }
      }
      else {
        fromDate = null;
        toDate = null;
        folderList();
      }
    }),));
    arr.add(buildItemDropDown(OptionMenuItem(text: AppLocalizations.text(LangKey.newest),isSelected: sortTypeKey == 'date' && sortTypeValue == 'asc', key: 'newest', action: () {
      if(sortTypeKey == 'date' && sortTypeValue == 'asc') return;
      setState(() {
        sortTypeKey = 'date';
        sortTypeValue = 'asc';
        isInitScreen = true;
      });
      folderList();
    })));
    arr.add(buildItemDropDown(OptionMenuItem(text: AppLocalizations.text(LangKey.oldest),isSelected: sortTypeKey == 'date' && sortTypeValue == 'desc', key: 'oldest', action: () {
      if(sortTypeKey == 'date' && sortTypeValue == 'desc') return;
      setState(() {
        sortTypeKey = 'date';
        sortTypeValue = 'desc';
        isInitScreen = true;
      });
      folderList();
    })));
    arr.add(buildItemDropDown(OptionMenuItem(text: AppLocalizations.text(LangKey.azSort),isSelected: sortTypeKey == 'name' && sortTypeValue == 'asc', key: 'azSort', action: () {
      if(sortTypeKey == 'name' && sortTypeValue == 'asc') return;
      setState(() {
        sortTypeKey = 'name';
        sortTypeValue = 'asc';
        isInitScreen = true;
      });
      folderList();
    })));
    arr.add(buildItemDropDown(OptionMenuItem(text: AppLocalizations.text(LangKey.zaSort),isSelected: sortTypeKey == 'name' && sortTypeValue == 'desc', key: 'zaSort', action: () {
      if(sortTypeKey == 'name' && sortTypeValue == 'desc') return;
      setState(() {
        sortTypeKey = 'name';
        sortTypeValue = 'desc';
        isInitScreen = true;
      });
      folderList();
    })));
    arr.add(buildItemDropDown(OptionMenuItem(text: AppLocalizations.text(LangKey.ownerFolder),isSelected: isOwner == null ? false : isOwner == true ? true : false, key: 'ownerFolder', action: () {
      if(isOwner == null) {
        setState(() {
          isOwner = true;
          isInitScreen = true;
        });
        folderList();
      }
      else if(isOwner == true) {
        setState(() {
          isOwner = null;
          isInitScreen = true;
        });
        folderList();
      }
      else {
        setState(() {
          isOwner = true;
          isInitScreen = true;
        });
        folderList();
      }
    })));
    arr.add(buildItemDropDown(OptionMenuItem(text: AppLocalizations.text(LangKey.notOwnerFolder),isSelected: isOwner == null ? false : isOwner == false ? true : false, key: 'notOwnerFolder', action: () {
      if(isOwner == null) {
        setState(() {
          isOwner = false;
          isInitScreen = true;
        });
        folderList();
      }
      else if(isOwner == false) {
        setState(() {
          isOwner = null;
          isInitScreen = true;
        });
        folderList();
      }
      else {
        setState(() {
          isOwner = false;
          isInitScreen = true;
        });
        folderList();
      }
    }),lastItem: true));
    return arr;
  }

  Widget buildItemDropDown(OptionMenuItem item, {bool lastItem = false}) {
    return InkWell(
        onTap: () {
          setState(() {
            isShowDropDownOptionMenu = false;
            item.isSelected = !(item.isSelected ?? false);
          });
          item.action!();
        },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: SizedBox(
              height: 35.0,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(width: 5.0,),
                  item.isSelected == null || item.isSelected == false ? Container(width: 30.0,) : const SizedBox(
                    width: 30.0,
                    child: Center(
                        child: Icon(Icons.check,
                            color: Colors.black,
                            size: 18)
                    ),
                  ),
                  Container(width: 5.0,),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: AutoSizeText(
                        item.text,
                        style: const TextStyle(
                            color: Colors.black
                        ),
                      ),
                    ),
                  ),
                  if(item.icon != null) Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 5.0,right: 15.0),
                      child: Icon(
                          item.icon,
                          color: Colors.black,
                          size: 22
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if(!lastItem) Padding(padding: const EdgeInsets.symmetric(horizontal: 15.0),child: Container(height: 1.0,color: Colors.grey.shade400,),)
        ],
      )
    );
  }
  
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Builder(
        builder: (context) {
          return Scaffold(
              appBar: AppBar(
                  iconTheme: const IconThemeData(
                    color: Colors.black,
                  ),
                  backgroundColor: Colors.white,
                  title: Text(AppLocalizations.text(LangKey.folderList),style: const TextStyle(color: Colors.black),),
                  actions: <Widget>[
                    isInitScreen ? Container() :
                    SizedBox(
                        height: 40.0,
                        width: 40.0,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              isShowDropDownOptionMenu = !isShowDropDownOptionMenu;
                            });
                          },
                          child: const Icon(Icons.more_vert,color: Colors.blueAccent,),
                        )),
                  ]),
              body:
              isInitScreen ? Center(child: Platform.isAndroid ? const CircularProgressIndicator() : const CupertinoActivityIndicator()) :
              Stack(
                children: [
                  Container(
                    color: Colors.white,
                    child: Column(
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
                        visibleFolders == null ? Container() :
                        Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: visibleFolders?.data == null ? Container() :
                            SmartRefresher(
                                enablePullDown: true,
                                enablePullUp: false,
                                controller: _refreshController,
                                onRefresh: _onRefresh,
                                onLoading: _onLoading,
                                header: const WaterDropHeader(),
                                child:
                                type == 0 ? listView() : gridView())
                        ))
                      ],
                    ),
                  ),
                  if(selectedFolder != null || isShowDropDownOptionMenu) GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedFolder = null;
                        isShowDropDownOptionMenu = false;
                      });
                    },
                    child: Container(
                      height: MediaQuery.of(context).size.height,
                      color: Colors.transparent,
                      child: SlidingUpPanel(
                        minHeight: isShowDropDownOptionMenu ? MediaQuery.of(context).size.height * 0.55 : MediaQuery.of(context).size.height * 0.45,
                        maxHeight: MediaQuery.of(context).size.height,
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(20.0),topRight: Radius.circular(20.0)),
                        panel: isShowDropDownOptionMenu ?
                        ListView.builder(
                          itemCount: _arrOptionMenuItemDropDown().length,
                          padding: EdgeInsets.zero,
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            return _arrOptionMenuItemDropDown()[index];
                          },
                        ) : ListView.builder(
                          itemCount: focusMenu(data: selectedFolder!).length,
                          padding: EdgeInsets.zero,
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            final values = focusMenu(data: selectedFolder!);
                            FocusedMenuItem item = values[index];
                            return InkWell(
                                onTap: () {
                                  item.onPressed();
                                  setState(() {
                                    selectedFolder = null;
                                  });
                                },
                                child: Column(
                                  children: [
                                    if(index == 0) Container(
                                      height: 50.0,
                                      decoration: BoxDecoration(
                                          color: const Color(0xff4fc4ca).withAlpha(20),
                                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(20.0),topRight: Radius.circular(20.0))
                                      ),
                                      child: Row(
                                        children: [
                                          const Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 10.0),
                                            child: Icon(Icons.folder,color: Colors.black,),
                                          ),
                                          Expanded(child: AutoSizeText(selectedFolder!.folderDisplayName ?? '',style: const TextStyle(fontWeight: FontWeight.bold),)),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                            child: InkWell(
                                              child: const SizedBox(
                                                  height:40,
                                                  width:40,
                                                  child: Icon(Icons.close,color: Colors.black,)),
                                              onTap: () {
                                                setState(() {
                                                  selectedFolder = null;
                                                });
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                        alignment: Alignment.center,
                                        margin: const EdgeInsets.only(bottom: 1,left: 10.0,right: 10.0),
                                        color: item.backgroundColor ?? Colors.white,
                                        height: 50.0,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 14),
                                          child: Column(
                                            children: [
                                              Expanded(
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: <Widget>[
                                                    item.title,
                                                    if (item.trailingIcon != null) ...[item.trailingIcon!]
                                                  ],
                                                ),
                                              ),
                                              if(index != values.length-1)
                                                InkWell(child: Container(height: 1,color: Colors.grey.shade200,))
                                            ],
                                          ),
                                        ))
                                  ],
                                )
                            );
                          },
                        ),
                      ),
                    ),
                  )
                ],
              )
          );
        },
    );
  }

  Future<void> openFolder(Data e,String? password) async {
    bool check = await checkFolderPassword(e, password ?? '');
    if(!check) return;
    if(!mounted) return;
    bool? result = await Navigator.of(context).push(MaterialPageRoute( builder: (context) => FileManagement(data: e,password: password,)));
    if(result == true) {
      folderList();
    }
  }
  
  Widget gridView() {
    return GridView.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            mainAxisSpacing: 10),
        itemCount: visibleFolders!.data!.length,
        itemBuilder: (BuildContext ctx, index) {
          final e = visibleFolders!.data![index];
          return Column(
            children: [
              Stack(
                children: [
                  FocusedMenuHolder(
                    onPressed: () {
                      showPasswordInputDialog(e,2);
                    },
                    menuItems: focusMenu(data:e),
                    menuOffset: 3.0,
                    menuWidth: MediaQuery.of(context).size.width * 0.6 > 240 ? 240 : MediaQuery.of(context).size.width * 0.6,
                    child: SizedBox(height: 80.0,width: 80.0,
                      child: Image.asset(e.folderPassword == false ?
                      'assets/ico/ico-folder.png' : 'assets/ico/ico-lock-folder.png',
                        package: 'document_management',fit: BoxFit.contain,)
                      ,),
                  ),
                  Positioned(bottom: 0,right: -10,child: InkWell(
                    onTap: () {
                      setState(() {
                        selectedFolder = e;
                      });
                    },
                    child: const SizedBox(height: 40.0,width: 40.0,
                      child: Icon(Icons.more_vert,color: Colors.white,)
                      ,),
                  ),)
                ],
              ),
              Container(height: 3.0),
              AutoSizeText(e.folderDisplayName ?? '',overflow: TextOverflow.ellipsis,style: const TextStyle(fontWeight: FontWeight.bold),),
              Container(height: 3.0),
              AutoSizeText('${e.totalItem ?? '0'} ${e.totalItem == null || e.totalItem == 0 ? AppLocalizations.text(LangKey.file) : AppLocalizations.text(LangKey.files)}',),
            ],
          );
        });
  }
  
  Widget listView() {
    return
      ListView(
        children: visibleFolders!.data!.map((e) => FocusedMenuHolder(
          onPressed: () {
            showPasswordInputDialog(e,2);
          },
          menuItems: focusMenu(data: e),
          menuOffset: 3.0,
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
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            selectedFolder = e;
                          });
                        },
                        child: const SizedBox(height: 40.0,width: 40.0,
                          child: Icon(Icons.more_vert,color: Colors.grey,)
                          ,),
                      ),),
                  ],
                ),
                Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: Container(height: 1.0,color: Colors.grey.shade300,width: MediaQuery.of(context).size.width*0.85,))
              ],
            ),
          ),
        )).toList(),
      );
  }

  List<FocusedMenuItem> focusMenu({Data? data}) {
    List<FocusedMenuItem> arr = [];
    if(data?.userPermission?.writeBucket == true || data?.userPermission?.readWriteBucket == true) {
      arr.add(FocusedMenuItem(title: AutoSizeText(AppLocalizations.text(LangKey.detailInfo),overflow: TextOverflow.ellipsis,),trailingIcon: const Icon(Icons.info_outline) ,onPressed: (){
        showPasswordInputDialog(data!, 4);
      }));
    }
    if(data?.userPermission?.writeBucket == true || data?.userPermission?.readWriteBucket == true) {
      arr.add(FocusedMenuItem(title: AutoSizeText(AppLocalizations.text(LangKey.changeName),overflow: TextOverflow.ellipsis,),trailingIcon: const Icon(Icons.edit) ,onPressed: (){
        data?.nameController.text = data.folderDisplayName ?? '';
        showPasswordInputDialog(data!,0);
      }));
    }
    if(data?.permission == 'custom' && data?.userPermission?.readWriteBucket == true) {
      arr.add(FocusedMenuItem(title: AutoSizeText(AppLocalizations.text(LangKey.userList),overflow: TextOverflow.ellipsis,),trailingIcon: const Icon(Icons.group) ,onPressed: (){
        Navigator.of(context).push(MaterialPageRoute( builder: (context) => ListUserFolderScreen(data: data!,)));
      }));
    }
    if(data?.owner == DocumentConnection.account?.user?.staff?.userName && data?.folderPassword != true) {
      arr.add(FocusedMenuItem(title: AutoSizeText(AppLocalizations.text(LangKey.createPassword),overflow: TextOverflow.ellipsis,),trailingIcon: const Icon(Icons.password_outlined) ,onPressed: () async {
      bool? result = await Navigator.of(context).push(MaterialPageRoute( builder: (context) => PasswordFolderScreen(data: data!, isCreatedPassword: true,)));
      if(result == true) {
        folderList();
      }
    }));
    }
    if(data?.owner == DocumentConnection.account?.user?.staff?.userName && data?.folderPassword == true) {
      arr.add(FocusedMenuItem(title: AutoSizeText(AppLocalizations.text(LangKey.changePassword),overflow: TextOverflow.ellipsis,),trailingIcon: const Icon(Icons.password_outlined) ,onPressed: () async {
        bool? result =  await Navigator.of(context).push(MaterialPageRoute( builder: (context) => PasswordFolderScreen(data: data!, isCreatedPassword: false,)));
        if(result == true) {
          folderList();
        }
    }));
    }
    if(data?.owner == DocumentConnection.account?.user?.staff?.userName && data?.folderPassword == true) {
      arr.add(FocusedMenuItem(title: AutoSizeText(AppLocalizations.text(LangKey.deletePassword),overflow: TextOverflow.ellipsis,),trailingIcon: const Icon(Icons.password_outlined) ,onPressed: () async {
        bool result = await showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: Text(AppLocalizations.text(LangKey.deletePasswordConfimation)),
            content: Text('${AppLocalizations.text(LangKey.deletePasswordConfimation)} ${data?.folderDisplayName ?? ''}?'),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text(AppLocalizations.text(LangKey.cancel)),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: () async {
                  Navigator.of(context).pop(true);
                } ,
                child: Text(AppLocalizations.text(LangKey.delete)),
              ),
            ],
          ),
        );
        if(result) {
          showPasswordInputDialog(data!,1);
        }
    }));
    }
    if(data?.owner == DocumentConnection.account?.user?.staff?.userName) {
      arr.add(FocusedMenuItem(title: AutoSizeText(AppLocalizations.text(LangKey.deleteFolder),overflow: TextOverflow.ellipsis,),trailingIcon: const Icon(Icons.delete_forever) ,onPressed: () async {
        showPasswordInputDialog(data!, 3);
    }));
    }
    arr.add(FocusedMenuItem(title: AutoSizeText(AppLocalizations.text(LangKey.shareFolder),overflow: TextOverflow.ellipsis,),trailingIcon: const Icon(Icons.share) ,onPressed: (){
      showPasswordInputDialog(data!, 5);
    }));
    // arr.add(FocusedMenuItem(title: AutoSizeText(AppLocalizations.text(LangKey.selectMany));overflow: TextOverflow.ellipsis,));trailingIcon: Icon(Icons.select_all) ,onPressed: (){}));
    return arr;
  }

  Future<void> deleteFolderRequest(Data data) async {
    bool result = await showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(AppLocalizations.text(LangKey.deleteFolderConfimation)),
        content: Text('${AppLocalizations.text(LangKey.deleteFolderConfimationNote)} ${data.folderDisplayName ?? ''}?'),
        actions: <Widget>[
          CupertinoDialogAction(
            child: Text(AppLocalizations.text(LangKey.cancel)),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.of(context).pop(true);
            } ,
            child: Text(AppLocalizations.text(LangKey.delete)),
          ),
        ],
      ),
    );
    if(result) {
      deleteFolder(data);
    }
  }

  void deleteFolder(Data data) async {
    await DocumentConnection.deleteFolder(data.folderName ?? '');
    try {
      int index = folders!.data!.indexOf(data);
      folders!.data!.removeAt(index);
    }catch(_) {}
    _getVisible();
    setState(() {});
  }

  Future<void> deleteFolderPassword(Data data,String password) async {
    bool check =  await checkFolderPassword(data,password);
    if(!check) return;
    if(!mounted) return;
    bool result = await DocumentConnection.deleteFolderPassword(context,data.folderName ?? '', password);
    if(result) {
      try {
        int index = folders!.data!.indexOf(data);
        folders!.data![index].folderPassword = false;
      }catch(_) {}
      _getVisible();
      setState(() {});
    }
  }

  void showPasswordInputDialog(Data data, int type) {
    if(type == 4 && data.folderPassword != true) {
      Navigator.of(context).push(MaterialPageRoute( builder: (context) => FolderInformationScreen(data: data,)));
    }
    else if(type == 5 && data.folderPassword != true) {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return ShareScreen(folderData: data);
      }));
    }
    else if(type == 2 && data.folderPassword != true) {
      openFolder(data,null);
    }
    else if(type == 3 && data.folderPassword != true) {
      deleteFolderRequest(data);
    }
    else {
      showDialog<bool>(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            content: Card(
              color: Colors.transparent,
              elevation: 0.0,
              child: Column(
                children: <Widget>[
                  if(type == 0) TextField(
                    autofocus: true,
                    controller: data.nameController,
                    decoration: InputDecoration(
                        labelText: AppLocalizations.text(LangKey.changeName),
                        filled: true,
                        fillColor: Colors.grey.shade50
                    ),
                  ),
                  if(data.folderPassword == true) TextField(
                    autofocus: type != 0,
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
                            Navigator.of(context).pop();
                            if(type == 0) {
                              await changeFolderName(data, data.nameController.text , password: data.folderPassword == true ? data.passwordController.text : '', isPasswordFolder: data.folderPassword == true ? true : false);
                              data.nameController.text = '';
                              data.passwordController.text = '';
                            }
                            else if(type == 1) {
                              await deleteFolderPassword(data, data.passwordController.text);
                              data.nameController.text = '';
                              data.passwordController.text = '';
                            }
                            else if(type == 2) {
                              await openFolder(data, data.folderPassword == true ? data.passwordController.text : null);
                              data.nameController.text = '';
                              data.passwordController.text = '';
                            }
                            else if(type == 3) {
                              await deleteFolderRequest(data);
                              data.nameController.text = '';
                              data.passwordController.text = '';
                            }
                            else if(type == 4) {
                              bool result = await checkFolderPassword(data, data.passwordController.text);
                              if(!mounted) return;
                              if(result) {
                                await Navigator.of(DocumentConnection.buildContext!).push(MaterialPageRoute( builder: (context) => FolderInformationScreen(data: data,password: data.passwordController.text,)));
                                data.nameController.text = '';
                                data.passwordController.text = '';
                              }
                            }
                            else if(type == 5) {
                              bool result = await checkFolderPassword(data, data.passwordController.text);
                              if(!mounted) return;
                              if(result) {
                                Navigator.of(DocumentConnection.buildContext!).push(MaterialPageRoute(builder: (context) {
                                  return ShareScreen(folderData: data);
                                }));
                                data.nameController.text = '';
                                data.passwordController.text = '';
                              }
                            }
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

  Future<bool> checkFolderPassword(Data data, String password) async {
    if(data.folderPassword != true) return true;
    return await DocumentConnection.checkFolderPassword(context,data.folderName!, password);
  }

  Future<void> changeFolderName(Data data,String folderName, {String password = '', bool isPasswordFolder = false}) async {
    if(folderName == '') {
      DocumentConnection.error(context, AppLocalizations.text(LangKey.emptyFolderName));
      return;
    }
    if(isPasswordFolder) {
      if(password == '') {
        DocumentConnection.error(context, AppLocalizations.text(LangKey.emptyPasswordFolder));
        return;
      }
    }
    bool check =  await checkFolderPassword(data,password);
    if(!check) return;
    if(!mounted) return;
    DocumentConnection.showLoading(context);
    bool result = await DocumentConnection.changeFolderName(data.folderName ?? '', folderName , password: password);
    if(!result) {
      if(!mounted) return;
      DocumentConnection.error(context, AppLocalizations.text(LangKey.somethingWrong));
      Navigator.of(context).pop();
    }
    else {
      data.folderDisplayName = folderName;
      setState(() {});
      if(!mounted) return;
      Navigator.of(context).pop();
    }
  }
}