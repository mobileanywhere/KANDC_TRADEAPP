import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:trade/components/app_common_dialog.dart';
import 'package:trade/components/app_widgets.dart';
import 'package:trade/components/basic_info_component.dart';
import 'package:trade/components/booking_history_bottom_sheet.dart';
import 'package:trade/components/cached_image_widget.dart';
import 'package:trade/components/countdown_widget.dart';
import 'package:trade/components/price_widget.dart';
import 'package:trade/components/review_list_view_component.dart';
import 'package:trade/components/view_all_label_component.dart';
import 'package:trade/handyman/component/service_proof_list_widget.dart';
import 'package:trade/handyman/service_proof_screen.dart';
import 'package:trade/main.dart';
import 'package:trade/models/Package_response.dart';
import 'package:trade/models/attachment_model.dart';
import 'package:trade/models/booking_detail_response.dart';
import 'package:trade/models/booking_list_response.dart';
import 'package:trade/models/extra_charges_model.dart';
import 'package:trade/models/service_model.dart';
import 'package:trade/networks/rest_apis.dart';
import 'package:trade/provider/components/assign_handyman_screen.dart';
import 'package:trade/provider/handyman_info_screen.dart';
import 'package:trade/provider/services/service_detail_screen.dart';
import 'package:trade/screens/booking_details/final_invocie_screen.dart';
import 'package:trade/screens/cash_management/component/cash_confirm_dialog.dart';
import 'package:trade/screens/complete_job_dialogue.dart';
import 'package:trade/screens/extra_charges/add_extra_charges_screen.dart';
import 'package:trade/screens/line_items_module.dart';
import 'package:trade/screens/rating_view_all_screen.dart';
import 'package:trade/screens/zoom_image_screen.dart';
import 'package:trade/utils/colors.dart';
import 'package:trade/utils/common.dart';
import 'package:trade/utils/configs.dart';
import 'package:trade/utils/constant.dart';
import 'package:trade/utils/extensions/string_extension.dart';
import 'package:trade/utils/model_keys.dart';

import '../../components/base_scaffold_widget.dart';
import '../../components/empty_error_state_widget.dart';
import '../shimmer/booking_detail_shimmer.dart';

class BookingDetailScreen extends StatefulWidget {
  final int bookingId;

  const BookingDetailScreen({super.key, required this.bookingId});

  @override
  BookingDetailScreenState createState() => BookingDetailScreenState();
}

class BookingDetailScreenState extends State<BookingDetailScreen> {
  late Future<BookingDetailResponse> future;

  GlobalKey countDownKey = GlobalKey();
  String? startDateTime = '';
  String? endDateTime = '';
  String? timeInterval = '0';
  String? paymentStatus = '';

  bool? confirmPaymentBtn = false;
  bool isCompleted = false;
  bool showBottomActionBar = false;

  @override
  void initState() {
    init();
    super.initState();
  }

  Future<void> init({bool flag = false}) async {
    future = bookingDetail({CommonKeys.bookingId: widget.bookingId.toString()});
    if (flag) {
      setState(() {});
    }
  }

  BookingDetailResponse? initialData() {
    if (cachedBookingDetailList.any(
      (element) => element.bookingDetail!.id == widget.bookingId.validate(),
    )) {
      return cachedBookingDetailList.firstWhere(
        (element) => element.bookingDetail!.id == widget.bookingId,
      );
    }
    return null;
  }

  //region Methods
  Future<void> confirmationRequestDialog(
    BuildContext context,
    String status,
    BookingDetailResponse res,
  ) async {
    if (status == BookingStatusKeys.complete &&
        res.bookingDetail!.paymentMethod == PAYMENT_METHOD_COD) {
      showInDialog(
        context,
        contentPadding: EdgeInsets.all(0),
        builder: (p0) {
          return AppCommonDialog(
            title: languages.cashPaymentConfirmation,
            child: CashConfirmDialog(
              bookingId: res.bookingDetail!.id.validate(),
              bookingAmount: res.bookingDetail!.totalAmount.validate(),
              onAccept: (String remarks) {
                appStore.setLoading(true);
                updateBooking(res, remarks, BookingStatusKeys.complete);
              },
            ),
          );
        },
      );

      return;
    }
    showConfirmDialogCustom(
      context,
      title: languages.confirmationRequestTxt,
      primaryColor:
          status == BookingStatusKeys.rejected
              ? Colors.redAccent
              : primaryColor,
      positiveText: languages.lblYes,
      negativeText: languages.lblNo,
      onAccept: (context) async {
        if (status == BookingStatusKeys.pending) {
          appStore.setLoading(true);
          updateBooking(res, '', BookingStatusKeys.accept);
        } else if (status == BookingStatusKeys.rejected) {
          appStore.setLoading(true);
          updateBooking(res, '', BookingStatusKeys.rejected);
        } else if (status == BookingStatusKeys.complete) {
          if (res.bookingDetail!.paymentMethod == PAYMENT_METHOD_COD) {
            return;
          }
        }
      },
    );
  }

  Future<void> assignBookingDialog(
    BuildContext context,
    int? bookingId,
    int? addressId,
  ) async {
    AssignHandymanScreen(
      bookingId: bookingId,
      serviceAddressId: addressId,
      onUpdate: () {
        appStore.setLoading(true);
        init(flag: true);

        if (appStore.isLoading) appStore.setLoading(false);
        setState(() {});
      },
    ).launch(context);
  }

