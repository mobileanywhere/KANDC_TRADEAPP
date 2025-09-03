import 'package:flutter/material.dart';
import 'package:trade/main.dart';
import 'package:trade/models/handyman_dashboard_response.dart';
import 'package:trade/utils/common.dart';
import 'package:trade/utils/configs.dart';
import 'package:trade/utils/constant.dart';
import 'package:trade/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

class HandymanCommissionComponent extends StatelessWidget {
  final Commission commission;

  const HandymanCommissionComponent({super.key, required this.commission});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: boxDecorationWithRoundedCorners(
        borderRadius: radius(8),
        backgroundColor: appStore.isDarkMode ? cardDarkColor : gray.withOpacity(0.1),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichTextWidget(
                textAlign: TextAlign.center,
                list: [
                  TextSpan(text: "${languages.lblHandymanType}: ", style: secondaryTextStyle()),
                  TextSpan(text: commission.name.validate(), style: boldTextStyle()),
                ],
              ),
              8.height,
              RichTextWidget(
                textAlign: TextAlign.center,
                list: [
                  TextSpan(text: '${languages.lblMyCommission}: ', style: secondaryTextStyle()),
                  TextSpan(
                      text: isCommissionTypePercent(commission.type) ? '${commission.commission.validate()}%' : '${getStringAsync(CURRENCY_COUNTRY_SYMBOL)}${commission.commission.validate()}',
                      style: boldTextStyle()),
                  if (isCommissionTypePercent(commission.type))
                    TextSpan(
                      text: ' (${languages.lblFixed})',
                      style: secondaryTextStyle(),
                    ),
                ],
              ),
            ],
          ),
          Spacer(),
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(shape: BoxShape.circle, color: primaryColor),
            child: Image.asset(percent_line, height: 22, width: 22, color: white),
          ),
        ],
      ),
    );
  }
}
