import 'package:document_management/widget/menu_item_option_page.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

class OptionPageButton extends StatefulWidget {
  final List<OptionMenuItem> items;
  const OptionPageButton({Key? key, required this.items}) : super(key: key);

  @override
  State<OptionPageButton> createState() => _OptionPageButtonState();
}

class _OptionPageButtonState extends State<OptionPageButton> {
  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2<dynamic>(
        customButton: Image.asset('assets/ico/ico-popup-menu.png',package: 'document_management',),
        items: _menuItems(),
        onChanged: (value) {
          OptionMenuItems.onChanged(context, value as OptionMenuItem);
        },
        itemHeight: 20,
        dropdownWidth: 270,
        dropdownDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
        ),
        itemPadding: const EdgeInsets.symmetric(horizontal: 5.0,vertical: 1.5),
        offset: const Offset(0,8),
      ),
    );
  }
  List<DropdownMenuItem<dynamic>>? _menuItems() {
    List<DropdownMenuItem> arr = [];
    for (var e in widget.items) {
      if(arr.isNotEmpty) {
        arr.add(
          const DropdownMenuItem<Divider>(enabled: false, child: Divider(color: Colors.grey,)),);
      }
      arr.add(DropdownMenuItem<OptionMenuItem>(
        value: e,
        child: OptionMenuItems.buildItem(e),
      ));
    }
    return arr;
  }
}