  Future<void> updateBooking(
    BookingDetailResponse bookDetail,
    String updateReason,
    String updatedStatus, {
    List<File>? images,
    List<Attachments>? attachments,
    String? description,
  }) async {
    DateTime now = DateTime.now();
    if (updatedStatus == BookingStatusKeys.inProgress) {
      startDateTime = DateFormat(BOOKING_SAVE_FORMAT).format(now);
      endDateTime = bookDetail.bookingDetail!.endAt.validate();
      timeInterval =
          bookDetail.bookingDetail!.durationDiff.validate().isEmptyOrNull
              ? "0"
              : bookDetail.bookingDetail!.durationDiff.validate();
      paymentStatus =
          bookDetail.bookingDetail!.isAdvancePaymentDone
              ? SERVICE_PAYMENT_STATUS_ADVANCE_PAID
              : bookDetail.bookingDetail!.paymentStatus.validate();
      //
    } else if (updatedStatus == BookingStatusKeys.hold) {
      String? currentDateTime = DateFormat(BOOKING_SAVE_FORMAT).format(now);
      startDateTime = bookDetail.bookingDetail!.startAt.validate();
      endDateTime = currentDateTime;
      var diff =
          DateTime.parse(currentDateTime)
              .difference(
                DateTime.parse(bookDetail.bookingDetail!.startAt.validate()),
              )
              .inMinutes;
      num count =
          int.parse(bookDetail.bookingDetail!.durationDiff.validate()) + diff;
      timeInterval = count.toString();
      paymentStatus =
          bookDetail.bookingDetail!.isAdvancePaymentDone
              ? SERVICE_PAYMENT_STATUS_ADVANCE_PAID
              : bookDetail.bookingDetail!.paymentStatus.validate();
    } else if (updatedStatus == BookingStatusKeys.pendingApproval) {
      startDateTime = bookDetail.bookingDetail!.startAt.toString();
      endDateTime = bookDetail.bookingDetail!.endAt.toString();
      timeInterval = bookDetail.bookingDetail!.durationDiff.validate();
      paymentStatus =
          bookDetail.bookingDetail!.isAdvancePaymentDone
              ? SERVICE_PAYMENT_STATUS_ADVANCE_PAID
              : bookDetail.bookingDetail!.paymentStatus.validate();
    } else if (updatedStatus == BookingStatusKeys.complete) {
      if (bookDetail.bookingDetail!.paymentStatus == PENDING &&
          bookDetail.bookingDetail!.paymentMethod == PAYMENT_METHOD_COD) {
        startDateTime = bookDetail.bookingDetail!.startAt.toString();
        endDateTime = bookDetail.bookingDetail!.endAt.toString();
        timeInterval = "0";
        paymentStatus = PENDING_BY_ADMINS;
        confirmPaymentBtn = false;
        isCompleted = true;
      } else {
        endDateTime = DateFormat(BOOKING_SAVE_FORMAT).format(now);
        startDateTime = bookDetail.bookingDetail!.startAt.validate();
        var diff =
            DateTime.parse(endDateTime.validate())
                .difference(
                  DateTime.parse(bookDetail.bookingDetail!.startAt.validate()),
                )
                .inMinutes;
        num count =
            int.parse(bookDetail.bookingDetail!.durationDiff.validate()) + diff;
        timeInterval = count.toString();
        paymentStatus =
            bookDetail.bookingDetail!.isAdvancePaymentDone
                ? SERVICE_PAYMENT_STATUS_ADVANCE_PAID
                : bookDetail.bookingDetail!.paymentStatus.validate();
      }
      //
    } else if (updatedStatus == BookingStatusKeys.rejected ||
        updatedStatus == BookingStatusKeys.cancelled) {
      startDateTime =
          bookDetail.bookingDetail!.startAt.validate().isNotEmpty
              ? bookDetail.bookingDetail!.startAt.validate()
              : bookDetail.bookingDetail!.date.validate();
      endDateTime = DateFormat(BOOKING_SAVE_FORMAT).format(now);
      timeInterval = bookDetail.bookingDetail!.durationDiff.toString();
      paymentStatus =
          bookDetail.bookingDetail!.isAdvancePaymentDone
              ? SERVICE_PAYMENT_STATUS_ADVANCE_PAID
              : bookDetail.bookingDetail!.paymentStatus.validate();
      //
    } else {
      paymentStatus =
          bookDetail.bookingDetail!.isAdvancePaymentDone
              ? SERVICE_PAYMENT_STATUS_ADVANCE_PAID
              : bookDetail.bookingDetail!.paymentStatus.validate();
    }
    countDownKey = GlobalKey();
    setState(() {});

    hideKeyboard(context);

    var request = {
      CommonKeys.id: bookDetail.bookingDetail!.id,
      BookingUpdateKeys.startAt: startDateTime,
      BookingUpdateKeys.endAt: endDateTime,
      BookingUpdateKeys.durationDiff: timeInterval,
      BookingUpdateKeys.reason: updateReason,
      BookingUpdateKeys.status: updatedStatus,
      BookingUpdateKeys.paymentStatus: paymentStatus,
    };

    if (updatedStatus == BookingStatusKeys.complete) {
      if (description != null) {
        request.addAll({'description': description});
      }
    }

    await bookingUpdateForCompleteStatus(request, imageFile: images)
        .then((res) async {
          if (paymentStatus == PENDING_BY_ADMINS) {
            finish(context);
          }
          init(flag: true);
        })
        .catchError((e) {
          appStore.setLoading(false);
          toast(e.toString(), print: true);
        });

    // refresh page after all action performed
    init(flag: true);
    return await 2.seconds.delay;
  }

