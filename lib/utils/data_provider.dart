import 'package:flutter/cupertino.dart';
import 'package:trade/main.dart';
import 'package:trade/models/about_model.dart';
import 'package:trade/utils/extensions/context_ext.dart';
import 'package:trade/utils/images.dart';

List<AboutModel> getAboutDataModel({BuildContext? context}) {
  List<AboutModel> aboutList = [];

  aboutList.add(AboutModel(
      title: context!.translate.lblTermsAndConditions, image: termCondition));
  aboutList.add(
      AboutModel(title: languages.lblPrivacyPolicy, image: privacy_policy));
  // aboutList.add(AboutModel(title: languages.lblHelpAndSupport, image: termCondition));
  // aboutList.add(AboutModel(title: languages.lblHelpLineNum, image: calling));
  // aboutList.add(AboutModel(title: languages.lblRateUs, image: rateUs));

  return aboutList;
}
