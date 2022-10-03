import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:document_management/connection/document_connection.dart';
import 'package:document_management/localization/app_localization.dart';
import 'package:document_management/localization/lang_key.dart';
import 'package:document_management/model/file_log.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:document_management/model/file.dart' as file;
import 'package:intl/intl.dart';

class FileInformationScreen extends StatefulWidget {
  final file.Data data;
  const FileInformationScreen({Key? key, required this.data}) : super(key: key);
  @override
  State<FileInformationScreen> createState() => _FileInformationScreenState();
}

class _FileInformationScreenState extends State<FileInformationScreen> {
  FileLog? fileLog;
  final format1 = DateFormat("dd/MM/yyyy HH:mm");
  final format2 = DateFormat("dd/MM/yyyy");
  bool isInitScreen = true;
  @override
  void initState() {
    super.initState();
    getDetail();
  }
  void getDetail() async {
    fileLog = await DocumentConnection.fileLog(widget.data.fileId ?? '');
    isInitScreen = false;
    setState(() {});
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
      title: Text(AppLocalizations.text(LangKey.detailInfo),style: const TextStyle(color: Colors.black),),
      ),
        body:
        isInitScreen ? Center(child: Platform.isAndroid ? const CircularProgressIndicator() : const CupertinoActivityIndicator()) :
        ListView(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          children: [
            Container(height: 20.0,),
            Row(
              children: [
                AutoSizeText('${AppLocalizations.text(LangKey.fileName)}:'),
                Container(width: 10.0,),
                Expanded(child: AutoSizeText(widget.data.fileName ?? ''))
              ],
            ),
            Container(height: 15.0,),
            const Divider(color: Colors.grey,height: 1,),
            Container(height: 15.0,),
            Row(
              children: [
                AutoSizeText('${AppLocalizations.text(LangKey.size)}:'),
                Container(width: 10.0,),
                Expanded(child: AutoSizeText('${widget.data.sizeFormat}'))
              ],
            ),
            Container(height: 15.0,),
            const Divider(color: Colors.grey,height: 1,),
            Container(height: 15.0,),
            Row(
              children: [
                AutoSizeText('${AppLocalizations.text(LangKey.folder)}:'),
                Container(width: 10.0,),
                Expanded(child: AutoSizeText(widget.data.folderDisplayName ?? ''))
              ],
            ),
            Container(height: 15.0,),
            const Divider(color: Colors.grey,height: 1,),
            Container(height: 15.0,),
            Row(
              children: [
                AutoSizeText('${AppLocalizations.text(LangKey.owner)}:'),
                Container(width: 10.0,),
                Expanded(child: AutoSizeText(widget.data.ownerName ?? ''))
              ],
            ),
            Container(height: 15.0,),
            const Divider(color: Colors.grey,height: 1,),
            Container(height: 15.0,),
            Row(
              children: [
                AutoSizeText('${AppLocalizations.text(LangKey.createdDate)}:'),
                Container(width: 10.0,),
                Expanded(child: AutoSizeText(widget.data.createdDate!))
              ],
            ),
            Container(height: 15.0,),
            const Divider(color: Colors.grey,height: 1,),
            Container(height: 20.0,),
            AutoSizeText('${AppLocalizations.text(LangKey.latestUpdatedDate)}:',style: const TextStyle(fontWeight: FontWeight.bold),),
            Container(height: 15.0,),
            if(fileLog?.data!=null) Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: AutoSizeText.rich(TextSpan(
                  children: [
                    TextSpan(text: '${widget.data.lastModified} ${AppLocalizations.text(LangKey.by)}'),
                    TextSpan(text: ' ${widget.data.updatedName}',style: const TextStyle(fontWeight: FontWeight.w600)),
                    TextSpan(text: ' ${AppLocalizations.text(LangKey.perform)}')
                  ]
              )),
            ),
            if(fileLog?.data!=null) Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: logView()
            )
          ],
        ),
    );
  }
  List<Widget> logView() {
    List<Widget> arr = [];
    for(int i =0;i<=fileLog!.data!.length-1;i++) {
      Data e = fileLog!.data![i];
      arr.add(Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AutoSizeText.rich(TextSpan(
              children: [
                TextSpan(text: '${e.indentity?.staff?.fullName} - '),
                TextSpan(text: '${e.updatedAt}',style: const TextStyle(fontWeight: FontWeight.w600))
              ]
          )),
          AutoSizeText('${e.description}')
        ],
      ));
      arr.add(Container(height: 10.0,));
    }
    return arr;
  }
}