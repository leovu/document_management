import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:document_management/connection/document_connection.dart';
import 'package:document_management/localization/app_localization.dart';
import 'package:document_management/localization/lang_key.dart';
import 'package:document_management/model/comment.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:document_management/model/file.dart' as file;

class CommentScreen extends StatefulWidget {
  final file.Data data;
  final String? password;
  const CommentScreen({Key? key, required this.data, this.password}) : super(key: key);
  @override
  State<CommentScreen> createState() => _CommentScreentState();
}

class _CommentScreentState extends State<CommentScreen> {
  bool isInitScreen = true;
  TextEditingController controller = TextEditingController();
  Comment? comments;
  @override
  void initState() {
    super.initState();
    commentList();
  }
  Future<void> commentList() async {
    setState(() {
      isInitScreen = true;
    });
    comments = await DocumentConnection.commentList(widget.data.fileId??'');
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
      title: Text(AppLocalizations.text(LangKey.commentFile),style: const TextStyle(color: Colors.black),),
    ),body: isInitScreen ? Center(child: Platform.isAndroid ? const CircularProgressIndicator() : const CupertinoActivityIndicator()) :
      Column(
    children: [
        Expanded(child: ListView(
          padding: const EdgeInsets.only(top: 15.0),
          children:
          comments?.data == null ? [] :
          comments!.data!.map((e) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Center(child: AutoSizeText(e.commentDate ?? '',style: const TextStyle(fontWeight: FontWeight.w600),)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: e.detail == null ? [] : e.detail!.map((h) =>
                    Column(
                      children: [
                        Container(height: 5.0,),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(padding: const EdgeInsets.only(right: 10.0),
                                child: h.staff?.staffAvatar == null ? CircleAvatar(
                                  radius: 20.0,
                                  child: AutoSizeText(h.staff!.getAvatarName()),
                                ) : CircleAvatar(
                                  radius: 20.0,
                                  backgroundImage:
                                  CachedNetworkImageProvider(h.staff!.staffAvatar!),
                                  backgroundColor: Colors.transparent,
                                ),),
                              Expanded(child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  AutoSizeText(h.staff?.fullName ?? '',maxLines: 1,style: const TextStyle(fontWeight: FontWeight.w600),),
                                  Container(height: 3.0,),
                                  AutoSizeText(h.message ?? '',),
                                ],
                              )),
                            ],
                          ),
                        ),
                        if(e.detail!.indexOf(h) != e.detail!.length-1) Padding(
                          padding: const EdgeInsets.only(top: 8.0,bottom: 8.0),
                          child: Container(height: 1.0,color: Colors.grey.shade300,width: MediaQuery.of(context).size.width*0.9,),
                        ),
                      ],)
                ).toList(),
              ),
            ],
          )).toList(),
        ),),
      Padding(
        padding: const EdgeInsets.only(top: 8.0,bottom: 15.0),
        child: Container(height: 1.0,color: Colors.grey.shade300),
      ),
      Row(
        children: [
          Expanded(child:
            Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: Container(
                height: 40.0,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(width: 0.5,color: Colors.grey.shade400)
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: Center(
                    child: TextField(
                      controller: controller,
                      decoration: InputDecoration.collapsed(
                          hintText: AppLocalizations.text(LangKey.inputComment)
                      ),
                    ),
                  ),
                ),
              ),
            ),),
          InkWell(
            onTap: () async {
              if(controller.text != '') {
                DocumentConnection.showLoading(context);
                bool result = await DocumentConnection.addComment(widget.data.fileId??'', controller.text);
                controller.text = '';
                if(!mounted) return;
                Navigator.of(context).pop();
                if(result) {
                  commentList();
                }
              }
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.0),
              child: Icon(Icons.send,color: Color(0xff4fc4ca),size: 35.0,),
            ),
          )
        ],
      ),
      Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom))
    ],
    ));
  }

}