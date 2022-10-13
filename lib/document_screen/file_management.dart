import 'dart:io';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:document_management/connection/document_connection.dart';
import 'package:document_management/connection/file_process.dart';
import 'package:document_management/connection/http_connection.dart';
import 'package:document_management/connection/upload.dart';
import 'package:document_management/document_screen/comment_scren.dart';
import 'package:document_management/document_screen/file_information_screen.dart';
import 'package:document_management/document_screen/file_version_history_screen.dart';
import 'package:document_management/document_screen/move_file_screen.dart';
import 'package:document_management/document_screen/share_screen.dart';
import 'package:document_management/document_screen/webview_screen.dart';
import 'package:document_management/localization/app_localization.dart';
import 'package:document_management/localization/lang_key.dart';
import 'package:document_management/model/file.dart';
import 'package:document_management/widget/menu_item_option_page.dart';
import 'package:document_management/widget/option_page_button.dart';
import 'package:file_icon/file_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:focused_menu/modals.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:document_management/model/folder.dart' as folder;
import 'package:pull_to_refresh/pull_to_refresh.dart';

class FileManagement extends StatefulWidget {
  final folder.Data data;
  final String? password;
  const FileManagement({Key? key, required this.data, this.password}) : super(key: key);
  @override
  State<FileManagement> createState() => _FileManagementState();
}

class _FileManagementState extends State<FileManagement> {
  Files? files;
  Files? visibleFiles;
  final _focusSearch = FocusNode();
  final _controllerSearch = TextEditingController();
  bool isInitScreen = true;
  final format1 = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z");
  final format2 = DateFormat("dd/MM/yyyy");
  final format3 = DateFormat("yyyy-MM-dd");
  final format4 = DateFormat("dd/MM/yyyy HH:mm");
  int? type = 0;
  Data? selectedFile;

  String sortTypeKey = 'date';
  String sortTypeValue = 'desc';
  bool? isOwner;
  String? fromDate;
  String? toDate;

  bool? hasAction;

  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  void _onRefresh() async{
    await Future.delayed(const Duration(milliseconds: 1000));
    await fileList();
    _refreshController.refreshCompleted();
  }

  void _onLoading() async{
    await Future.delayed(const Duration(milliseconds: 1000));
    await fileList();
    _refreshController.loadComplete();
  }

  @override
  void initState() {
    super.initState();
    fileList();
  }

  Future<void> fileList() async {
    setState(() {
      isInitScreen = true;
    });
    files = await DocumentConnection.fileList(widget.data.folderName!,sortTypeKey,sortTypeValue,owner: isOwner == null ? null : isOwner == true ? 1 : 0,fromDate: fromDate,toDate: toDate,password: widget.password);
    _getVisible();
    setState(() {
      isInitScreen = false;
    });
  }

