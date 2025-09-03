import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:trade/app_theme.dart';
import 'package:trade/components/app_widgets.dart';
import 'package:trade/components/booking_item_component.dart';
import 'package:trade/components/booking_status_dropdown.dart';
import 'package:trade/fragments/shimmer/booking_shimmer.dart';
import 'package:trade/main.dart';
import 'package:trade/models/booking_list_response.dart';
import 'package:trade/models/booking_status_response.dart';
import 'package:trade/networks/rest_apis.dart';
import 'package:trade/utils/common.dart';
import 'package:trade/utils/configs.dart';
import 'package:trade/utils/constant.dart';
import 'package:trade/utils/extensions/string_extension.dart';
import 'package:trade/utils/images.dart';
import 'package:trade/utils/model_keys.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';

import '../components/empty_error_state_widget.dart';
import '../models/sample_area_name_response.dart';

// ignore: must_be_immutable
class BookingFragment extends StatefulWidget {
  String? statusType;
  bool isRequests;
  String? redirectedStatus;

  BookingFragment(
      {super.key, this.statusType, required this.isRequests, this.redirectedStatus});

  @override
  BookingFragmentState createState() => BookingFragmentState();
}

class BookingFragmentState extends State<BookingFragment>
    with SingleTickerProviderStateMixin {
  ScrollController scrollController = ScrollController();

  int page = 1;
  int inspectionPage = 1;
  List<BookingData> bookings = [];
  List<BookingData> inspectionBookings = [];

  String selectedValue = BOOKING_PAYMENT_STATUS_ALL;
  bool isLastPage = false;
  bool isLastPageInspection = false;
  bool hasError = false;
  bool isApiCalled = false;

  Future<List<BookingData>>? future;
  Future<List<BookingData>>? inspactionFuture;
  UniqueKey keyForStatus = UniqueKey();

  @override
  void initState() {
    super.initState();

    if (isUserTypeHandyman) {
      LiveStream().on(LIVESTREAM_HANDY_BOARD, (index) {
        if (index is Map && index["index"] == 1) {
          selectedValue = BookingStatusKeys.accept;
          fetchAllBookingList();
          fetchInspectionList();
          setState(() {});
        }
      });

      LiveStream().on(LIVESTREAM_HANDYMAN_ALL_BOOKING, (index) {
        if (index == 1) {
          selectedValue = '';
          fetchAllBookingList();
          fetchInspectionList();
          setState(() {});
        }
      });

      // LiveStream().on(LIVESTREAM_UPDATE_BOOKINGS, (p0) {
      //   page = 1;
      //   fetchAllBookingList();
      //   fetchInspectionList();
      //   setState(() {});
      // });
    }

    init();
  }

  void updateBookings() {
    page = 1;
    fetchAllBookingList();
    fetchInspectionList();
    setState(() {});
  }

  void init() async {
    appStore.setLoading(false);
    if (widget.statusType.validate().isNotEmpty) {
      selectedValue = widget.statusType.validate();
    }

    if (widget.isRequests) {
      fetchAllBookingList(
        loading: true,
      );
    } else {
      fetchInspectionList(loading: true);
    }
  }

  Future<void> _showDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Filter',
            style: primaryTextStyle(color: black, size: 20),
          ),
          content: FilterDialogWidget(
            selectedValue: selectedValue,
            keyForStatus: keyForStatus,
            onFilterApplied: (p0) {
              if (widget.isRequests) {
                setState(() {
                  page = 1;
                  appStore.setLoading(true);

                  selectedValue =
                      p0.value.validate(value: BOOKING_PAYMENT_STATUS_ALL);
                  fetchAllBookingList(loading: true);

                  if (bookings.isNotEmpty) {
                    scrollController.animateTo(0,
                        duration: 1.seconds, curve: Curves.easeOutQuart);
                  } else {
                    scrollController = ScrollController();
                  }
                });
              } else {
                setState(() {
                  page = 1;
                  appStore.setLoading(true);

                  selectedValue =
                      p0.value.validate(value: BOOKING_PAYMENT_STATUS_ALL);
                  fetchInspectionList(loading: true);

                  if (bookings.isNotEmpty) {
                    scrollController.animateTo(0,
                        duration: 1.seconds, curve: Curves.easeOutQuart);
                  } else {
                    scrollController = ScrollController();
                  }
                });
              }
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Okay'),
            ),
          ],
        );
      },
    );
  }

  Future<void> fetchAllBookingList({bool loading = true}) async {
    appStore.setLoading(loading);
    future = getBookingList(page,
        status: widget.redirectedStatus ?? selectedValue,
        bookings: bookings, lastPageCallback: (b) {
      isLastPage = b;
    });
    appStore.setLoading(false);
    setState(() {});
  }

  Future<void> fetchInspectionList({bool loading = true}) async {
    appStore.setLoading(loading);
    var request = {'customer_id': appStore.uid};
    inspactionFuture = getInspectionList(inspectionPage, request,
        status: selectedValue,
        bookings: inspectionBookings, lastPageCallback: (b) {
      isLastPageInspection = b;
    });
    appStore.setLoading(false);
    setState(() {});
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    LiveStream().dispose(LIVESTREAM_UPDATE_BOOKINGS);
    LiveStream().dispose(LIVESTREAM_HANDY_BOARD);
    // LiveStream().dispose(LIVESTREAM_HANDYMAN_ALL_BOOKING);
    // LiveStream().dispose(LIVESTREAM_HANDY_BOARD);
    super.dispose();
  }

  Timer? _debounce;
  onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 700), () {
      if (query.isNotEmpty) {
        future = fetchBookingList(
            page: page,
            key: query,
            bookings: bookings,
            lastPageCallback: (b) {
              isLastPage = b;
            });
      } else {
        fetchAllBookingList(
          loading: true,
        );
      }
      setState(() {});
    });
  }

  Widget servicesWidget() {
    return Stack(
      children: [
        SnapHelperWidget<List<BookingData>>(
          initialData: cachedBookingList,
          future: future,
          loadingWidget: BookingShimmer(),
          onSuccess: (list) {
            if (isUserTypeProvider) {
              // Sort the list based on the date in descending order
              list.sort((a, b) => DateTime.parse(b.date ?? '')
                  .compareTo(DateTime.parse(a.date ?? '')));
            }
            return AnimatedListView(
              controller: scrollController,
              onSwipeRefresh: () async {
                page = 1;
                await fetchAllBookingList(loading: true);
                setState(() {});
                return await 1.seconds.delay;
              },
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              listAnimationType: ListAnimationType.FadeIn,
              fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
              itemCount: list.length,
              shrinkWrap: true,
              physics: AlwaysScrollableScrollPhysics(),
              emptyWidget: NoDataWidget(
                title: languages.noBookingTitle,
                subTitle: languages.noBookingSubTitle,
                imageWidget: EmptyStateWidget(),
              ),
              itemBuilder: (_, index) => BookingItemComponent(
                  bookingData: list[index],
                  index: index,
                  onUpdate: updateBookings),
              //disposeScrollController: false,
              onNextPage: () {
                if (!isLastPage) {
                  page++;
                  appStore.setLoading(true);

                  fetchAllBookingList();
                  setState(() {});
                }
              },
            ).paddingOnly(left: 0, right: 0, bottom: 0, top: 76);
          },
          errorBuilder: (error) {
            return NoDataWidget(
              title: error,
              retryText: languages.reload,
              imageWidget: ErrorStateWidget(),
              onRetry: () {
                keyForStatus = UniqueKey();
                appStore.setLoading(true);
                page = 1;

                fetchAllBookingList();
                setState(() {});
              },
            );
          },
        ),
        Positioned(
          left: 16,
          right: 16,
          top: 16,
          child: BookingStatusDropdown(
            isValidate: false,
            statusType: selectedValue,
            key: keyForStatus,
            onValueChanged: (BookingStatusResponse value) {
              page = 1;
              appStore.setLoading(true);

              selectedValue =
                  value.value.validate(value: BOOKING_PAYMENT_STATUS_ALL);
              fetchAllBookingList(loading: true);
              setState(() {});

              if (bookings.isNotEmpty) {
                scrollController.animateTo(0,
                    duration: 1.seconds, curve: Curves.easeOutQuart);
              } else {
                scrollController = ScrollController();
              }
            },
          ),
        ),
        Observer(builder: (_) => LoaderWidget().visible(appStore.isLoading)),
      ],
    );
  }

  Widget inspectionWidget() {
    return Stack(
      children: [
        SnapHelperWidget<List<BookingData>>(
          initialData: cachedBookingListInspection,
          future: inspactionFuture,
          loadingWidget: BookingShimmer(),
          onSuccess: (inspectionList) {
            return AnimatedListView(
              controller: scrollController,
              onSwipeRefresh: () async {
                inspectionPage = 1;
                await fetchInspectionList(loading: true);
                setState(() {});
                return await 1.seconds.delay;
              },
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              listAnimationType: ListAnimationType.FadeIn,
              fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
              itemCount: inspectionList.length,
              shrinkWrap: true,
              physics: AlwaysScrollableScrollPhysics(),
              emptyWidget: NoDataWidget(
                title: languages.noBookingTitle,
                subTitle: languages.noBookingSubTitle,
                imageWidget: EmptyStateWidget(),
              ),
              itemBuilder: (_, index) => BookingItemComponent(
                  bookingData: inspectionList[index],
                  index: index,
                  inspection: true),
              //disposeScrollController: false,
              onNextPage: () {
                if (!isLastPageInspection) {
                  inspectionPage++;
                  appStore.setLoading(true);

                  fetchInspectionList();
                  setState(() {});
                }
              },
            ).paddingOnly(left: 0, right: 0, bottom: 0, top: 10);
          },
          errorBuilder: (error) {
            return NoDataWidget(
              title: error,
              retryText: languages.reload,
              imageWidget: ErrorStateWidget(),
              onRetry: () {
                keyForStatus = UniqueKey();
                appStore.setLoading(true);
                inspectionPage = 1;

                fetchInspectionList();
                setState(() {});
              },
            );
          },
        ).paddingOnly(top: 66),
        Positioned(
          left: 16,
          right: 16,
          top: 16,
          child: BookingStatusDropdown(
            isValidate: false,
            statusType: selectedValue,
            key: keyForStatus,
            onValueChanged: (BookingStatusResponse value) {
              page = 1;
              appStore.setLoading(true);

              selectedValue =
                  value.value.validate(value: BOOKING_PAYMENT_STATUS_ALL);
              fetchInspectionList(loading: true);
              setState(() {});

              if (bookings.isNotEmpty) {
                scrollController.animateTo(0,
                    duration: 1.seconds, curve: Curves.easeOutQuart);
              } else {
                scrollController = ScrollController();
              }
            },
          ),
          // Row(
          //   children: [
          //     Expanded(
          //       child: AppTextField(
          //         textFieldType: TextFieldType.NAME,
          //         isValidationRequired: false,
          //         decoration: inputDecoration(context,
          //             hint: 'Search Inspections', islabelText: false),
          //       ),
          //     ),
          //     8.width,
          //     Container(
          //       width: 45.0,
          //       height: 45.0,
          //       decoration: BoxDecoration(
          //         color: selectedValue == BOOKING_PAYMENT_STATUS_ALL
          //             ? cardColor
          //             : primaryColor,
          //         borderRadius: BorderRadius.circular(8.0),
          //       ),
          //       child: Icon(
          //         Icons.filter_list,
          //         color: selectedValue == BOOKING_PAYMENT_STATUS_ALL
          //             ? black
          //             : white,
          //       ),
          //     ).onTap(() {
          //       _showDialog(context);
          //     }),
          //   ],
          // ),
        ),
        Observer(builder: (_) => LoaderWidget().visible(appStore.isLoading)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return isUserTypeHandyman
        ? servicesWidget()
        : widget.isRequests
            ? servicesWidget()
            : inspectionWidget();
  }
}

class FilterDialogWidget extends StatefulWidget {
  final Function(BookingStatusResponse) onFilterApplied;
  final String selectedValue;
  final UniqueKey keyForStatus;

  const FilterDialogWidget(
      {super.key,
      required this.onFilterApplied,
      required this.selectedValue,
      required this.keyForStatus});

  @override
  State<FilterDialogWidget> createState() => _FilterDialogWidgetState();
}

class _FilterDialogWidgetState extends State<FilterDialogWidget> {
  SampleAreaNameResponse? selectedArea;
  int? selectedAreaId;
  List<SampleAreaNameResponse> areaNameList = [
    SampleAreaNameResponse(
      name: 'Abhishek Mishra',
      id: 1,
    ),
    SampleAreaNameResponse(
      name: 'Vijay',
      id: 2,
    ),
    SampleAreaNameResponse(
      name: 'Rohit Sharma',
      id: 3,
    ),
    SampleAreaNameResponse(
      name: 'Aman Chaudhary',
      id: 4,
    ),
  ];

  TextEditingController dateTimeCont1 = TextEditingController();
  TextEditingController dateTimeCont2 = TextEditingController();
  DateTime currentDateTime = DateTime.now();
  DateTime? selectedDate;
  DateTime? finalDate;

  void selectDateAndTime(BuildContext context, {bool from = false}) async {
    await showDatePicker(
      context: context,
      initialDate: selectedDate ?? currentDateTime,
      firstDate: selectedDate ?? currentDateTime,
      lastDate: currentDateTime.add(30.days),
      locale: Locale(appStore.selectedLanguageCode),
      cancelText: languages.lblCancel,
      confirmText: languages.lblOk,
      helpText: 'Select Date',
      builder: (_, child) {
        return Theme(
          data: appStore.isDarkMode ? ThemeData.dark() : AppTheme.lightTheme,
          child: child!,
        );
      },
    ).then((date) async {
      if (date != null) {
        if (from) {
          selectedDate = date;
          dateTimeCont1.text = DateFormat('dd-MMM-yyyy').format(date);
        } else {
          if (date.isAfter(selectedDate!)) {
            dateTimeCont2.text = DateFormat('dd-MMM-yyyy').format(date);
          } else {
            toast('Should not be before From Date.',
                bgColor: redColor.withOpacity(0.6), textColor: white);
          }
        }
        setState(() {});
      }
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: context.width() * 1,
      height: context.height() * 0.5,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status:',
              style: primaryTextStyle(color: black, size: 14),
            ),
            10.height,
            BookingStatusDropdown(
              isValidate: false,
              statusType: widget.selectedValue,
              key: widget.keyForStatus,
              onValueChanged: (BookingStatusResponse value) {
                // widget.onFilterApplied(value);
                // appStore.setLoading(true);
              },
            ),
            16.height,
            Text(
              'HomeOwner:',
              style: primaryTextStyle(color: black, size: 14),
            ),
            10.height,
            DropdownButtonFormField<SampleAreaNameResponse>(
              decoration: inputDecoration(context,
                  hint: 'All Home-Owner', islabelText: false),
              style: primaryTextStyle(color: primaryColor),
              isExpanded: true,
              dropdownColor: context.cardColor,
              menuMaxHeight: 300,
              value: selectedArea,
              items: areaNameList.map((SampleAreaNameResponse e) {
                return DropdownMenuItem<SampleAreaNameResponse>(
                  value: e,
                  child: Text(e.name ?? '',
                      style: primaryTextStyle(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                );
              }).toList(),
              onChanged: (SampleAreaNameResponse? value) async {
                selectedAreaId = value?.id ?? 0;
                setState(() {});
              },
            ),
            16.height,
            Text(
              'From',
              style: primaryTextStyle(color: black, size: 14),
            ),
            10.height,
            AppTextField(
              textFieldType: TextFieldType.OTHER,
              controller: dateTimeCont1,
              isValidationRequired: true,
              validator: (value) {
                if (value!.isEmpty) return 'Required Text';
                return null;
              },
              readOnly: true,
              onTap: () {
                selectDateAndTime(context, from: true);
              },
              decoration: inputDecoration(context,
                      prefixIcon:
                          ic_calendar.iconImage(size: 10).paddingAll(14))
                  .copyWith(
                fillColor: context.scaffoldBackgroundColor,
                filled: true,
                hintText: 'Choose Date',
                hintStyle: secondaryTextStyle(),
              ),
            ),
            16.height,
            Text(
              'To',
              style: primaryTextStyle(color: black, size: 14),
            ),
            10.height,
            AppTextField(
              textFieldType: TextFieldType.OTHER,
              controller: dateTimeCont2,
              isValidationRequired: true,
              validator: (value) {
                if (value!.isEmpty) return 'Required Text';
                return null;
              },
              readOnly: true,
              onTap: () {
                if (dateTimeCont1.text.isEmpty) {
                  toast('Choose From Date.',
                      bgColor: redColor.withOpacity(0.6), textColor: white);
                } else {
                  selectDateAndTime(context);
                }
              },
              decoration: inputDecoration(context,
                      prefixIcon:
                          ic_calendar.iconImage(size: 10).paddingAll(14))
                  .copyWith(
                fillColor: context.scaffoldBackgroundColor,
                filled: true,
                hintText: 'Choose Date',
                hintStyle: secondaryTextStyle(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
