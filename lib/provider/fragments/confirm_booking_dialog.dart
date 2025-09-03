import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:trade/main.dart';
import 'package:trade/networks/rest_apis.dart';
import 'package:trade/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../utils/configs.dart';

class ConfirmBookingDialog extends StatefulWidget {
  final String serviceId;
  final String providerId;
  final String customerId;
  final String description;
  final String address;
  final String date;
  final String amount;
  final String quantity;
  final String totalAmount;
  final String couponId;
  final String attachmentCount;
  final bool isSlotAvailable;
  final String? bookingDate;
  final String? bookingSlot;
  final String? bookingDay;
  final List<File> imagesFile;
  final String technicalId;

  const ConfirmBookingDialog({super.key, 
    required this.serviceId,
    required this.providerId,
    required this.customerId,
    required this.description,
    required this.address,
    required this.date,
    required this.amount,
    required this.quantity,
    required this.totalAmount,
    required this.couponId,
    required this.attachmentCount,
    this.bookingDate,
    this.bookingDay,
    this.bookingSlot,
    required this.isSlotAvailable,
    required this.imagesFile,
    required this.technicalId,
  });

  @override
  State<ConfirmBookingDialog> createState() => _ConfirmBookingDialogState();
}

class _ConfirmBookingDialogState extends State<ConfirmBookingDialog> {
  Map? selectedPackage;
  List<int> selectedService = [];

  bool isSelected = false;
  String serviceId = "";

  // provider-booking-save api ================================

  Future<void> providerBookServices() async {
    Map<String, String> request = {
      'service_id': widget.serviceId,
      'provider_id': widget.providerId,
      'customer_id': widget.customerId,
      'description': widget.description,
      'address': widget.address,
      'date': widget.date,
      'amount': widget.amount,
      'quantity': widget.quantity,
      'total_amount': widget.totalAmount,
      'coupon_id': widget.couponId,
      'attachment_count': widget.attachmentCount,
      'technician_id': widget.technicalId,
    };

    appStore.setLoading(true);

    await providerBookServicesApi(request,
            imageFile: widget.imagesFile
                .where((element) => !element.path.contains('http'))
                .toList())
        .then((bookingDetailResponse) async {
      appStore.setLoading(false);
      Navigator.of(context).pop();
    }).catchError((e, StackTrace d) {
      appStore.setLoading(false);
      debugPrint('stack trace error: $d');
      toast(e.toString(), print: true);
    });
  }

  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        return SizedBox(
            width: context.width(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(ic_confirm_check,
                    height: 100, width: 100, color: primaryColor),
                24.height,
                Text('Confirm Request', style: boldTextStyle(size: 20)),
                16.height,
                Text('Do you want to confirm this request?',
                    style: primaryTextStyle(), textAlign: TextAlign.center),
                16.height,
                appStore.isLoading
                    ? Loader()
                    : Row(
                        children: [
                          AppButton(
                            onTap: () {
                              finish(context);
                            },
                            text: 'Cancel',
                            textColor: textPrimaryColorGlobal,
                          ).expand(),
                          16.width,
                          AppButton(
                            text: 'Confirm',
                            textColor: Colors.white,
                            color: context.primaryColor,
                            onTap: () async {
                              await providerBookServices();
                            },
                          ).expand(),
                        ],
                      )
              ],
            ));
      },
    );
  }
}
