import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:document_management/connection/document_connection.dart';
import 'package:document_management/connection/file_process.dart';
import 'package:document_management/connection/http_connection.dart';
import 'package:document_management/document_screen/webview_screen.dart';
import 'package:document_management/localization/app_localization.dart';
import 'package:document_management/localization/lang_key.dart';
import 'package:file_icon/file_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:document_management/model/file.dart' as file;
import 'package:intl/intl.dart';

class FileVersionHistoryScreen extends StatefulWidget {
  final file.Data data;
  const FileVersionHistoryScreen({Key? key, required this.data}) : super(key: key);
  @override
  State<FileVersionHistoryScreen> createState() => _FileVersionHistoryScreenState();
}

class _FileVersionHistoryScreenState extends State<FileVersionHistoryScreen> {
  file.Files? files;
  bool isInitScreen = true;
  final format1 = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z");
  final format2 = DateFormat("dd/MM/yyyy");
  final format3 = DateFormat("yyyy-MM-dd");
  final format4 = DateFormat("dd/MM/yyyy HH:mm");
  bool? hasAction;

  @override
  void initState() {
    super.initState();
    fileList();
  }

  void fileList() async {
    setState(() {
      isInitScreen = true;
    });
    files = await DocumentConnection.versionFile(widget.data.key??'');
    setState(() {
      isInitScreen = false;
    });
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
        title: Text(AppLocalizations.text(LangKey.versionHistory),style: const TextStyle(color: Colors.black),),
       ),body:
            isInitScreen ? Center(child: Platform.isAndroid ? const CircularProgressIndicator()
                : const CupertinoActivityIndicator())
          : Container(
                color: Colors.white,
                child: listView()),
      ),
    );
  }
  Widget listView() {
    return
      ListView(
        children: files!.data!.map((e) => InkWell(
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
              String? result = await FileProcess.download(context,'${HTTPConnection.domain}files/download?file_id=${widget.data.fileId}&version_id=${e.versionId}','${e.lastModified}_${e.fileName}');
              if(!mounted) return;
              await FileProcess.openFile(result,context,e.fileName!);
              setState(() {
                e.isDownloading = false;
              });
            }},
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
                      padding: const EdgeInsets.only(left: 8.0,right: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(child: AutoSizeText(e.fileName ?? '',overflow: TextOverflow.ellipsis,style: const TextStyle(fontWeight: FontWeight.bold),maxLines: 1,textScaleFactor: 1.1,),),
                              Container(width: 5.0,),
                              AutoSizeText('Ver ${e.version ?? 1} - ${format2.format(format4.parse(e.lastModified!, true).toLocal())}',overflow: TextOverflow.ellipsis,maxLines: 1,textScaleFactor: 0.95,)
                            ],
                          ),
                          Container(height: 3.0),
                          AutoSizeText(e.sizeFormat ?? ''),
                          Row(
                            children: [
                              e.avatar == null ? CircleAvatar(
                                radius: 10.0,
                                child: Text(e.getAvatarVersionName()),
                              ) : CircleAvatar(
                                radius: 10.0,
                                backgroundImage:
                                CachedNetworkImageProvider(e.avatar!),
                                backgroundColor: Colors.transparent,
                              ),
                              Container(width: 8.0),
                              Expanded(child: AutoSizeText(e.updatedName ?? '',overflow: TextOverflow.ellipsis,maxLines: 1,textScaleFactor: 0.95,),),
                              Container(width: 5.0,),
                              if(files!.data!.indexOf(e) != 0) InkWell(
                                onTap: () async {
                                  restoreVersionRequest(e);
                                },
                                child: SizedBox(height: 25.0,width: 25.0,
                                  child: Icon(Icons.swap_horizontal_circle_outlined,color: Colors.grey.shade600,)
                                  ,),
                              ),
                              Container(width: 5.0,),
                              InkWell(
                                onTap: () async {
                                  if(e.isDownloaded) return;
                                  if(!e.isDownloading) {
                                    setState(() {
                                      e.isDownloading = true;
                                    });
                                    String? result = await FileProcess.download(context,'${HTTPConnection.domain}files/download?file_id=${widget.data.fileId}&version_id=${e.versionId}','${e.lastModified}_${e.fileName}');
                                    setState(() {
                                      if(result != null) {
                                        e.isDownloaded = true;
                                      }
                                      e.isDownloading = false;
                                    });
                                  }
                                },
                                child: SizedBox(height: 25.0,width: 25.0,
                                  child: Icon(e.isDownloaded ? Icons.cloud_done_outlined :Icons.cloud_download_outlined,color: Colors.grey.shade600,)
                                  ,),
                              ),
                              Container(width: 5.0,),
                              if(files!.data!.indexOf(e) != 0) InkWell(
                                onTap: () async {
                                  deleteFileRequest(e);
                                },
                                child: SizedBox(height: 25.0,width: 25.0,
                                  child: Icon(Icons.delete,color: Colors.grey.shade600,)
                                  ,),
                              ),
                            ],
                          )
                        ],
                      ),
                    )),
                  ],
                ),
                Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: Container(height: 1.0,color: Colors.grey.shade300,width: MediaQuery.of(context).size.width*0.95,))
              ],
            ),
          ),
        )).toList(),
      );
  }
  void restoreVersionRequest(file.Data data) async {
    bool result = await showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(AppLocalizations.text(LangKey.replaceFileConfimation)),
        content: Text('${AppLocalizations.text(LangKey.replaceFileConfimationNote)} ${data.fileName ?? ''} Ver ${data.version ?? 1}?'),
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
            child: Text(AppLocalizations.text(LangKey.replaceFile)),
          ),
        ],
      ),
    );
    if(result) {
      restoreVersion(data);
    }
  }
  void restoreVersion(file.Data data) async {
    await DocumentConnection.restoreVersion(widget.data.key??'', data.versionId ?? '');
    hasAction = true;
    fileList();
  }
  void deleteFileRequest(file.Data data) async {
    bool result = await showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(AppLocalizations.text(LangKey.deleteFileConfimation)),
        content: Text('${AppLocalizations.text(LangKey.deleteFileConfimationNote)} ${data.fileName ?? ''} Ver ${data.version ?? 1}?'),
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
  void deleteFile(file.Data data) async {
    await DocumentConnection.deleteFile(widget.data.fileId??'',versionId: data.versionId);
    try {
      int index = files!.data!.indexOf(data);
      files!.data!.removeAt(index);
    }catch(_) {}
    setState(() {});
  }
}