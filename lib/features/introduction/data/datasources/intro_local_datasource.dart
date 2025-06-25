import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/intro_page_model.dart';

abstract class IntroLocalDataSource {
  Future<List<IntroPageModel>> getIntroPageModels();
}

class IntroLocalDataSourceImpl implements IntroLocalDataSource {
  @override
  Future<List<IntroPageModel>> getIntroPageModels() async {
    final jsonString = await rootBundle.loadString('assets/data/introduction_pages.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((jsonItem) => IntroPageModel.fromJson(jsonItem)).toList();
  }
}