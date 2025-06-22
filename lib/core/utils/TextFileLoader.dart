import 'package:flutter/material.dart';
import 'dart:io';


class TextFileLoader
{ 
  
  
  static String loadTextFile(String name)
  { 
     final file = File(name);
     final contents = file.readAsStringSync();
     return contents;
  } 
  
}

class SDG_1 extends StatelessWidget {
  const SDG_1({super.key});

  @override
  Widget build(BuildContext context) {
    final textContent = TextFileLoader.loadTextFile('Pfad_zu_deiner_Datei.txt');

    return Text(textContent);      
  }
}


