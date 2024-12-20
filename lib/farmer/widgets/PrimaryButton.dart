import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final Function press;
  final Color color, textColor;

  const PrimaryButton({
    required this.text,
    required this.press,
    required this.color,
    this.textColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      width: size.width * 0.8,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(29),
        child: TextButton(
          // padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
          style: ButtonStyle(
            foregroundColor: WidgetStateProperty.all<Color>(color),
          ),

          onPressed: () => press(),
          child: Text(
            text,
            style: TextStyle(
              color: textColor,
              fontFamily: 'Lato',
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
