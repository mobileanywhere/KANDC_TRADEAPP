import 'package:flutter/material.dart';
import 'package:trade/main.dart';
import 'package:trade/utils/common.dart';
import 'package:trade/utils/images.dart';
import 'package:trade/utils/model_keys.dart';
import 'package:nb_utils/nb_utils.dart';

class TodayCashComponent extends StatelessWidget {
  final num todayCashAmount;
  final Function(int, {String? statusType})? switchToFragmentCallback;

  const TodayCashComponent(
      {super.key, required this.todayCashAmount, this.switchToFragmentCallback});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // CashBalanceDetailScreen().launch(context);
        if (isUserTypeHandyman) {
        } else {
          if (switchToFragmentCallback != null) {
            switchToFragmentCallback!(2,
                statusType: BookingStatusKeys.inProgress);
          }
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: EdgeInsets.symmetric(horizontal: 16),
        decoration: boxDecorationDefault(
            borderRadius: radius(), color: context.cardColor),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  decoration: boxDecorationDefault(
                      color: context.primaryColor, shape: BoxShape.circle),
                  padding: EdgeInsets.all(8),
                  child: Image.asset(ic_inprogress_inspection,
                      color: Colors.white, height: 24),
                ),
                16.width,
                Text(
                        isUserTypeHandyman
                            ? 'Today\'s Services'
                            : 'In Progress Inspection',
                        style: boldTextStyle())
                    .expand(),
                16.width,
                Text(
                  todayCashAmount.toString(),
                  style: primaryTextStyle(
                      color: appStore.isDarkMode
                          ? Colors.white
                          : context.primaryColor,
                      weight: FontWeight.bold,
                      size: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