  void _handlePendingApproval({
    required BookingDetailResponse val,
    bool isAddExtraCharges = false,
  }) async {
    appStore.setLoading(true);

    Map req = {
      CommonKeys.id: val.bookingDetail!.id.validate(),
      BookingUpdateKeys.startAt: val.bookingDetail!.startAt.toString(),
      BookingUpdateKeys.endAt: val.bookingDetail!.endAt.toString(),
      BookingUpdateKeys.status: BookingStatusKeys.complete,
      BookingUpdateKeys.durationDiff: timeInterval,
      BookingUpdateKeys.paymentStatus:
          val.bookingDetail!.isAdvancePaymentDone
              ? SERVICE_PAYMENT_STATUS_ADVANCE_PAID
              : val.bookingDetail!.paymentStatus.validate(),
    };

    if (chargesList.isNotEmpty && isAddExtraCharges) {
      List<Map<String, dynamic>> charges = [];

      for (var element in chargesList) {
        charges.add({
          "title": element.title.validate(),
          "qty": element.qty.validate(),
          "price": element.price.validate(),
        });
      }
      req.putIfAbsent(BookingServiceKeys.extraCharges, () => charges);
    }

    await bookingUpdate(req)
        .then((res) async {
          //
          init(flag: true);
        })
        .catchError((e) {
          toast(e.toString(), print: true);
        });

    appStore.setLoading(false);
  }

  //endregion

