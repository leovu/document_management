import 'package:auto_size_text/auto_size_text.dart';
import 'package:document_management/connection/document_connection.dart';
import 'package:document_management/localization/app_localization.dart';
import 'package:document_management/localization/lang_key.dart';
import 'package:flutter/material.dart';
import '../model/folder.dart';

class PasswordFolderScreen extends StatefulWidget {
  final bool isCreatedPassword;
  final Data data;
  const PasswordFolderScreen({Key? key, required this.isCreatedPassword, required this.data}) : super(key: key);
  @override
  State<PasswordFolderScreen> createState() => _PasswordFolderScreenState();
}

class _PasswordFolderScreenState extends State<PasswordFolderScreen> {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _newPasswordConfirmationController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return  Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
        color: Colors.black, 
      ),
      backgroundColor: Colors.white,
      title: Text(AppLocalizations.text(widget.isCreatedPassword ? LangKey.createPassword : LangKey.changePassword),style: const TextStyle(color: Colors.black),),
    ),
    body: Form(
      key: formKey,
      child: ListView(
        physics: const ClampingScrollPhysics(),
        children: [
          Container(height: 15.0,),
          if(!widget.isCreatedPassword) Padding(
            padding: const EdgeInsets.only(bottom: 15.0,left: 15.0,right: 15.0),
            child: Container(
              height: 40.0,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(10.0)
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Row(
                  children: [
                    Icon(Icons.shield_moon_outlined,color: Colors.grey.shade600,),
                    Container(width: 5.0,),
                    Expanded(child: Center(
                      child: TextFormField(
                        decoration: InputDecoration.collapsed(
                            hintText: AppLocalizations.text(LangKey.currentPassword),
                          hintStyle: const TextStyle(fontSize: 12.0),
                        ),
                        validator: (val) {
                          if (val!.isEmpty || val.length < 8) {
                            return AppLocalizations.text(LangKey.passwordValidation);
                          }
                          return null;
                        },
                        controller: _currentPasswordController,
                        obscureText: true,
                      ),
                    ),)
                  ],
                )
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 15.0,left: 15.0,right: 15.0),
            child: Container(
              height: 40.0,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(10.0)
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child:
                  Row(
                  children: [
                  Icon(Icons.lock_outline,color: Colors.grey.shade600,),
                  Container(width: 5.0,),
                  Expanded(child: Center(
                    child: TextFormField(
                      decoration: InputDecoration.collapsed(
                          hintText: AppLocalizations.text(LangKey.newPassword),
                        hintStyle: const TextStyle(fontSize: 12.0),
                      ),
                      controller: _newPasswordController,
                      obscureText: true,
                      validator: (val) {
                        if (val!.isEmpty || val.length < 8) {
                          return AppLocalizations.text(LangKey.passwordValidation);
                        }
                        return null;
                      },
                    ),
                  ),)],
                  )
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 15.0,left: 15.0,right: 15.0),
            child: Container(
              height: 40.0,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(10.0)
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Row(
                  children: [
                    Icon(Icons.lock_outline,color: Colors.grey.shade600,),
                    Container(width: 5.0,),
                    Expanded(child: Center(
                      child: TextFormField(
                        decoration: InputDecoration.collapsed(
                            hintText: AppLocalizations.text(LangKey.newPasswordConfirmation),
                            hintStyle: const TextStyle(fontSize: 12.0),
                        ),
                        controller: _newPasswordConfirmationController,
                        obscureText: true,
                        validator: (val) {
                          if (val!.isEmpty || val.length < 8) {
                            return AppLocalizations.text(LangKey.passwordValidation);
                          }
                          if (val != _newPasswordController.text) {
                            return AppLocalizations.text(LangKey.newPasswordReInputValidation);
                          }
                          return null;
                        },
                      ),
                    ),)],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0,left: 15.0,right: 15.0,top: 15.0),
            child: Container(
              width: MediaQuery.of(context).size.width *0.9,
              height: 40.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: const Color(0xff4fc4ca),
              ),
              child: InkWell(
                onTap: () async {
                  bool result = await validate();
                  if(!result) return;
                  if(widget.isCreatedPassword) {
                    bool result = await DocumentConnection.createFolderPassword(widget.data.folderName!,_newPasswordController.text);
                    if(result) {
                      if(!mounted) return;
                      Navigator.of(context).pop(true);
                    }
                  }
                  else {
                    bool checkPassword = await DocumentConnection.checkFolderPassword(widget.data.folderName!, _currentPasswordController.text);
                    if(checkPassword) {
                      bool result = await DocumentConnection.updateFolderPassword(widget.data.folderName!, _currentPasswordController.text, _newPasswordController.text);
                      if(result) {
                        if(!mounted) return;
                        Navigator.of(context).pop(true);
                      }
                    }
                  }
                },
                child: Center(
                  child: AutoSizeText(AppLocalizations.text(LangKey.accept),style: const TextStyle(color: Colors.white,fontWeight: FontWeight.bold),textScaleFactor: 1.35,),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 15.0,left: 15.0,right: 15.0),
            child: Container(
              width: MediaQuery.of(context).size.width *0.9,
              height: 40.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.grey.shade200,
              ),
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Center(
                  child: AutoSizeText(AppLocalizations.text(LangKey.cancel),style: TextStyle(color: Colors.grey.shade600,fontWeight: FontWeight.bold),textScaleFactor: 1.35,),
                ),
              ),
            ),
          )
        ],
      ),
    ),);
  }
  Future<bool> validate() async{
    FormState? form = formKey.currentState;
    form?.save();
    return form?.validate() ?? false;
  }
}