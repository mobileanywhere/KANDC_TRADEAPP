import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:trade/app_theme.dart';
import 'package:trade/components/app_widgets.dart';
import 'package:trade/components/back_widget.dart';
import 'package:trade/components/custom_image_picker.dart';
import 'package:trade/main.dart';
import 'package:trade/models/attachment_model.dart';
import 'package:trade/models/booking_detail_response.dart';
import 'package:trade/provider/fragments/confirm_booking_dialog.dart';
import 'package:trade/provider/fragments/search_technician_widget.dart';
import 'package:trade/provider/services/components/category_sub_cat_drop_down.dart';
import 'package:trade/utils/colors.dart';
import 'package:trade/utils/common.dart';
import 'package:trade/utils/configs.dart';
import 'package:trade/utils/constant.dart';
import 'package:trade/utils/extensions/string_extension.dart';
import 'package:trade/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

class CreateServiceRequest extends StatefulWidget {
  final String? customerId;
  final String? customerName;
  final String? customerAddress;
  const CreateServiceRequest(
      {this.customerId, this.customerName, this.customerAddress, super.key});

  @override
  State<CreateServiceRequest> createState() => _CreateServiceRequestState();
}

class _CreateServiceRequestState extends State<CreateServiceRequest> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  FocusNode focusNodeSelectedMainCategory = FocusNode();
  FocusNode focusNodeSelectedMainSubCategory = FocusNode();

  TextEditingController descriptionCont = TextEditingController();
  TextEditingController dateTimeCont = TextEditingController();

  DateTime currentDateTime = DateTime.now();
  DateTime? selectedDate;
  DateTime? finalDate;
  TimeOfDay? pickedTime;
  bool isButtonClicked = false;
  bool isNowButtonClicked = true;

  num advancePaymentAmount = 0;
  CouponData? appliedCouponData;
  int itemCount = 1;

  UniqueKey uniqueKey = UniqueKey();

  List<File> imageFiles = [];
  List<Attachments> tempAttachments = [];

  bool isUpdate = false;

  @override
  void initState() {
    super.initState();
    // getHandyman(providerId: appStore.userId, list: technicianList, page: 1)
    //     .then((value) {
    //   technicianList = value;
    //   setState(() {});
    // });
    init();
  }

  init() async {
    setCurrentDateWithAdditional2Hours();
  }

  void selectDateAndTime(BuildContext context) async {
    await showDatePicker(
      context: context,
      initialDate: selectedDate ?? currentDateTime,
      firstDate: currentDateTime,
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
        await showTimePicker(
          context: context,
          initialTime: pickedTime ?? TimeOfDay.now(),
          cancelText: languages.lblCancel,
          confirmText: languages.lblOk,
          builder: (_, child) {
            return Theme(
              data:
                  appStore.isDarkMode ? ThemeData.dark() : AppTheme.lightTheme,
              child: child!,
            );
          },
        ).then((time) {
          if (time != null) {
            finalDate = DateTime(
                date.year, date.month, date.day, time.hour, time.minute);

            DateTime now = DateTime.now().subtract(1.minutes);
            if (date.isToday &&
                finalDate!.millisecondsSinceEpoch <
                    now.millisecondsSinceEpoch) {
              return toast('Select other booking time.');
            }

            selectedDate = date;
            pickedTime = time;
            dateTimeCont.text =
                "${formatDate(selectedDate.toString(), format: DATE_FORMAT_3)} ${pickedTime!.format(context).toString()}";

            setState(() {
              isNowButtonClicked = false;
              isButtonClicked = true;
            });
          }
        }).catchError((e) {
          toast(e.toString());
        });
      }
    });
  }

  void setCurrentDateWithAdditional2Hours() {
    final DateTime newDateTime = currentDateTime.add(Duration(hours: 2));

    selectedDate = newDateTime;
    pickedTime = TimeOfDay.fromDateTime(newDateTime);
    finalDate = newDateTime;

    dateTimeCont.text =
        "${formatDate(selectedDate.toString(), format: DATE_FORMAT_3)} ${pickedTime!.format(context).toString()}";
    setState(() {});
  }

  int? selectedMainServiceId = -1;
  int? selectedSubcategoryId = -1;
  int? selectedServiceSubcategoryId = -1;
  int? selectedServiceId = -1;
  int? onSelectService = -1;

  // UserData? selectedTechnician;
  int? selectedTechnicianId;
  // List<UserData> technicianList = [];

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: appBarWidget(
        'Create Service Request',
        textColor: white,
        elevation: 0.0,
        color: context.primaryColor,
        backWidget: BackWidget(),
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Stack(
          fit: StackFit.expand,
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 24, right: 16, left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.customerName != null)
                    Column(
                      children: [
                        16.height,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Request For :',
                              style: boldTextStyle(
                                  size: LABEL_TEXT_SIZE,
                                  color: appStore.isDarkMode
                                      ? white
                                      : gray.withOpacity(0.8)),
                            ),
                            Text(widget.customerName.validate(),
                                style: boldTextStyle(
                                    color: primaryColor, size: 16)),
                          ],
                        ),
                        16.height,
                        Divider(height: 0, color: context.dividerColor),
                      ],
                    ),
                  widget.customerName != null ? 16.height : 8.height,
                  Text('Enter Detail Information',
                      style: boldTextStyle(size: 14)),
                  20.height,
                  // DropdownButtonFormField<SampleAreaNameResponse>(
                  //   decoration:
                  //       inputDecoration(context, hint: 'Select Category'),
                  //   style: primaryTextStyle(color: primaryColor),
                  //   isExpanded: true,
                  //   dropdownColor: context.cardColor,
                  //   menuMaxHeight: 300,
                  //   value: selectedMainService,
                  //   focusNode: focusNodeSelectedMainCategory,
                  //   items: mainServiceList.map((SampleAreaNameResponse e) {
                  //     return DropdownMenuItem<SampleAreaNameResponse>(
                  //       value: e,
                  //       child: Text(e.name ?? '',
                  //           style: primaryTextStyle(),
                  //           maxLines: 1,
                  //           overflow: TextOverflow.ellipsis),
                  //     );
                  //   }).toList(),
                  //   onChanged: (SampleAreaNameResponse? value) async {
                  //     selectedMainServiceId = value?.id ?? 0;
                  //     setState(() {});
                  //   },
                  //   validator: (value) {
                  //     if (value == null) {
                  //       return 'This field is required.';
                  //     }
                  //     return null;
                  //   },
                  // ),
                  // 16.height,
                  // DropdownButtonFormField<SampleAreaNameResponse>(
                  //   decoration:
                  //       inputDecoration(context, hint: 'Select Sub-Category'),
                  //   style: primaryTextStyle(color: primaryColor),
                  //   isExpanded: true,
                  //   dropdownColor: context.cardColor,
                  //   menuMaxHeight: 300,
                  //   value: selectedSubCategory,
                  //   focusNode: focusNodeSelectedMainSubCategory,
                  //   items: subCategoryList.map((SampleAreaNameResponse e) {
                  //     return DropdownMenuItem<SampleAreaNameResponse>(
                  //       value: e,
                  //       child: Text(e.name ?? '',
                  //           style: primaryTextStyle(),
                  //           maxLines: 1,
                  //           overflow: TextOverflow.ellipsis),
                  //     );
                  //   }).toList(),
                  //   onChanged: (SampleAreaNameResponse? value) async {
                  //     selectedSubcategoryId = value?.id ?? 0;
                  //     setState(() {});
                  //   },
                  //   validator: (value) {
                  //     if (value == null) {
                  //       return 'This field is required.';
                  //     }
                  //     return null;
                  //   },
                  // ),
                  // 16.height,
                  CategorySubCatDropDown(
                    hintCategory: 'Select Service Category',
                    hintSubCategory: 'Select Service Sub Category',
                    hintService: 'Select Service',
                    hintMainType: 'Select Category',
                    hintMainSubType: 'Select Sub-Category',
                    fillColor: cardColor,
                    isServiceValidate: true,
                    isCategoryValidate: true,
                    isSubCategoryValidate: true,
                    isMainTypeValidate: true,
                    isMainSubTypeValidate: true,
                    categoryId: selectedServiceSubcategoryId == -1
                        ? null
                        : selectedServiceSubcategoryId,
                    subCategoryId:
                        selectedServiceId == -1 ? null : selectedServiceId,
                    mainTypeId: selectedMainServiceId == -1
                        ? null
                        : selectedMainServiceId,
                    mainSubTypeId: selectedSubcategoryId == -1
                        ? null
                        : selectedSubcategoryId,
                    onCategorySelect: (int? val) {
                      selectedServiceSubcategoryId = val!;
                      setState(() {});
                    },
                    onSubCategorySelect: (int? val) {
                      selectedServiceId = val!;
                      setState(() {});
                    },
                    onServiceSelect: (val) {
                      onSelectService = val;
                      setState(() {});
                    },
                    onMainTypeSelect: (val) {
                      selectedMainServiceId = val;
                      setState(() {});
                    },
                    onMainSubTypeSelect: (val) {
                      selectedSubcategoryId = val;
                      setState(() {});
                    },
                  ),
                  SearchTechnicianWidget(
                    onSelectingTechnician: (userData) {
                      selectedTechnicianId = userData.id;
                      setState(() {});
                    },
                  ),
                  16.height,
                  Container(
                    decoration: boxDecorationDefault(color: context.cardColor),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 26),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Date And Time:',
                                style: boldTextStyle(size: LABEL_TEXT_SIZE)),
                            8.height,
                            SizedBox(
                              width: context.width() * 0.89,
                              height: context.height() * 0.05,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        setCurrentDateWithAdditional2Hours();
                                        setState(() {
                                          isNowButtonClicked = true;
                                          isButtonClicked = false;
                                        });
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: isNowButtonClicked
                                                ? primaryColor
                                                : null,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(12)),
                                            boxShadow: defaultBoxShadow(
                                                blurRadius: 0,
                                                spreadRadius: 0)),
                                        padding: EdgeInsets.all(10),
                                        child: Center(
                                            child: Text(
                                          'Now',
                                          style: TextStyle(
                                              color: isNowButtonClicked
                                                  ? white
                                                  : null),
                                        )),
                                      ),
                                    ),
                                  ),
                                  20.width,
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        selectDateAndTime(context);
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: isButtonClicked
                                                ? primaryColor
                                                : null,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(12)),
                                            boxShadow: defaultBoxShadow(
                                                blurRadius: 0,
                                                spreadRadius: 0)),
                                        padding: EdgeInsets.all(10),
                                        child: Center(
                                            child: Text(
                                          'Schedule',
                                          style: TextStyle(
                                            color:
                                                isButtonClicked ? white : null,
                                          ),
                                        )),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (selectedDate != null && !isNowButtonClicked)
                              8.height,
                            if (selectedDate != null && !isNowButtonClicked)
                              AppTextField(
                                textFieldType: TextFieldType.OTHER,
                                controller: dateTimeCont,
                                isValidationRequired: true,
                                validator: (value) {
                                  if (value!.isEmpty) return 'Required Text';
                                  return null;
                                },
                                readOnly: true,
                                onTap: () {
                                  selectDateAndTime(context);
                                },
                                decoration: inputDecoration(context,
                                        prefixIcon: ic_calendar
                                            .iconImage(size: 10)
                                            .paddingAll(14))
                                    .copyWith(
                                  fillColor: context.scaffoldBackgroundColor,
                                  filled: true,
                                  hintText: 'Choose Date And Time',
                                  hintStyle: secondaryTextStyle(),
                                ),
                              ),
                            20.height,
                          ],
                        ),
                        Visibility(
                          visible: false,
                          child: Text('Your Address',
                              style: boldTextStyle(size: LABEL_TEXT_SIZE)),
                        ),
                        Visibility(
                          visible: false,
                          child: AppTextField(
                            textFieldType: TextFieldType.MULTILINE,
                            // controller: addressCont,
                            maxLines: 1,
                            onFieldSubmitted: (s) {
                              // widget.data.serviceDetail!.address = s;
                            },
                            initialValue: appStore.address,
                            enabled: false,
                            decoration: inputDecoration(
                              context,
                              prefixIcon: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  ic_location
                                      .iconImage(size: 22)
                                      .paddingOnly(top: 8),
                                ],
                              ),
                            ).copyWith(
                              fillColor: context.scaffoldBackgroundColor,
                              filled: true,
                              // hintText: language.lblEnterYourAddress,
                              hintStyle: secondaryTextStyle(),
                            ),
                          ),
                        ),
                        Text("Comments:",
                            style: boldTextStyle(size: LABEL_TEXT_SIZE)),
                        8.height,
                        AppTextField(
                          scrollPadding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom +
                                  14 * 4),
                          textFieldType: TextFieldType.MULTILINE,
                          controller: descriptionCont,
                          maxLines: 10,
                          minLines: 4,
                          isValidationRequired: false,
                          onFieldSubmitted: (s) {
                            // widget.data.serviceDetail!.bookingDescription = s;
                          },
                          decoration: inputDecoration(context).copyWith(
                            fillColor: context.scaffoldBackgroundColor,
                            filled: true,
                            hintText: 'Enter Comments',
                            hintStyle: secondaryTextStyle(),
                          ),
                        ),
                        16.height,
                        CustomImagePicker(
                          key: uniqueKey,
                          isGridTypeView: true,
                          onRemoveClick: (value) {
                            if (tempAttachments.validate().isNotEmpty &&
                                imageFiles.isNotEmpty) {
                              showConfirmDialogCustom(
                                context,
                                dialogType: DialogType.DELETE,
                                positiveText: 'Delete',
                                negativeText: 'Cancel',
                                onAccept: (p0) {
                                  imageFiles.removeWhere(
                                      (element) => element.path == value);
                                  // removeAttachment(id: tempAttachments.validate().firstWhere((element) => element.url == value).id.validate());
                                },
                              );
                            } else {
                              showConfirmDialogCustom(
                                context,
                                dialogType: DialogType.DELETE,
                                positiveText: 'Delete',
                                negativeText: 'Cancel',
                                onAccept: (p0) {
                                  imageFiles.removeWhere(
                                      (element) => element.path == value);
                                  if (isUpdate) {
                                    uniqueKey = UniqueKey();
                                  }
                                  setState(() {});
                                },
                              );
                            }
                          },
                          selectedImages: imageFiles
                              .validate()
                              .map((e) => e.path.validate())
                              .toList(),
                          onFileSelected: (List<File> files) async {
                            imageFiles = files;
                            setState(() {});
                          },
                        ),
                        10.height,
                      ],
                    ),
                  ),
                  60.height,
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              left: 16,
              right: 16,
              child: Container(
                color: white,
                height: context.height() * 0.1,
                child: Row(
                  children: [
                    AppButton(
                      onTap: () async {
                        hideKeyboard(context);
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          if (onSelectService != null &&
                              onSelectService != -1) {
                            if (selectedTechnicianId != null) {
                              showInDialog(
                                context,
                                barrierDismissible: false,
                                builder: (p0) {
                                  return StatefulBuilder(
                                      builder: (context, setState) {
                                    return ConfirmBookingDialog(
                                      serviceId: '$onSelectService',
                                      providerId: appStore.userId.toString(),
                                      quantity: '1',
                                      address: widget.customerAddress ?? '',
                                      amount: '0',
                                      totalAmount: '0',
                                      customerId: widget.customerId ?? '',
                                      couponId: '',
                                      description: descriptionCont.text,
                                      isSlotAvailable: true,
                                      attachmentCount:
                                          imageFiles.length.toString(),
                                      date: finalDate.toString(),
                                      imagesFile: imageFiles,
                                      technicalId:
                                          '${selectedTechnicianId ?? ''}',
                                    );
                                  });
                                },
                              );
                            } else {
                              toast('Choose one trade.',
                                  bgColor: redColor.withOpacity(0.6),
                                  textColor: white);
                            }
                          } else {
                            toast('Service should not empty.',
                                bgColor: redColor.withOpacity(0.6),
                                textColor: white);
                          }
                        }
                      },
                      text: 'Next',
                      textColor: Colors.white,
                      width: context.width(),
                      color: context.primaryColor,
                    ).expand(),
                  ],
                ),
              ),
            ),
            Observer(
                builder: (context) =>
                    LoaderWidget().visible(appStore.isLoading))
          ],
        ),
      ),
    );
  }
}
