import 'package:flutter/material.dart';
import 'package:image_labeling/utils/constants.dart';

class ResultItem extends StatelessWidget {
  final String text;
  final int index;
  const ResultItem({
    Key? key,
    required this.text,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 16, bottom: 16),
      decoration: BoxDecoration(
        color: Constants.dialogColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.22),
            spreadRadius: 0,
            blurRadius: 8,
            offset: Offset(4, 6),
          ),
        ],
      ),
      child: Text(
        "${index + 1} - $text",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Constants.textColor,
          fontSize: 20,
        ),
      ),
    );
  }
}
