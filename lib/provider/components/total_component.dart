import 'package:flutter/material.dart';
import 'package:trade/main.dart';
import 'package:trade/models/dashboard_response.dart';
import 'package:trade/provider/components/total_widget.dart';
import 'package:trade/provider/handyman_list_screen.dart';
import 'package:trade/utils/common.dart';
import 'package:trade/utils/constant.dart';
import 'package:trade/utils/images.dart';
import 'package:trade/utils/model_keys.dart';
import 'package:nb_utils/nb_utils.dart';

class TotalComponent extends StatelessWidget {
  final DashboardResponse snap;
  final Function(int, {String? statusType}) switchToFragmentCallback;

  const TotalComponent({super.key, required this.snap, required this.switchToFragmentCallback});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        TotalWidget(
                title: 'Total Requests',
                total: snap.totalBooking.toString(),
                icon: ic_total_requests)
            .onTap(
          () {
            switchToFragmentCallback(1, statusType: BookingStatusKeys.all);
          //  LiveStream().emit(LIVESTREAM_PROVIDER_ALL_BOOKING, 1);
          },
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
        ),
        TotalWidget(
          title:
              isUserTypeProvider ? 'Open Requests' : languages.lblTotalService,
          total: snap.openRequests.validate().toString(),
          icon: ic_open_requests,
        ).onTap(
          () {
            switchToFragmentCallback(1, statusType: BookingStatusKeys.pending);
          },
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
        ),
        if (snap.earningType == EARNING_TYPE_SUBSCRIPTION && isUserTypeProvider)
          TotalWidget(
            title: languages.lblTotalHandyman,
            total: snap.totalHandyman.validate().toString(),
            icon: handyman,
          ).onTap(
            () {
              HandymanListScreen().launch(context);
            },
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
          ),
        TotalWidget(
          title: isUserTypeProvider
              ? 'Total Inspections'
              : languages.monthlyEarnings,
          total: isUserTypeProvider
              ? snap.totalInspections.validate().toString()
              : "${isCurrencyPositionLeft ? appStore.currencySymbol : ""}${snap.totalRevenue.validate().toStringAsFixed(DECIMAL_POINT).formatNumberWithComma()}${isCurrencyPositionRight ? appStore.currencySymbol : ""}",
          icon: ic_total_inspection,
        ).onTap(
          () {
            switchToFragmentCallback(2,
                statusType: BookingStatusKeys.all);
           // LiveStream().emit(LIVESTREAM_PROVIDER_ALL_INSPECTION, 2);
          },
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
        ),
        if (snap.earningType == EARNING_TYPE_COMMISSION)
          TotalWidget(
            title:
                isUserTypeProvider ? 'Open Inspections' : languages.lblWallet,
            total: isUserTypeProvider
                ? snap.openInspections.validate().toString()
                : "${isCurrencyPositionLeft ? appStore.currencySymbol : ""}${snap.providerWallet != null ? snap.providerWallet?.amount.validate().toStringAsFixed(DECIMAL_POINT).formatNumberWithComma() : "0"}${isCurrencyPositionRight ? appStore.currencySymbol : ""}",
            icon: isUserTypeProvider ? ic_open_inspection : un_fill_wallet,
          ).onTap(
            () {
              switchToFragmentCallback(2,
                  statusType: BookingStatusKeys.pending);
            },
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
          ),
      ],
    ).paddingAll(16);
  }
}
