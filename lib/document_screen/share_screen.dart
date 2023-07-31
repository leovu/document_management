import 'package:auto_size_text/auto_size_text.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:document_management/connection/document_connection.dart';
import 'package:document_management/localization/app_localization.dart';
import 'package:document_management/localization/lang_key.dart';
import 'package:document_management/model/file.dart' as file;
import 'package:document_management/model/folder.dart' as folder;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class ShareScreen extends StatefulWidget {
  final file.Data? fileData;
  final folder.Data? folderData;
  const ShareScreen({Key? key, this.fileData, this.folderData}) : super(key: key);
  @override
  State<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareScreen> {
  int typeShare = 0;
  String? date;
  String? hour;
  String? minute;
  final format3 = DateFormat("yyyy-MM-dd");
  final format2 = DateFormat("yyyy-MM-dd HH:mm:ss");
  String? urlLimited;
  String? urlUnlimited;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getShareLink();
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
      title: Text(widget.folderData != null ? AppLocalizations.text(LangKey.shareFolder) : AppLocalizations.text(LangKey.shareFile),style: const TextStyle(color: Colors.black),),
    ),body:
    Column(
      children: [
        Expanded(child: ListView(
          padding: const EdgeInsets.all(15.0),
          physics: const ClampingScrollPhysics(),
          children: [
            AutoSizeText(AppLocalizations.text(LangKey.shareNote)),
            Container(height: 20.0,),
            Row(
              children: [
                Expanded(child: InkWell(
                  onTap: () {
                    setState(() {
                      typeShare = 0;
                      if(urlLimited == null) {
                        date = null;
                        hour = null;
                        minute = null;
                      }
                    });
                    if(urlUnlimited == null) {
                      getShareLink();
                    }
                  },
                  child: Row(
                    children: [
                      typeShare == 0 ? const Icon(Icons.radio_button_checked,color: Color(0xff4fc4ca)) : const Icon(Icons.radio_button_off,color: Colors.grey),
                      Container(width: 5.0,),
                      AutoSizeText(AppLocalizations.text(LangKey.unlimited),maxLines: 1,)
                    ],
                  ),
                )),
                Expanded(child: InkWell(
                  onTap: () {
                    setState(() {
                      typeShare = 1;
                    });
                    if(urlLimited == null && (date != null && minute != null && hour != null)) {
                      getShareLink();
                    }
                  },
                  child: Row(
                    children: [
                      typeShare == 1 ? const Icon(Icons.radio_button_checked,color: Color(0xff4fc4ca)) : const Icon(Icons.radio_button_off,color: Colors.grey),
                      Container(width: 5.0,),
                      AutoSizeText(AppLocalizations.text(LangKey.limited),maxLines: 1,)
                    ],
                  ),
                )),
              ],
            ),
            Container(height: 20.0,),
            if(typeShare == 1) AutoSizeText('${AppLocalizations.text(LangKey.pickTime)}: '),
            if(typeShare == 1) Container(height: 20.0,),
            if(typeShare == 1) Row(
              children: [
                AutoSizeText(AppLocalizations.text(LangKey.date)),
                Container(width: 5.0,),
                InkWell(
                  onTap: () async {
                    List<DateTime?>? results = await showCalendarDatePicker2Dialog(
                      context: context,
                      config: CalendarDatePicker2WithActionButtonsConfig(
                        calendarType: CalendarDatePicker2Type.single,
                        okButton: AutoSizeText(AppLocalizations.text(LangKey.accept),style: const TextStyle(color: Colors.blue,fontWeight: FontWeight.bold),),
                        cancelButton: InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: AutoSizeText(AppLocalizations.text(LangKey.cancel),style: const TextStyle(color: Colors.blue,fontWeight: FontWeight.bold),),
                        ),
                      ),
                      dialogSize: const Size(325, 400),
                      borderRadius: BorderRadius.circular(15),
                    );
                    if(results != null) {
                      date = format3.format(results[0]!);
                    }
                    setState(() {});
                    getShareLink();
                  },
                  child: Container(
                    height: 30.0,
                    width: 250.0,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(color: Colors.grey.shade400)
                    ),
                    child: Row(
                      children: [
                        Expanded(child: Center(child: AutoSizeText(date??''))),
                        const Icon(Icons.arrow_drop_down)
                      ],
                    ),
                  ),
                )
              ],
            ),
            if(typeShare == 1) Container(height: 20.0,),
            if(typeShare == 1) Row(
              children: [
                Row(
                  children: [
                    AutoSizeText(AppLocalizations.text(LangKey.hour)),
                    Container(width: 16.0,),
                    InkWell(
                      onTap: () async {
                        TimeOfDay? time = await showTimePicker(
                          initialTime: TimeOfDay.now(),
                          context: context,
                          builder: (context, child) {
                            return MediaQuery(
                              data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                              child: child!,
                            );
                          },
                        );
                        if(time != null) {
                          if(time.hour < 10) {
                            hour = '0${time.hour}';
                          }
                          else {
                            hour = '${time.hour}';
                          }
                          if(time.minute < 10) {
                            minute = '0${time.minute}';
                          }
                          else {
                            minute = '${time.minute}';
                          }
                          setState(() {});
                          getShareLink();
                        }
                      },
                      child: Container(
                        height: 30.0,
                        width: 60.0,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(color: Colors.grey.shade400)
                        ),
                        child: Row(
                          children: [
                            Expanded(child: Center(child: AutoSizeText(hour??''))),
                            const Icon(Icons.arrow_drop_down)
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                Container(width: 15.0,),
                Row(
                  children: [
                    AutoSizeText(AppLocalizations.text(LangKey.minute)),
                    Container(width: 8.0,),
                    InkWell(
                      onTap: () async {
                        TimeOfDay? time = await showTimePicker(
                          initialTime: TimeOfDay.now(),
                          context: context,
                          builder: (context, child) {
                            return MediaQuery(
                              data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                              child: child!,
                            );
                          },
                        );
                        if(time != null) {
                          if(time.hour < 10) {
                            hour = '0${time.hour}';
                          }
                          else {
                            hour = '${time.hour}';
                          }
                          if(time.minute < 10) {
                            minute = '0${time.minute}';
                          }
                          else {
                            minute = '${time.minute}';
                          }
                          setState(() {});
                          getShareLink();
                        }
                      },
                      child: Container(
                        height: 30.0,
                        width: 60.0,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(color: Colors.grey.shade400)
                        ),
                        child: Row(
                          children: [
                            Expanded(child: Center(child: AutoSizeText(minute??''))),
                            const Icon(Icons.arrow_drop_down)
                          ],
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
            Container(height: 20.0,),
            const AutoSizeText('URL: '),
            Container(height: 15.0,),
            Container(
              height: 40.0,
              width: 250.0,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: Colors.grey.shade400)
              ),
              child:
              Center(child: AutoSizeText(typeShare == 0 ? (urlUnlimited??'') : (urlLimited??''))),
            ),
          ],
        ),),
        Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
          child: Center(
            child: Container(
              width: MediaQuery.of(context).size.width *0.9,
              height: 45.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: enabledCopyUrl() ? const Color(0xff4fc4ca) : Colors.grey,
              ),
              child: InkWell(
                onTap: () async {
                  if(typeShare == 0 && urlUnlimited != null && urlUnlimited != '') {
                    Clipboard.setData(ClipboardData(text: urlUnlimited!));
                    try{
                      ScaffoldMessenger.of(DocumentConnection.buildContext!).hideCurrentSnackBar();
                    }catch(_){}
                    try{
                      ScaffoldMessenger.of(DocumentConnection.buildContext!).showSnackBar(SnackBar(
                        content: Text(AppLocalizations.text(LangKey.copyUrlCompleted)),duration: const Duration(seconds: 2),));
                    }catch(_){}
                  }
                  else if(typeShare == 1 && urlLimited != null && urlLimited != '') {
                    Clipboard.setData(ClipboardData(text: urlLimited!));
                    try{
                      ScaffoldMessenger.of(DocumentConnection.buildContext!).hideCurrentSnackBar();
                    }catch(_){}
                    try{
                      ScaffoldMessenger.of(DocumentConnection.buildContext!).showSnackBar(SnackBar(
                        content: Text(AppLocalizations.text(LangKey.copyUrlCompleted)),duration: const Duration(seconds: 2),));
                    }catch(_){}
                  }
                },
                child: Center(
                  child: AutoSizeText(AppLocalizations.text(LangKey.copyUrl),
                    style: TextStyle(color: enabledCopyUrl() ? Colors.white : Colors.black,fontWeight: FontWeight.bold),textScaleFactor: 1.5,),
                ),
              ),
            ),
          ),
        )
      ],
    ));
  }

  bool enabledCopyUrl() {
    if(typeShare == 0) {
      return urlUnlimited != null;
    }
    else {
      return urlLimited != null;
    }
  }

  void getShareLink() async {
    if(widget.folderData != null) {
      if(typeShare == 0) {
        DocumentConnection.showLoading(context);
        urlUnlimited = await DocumentConnection.shareFolder(widget.folderData?.folderName??'');
        if(!mounted) return;
        Navigator.of(context).pop();
        setState(() {});
      }
      else {
        if(date != null && hour != null && minute != null) {
          final String time = '$date $hour:$minute:00';
          final DateTime dateTime = format2.parse(time);
          final bool isExpired = dateTime.isBefore(DateTime.now());
          if(isExpired) {
            urlLimited = '';
            setState(() {});
            DocumentConnection.error(context, AppLocalizations.text(LangKey.timeShareExpired));
          }
          else {
            DocumentConnection.showLoading(context);
            urlLimited = await DocumentConnection.shareFolder(widget.folderData?.folderName??'',expireTime: '$date $hour:$minute:00');
            if(!mounted) return;
            Navigator.of(context).pop();
            setState(() {});
          }
        }
      }
    }
    else if(widget.fileData != null) {
      if(typeShare == 0) {
        DocumentConnection.showLoading(context);
        urlUnlimited = await DocumentConnection.shareFile(widget.fileData?.key??'');
        if(!mounted) return;
        Navigator.of(context).pop();
        setState(() {});
      }
      else {
        if(date != null && hour != null && minute != null) {
          final String time = '$date $hour:$minute:00';
          final DateTime dateTime = format2.parse(time);
          final bool isExpired = dateTime.isBefore(DateTime.now());
          if(isExpired) {
            urlLimited = '';
            setState(() {});
            DocumentConnection.error(context, AppLocalizations.text(LangKey.timeShareExpired));
          }
          else {
            DocumentConnection.showLoading(context);
            urlLimited = await DocumentConnection.shareFile(widget.fileData?.key??'',expireTime: '$date $hour:$minute:00');
            if(!mounted) return;
            Navigator.of(context).pop();
            setState(() {});
          }
        }
      }
    }
  }
}