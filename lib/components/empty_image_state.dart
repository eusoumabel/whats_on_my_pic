import 'package:flutter/material.dart';
import 'package:image_labeling/utils/constants.dart';

class EmptyImageState extends StatelessWidget {
  const EmptyImageState({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Selecione uma imagem para tentarmos adivinhar 'What's on your pic'.",
        style: TextStyle(
          color: Constants.textColor,
          fontSize: 17,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
