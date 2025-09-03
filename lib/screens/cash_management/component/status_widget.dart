import 'package:flutter/material.dart';
import 'package:trade/screens/cash_management/model/cash_filter_model.dart';
import 'package:nb_utils/nb_utils.dart';

class StatusWidget extends StatelessWidget {
  final CashFilterModel data;
  final bool isSelected;

  const StatusWidget({super.key, required this.data, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 4, left: 4),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: boxDecorationDefault(border: Border.all(color: context.dividerColor), color: isSelected ? context.primaryColor : context.cardColor),
      child: Text(data.name.validate(), style: primaryTextStyle(color: isSelected ? Colors.white : textPrimaryColorGlobal)),
    );
  }
}