  //region Components
  Widget _serviceDetailWidget({
    required BookingData bookingDetail,
    required ServiceData serviceDetail,
  }) {
    return GestureDetector(
      onTap: () {
        if (bookingDetail.isPostJob || bookingDetail.isPackageBooking) {
          //
        } else {
          ServiceDetailScreen(
            serviceId: bookingDetail.serviceId.validate(),
          ).launch(context);
        }
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (bookingDetail.isPackageBooking)
                Text(
                  bookingDetail.bookingPackage!.name.validate(),
                  style: boldTextStyle(size: LABEL_TEXT_SIZE),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                )
              else
                Text(
                  bookingDetail.serviceName.validate(),
                  style: boldTextStyle(size: LABEL_TEXT_SIZE),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              12.height,
              if ((bookingDetail.date.validate().isNotEmpty))
                Row(
                  children: [
                    Text("${languages.lblDate}: ", style: secondaryTextStyle()),
                    Text(
                      formatDate(
                        bookingDetail.date.validate(),
                        format: DATE_FORMAT_2,
                      ),
                      style: boldTextStyle(size: 12),
                    ),
                  ],
                ),
              8.height,
              if ((bookingDetail.date.validate().isNotEmpty))
                Row(
                  children: [
                    Text("${languages.lblTime}: ", style: secondaryTextStyle()),
                    buildTimeWidget(bookingDetail: bookingDetail),
                  ],
                ),
            ],
          ).expand(),
          if (serviceDetail.attchments!.isNotEmpty &&
              !bookingDetail.isPackageBooking)
            CachedImageWidget(
              url:
                  serviceDetail.attchments!.isNotEmpty
                      ? serviceDetail.attchments!.first.url.validate()
                      : "",
              height: 90,
              width: 90,
              fit: BoxFit.cover,
              radius: 8,
            )
          else
            CachedImageWidget(
              url:
                  bookingDetail.bookingPackage != null
                      ? bookingDetail.bookingPackage!.imageAttachments
                              .validate()
                              .isNotEmpty
                          ? bookingDetail.bookingPackage!.imageAttachments
                                  .validate()
                                  .first
                                  .validate()
                                  .isNotEmpty
                              ? bookingDetail.bookingPackage!.imageAttachments
                                  .validate()
                                  .first
                                  .validate()
                              : ''
                          : ''
                      : '',
              height: 90,
              width: 90,
              fit: BoxFit.cover,
              radius: 8,
            ),
        ],
      ),
    );
  }

  Widget _buildCounterWidget({required BookingDetailResponse value}) {
    if (value.bookingDetail!.isHourlyService &&
        (value.bookingDetail!.status == BookingStatusKeys.inProgress ||
            value.bookingDetail!.status == BookingStatusKeys.hold ||
            value.bookingDetail!.status == BookingStatusKeys.complete ||
            value.bookingDetail!.status == BookingStatusKeys.onGoing)) {
      return CountdownWidget(
        bookingDetailResponse: value,
        key: countDownKey,
      ).paddingSymmetric(horizontal: 16);
    } else {
      return Offstage();
    }
  }

  Widget _buildReasonWidget({required BookingDetailResponse snap}) {
    if ((snap.bookingDetail!.status == BookingStatusKeys.hold ||
            snap.bookingDetail!.status == BookingStatusKeys.cancelled ||
            snap.bookingDetail!.status == BookingStatusKeys.rejected ||
            snap.bookingDetail!.status == BookingStatusKeys.failed) &&
        ((snap.bookingDetail!.reason != null &&
            snap.bookingDetail!.reason!.isNotEmpty))) {
      return Container(
        padding: EdgeInsets.all(16),
        color: redColor.withOpacity(0.05),
        width: context.width(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(languages.lblReason, style: secondaryTextStyle()),
            Text(
              snap.bookingDetail!.reason.validate(),
              style: primaryTextStyle(color: redColor),
            ),
          ],
        ),
      );
    }

    return Offstage();
  }

  Widget _customerReviewWidget({
    required BookingDetailResponse bookingDetailResponse,
  }) {
    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (bookingDetailResponse.ratingData!.isNotEmpty)
              ViewAllLabel(
                label:
                    '${languages.review} (${bookingDetailResponse.bookingDetail!.totalReview})',
                list: bookingDetailResponse.ratingData!,
                onTap: () {
                  RatingViewAllScreen(
                    serviceId: bookingDetailResponse.service!.id!,
                  ).launch(context);
                },
              ),
            8.height,
            ReviewListViewComponent(
              ratings: bookingDetailResponse.ratingData!,
              padding: EdgeInsets.symmetric(vertical: 6),
              physics: NeverScrollableScrollPhysics(),
            ),
          ],
        )
        .paddingSymmetric(horizontal: 16)
        .visible(bookingDetailResponse.service!.totalRating != null);
  }

  Widget buildTimeWidget({required BookingData bookingDetail}) {
    if (bookingDetail.bookingSlot == null) {
      return Text(
        formatDate(bookingDetail.date.validate(), format: DATE_FORMAT_3),
        style: boldTextStyle(size: 12),
      );
    }
    return Text(
      TimeOfDay(
        hour:
            bookingDetail.bookingSlot
                .validate()
                .splitBefore(':')
                .split(":")
                .first
                .toInt(),
        minute:
            bookingDetail.bookingSlot
                .validate()
                .splitBefore(':')
                .split(":")
                .last
                .toInt(),
      ).format(context),
      style: boldTextStyle(size: 12),
    );
  }

  /// Summary and Description Widget
  Widget _summaryAndDescriptionWidget({
    required String title,
    required String? content,
    required BuildContext context,
  }) {
    if (content.validate().isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8),
            Text(title, style: boldTextStyle(size: LABEL_TEXT_SIZE)),
            SizedBox(height: 8),
            ReadMoreText(
              content.validate(),
              style: secondaryTextStyle(),
              colorClickableText: context.primaryColor,
            ),
            SizedBox(height: 8),
          ],
        ),
      );
    } else {
      return const Offstage();
    }
  }

  Widget myServiceList({required List<ServiceData> serviceList}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        24.height,
        Text(
          languages.lblMyService,
          style: boldTextStyle(size: LABEL_TEXT_SIZE),
        ),
        8.height,
        AnimatedListView(
          itemCount: serviceList.length,
          shrinkWrap: true,
          listAnimationType: ListAnimationType.FadeIn,
          itemBuilder: (_, i) {
            ServiceData data = serviceList[i];

            return Container(
              width: context.width(),
              margin: EdgeInsets.symmetric(vertical: 8),
              padding: EdgeInsets.all(8),
              decoration: boxDecorationWithRoundedCorners(
                backgroundColor: context.cardColor,
                borderRadius: BorderRadius.all(Radius.circular(defaultRadius)),
              ),
              child: Row(
                children: [
                  CachedImageWidget(
                    url:
                        data.imageAttachments.validate().isNotEmpty
                            ? data.imageAttachments!.first.validate()
                            : "",
                    fit: BoxFit.cover,
                    height: 50,
                    width: 50,
                    radius: defaultRadius,
                  ),
                  16.width,
                  Text(
                    data.name.validate(),
                    style: primaryTextStyle(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ).expand(),
                ],
              ),
            );
          },
        ),
      ],
    ).paddingSymmetric(horizontal: 16);
  }

  Widget packageWidget({required PackageData package}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          languages.includedInThisPackage,
          style: boldTextStyle(),
        ).paddingSymmetric(horizontal: 16, vertical: 8),
        AnimatedListView(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          listAnimationType: ListAnimationType.FadeIn,
          fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
          itemCount: package.serviceList!.length,
          padding: EdgeInsets.all(8),
          itemBuilder: (_, i) {
            ServiceData data = package.serviceList![i];

            return Container(
              padding: EdgeInsets.all(8),
              margin: EdgeInsets.all(8),
              decoration: boxDecorationWithRoundedCorners(
                borderRadius: radius(),
                backgroundColor: context.cardColor,
                border:
                    appStore.isDarkMode
                        ? Border.all(color: context.dividerColor)
                        : null,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CachedImageWidget(
                    url:
                        data.imageAttachments!.isNotEmpty
                            ? data.imageAttachments!.first.validate()
                            : "",
                    height: 70,
                    width: 70,
                    fit: BoxFit.cover,
                    radius: 8,
                  ),
                  16.width,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.name.validate(),
                        style: boldTextStyle(size: LABEL_TEXT_SIZE),
                      ),
                      4.height,
                      if (data.subCategoryName.validate().isNotEmpty)
                        Marquee(
                          child: Row(
                            children: [
                              Text(
                                '${data.categoryName}',
                                style: boldTextStyle(
                                  color: textSecondaryColorGlobal,
                                ),
                              ),
                              Text(
                                '  >  ',
                                style: boldTextStyle(
                                  color: textSecondaryColorGlobal,
                                ),
                              ),
                              Text(
                                '${data.subCategoryName}',
                                style: boldTextStyle(
                                  color: context.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Text(
                          '${data.categoryName}',
                          style: secondaryTextStyle(),
                        ),
                      4.height,
                      PriceWidget(
                        price: data.price.validate(),
                        hourlyTextColor: Colors.white,
                        size: 16,
                      ),
                    ],
                  ).flexible(),
                ],
              ),
            ).onTap(() {
              ServiceDetailScreen(serviceId: data.id!).launch(context);
            });
          },
        ),
      ],
    );
  }

  Widget _action({required BookingDetailResponse res}) {
    showBottomActionBar = false;
    debugPrint('we are in actions ================================>');
    if (isUserTypeProvider) {
      debugPrint('in user provider ================================>');
      if (res.isMe.validate()) {
        debugPrint('is me handyman ================================>');
        return handleHandyman(res: res);
      } else {
        debugPrint('is me provider ================================>');
        return handleProvider(res: res);
      }
    } else if (isUserTypeHandyman) {
      debugPrint('user handyman ================================>');
      return handleHandyman(res: res);
    }

    return Offstage();
  }

  Widget handleProvider({required BookingDetailResponse res}) {
    debugPrint('handleProvider ================================>');
    if (res.bookingDetail!.status == BookingStatusKeys.pending) {
      debugPrint(
        'handleProvider : with in pending ================================>',
      );
      showBottomActionBar = true;
      return Row(
        children: [
          AppButton(
            text: languages.accept,
            color: context.primaryColor,
            onTap: () async {
              bool? flag = await showConfirmDialogCustom(
                context,
                title: languages.wouldYouLikeToAssignThisBooking,
                primaryColor: primaryColor,
                positiveText: languages.lblYes,
                negativeText: languages.lblNo,
                onAccept: (_) async {
                  var request = {
                    CommonKeys.id: res.bookingDetail!.id.validate(),
                    BookingUpdateKeys.status: BookingStatusKeys.accept,
                    BookingUpdateKeys.paymentStatus:
                        res.bookingDetail!.isAdvancePaymentDone
                            ? SERVICE_PAYMENT_STATUS_ADVANCE_PAID
                            : res.bookingDetail!.paymentStatus.validate(),
                  };
                  appStore.setLoading(true);
                  var response = await bookingUpdate(request);
                  appStore.setLoading(false);
                  LiveStream().emit(LIVESTREAM_UPDATE_BOOKINGS);

                  init(flag: true);

                  return true;
                },
              );
            },
          ).expand(),
          16.width,
          AppButton(
            text: languages.decline,
            textColor: textPrimaryColorGlobal,
            onTap: () {
              confirmationRequestDialog(
                context,
                BookingStatusKeys.rejected,
                res,
              );
            },
          ).expand(),
        ],
      );
    } else if (res.bookingDetail!.status == BookingStatusKeys.accept) {
      debugPrint(
        'handleProvider : with in accept ================================>',
      );
      showBottomActionBar = true;

      if (res.handymanData.validate().isEmpty) {
        return AppButton(
          text: languages.lblAssignHandyman,
          color: context.primaryColor,
          onTap: () {
            assignBookingDialog(
              context,
              res.bookingDetail!.id,
              res.bookingDetail!.bookingAddressId,
            );
          },
        );
      } else {
        return Text(
          '${res.handymanData!.first.displayName.validate()} ${languages.lblAssigned}',
          style: boldTextStyle(),
        ).center();
      }
    } else if (res.bookingDetail?.status == BookingStatusKeys.complete) {
      debugPrint(
        'handleProvider : with in completed ================================>',
      );
      showBottomActionBar = true;
      return AppButton(
        text:
            ((res.bookingDetail?.isInvoiceGenerated ?? 0) == 0)
                ? 'Create Invoice'
                : 'View Invoice',
        color: context.primaryColor,
        onTap: () {
          generateFinalInvoice(res);
        },
      );
    }
    debugPrint('handleProvider : out now ================================>');

    return Offstage();
  }

  Widget handleHandyman({required BookingDetailResponse res}) {
    log(res.bookingDetail!.paymentStatus);
    debugPrint('BookingStatus Now: ${res.bookingDetail!.status}');
    if (res.bookingDetail!.status == BookingStatusKeys.accept) {
      showBottomActionBar = true;

      return Container(
        child: Row(
          children: [
            AppButton(
              text: languages.lblStartDrive,
              color: startDriveButtonColor,
              onTap: () {
                showConfirmDialogCustom(
                  context,
                  title: languages.confirmationRequestTxt,
                  primaryColor: context.primaryColor,
                  positiveText: languages.lblYes,
                  negativeText: languages.lblNo,
                  onAccept: (c) {
                    appStore.setLoading(true);
                    updateBooking(res, '', BookingStatusKeys.inProgress);
                  },
                );
              },
            ).expand(),
            16.width,
            AppButton(
              text: languages.decline,
              textColor: textPrimaryColorGlobal,
              onTap: () {
                showConfirmDialogCustom(
                  context,
                  title: languages.confirmationRequestTxt,
                  positiveText: languages.lblYes,
                  negativeText: languages.lblNo,
                  onAccept: (val) {
                    appStore.setLoading(true);
                    updateBooking(res, '', BookingStatusKeys.pending);
                  },
                  primaryColor: context.primaryColor,
                );
              },
            ).expand(),
          ],
        ),
      );
    } else if (res.bookingDetail!.status == BookingStatusKeys.pendingApproval) {
      showBottomActionBar = true;
      return Container(
        child: Row(
          children: [
            AppButton(
              text: languages.lblCompleted,
              textStyle: boldTextStyle(color: white),
              color: context.primaryColor,
              onTap: () {
                showConfirmDialogCustom(
                  context,
                  onAccept: (_) {
                    _handlePendingApproval(val: res, isAddExtraCharges: false);
                  },
                  primaryColor: context.primaryColor,
                  positiveText: languages.lblYes,
                  negativeText: languages.lblNo,
                  title: languages.confirmationRequestTxt,
                );
              },
            ).expand(),
            if (!res.bookingDetail!.isFreeService &&
                res.bookingDetail!.bookingPackage == null)
              AppButton(
                margin: EdgeInsets.only(left: 16),
                color: addExtraCharge,
                onTap: () async {
                  chargesList.clear();
                  bool? a = await AddExtraChargesScreen().launch(context);

                  if (a ?? false) {
                    _handlePendingApproval(val: res, isAddExtraCharges: true);
                  }
                },
                child:
                    Text(
                      languages.lblAddExtraCharges,
                      style: boldTextStyle(color: Colors.white),
                    ).fit(),
              ).expand(),
          ],
        ),
      );
    } else if (res.bookingDetail!.status == BookingStatusKeys.onGoing) {
      showBottomActionBar = true;

      return Text(
        languages.lblWaitingForResponse,
        style: boldTextStyle(),
      ).center();
    } else if (res.bookingDetail!.status == BookingStatusKeys.complete) {
      if (res.bookingDetail!.paymentMethod == PAYMENT_METHOD_COD &&
          res.bookingDetail!.paymentStatus == PENDING) {
        showBottomActionBar = true;
        return AppButton(
          text: languages.lblConfirmPayment,
          color: context.primaryColor,
          onTap: () {
            confirmationRequestDialog(context, BookingStatusKeys.complete, res);
          },
        );
      } else if (res.bookingDetail!.paymentStatus == PAID ||
          res.bookingDetail!.paymentStatus == PENDING_BY_ADMINS) {
        showBottomActionBar = true;
        return AppButton(
          text: languages.lblServiceProof,
          color: context.primaryColor,
          onTap: () {
            ServiceProofScreen(bookingDetail: res)
                .launch(context, pageRouteAnimation: PageRouteAnimation.Fade)
                .then((value) {
                  init(flag: true);
                });
          },
        );
      } else if (res.isMe.validate() &&
          res.bookingDetail?.status == BookingStatusKeys.complete) {
        debugPrint(
          'handleProvider : with in completed ================================>',
        );
        showBottomActionBar = true;
        return AppButton(
          text:
              ((res.bookingDetail?.isInvoiceGenerated ?? 0) == 0)
                  ? 'Create Invoice'
                  : 'View Invoice',
          color: context.primaryColor,
          onTap: () {
            generateFinalInvoice(res);
          },
        );
      }
    } else if (res.bookingDetail!.status == BookingStatusKeys.inProgress) {
      showBottomActionBar = true;
      return Row(
        children: [
          Expanded(
            child: AppButton(
              text: res.bookingDetail!.statusLabel.validate(),
              textColor: black,
              color: white,
              onTap: () {},
            ),
          ),
          16.width,
          Expanded(
            child: AppButton(
              text: 'Complete',
              color: primaryColor,
              onTap: () {
                _handleDoneClick(status: res);
              },
            ),
          ),
        ],
      );
    }
    return Offstage();
  }

  void generateFinalInvoice(BookingDetailResponse res) async {
    final generated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => FinalInvoiceScreen(
              isViewInvoice:
                  ((res.bookingDetail?.isInvoiceGenerated ?? 0) != 0),
              serviceId: res.bookingDetail?.serviceId ?? 0,
              bookingId: res.bookingDetail?.id ?? 0,
              categoryId: res.bookingDetail?.categoryId ?? 0,
              subCategoryId: res.bookingDetail?.subCategoryId ?? 0,
              customerId: res.bookingDetail?.customerId ?? 0,
            ),
      ),
    );
    if (generated) {
      init(flag: true);
      return await 2.seconds.delay;
    }
  }

  //region Methods
  void commonStartTimer({
    required bool isHourlyService,
    required String status,
    required int timeInSec,
  }) {
    if (isHourlyService) {
      Map<String, dynamic> liveStreamRequest = {
        "inSeconds": timeInSec,
        "status": status,
      };
      LiveStream().emit(LIVESTREAM_START_TIMER, liveStreamRequest);
    }
  }

  //region Done Service
  void _handleDoneClick({required BookingDetailResponse status}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CompleteJobDialogue(
          onComplete: (images, attachments, description) async {
            appStore.setLoading(true);

            await updateBooking(
                  status,
                  '',
                  BookingStatusKeys.complete,
                  images: images,
                  attachments: attachments,
                  description: description,
                )
                .then((res) async {
                  commonStartTimer(
                    isHourlyService: status.bookingDetail!.isHourlyService,
                    status: BookingStatusKeys.complete,
                    timeInSec:
                        status.bookingDetail!.durationDiff.validate().toInt(),
                  );

                  appStore.setLoading(false);
                  init();
                  setState(() {});
                })
                .catchError((e) {
                  appStore.setLoading(false);
                  toast(e.toString(), print: true);
                });
          },
          onCancel: () {
            // Handle cancel action
          },
        );
      },
    );
  }

  Widget extraChargesWidget({
    required List<ExtraChargesModel> extraChargesList,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        16.height,
        Text(
          languages.lblExtraCharges,
          style: boldTextStyle(size: LABEL_TEXT_SIZE),
        ),
        16.height,
        Container(
          decoration: boxDecorationWithRoundedCorners(
            backgroundColor: context.cardColor,
            borderRadius: radius(),
          ),
          padding: EdgeInsets.all(16),
          child: AnimatedListView(
            itemCount: extraChargesList.length,
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            listAnimationType: ListAnimationType.FadeIn,
            fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (_, i) {
              ExtraChargesModel data = extraChargesList[i];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        data.title.validate(),
                        style: secondaryTextStyle(size: 14),
                      ).expand(),
                      16.width,
                      Row(
                        children: [
                          Text(
                            '${data.qty} * ${data.price.validate()} = ',
                            style: secondaryTextStyle(),
                          ),
                          4.width,
                          PriceWidget(
                            price:
                                '${data.price.validate() * data.qty.validate()}'
                                    .toDouble(),
                            size: 16,
                            color: textPrimaryColorGlobal,
                            isBoldText: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                  8.height,
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  //region Body
  Widget buildBodyWidget(AsyncSnapshot<BookingDetailResponse> res) {
    if (res.hasError) {
      return NoDataWidget(
        title: res.error.toString(),
        imageWidget: ErrorStateWidget(),
        retryText: languages.reload,
        onRetry: () {
          appStore.setLoading(true);

          init();
          setState(() {});
        },
      );
    } else if (res.hasData) {
      countDownKey = GlobalKey();
      return Stack(
        fit: StackFit.expand,
        children: [
          Stack(
            children: [
              AnimatedScrollView(
                padding: EdgeInsets.only(bottom: 100),
                physics: AlwaysScrollableScrollPhysics(),
                listAnimationType: ListAnimationType.FadeIn,
                fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Show Reason if booking is canceled
                  _buildReasonWidget(snap: res.data!),

                  /// Booking & Service Details
                  _requestStatusWidget(res),

                  Divider(height: 0, color: context.dividerColor),
                  8.height,

                  /// Total Service Time
                  _buildCounterWidget(value: res.data!),

                  /// Summary Widget
                  _summaryAndDescriptionWidget(
                    title: 'Summary',
                    content: res.data!.bookingDetail!.summary,
                    context: context,
                  ),

                  /// Description Widget
                  _summaryAndDescriptionWidget(
                    title: 'Comments',
                    content: res.data!.bookingDetail!.description,
                    context: context,
                  ),

                  /// My Service List
                  if (res.data!.postRequestDetail != null &&
                      res.data!.postRequestDetail!.service != null)
                    myServiceList(
                      serviceList: res.data!.postRequestDetail!.service!,
                    ),

                  /// Package Info if User selected any Package
                  if (res.data!.bookingDetail!.bookingPackage != null)
                    packageWidget(
                      package: res.data!.bookingDetail!.bookingPackage!,
                    ),

                  /// Service Proof Images
                  ServiceProofListWidget(
                    serviceProofList: res.data!.serviceProof!,
                  ),

                  if ((res.data?.bookingDetail?.attachments != null &&
                      res.data!.bookingDetail!.attachments!.isNotEmpty))
                    Text(
                      'Attachments',
                      style: boldTextStyle(
                        size: LABEL_TEXT_SIZE,
                        color: appStore.isDarkMode ? white : black,
                      ),
                    ).paddingOnly(left: 16, right: 16),

                  if ((res.data?.bookingDetail?.attachments != null &&
                      res.data!.bookingDetail!.attachments!.isNotEmpty))
                    10.height,
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: res.data?.bookingDetail?.attachments?.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          if (res.data?.bookingDetail?.attachments?[index] !=
                              null) {
                            ZoomImageScreen(
                              galleryImages: [
                                res.data?.bookingDetail?.attachments?[index] ??
                                    'https://picsum.photos/200',
                              ],
                              index: 0,
                            ).launch(context);
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            child: CachedImageWidget(
                              url:
                                  res
                                      .data
                                      ?.bookingDetail
                                      ?.attachments?[index] ??
                                  '',
                              height: context.height(),
                              fit: BoxFit.cover,
                              placeHolderImage: 'assets/ic_launcher.png',
                            ),
                          ),
                        ),
                      );
                    },
                  ).paddingOnly(left: 16, right: 16, bottom: 16),

                  // Line Items
                  if (res.data!.bookingDetail!.status ==
                      BookingStatusKeys.inProgress)
                    Visibility(
                      visible: false,
                      child: LineItemsModule(
                        bookingId: res.data!.bookingDetail!.id.toString(),
                        customerId:
                            res.data!.bookingDetail!.customerId!.toString(),
                        serviceId:
                            res.data!.bookingDetail!.serviceId!.toString(),
                        categoryId:
                            res.data?.bookingDetail?.categoryId
                                ?.validate()
                                .toString(),
                        subCategoryId:
                            res.data?.bookingDetail?.subCategoryId
                                ?.validate()
                                .toString(),
                      ),
                    ),

                  /// About Handyman Card
                  if (res.data!.handymanData!.isNotEmpty &&
                      appStore.userType != USER_TYPE_HANDYMAN)
                    _aboutTechnicianCard(res),

                  /// About Customer Card
                  _aboutCustomerCard(res),

                  /// Customer Review Widget
                  if (res.data!.ratingData.validate().isNotEmpty)
                    _customerReviewWidget(bookingDetailResponse: res.data!),
                ],
              ),
              // Buttons
              Positioned(
                bottom: 0,
                child: Container(
                  width: context.width(),
                  decoration: BoxDecoration(color: context.cardColor),
                  padding:
                      showBottomActionBar
                          ? EdgeInsets.all(16)
                          : EdgeInsets.zero,
                  child: _action(res: res.data!),
                ),
              ),
            ],
          ),
          Observer(
            builder: (context) => LoaderWidget().visible(appStore.isLoading),
          ),
        ],
      );
    }
    return BookingDetailShimmer();
  }

  Padding _aboutTechnicianCard(AsyncSnapshot<BookingDetailResponse> res) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        24.height,
        Text(
          languages.lblAboutHandyman,
          style: boldTextStyle(size: LABEL_TEXT_SIZE),
        ),
        16.height,
        Container(
          decoration: boxDecorationWithRoundedCorners(
            backgroundColor: context.cardColor,
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          padding: EdgeInsets.all(16),
          child: Column(
            children:
                res.data!.handymanData!.map((e) {
                  return BasicInfoComponent(
                    1,
                    handymanData: e,
                    service: res.data!.service,
                    onEditingHandyman: (value) {
                      if (value) {
                        assignBookingDialog(
                          context,
                          res.data?.bookingDetail?.id,
                          res.data?.bookingDetail?.bookingAddressId,
                        );
                      }
                      setState(() {});
                    },
                    bookingDetail: res.data!.bookingDetail!,
                    isTechnician: true,
                  ).paddingOnly(bottom: 24).onTap(() {
                    if (res.data!.bookingDetail!.canCustomerContact) {
                      HandymanInfoScreen(
                        handymanId: e.id,
                        service: res.data!.service,
                      ).launch(context).then((value) => null);
                    }
                  });
                }).toList(),
          ),
        ),
      ],
    ).paddingOnly(left: 16, right: 16);
  }

  Padding _aboutCustomerCard(AsyncSnapshot<BookingDetailResponse> res) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        16.height,
        // if(res.data!.bookingDetail!.canCustomerContact)
        aboutCustomerWidget(
          context: context,
          bookingDetail: res.data!.bookingDetail,
        ),
        16.height,
        Container(
          decoration: boxDecorationWithRoundedCorners(
            backgroundColor: context.cardColor,
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BasicInfoComponent(
                0,
                customerData: res.data!.customer,
                service: res.data!.service,
                bookingDetail: res.data!.bookingDetail,
              ),
            ],
          ),
        ),
      ],
    ).paddingOnly(left: 16, right: 16, bottom: 16);
  }

  Padding _requestStatusWidget(AsyncSnapshot<BookingDetailResponse> res) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        8.height,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              languages.lblBookingID,
              style: boldTextStyle(
                size: LABEL_TEXT_SIZE,
                color: appStore.isDarkMode ? white : gray.withOpacity(0.8),
              ),
            ),
            Text(
              '#${res.data!.bookingDetail!.id.toString().validate()}',
              style: boldTextStyle(color: primaryColor, size: 16),
            ),
          ],
        ),
        8.height,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Status',
              style: boldTextStyle(
                size: LABEL_TEXT_SIZE,
                color: appStore.isDarkMode ? white : gray.withOpacity(0.8),
              ),
            ),
            Text(
              res.hasData
                  ? res.data!.bookingDetail!.status
                              .validate()
                              .toBookingStatus() ==
                          'Hold'
                      ? 'On Hold'
                      : res.data!.bookingDetail!.status
                          .validate()
                          .toBookingStatus()
                  : "",
              style: boldTextStyle(color: primaryColor, size: 16),
            ),
          ],
        ),
        16.height,
        Divider(height: 0, color: context.dividerColor),
        12.height,
        _serviceDetailWidget(
          serviceDetail: res.data!.service!,
          bookingDetail: res.data!.bookingDetail!,
        ),
      ],
    ).paddingAll(16);
  }

  //endregion

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<BookingDetailResponse>(
      future: future,
      initialData: initialData(),
      builder: (context, snap) {
        return RefreshIndicator(
          onRefresh: () async {
            init(flag: true);
            return await 2.seconds.delay;
          },
          child: AppScaffold(
            appBarTitle:
                snap.hasData
                    ? snap.data != null
                        ? snap.data?.bookingDetail?.serviceName.validate()
                        : ''
                    : '',
            actions: [
              if (snap.hasData)
                TextButton(
                  onPressed: () {
                    showModalBottomSheet(
                      backgroundColor: Colors.transparent,
                      context: context,
                      isScrollControlled: true,
                      isDismissible: true,
                      shape: RoundedRectangleBorder(
                        borderRadius: radiusOnly(
                          topLeft: defaultRadius,
                          topRight: defaultRadius,
                        ),
                      ),
                      builder: (_) {
                        return DraggableScrollableSheet(
                          initialChildSize: 0.50,
                          minChildSize: 0.2,
                          maxChildSize: 1,
                          builder:
                              (context, scrollController) =>
                                  BookingHistoryBottomSheet(
                                    data:
                                        snap.data!.bookingActivity!.reversed
                                            .toList(),
                                    scrollController: scrollController,
                                  ),
                        );
                      },
                    );
                  },
                  child: Text(
                    languages.lblCheckStatus,
                    style: boldTextStyle(color: white),
                  ),
                ).paddingRight(8),
            ],
            body: buildBodyWidget(snap),
          ),
        );
      },
    );
  }
}
