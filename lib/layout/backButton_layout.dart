import 'package:flutter/material.dart';

class GoBackButton extends StatelessWidget{

  const GoBackButton();

  Widget build(BuildContext context)
  {
    return BackButton(
      onPressed: () => Navigator.pop(context),
      color: Colors.white,
    );

  }
}