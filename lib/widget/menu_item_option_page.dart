import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class OptionMenuItem {
  final String text;
  final IconData? icon;
  bool? isSelected;
  final String key;
  final Function? action;

  OptionMenuItem({
    required this.text,
    this.icon,
    this.isSelected = false,
    required this.key,
    this.action
  });
}

class OptionMenuItems {
  static Widget buildItem(OptionMenuItem item) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(width: 5.0,),
        item.isSelected == null || item.isSelected == false ? Container(width: 30.0,) : const SizedBox(
          width: 30.0,
          child: Center(
            child: Icon(Icons.check,
                color: Colors.black,
                size: 18)
          ),
        ),
        Container(width: 5.0,),
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: AutoSizeText(
              item.text,
              textScaleFactor: 1.25,
              style: const TextStyle(
                color: Colors.black
              ),
            ),
          ),
        ),
        if(item.icon != null) Center(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 5.0,right: 10.0),
            child: Icon(
                item.icon,
                color: Colors.black,
                size: 18
            ),
          ),
        ),
      ],
    );
  }

  static onChanged(BuildContext context, OptionMenuItem item) {
    if(item.action != null) {
      item.action!();
    }
  }
}