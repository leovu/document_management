import 'dart:io';
import 'package:document_management/connection/document_connection.dart';
import 'package:document_management/connection/http_connection.dart';
import 'package:flutter/cupertino.dart';
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
  void initState() {
    super.initState();
    print('***** Webview Load *****');
    print(widget.url);
    print('***** Webview Load *****');
    if (Platform.isAndroid) WebView.platform = AndroidWebView();
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
            WebView(
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (c) {
                c.loadUrl(
                  widget.url,
                );
              },
              onPageFinished: (c) {
                if(isCompleted) return;
                setState(() {
                  isCompleted = true;
                });
              },
            ),
            !isCompleted
                ? Center(child: Platform.isAndroid ? const CircularProgressIndicator() : const CupertinoActivityIndicator())
                : Container(),
          ],
        ));
  }
}
