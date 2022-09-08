import 'dart:io';

import 'package:document_management/connection/document_connection.dart';
import 'package:document_management/connection/http_connection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebViewScreen extends StatefulWidget {
  final String url;
  final String fileName;
  const WebViewScreen({Key? key, required this.url, required this.fileName}) : super(key: key);
  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  InAppWebViewController? webViewController;
  bool isCompleted = false;
  @override
  Widget build(BuildContext context) {
    InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
        crossPlatform: InAppWebViewOptions(
            javaScriptEnabled: true,
            cacheEnabled: true,
            supportZoom: false,
            clearCache: false,
            transparentBackground: true,
            useShouldOverrideUrlLoading: true,
            mediaPlaybackRequiresUserGesture: false),
        android: AndroidInAppWebViewOptions(
          useHybridComposition: false,
          supportMultipleWindows: false,
        ),
        ios: IOSInAppWebViewOptions(
          allowsInlineMediaPlayback: true,
        ));
    final GlobalKey webViewKey = GlobalKey();
    return Scaffold(
        appBar: AppBar(iconTheme: const IconThemeData(
          color: Colors.black, 
        ),
          backgroundColor: Colors.white,
          title: Text(widget.fileName,style: const TextStyle(color: Colors.black),),
        ),
        body: Stack(
          children: [
            InAppWebView(
              key: webViewKey,
              initialUrlRequest: URLRequest(url: Uri.parse(widget.url),
                  headers: {
                    'brand-code' : HTTPConnection.brandCode,
                    'Authorization':'Bearer ${DocumentConnection.account!.accessToken}'
                  }),
              initialOptions: options,
              onWebViewCreated: (controller) async {
                webViewController = controller;
              },
              onLoadStop: (controller, url) {
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
