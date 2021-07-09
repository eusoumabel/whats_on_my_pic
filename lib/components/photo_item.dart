import 'dart:io';

import 'package:flutter/material.dart';

class PhotoItem extends StatelessWidget {
  const PhotoItem({
    Key? key,
    required File? image,
  })  : _image = image,
        super(key: key);

  final File? _image;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        image: DecorationImage(
          image: FileImage(_image!),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
