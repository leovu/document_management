import 'package:document_management/document_management.dart';
import 'package:document_management/localization/app_localization.dart';
import 'package:document_management/localization/lang_key.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const MaterialApp(
    supportedLocales: [Locale('en', 'US')],
    locale: Locale('en','US'),
    localizationsDelegates: <LocalizationsDelegate<dynamic>>[
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate
    ],
    title: 'Navigation Basics',
    debugShowCheckedModeBanner: false,
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final TextEditingController _tokenController = TextEditingController();
  final TextEditingController _domainController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        _tokenController.text = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczovL3N0YWZmLWFwaS5zdGFnLmVwb2ludHMudm4vdXNlci9sb2dpbiIsImlhdCI6MTY2MzA0MTQ5OCwiZXhwIjoxNjYzMDYzMDk4LCJuYmYiOjE2NjMwNDE0OTgsImp0aSI6Ik9Ba3ZpQU1NOFhmSzA4dzEiLCJzdWIiOjEsInBydiI6ImEwZjNlNzRiZWRmNTEyYzQ3NzgyOTdkZTVmOTIwODZkYWQzOWNhOWYiLCJzaWQiOiJhZG1pbkBwaW9hcHBzLnZuIiwiYnJhbmRfY29kZSI6InFjIn0.sHa1IjewqmjTUA_noapsFuyPBZhTQB4hdHQ47Ft6kbs';
        _domainController.text = 'https://qc.stag.epoints.vn/file/api/';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),

      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 15.0,left: 15.0,right: 15.0),
            child: Container(
              height: 40.0,
              decoration: BoxDecoration(
                  border: Border.all(width: 1.0)
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Center(
                  child: TextField(
                    decoration: const InputDecoration.collapsed(
                        hintText: 'Token'
                    ),
                    controller: _tokenController,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 15.0,left: 15.0,right: 15.0),
            child: Container(
              height: 40.0,
              decoration: BoxDecoration(
                  border: Border.all(width: 1.0)
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Center(
                  child: TextField(
                    decoration: const InputDecoration.collapsed(
                        hintText: 'Domain'
                    ),
                    controller: _domainController,
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: InkWell(
                onTap: () async {
                  if(_tokenController.value.text == '') {
                    errorDialog('Token Empty');
                    return;
                  }
                  if(_domainController.value.text == '') {
                    errorDialog('Domain Empty');
                    return;
                  }
                  DocumentManagement.open(context,const Locale(LangKey.langVi, 'VN'), _tokenController.value.text, domain: _domainController.value.text, brandCode: 'qc');
                },
                child: Container(
                    height: 40.0,
                    width: 80.0,
                    color: Colors.blue,
                    child: const Center(child: Text('Login',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),)))),
          ),
        ],
      ),
    );
  }
  void errorDialog(String text) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.text(LangKey.warning)),
        content: Text(text),
        actions: [
          ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(AppLocalizations.text(LangKey.accept)))
        ],
      ),
    );
  }
}
