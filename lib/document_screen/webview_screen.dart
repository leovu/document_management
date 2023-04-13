import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  final String url;
  final String fileName;
  const WebViewScreen({Key? key, required this.url, required this.fileName}) : super(key: key);
  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  WebViewController? controller;
  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      print('***** Webview Load *****');
      print(Uri.encodeFull(widget.url));
      print('***** Webview Load *****');
    }
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            if(!isCompleted) {
              setState(() {
                isCompleted = true;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {},
        ),
      )
      ..loadRequest(Uri.parse(Uri.encodeFull(widget.url)));
  }
  bool isCompleted = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(iconTheme: const IconThemeData(
          color: Colors.black, 
        ),
          backgroundColor: Colors.white,
          title: Text(widget.fileName,style: const TextStyle(color: Colors.black),),
        ),
        body: Stack(
          children: [
            if(controller != null) WebViewWidget(controller: controller!),
            !isCompleted
                ? Center(child: Platform.isAndroid ? const CircularProgressIndicator() : const CupertinoActivityIndicator())
                : Container(),
          ],
        ));
  }
}
