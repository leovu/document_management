import 'dart:io';
import 'package:file_icon/file_icon.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:document_management/connection/document_connection.dart';
import 'package:document_management/localization/app_localization.dart';
import 'package:document_management/localization/lang_key.dart';
import 'package:document_management/model/folder.dart' as r;
import 'package:document_management/model/folder_information.dart';
import 'package:document_management/model/folder_log.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FolderInformationScreen extends StatefulWidget {
  final r.Data? data;
  const FolderInformationScreen({Key? key,this.data}) : super(key: key);
  @override
  State<FolderInformationScreen> createState() => _FolderInformationScreentState();
}

class _FolderInformationScreentState extends State<FolderInformationScreen> {
  FolderInformation? folderInformation;
  FolderLog? folderLog;
  int type = 0;
  final format1 = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z");
  final format2 = DateFormat("dd/MM/yyyy");
  bool isInitScreen = true;
  @override
  void initState() {
    super.initState();
    getDetail();
  }
  void getDetail() async {
    folderInformation = await DocumentConnection.folderInformation(widget.data?.folderName ?? '');
    folderLog = await DocumentConnection.folderLog(widget.data?.folderName ?? '');
    isInitScreen = false;
    setState(() {});
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return
      Scaffold(
        appBar: AppBar(
            iconTheme: const IconThemeData(
              color: Colors.black, 
            ),
            backgroundColor: Colors.white,
            title: Text(AppLocalizations.text(LangKey.detailInfo),style: const TextStyle(color: Colors.black),),),
        body: Column(
          children: [
            Row(
              children: [
                Expanded(child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 10.0),
                  child: SizedBox(
                      height: 40.0,
                      width: 160.0,
                      child: MaterialButton(
                        color: type == 0 ? const Color(0xff4fc4ca) : Colors.grey,
                        child: Center(child: AutoSizeText(AppLocalizations.text(LangKey.detailInfo),style: TextStyle(color: type == 0 ? Colors.white : Colors.black ,fontWeight: FontWeight.bold),),),
                        onPressed: () {
                          if(type == 0) return;
                          setState(() {
                            type = 0;
                          });
                        },
                      )),
                ),),
                Expanded(child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 10.0),
                  child: SizedBox(
                      height: 40.0,
                      width: 160.0,
                      child: MaterialButton(
                        color: type == 1 ? const Color(0xff4fc4ca) : Colors.grey,
                        child: Center(child: AutoSizeText(AppLocalizations.text(LangKey.logHistory),style: TextStyle(color: type == 1 ? Colors.white : Colors.black ,fontWeight: FontWeight.bold),),),
                        onPressed: () {
                          if(type == 1) return;
                          setState(() {
                            type = 1;
                          });
                        },
                      )),
                ),),
              ],
            ),
            isInitScreen ? Expanded(child: Center(child: Platform.isAndroid ? const CircularProgressIndicator() : const CupertinoActivityIndicator())) :
            Expanded(child:
              type == 0 ?
                folderInformation?.data == null ? Container() : detailView()
                  : folderLog?.data == null ? Container() : logView()
            )
          ],
        ));
  }

  Widget detailView() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      children: [
        Container(height: 20.0,),
        Row(
          children: [
            AutoSizeText('${AppLocalizations.text(LangKey.folderName)}:'),
            Expanded(child: AutoSizeText(folderInformation?.data?.displayName ?? ''))
          ],
        ),
        Container(height: 20.0,),
        Row(
          children: [
            AutoSizeText('${AppLocalizations.text(LangKey.totalFiles)}:'),
            Container(width: 10.0,),
            Expanded(child: AutoSizeText('${folderInformation?.data?.totalItem ?? 0}'))
          ],
        ),
        Container(height: 20.0,),
        Row(
          children: [
            AutoSizeText('${AppLocalizations.text(LangKey.size)}:'),
            Container(width: 10.0,),
            Expanded(child: AutoSizeText(folderInformation?.data?.sizeFormat ?? ''))
          ],
        ),
        Container(height: 20.0,),
        Row(
          children: [
            AutoSizeText('${AppLocalizations.text(LangKey.owner)}:'),
            Container(width: 10.0,),
            Expanded(child: AutoSizeText(folderInformation?.data?.ownerName ?? ''))
          ],
        ),
        Container(height: 20.0,),
        Row(
          children: [
            AutoSizeText('${AppLocalizations.text(LangKey.accessPermission)}:'),
            Container(width: 10.0,),
            Expanded(child: AutoSizeText(folderInformation?.data?.permission == 'public' ?
            AppLocalizations.text(LangKey.public) : folderInformation?.data?.permission == 'private'
                ? AppLocalizations.text(LangKey.private)
                : AppLocalizations.text(LangKey.targetOnly)))
          ],
        ),
        Container(height: 20.0,),
        Row(
          children: [
            AutoSizeText('${AppLocalizations.text(LangKey.createdDate)}:'),
            Container(width: 10.0,),
            Expanded(child: AutoSizeText(format2.format(format1.parse(folderInformation!.data!.createdDate!, true).toLocal())))
          ],
        ),
        Container(height: 20.0,),
        Row(
          children: [
            AutoSizeText('${AppLocalizations.text(LangKey.latestUpdatedDate)}:'),
            Container(width: 10.0,),
            Expanded(child: AutoSizeText.rich(
              TextSpan(
                  children: [
                    TextSpan(text: '${format2.format(format1.parse(folderInformation!.data!.updatedDate!, true).toLocal())} ${AppLocalizations.text(LangKey.by)} '),
                    TextSpan(text: folderInformation?.data?.updatedByName ?? '',style: const TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: ' ${AppLocalizations.text(LangKey.updated)}')
                  ]
              ),
            ))
          ],
        ),
      ],
    );
  }

  Widget logView() {
    return ListView(
        padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 10.0),
        children: folderLog!.data!.map((e) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:
          e.detail == null ? [] :
          e.detail!.map((i) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AutoSizeText('${i.indentity?.staff?.fullName ?? ''} - ${e.logDate ?? ''}',style: const TextStyle(fontWeight: FontWeight.bold),),
              AutoSizeText(i.description ?? ''),
              if(i.properties?.file!=null && i.properties!.file!.isNotEmpty) Column(
                children: i.properties!.file!.map((h) => Padding(
                  padding: const EdgeInsets.only(left: 20.0,right: 15.0,bottom: 20.0),
                  child: Row(
                    children: [
                      FileIcon(
                        h,
                        size: 40,
                      ),
                      Container(width: 5.0,),
                      Expanded(child: AutoSizeText(h,style: TextStyle(color: Colors.grey.shade800),maxLines: 1,overflow: TextOverflow.ellipsis,))
                    ],
                  ),
                )).toList(),
              )
            ],
          )).toList(),
        )).toList());
  }
}