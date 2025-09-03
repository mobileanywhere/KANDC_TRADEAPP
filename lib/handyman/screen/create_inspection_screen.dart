import 'package:flutter/material.dart';
import 'package:trade/app_theme.dart';
import 'package:trade/components/back_widget.dart';
import 'package:trade/main.dart';
import 'package:trade/utils/common.dart';
import 'package:trade/utils/configs.dart';
import 'package:trade/utils/constant.dart';
import 'package:trade/utils/extensions/string_extension.dart';
import 'package:trade/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

class CreateInspectionScreen extends StatefulWidget {
  final String homeOwnerName;
  const CreateInspectionScreen({super.key, required this.homeOwnerName});

  @override
  State<CreateInspectionScreen> createState() => _CreateInspectionScreenState();
}

class _CreateInspectionScreenState extends State<CreateInspectionScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  UniqueKey uniqueKey = UniqueKey();

  TextEditingController description = TextEditingController();
  TextEditingController dateTimeCont = TextEditingController();

  FocusNode descriptionFocus = FocusNode();

  DateTime currentDateTime = DateTime.now();
  DateTime? selectedDate;
  DateTime? finalDate;
  TimeOfDay? pickedTime;

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
              return toast('Selected Other Booking Time');
            }

            selectedDate = date;
            pickedTime = time;
            // widget.data.serviceDetail!.dateTimeVal = finalDate.toString();
            dateTimeCont.text =
                "${formatDate(selectedDate.toString(), format: DATE_FORMAT_3)} ${pickedTime!.format(context).toString()}";
          }
        }).catchError((e) {
          toast(e.toString());
        });
      }
    });
  }

  //region Build Widget
  Widget buildFormWidget() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: boxDecorationWithRoundedCorners(
        borderRadius: radius(),
        // backgroundColor: context.cardColor,
      ),
      child: Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Wrap(
          runSpacing: 16,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Date And Time',
                    style: boldTextStyle(size: LABEL_TEXT_SIZE)),
                8.height,
                AppTextField(
                  textFieldType: TextFieldType.OTHER,
                  controller: dateTimeCont,
                  isValidationRequired: true,
                  validator: (value) {
                    if (value!.isEmpty) return languages.hintRequired;
                    return null;
                  },
                  readOnly: true,
                  onTap: () {
                    selectDateAndTime(context);
                  },
                  decoration: inputDecoration(context,
                          prefixIcon:
                              ic_calendar.iconImage(size: 10).paddingAll(14))
                      .copyWith(
                    fillColor: context.cardColor,
                    filled: true,
                    hintText: 'Choose Date and Time',
                    hintStyle: secondaryTextStyle(),
                  ),
                ),
              ],
            ),
            AppTextField(
              textFieldType: TextFieldType.MULTILINE,
              maxLines: 4,
              controller: description,
              focus: descriptionFocus,
              // nextFocus: priceFocus,
              errorThisFieldRequired: languages.hintRequired,
              decoration: inputDecoration(context,
                  hint: languages.hintDescription,
                  fillColor: context.cardColor),
            ),
            16.height,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        widget.homeOwnerName,
        textColor: white,
        elevation: 0.0,
        color: context.primaryColor,
        backWidget: BackWidget(),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              buildFormWidget(),
            ],
          ),
          Positioned(
            bottom: 0,
            child: AppButton(
              text: 'Submit',
              color: primaryColor,
              textColor: white,
              width: context.width() * 0.9,
              onTap: () {},
            ).paddingSymmetric(horizontal: 16),
          ),
        ],
      ),
    );
  }
}