  _getVisible() {
    String val = _controllerSearch.value.text.toLowerCase();
    if(val != '') {
      visibleFiles = Files();
      try {
        visibleFiles?.data = <Data>[...files!.data!.toList()];
      }catch(_) {}
      visibleFiles!.data = visibleFiles!.data!.where((element) {
        try {
          if(
          (element.fileName!.toLowerCase()).contains(val)) {
            return true;
          }
          return false;
        }catch(e){
          return false;
        }
      }).toList();
    }
    else {
      visibleFiles = Files();
      try {
        visibleFiles?.data = <Data>[...files!.data!.toList()];
      }catch(_) {}
    }
  }
  Future<bool> _onWillPop() async {
    Navigator.of(context).pop(hasAction);
    return Future.value(true);
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return WillPopScope(
      onWillPop: () => _onWillPop(),
      child: Scaffold(
          appBar: AppBar(
              iconTheme: const IconThemeData(
                color: Colors.black,
              ),
              backgroundColor: Colors.white,
              title: Text(widget.data.folderDisplayName ?? AppLocalizations.text(LangKey.fileList),style: const TextStyle(color: Colors.black),),
              actions: <Widget>[
                isInitScreen ? Container() :
                SizedBox(
                    height: 40.0,
                    width: 40.0,
                    child: OptionPageButton(
                      items: [
                        if(widget.data.userPermission?.writeBucket == true || widget.data.userPermission?.readWriteBucket == true) OptionMenuItem(text: AppLocalizations.text(LangKey.uploadFile), icon: Icons.upload_file, key: 'uploadFile', action:  () async {
                          upload(context, uploadFile);
                        }),
                        OptionMenuItem(text: AppLocalizations.text(LangKey.icons), icon: Icons.category_outlined, key: 'icons',isSelected: type == 1 ? true : false, action: () {
                          if(type != 1) {
                            setState(() {
                              type = 1;
                            });
                          }
                        }),
                        OptionMenuItem(text: AppLocalizations.text(LangKey.list), key: 'list', icon: Icons.list_outlined, isSelected: type == 0 ? true : false, action: () {
                          if(type != 0) {
                            setState(() {
                              type = 0;
                            });
                          }
                        }),
                        OptionMenuItem(text: AppLocalizations.text(LangKey.customDateFile),isSelected: !(fromDate == null && toDate == null), key: 'customDate', action: () async {
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
                              fileList();
                            }
                          }
                          else {
                            fromDate = null;
                            toDate = null;
                            fileList();
                          }
                        }),
                        OptionMenuItem(text: AppLocalizations.text(LangKey.newest),isSelected: sortTypeKey == 'date' && sortTypeValue == 'asc', key: 'newest', action: () {
                          if(sortTypeKey == 'date' && sortTypeValue == 'asc') return;
                          setState(() {
                            sortTypeKey = 'date';
                            sortTypeValue = 'asc';
                            isInitScreen = true;
                          });
                          fileList();
                        }),
                        OptionMenuItem(text: AppLocalizations.text(LangKey.oldest),isSelected: sortTypeKey == 'date' && sortTypeValue == 'desc', key: 'oldest', action: () {
                          if(sortTypeKey == 'date' && sortTypeValue == 'desc') return;
                          setState(() {
                            sortTypeKey = 'date';
                            sortTypeValue = 'desc';
                            isInitScreen = true;
                          });
                          fileList();
                        }),
                        OptionMenuItem(text: AppLocalizations.text(LangKey.azSort),isSelected: sortTypeKey == 'name' && sortTypeValue == 'asc', key: 'azSort', action: () {
                          if(sortTypeKey == 'name' && sortTypeValue == 'asc') return;
                          setState(() {
                            sortTypeKey = 'name';
                            sortTypeValue = 'asc';
                            isInitScreen = true;
                          });
                          fileList();
                        }),
                        OptionMenuItem(text: AppLocalizations.text(LangKey.zaSort),isSelected: sortTypeKey == 'name' && sortTypeValue == 'desc', key: 'zaSort', action: () {
                          if(sortTypeKey == 'name' && sortTypeValue == 'desc') return;
                          setState(() {
                            sortTypeKey = 'name';
                            sortTypeValue = 'desc';
                            isInitScreen = true;
                          });
                          fileList();
                        }),
                        OptionMenuItem(text: AppLocalizations.text(LangKey.sizeDsc),isSelected: sortTypeKey == 'size' && sortTypeValue == 'desc', key: 'sizeDsc', action: () {
                          if(sortTypeKey == 'size' && sortTypeValue == 'desc') return;
                          setState(() {
                            sortTypeKey = 'size';
                            sortTypeValue = 'desc';
                            isInitScreen = true;
                          });
                          fileList();
                        }),
                        OptionMenuItem(text: AppLocalizations.text(LangKey.sizeAsc),isSelected: sortTypeKey == 'size' && sortTypeValue == 'asc', key: 'sizeAsc', action: () {
                          if(sortTypeKey == 'size' && sortTypeValue == 'asc') return;
                          setState(() {
                            sortTypeKey = 'size';
                            sortTypeValue = 'asc';
                            isInitScreen = true;
                          });
                          fileList();
                        }),
                        OptionMenuItem(text: AppLocalizations.text(LangKey.ownerFile),isSelected: isOwner == null ? false : isOwner == true ? true : false, key: 'ownerFile', action: () {
                          if(isOwner == null) {
                            setState(() {
                              isOwner = true;
                              isInitScreen = true;
                            });
                            fileList();
                          }
                          else if(isOwner == true) {
                            setState(() {
                              isOwner = null;
                              isInitScreen = true;
                            });
                            fileList();
                          }
                          else {
                            setState(() {
                              isOwner = true;
                              isInitScreen = true;
                            });
                            fileList();
                          }
                        }),
                        OptionMenuItem(text: AppLocalizations.text(LangKey.notOwnerFile) ,isSelected: isOwner == null ? false : isOwner == false ? true : false, key: 'notOwnerFile', action: () {
                          if(isOwner == null) {
                            setState(() {
                              isOwner = false;
                              isInitScreen = true;
                            });
                            fileList();
                          }
                          else if(isOwner == false) {
                            setState(() {
                              isOwner = null;
                              isInitScreen = true;
                            });
                            fileList();
                          }
                          else {
                            setState(() {
                              isOwner = false;
                              isInitScreen = true;
                            });
                            fileList();
                          }
                        }),
                      ],
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
                    visibleFiles == null ? Container() :
                    visibleFiles?.data == null ? Container() :
                    SmartRefresher(
                        enablePullDown: true,
                        enablePullUp: false,
                        controller: _refreshController,
                        onRefresh: _onRefresh,
                        onLoading: _onLoading,
                        header: const WaterDropHeader(),
                        child:
                        type == 0 ? listView() : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: gridView(),
                    )))
                  ],
                ),
              ),
              if(selectedFile != null) GestureDetector(
                onTap: () {
                  setState(() {
                    selectedFile = null;
                  });
                },
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  color: Colors.transparent,
                  child: SlidingUpPanel(
                    minHeight: MediaQuery.of(context).size.height * 0.45,
                    maxHeight: MediaQuery.of(context).size.height,
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(20.0),topRight: Radius.circular(20.0)),
                    panel: ListView.builder(
                      itemCount: focusMenu(data: selectedFile!).length,
                      padding: EdgeInsets.zero,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        final values = focusMenu(data: selectedFile!);
                        FocusedMenuItem item = values[index];
                        return InkWell(
                            onTap: () {
                              item.onPressed();
                              setState(() {
                                selectedFile = null;
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
                                        child: Icon(Icons.file_present,color: Colors.black,),
                                      ),
                                      Expanded(child: AutoSizeText(selectedFile!.fileName ?? '',style: const TextStyle(fontWeight: FontWeight.bold),)),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                        child: InkWell(
                                          child: const SizedBox(
                                              height:40,
                                              width:40,
                                              child: Icon(Icons.close,color: Colors.black,)),
                                          onTap: () {
                                            setState(() {
                                              selectedFile = null;
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
      ),
    );
  }

  Widget gridView() {
    return GridView.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 205,
            mainAxisSpacing: 10),
        itemCount: visibleFiles!.data!.length,
        itemBuilder: (BuildContext ctx, index) {
          final e = visibleFiles!.data![index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    FocusedMenuHolder(
                      onPressed: () {},
                      menuItems: focusMenu(data:e),
                      menuOffset: 3.0,
                      menuWidth: MediaQuery.of(context).size.width * 0.6 > 240 ? 240 : MediaQuery.of(context).size.width * 0.6,
                      child: InkWell(
                        onTap: () async {
                          if(!e.isDownloaded) {
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                              return WebViewScreen(url: e.previewMobile ?? '', fileName: e.fileName!,);
                            }));
                          }
                          else {
                            if(e.isDownloading) return;
                            setState(() {
                              e.isDownloading = true;
                            });
                            String? result = await FileProcess.download(context,'${HTTPConnection.domain}files/download?file_id=${e.fileId}','${e.createdDate}_${e.fileName}',e.info?.ext??'');
                            if(!mounted) return;
                            await FileProcess.openFile(result,context,e.fileName!);
                            setState(() {
                              e.isDownloading = false;
                            });
                          }
                        },
                        child: SizedBox(height: 80.0,width: 80.0,
                          child: FileIcon(
                            e.fileName!,
                            size: 80,
                          ),),
                      ),
                    ),
                    Positioned(bottom: 0,right: -10,child: InkWell(
                      onTap: () {
                        setState(() {
                          selectedFile = e;
                        });
                      },
                      child: SizedBox(height: 40.0,width: 40.0,
                        child: Icon(Icons.info,color: const Color(0xff4fc4ca).withAlpha(180),)
                        ,),
                    ),),
                    Positioned(top: 0,right: -10,child: InkWell(
                      onTap: () async {
                        if(e.isDownloaded) return;
                        if(!e.isDownloading) {
                          setState(() {
                            e.isDownloading = true;
                          });
                          String? result = await FileProcess.download(context,'${HTTPConnection.domain}files/download?file_id=${e.fileId}','${e.createdDate}_${e.fileName}',e.info?.ext??'');
                          setState(() {
                            if(result != null) {
                              e.isDownloaded = true;
                            }
                            e.isDownloading = false;
                          });
                        }
                      },
                      child: SizedBox(height: 40.0,width: 40.0,
                        child: Icon(e.isDownloaded ? Icons.cloud_done_outlined :Icons.cloud_download_outlined,color: Colors.grey.shade600,)
                        ,),
                    ),),
                    if(e.isDownloading) const Positioned.fill(
                      child: Align(
                          alignment: Alignment.center,
                          child: SizedBox(
                            height: 10.0,
                            width: 10.0,
                            child: CircularProgressIndicator(color: Colors.black,),
                          )
                      ),
                    ),
                  ],
                ),
              ),
              AutoSizeText(e.fileName ?? '',overflow: TextOverflow.ellipsis,style: const TextStyle(fontWeight: FontWeight.bold),textScaleFactor: 1.05,),
              Container(height: 3.0),
              AutoSizeText('Ver ${e.version} - ${format2.format(format4.parse(e.createdDate!, true))}',overflow: TextOverflow.ellipsis,maxLines: 1,textScaleFactor: 0.8,),
              Container(height: 3.0),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(child: Container()),
                  e.updatedAvatar == null ? CircleAvatar(
                    radius: 8.0,
                    child: Center(child: AutoSizeText(e.getAvatarName())),
                  ) : CircleAvatar(
                    radius: 8.0,
                    backgroundImage:
                    CachedNetworkImageProvider(e.updatedAvatar!),
                    backgroundColor: Colors.transparent,
                  ),
                  Container(width: 4.0),
                  Expanded(flex: 2,child: AutoSizeText(e.updatedName ?? '',overflow: TextOverflow.ellipsis,maxLines: 1,textScaleFactor: 0.9,),),
                ],
              )
            ],
          );
        });
  }
  Widget listView() {
    return
      ListView(
        children: visibleFiles!.data!.map((e) => FocusedMenuHolder(
          onPressed: () async {
            if(!e.isDownloaded) {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return WebViewScreen(url: e.previewMobile ?? '', fileName: e.fileName!,);
              }));
            }
            else {
              if(e.isDownloading) return;
              setState(() {
                e.isDownloading = true;
              });
              String? result = await FileProcess.download(context,'${HTTPConnection.domain}files/download?file_id=${e.fileId}','${e.createdDate}_${e.fileName}',e.info?.ext??'');
              if(!mounted) return;
              await FileProcess.openFile(result,context,e.fileName!);
              setState(() {
                e.isDownloading = false;
              });
            }},
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
                      child:
                      Stack(
                        children: [
                          SizedBox(height: 60.0,width: 60.0,
                            child: FileIcon(
                              e.fileName!,
                              size: 60,
                            ),),
                          Positioned(top: 0,right: -10,child: InkWell(
                            onTap: () async {
                              if(e.isDownloaded) return;
                              if(!e.isDownloading) {
                                setState(() {
                                  e.isDownloading = true;
                                });
                                String? result = await FileProcess.download(context,'${HTTPConnection.domain}files/download?file_id=${e.fileId}','${e.createdDate}_${e.fileName}',e.info?.ext??'');
                                setState(() {
                                  if(result != null) {
                                    e.isDownloaded = true;
                                  }
                                  e.isDownloading = false;
                                });
                              }
                            },
                            child: SizedBox(height: 40.0,width: 40.0,
                              child: Icon(e.isDownloaded ? Icons.cloud_done_outlined :Icons.cloud_download_outlined,color: Colors.grey.shade600,)
                              ,),
                          ),),
                          if(e.isDownloading) const Positioned.fill(
                            child: Align(
                                alignment: Alignment.center,
                                child: SizedBox(
                                  height: 10.0,
                                  width: 10.0,
                                  child: CircularProgressIndicator(color: Colors.black,),
                                )
                            ),
                          ),
                        ],
                      ),),
                    Expanded(child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(child: AutoSizeText(e.fileName ?? '',overflow: TextOverflow.ellipsis,style: const TextStyle(fontWeight: FontWeight.bold),maxLines: 1,textScaleFactor: 1.1,),),
                              Container(width: 5.0,),
                              AutoSizeText('Ver ${e.version} - ${format2.format(format4.parse(e.createdDate!, true))}',overflow: TextOverflow.ellipsis,maxLines: 1,textScaleFactor: 0.95,)
                            ],
                          ),
                          Container(height: 8.0),
                          Row(
                            children: [
                              e.updatedAvatar == null ? CircleAvatar(
                                radius: 10.0,
                                child: Center(child: AutoSizeText(e.getAvatarName())),
                              ) : CircleAvatar(
                                radius: 10.0,
                                backgroundImage:
                                CachedNetworkImageProvider(e.updatedAvatar!),
                                backgroundColor: Colors.transparent,
                              ),
                              Container(width: 8.0),
                              Expanded(child: AutoSizeText(e.updatedName ?? '',overflow: TextOverflow.ellipsis,maxLines: 1,textScaleFactor: 0.95,),),
                            ],
                          )
                        ],
                      ),
                    )),
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            selectedFile = e;
                          });
                        },
                        child: SizedBox(height: 40.0,width: 40.0,
                          child: Icon(Icons.info,color: const Color(0xff4fc4ca).withAlpha(180),)
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
    arr.add(FocusedMenuItem(title: AutoSizeText(AppLocalizations.text(LangKey.preview),overflow: TextOverflow.ellipsis,),trailingIcon: const Icon(Icons.remove_red_eye_outlined) ,onPressed: () async {
      if(!data!.isDownloaded) {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return WebViewScreen(url: data.previewMobile ?? '', fileName: data.fileName!,);
        }));
      }
      else {
        if(data.isDownloading) return;
        setState(() {
          data.isDownloading = true;
        });
        String? result = await FileProcess.download(context,'${HTTPConnection.domain}files/download?file_id=${data.fileId}','${data.createdDate}_${data.fileName}',data.info?.ext??'');
        if(!mounted) return;
        await FileProcess.openFile(result,context,data.fileName!);
        setState(() {
          data.isDownloading = false;
        });
    }}));
    if(widget.data.userPermission?.writeBucket == true || widget.data.userPermission?.readWriteBucket == true) {
      arr.add(FocusedMenuItem(title: AutoSizeText(AppLocalizations.text(LangKey.replaceFile),overflow: TextOverflow.ellipsis,),trailingIcon: const Icon(Icons.swap_horizontal_circle_outlined) ,onPressed: (){
        replace(context, replaceFile, data!);
      }));
    }
    arr.add(FocusedMenuItem(title: AutoSizeText(AppLocalizations.text(LangKey.share),overflow: TextOverflow.ellipsis,),trailingIcon: const Icon(Icons.share) ,onPressed: (){
      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return ShareScreen(fileData: data!);
      }));
    }));
    if(widget.data.userPermission?.readWriteBucket == true) {
      arr.add(FocusedMenuItem(title: AutoSizeText(AppLocalizations.text(LangKey.moveFile),overflow: TextOverflow.ellipsis,),trailingIcon: const Icon(Icons.drive_file_move_outline) ,onPressed: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return MoveFileScreen(fileData: data!,folderData: widget.data,);
        }));
      }));
    }
    if(widget.data.userPermission?.writeBucket == true || widget.data.userPermission?.readWriteBucket == true) {
      arr.add(FocusedMenuItem(title: AutoSizeText(AppLocalizations.text(LangKey.changeName),overflow: TextOverflow.ellipsis,),trailingIcon: const Icon(Icons.edit) ,onPressed: (){
        data!.nameController.text = '${data.fileName?.replaceAll(getFileExtension(data.fileName??''), '')}';
        showPasswordInputDialog(data,0);
      }));
    }
    if(widget.data.userPermission?.writeBucket == true || widget.data.userPermission?.readWriteBucket == true) {
      arr.add(FocusedMenuItem(title: AutoSizeText(AppLocalizations.text(LangKey.copyFile),overflow: TextOverflow.ellipsis,),trailingIcon: const Icon(Icons.copy) ,onPressed: () async {
        data!.nameController.text = '${data.fileName?.replaceAll(getFileExtension(data.fileName??''), '')} (${AppLocalizations.text(LangKey.copyFile)})';
        showPasswordInputDialog(data,2);
      }));
    }
    arr.add(FocusedMenuItem(title: AutoSizeText(AppLocalizations.text(LangKey.commentFile),overflow: TextOverflow.ellipsis,),trailingIcon: const Icon(Icons.comment) ,onPressed: (){
      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return CommentScreen(data: data!);
      }));
    }));
    arr.add(FocusedMenuItem(title: AutoSizeText(AppLocalizations.text(LangKey.downloadFile),overflow: TextOverflow.ellipsis,),trailingIcon: const Icon(Icons.download_rounded) ,onPressed: () async {
      if(data!.isDownloaded) return;
      if(data.isDownloading) return;
      setState(() {
        data.isDownloading = true;
      });
      String? result = await FileProcess.download(context,'${HTTPConnection.domain}files/download?file_id=${data.fileId}','${data.createdDate}_${data.fileName}',data.info?.ext??'');
      if(!mounted) return;
      setState(() {
        if(result != null) {
          data.isDownloaded = true;
        }
        data.isDownloading = false;
      });
    }));
    arr.add(FocusedMenuItem(title: AutoSizeText(AppLocalizations.text(LangKey.detailInfo),overflow: TextOverflow.ellipsis,),trailingIcon: const Icon(Icons.info_outline) ,onPressed: (){
      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return FileInformationScreen(data: data!);
      }));
    }));
    if(widget.data.userPermission?.writeBucket == true || widget.data.userPermission?.readWriteBucket == true) {
      arr.add(FocusedMenuItem(title: AutoSizeText(AppLocalizations.text(LangKey.versionHistory),overflow: TextOverflow.ellipsis,),trailingIcon: const Icon(Icons.history) ,onPressed: () async {
        bool? result = await Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return FileVersionHistoryScreen(data: data!);
        }));
        if(result == true) {
          fileList();
        }
      }));
    }
    if(data?.owner == DocumentConnection.account?.user?.staff?.userName || widget.data.owner == DocumentConnection.account?.user?.staff?.userName) {
      arr.add(FocusedMenuItem(title: AutoSizeText(AppLocalizations.text(LangKey.delete),overflow: TextOverflow.ellipsis,),trailingIcon: const Icon(Icons.delete) ,onPressed: (){
        showPasswordInputDialog(data!,1);
      }));
    }
    return arr;
  }

  Future<void> uploadFile(File file, String fileName) async {
    bool result = await FileProcess.upload(fileName,widget.data.folderName ?? '',file);
    if(result) {
      fileList();
      hasAction = true;
    }
  }

  Future<void> replaceFile(File file, Data data) async {
    bool result = await FileProcess.replace(data.key ?? '',file);
    if(result) {
      fileList();
      hasAction = true;
    }
  }

  Future<void> copyFile(Data data,String fileName) async {
    if(fileName == '') {
      DocumentConnection.error(context, AppLocalizations.text(LangKey.emptyFileName));
      return;
    }
    if(!mounted) return;
    DocumentConnection.showLoading(context);
    bool result = await DocumentConnection.copyFile(data.key??'',fileName);
    if(!result) {
      if(!mounted) return;
      DocumentConnection.error(context, AppLocalizations.text(LangKey.somethingWrong));
      Navigator.of(context).pop();
    }
    else {
      hasAction = true;
      if(!mounted) return;
      Navigator.of(context).pop();
      fileList();
    }
  }

  void showPasswordInputDialog(Data data, int type) async {
    if(type == 1 && widget.data.folderPassword != true) {
      deleteFileRequest(data);
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
                  if(type == 0 || type == 2) TextField(
                    controller: data.nameController,
                    decoration: InputDecoration(
                        labelText: AppLocalizations.text(LangKey.changeName),
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
                              await changeFileName(data, data.nameController.text);
                              data.nameController.text = '';
                            }
                            else if(type == 2) {
                              await copyFile(data,data.nameController.text);
                              data.nameController.text = '';
                            }
                            else {
                              deleteFileRequest(data);
                              data.nameController.text = '';
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
  Future<void> changeFileName(Data data,String fileName) async {
    if(fileName == '') {
      DocumentConnection.error(context, AppLocalizations.text(LangKey.emptyFileName));
      return;
    }
    if(!mounted) return;
    DocumentConnection.showLoading(context);
    bool result = await DocumentConnection.changeFileName(data.fileId??'',fileName);
    if(!result) {
      if(!mounted) return;
      DocumentConnection.error(context, AppLocalizations.text(LangKey.somethingWrong));
      Navigator.of(context).pop();
    }
    else {
      data.fileName = fileName;
      hasAction = true;
      setState(() {});
      if(!mounted) return;
      Navigator.of(context).pop();
    }
  }
  void deleteFileRequest(Data data) async {
    bool result = await showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(AppLocalizations.text(LangKey.deleteFileConfimation)),
        content: Text('${AppLocalizations.text(LangKey.deleteFileConfimationNote)} ${data.fileName ?? ''}?'),
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
      deleteFile(data);
    }
  }
  void deleteFile(Data data) async {
    await DocumentConnection.deleteFile(data.fileId??'');
    try {
      int index = files!.data!.indexOf(data);
      files!.data!.removeAt(index);
      hasAction = true;
    }catch(_) {}
    _getVisible();
    setState(() {});
  }

  void upload(BuildContext context, UploadFile uploadFile) {
    showModalActionSheet<String>(
      context: context,
      actions: Upload.attachmentSheetAction(),
    ).then((value) => value == 'Photo Gallery'
        ? Upload.handleImageSelection(context,ImageSource.gallery,uploadFile,null)
        : value == "Photo Camera"
        ? Upload.handleImageSelection(context,ImageSource.camera,uploadFile,null)
        : value == 'Video'
        ? Upload.handelVideoSelection(context,uploadFile,null)
        : value == 'File'
        ? Upload.handleFileSelection(context,uploadFile,null)
        : {});
  }
  void replace(BuildContext context, ReplaceFile replaceFile, Data data) {
    showModalActionSheet<String>(
      context: context,
      actions: Upload.attachmentSheetAction(),
    ).then((value) => value == 'Photo Gallery'
        ? Upload.handleImageSelection(context,ImageSource.gallery,null,replaceFile,data: data)
        : value == "Photo Camera"
        ? Upload.handleImageSelection(context,ImageSource.camera,null,replaceFile,data: data)
        : value == 'Video'
        ? Upload.handelVideoSelection(context,null,replaceFile,data: data)
        : value == 'File'
        ? Upload.handleFileSelection(context,null,replaceFile,data: data)
        : {});
  }
  String getFileExtension(String fileName) {
    try {
      return '.${fileName.split('.').last}';
    } catch(e){
      return '';
    }
  }
}
