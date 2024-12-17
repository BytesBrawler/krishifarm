import 'package:flutter/material.dart';
import 'package:krishfarm/farmer/services/CropFieldProvider.dart';

class CropDropdownField extends StatefulWidget {
  final Function callback;
  final bool isEnglish;
  final String text;
  final String dropdownType;
  final String selectedItem;

  CropDropdownField(this.callback, this.isEnglish, this.text, this.dropdownType,
      this.selectedItem);

  @override
  _CropDropdownFieldState createState() => _CropDropdownFieldState();
}

class _CropDropdownFieldState extends State<CropDropdownField> {
  final _controller = TextEditingController();

  void setControllerValue(String value) {
    setState(() {
      _controller.text = value;
    });
    widget.callback(value);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(
            color: Colors.green[800]!,
            width: 0.5,
          ),
          borderRadius: BorderRadius.circular(20.0),
          color: Colors.white),
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      child: Row(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
            child: Icon(
              Icons.format_list_numbered,
              color: Colors.green[800],
            ),
          ),
          Container(
            height: 30.0,
            width: 0.5,
            color: Colors.green[800],
            margin: const EdgeInsets.only(left: 00.0, right: 10.0),
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              onTap: () {
                FocusScope.of(context).requestFocus(new FocusNode());
                CropFieldProvider.showCropDropdown(context, setControllerValue,
                    widget.dropdownType, widget.selectedItem);
              },
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: widget.isEnglish ? widget.text : 'एक फसल का चयन करें',
                hintStyle: TextStyle(color: Colors.grey, fontFamily: 'Varela'),
              ),
            ),
          )
        ],
      ),
    );
  }
}
