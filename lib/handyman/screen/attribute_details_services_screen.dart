import 'package:flutter/material.dart';
import 'package:trade/utils/common.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/app_widgets.dart';
import '../../components/back_widget.dart';
import '../../main.dart';
import '../../models/inspection_attributes_response.dart';
import '../../models/request_inspection_attribute_model.dart';
import '../../utils/colors.dart';

class AttributeDetailsServicesScreen extends StatefulWidget {
  final List<InspectionAttributeValue> attributeValuesList;
  final InspectionAttributeData? areaDetails;
  const AttributeDetailsServicesScreen({
    super.key,
    required this.attributeValuesList,
    this.areaDetails,
  });

  @override
  State<AttributeDetailsServicesScreen> createState() =>
      _AttributeDetailsServicesScreenState();
}

class _AttributeDetailsServicesScreenState
    extends State<AttributeDetailsServicesScreen> {
  List<RequestAttribute> requestAttributes = [];

  void addIfChanged(InspectionAttributeValue inspectionAttributeValue) {
    RequestAttribute newItem = RequestAttribute(
        attributeId: inspectionAttributeValue.id!,
        value: inspectionAttributeValue.selectedOption!);

    int existingIndex = requestAttributes
        .indexWhere((item) => item.attributeId == newItem.attributeId);

    if (existingIndex != -1) {
      requestAttributes[existingIndex] = newItem;
    } else {
      requestAttributes.add(newItem);
    }
    setState(() {});
    for (var i = 0; i < requestAttributes.length; i++) {
      debugPrint(
          'Items:${requestAttributes[i].attributeId} ${requestAttributes[i].value}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (val) async {
        if (val) {
        } else {
          Navigator.pop(context, requestAttributes);
        }
      },
      child: Scaffold(
        appBar: appBarWidget(
          widget.areaDetails?.tagName ?? '',
          textColor: white,
          elevation: 0.0,
          color: context.primaryColor,
          backWidget: BackWidget(onPressed: () {
            Navigator.pop(context, requestAttributes);
          }),
        ),
        body: appStore.isLoading
            ? LoaderWidget()
            : Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: listViewItems(),
              ),
      ),
    );
  }

  Widget listViewItems() {
    return AnimatedListView(
        physics: AlwaysScrollableScrollPhysics(),
        itemCount: widget.attributeValuesList.length,
        itemBuilder: (context, index) {
          return itemListItem(index, widget.attributeValuesList)
              .paddingOnly(bottom: 12);
        });
  }

  Widget itemListItem(int index, List<InspectionAttributeValue> itemList) {
    return Container(
      padding: EdgeInsets.all(10),
      width: context.width() * 0.1,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12), color: cardColor),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              itemList[index].name ?? '',
              maxLines: 4,
              style: primaryTextStyle(weight: FontWeight.bold,color: Colors.black),
            ),
          ),
          Expanded(
            child: DropdownButtonFormField<String>(
              decoration: inputDecoration(context,
                  hint: 'Select Options', islabelText: false, ),
              isExpanded: true,
              value: itemList[index].selectedOption,
              dropdownColor: context.cardColor,
              items: itemList[index].options?.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item,
                      style: primaryTextStyle(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                );
              }).toList(),
              onChanged: (String? value) async {
                hideKeyboard(context);
                setState(() {
                  itemList[index].selectedOption = value;
                });
                addIfChanged(itemList[index]);
              },
            ),
          ),
        ],
      ),
    ).onTap(() {
      // CreateServiceRequest().launch(context);
    });
  }
}
