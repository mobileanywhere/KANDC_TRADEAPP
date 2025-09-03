import 'package:flutter/material.dart';
import 'package:trade/provider/provider_dashboard_screen.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/app_widgets.dart';
import '../../components/back_widget.dart';
import '../../main.dart';
import '../../models/inspection_attributes_response.dart';
import '../../models/property_model.dart';
import '../../models/request_inspection_attribute_model.dart';
import '../../models/user_data_model.dart';
import '../../networks/rest_apis.dart';
import '../../utils/colors.dart';
import '../../utils/common.dart';
import '../../utils/configs.dart';
import 'attribute_details_services_screen.dart';

class CreateInspectionAttributeScreen extends StatefulWidget {
  final UserDataHomeOwner? searchedOwner;
  final int? inspectionId;
  const CreateInspectionAttributeScreen({
    super.key,
    this.searchedOwner,
    this.inspectionId,
  });

  @override
  State<CreateInspectionAttributeScreen> createState() =>
      _CreateInspectionAttributeScreenState();
}

class _CreateInspectionAttributeScreenState
    extends State<CreateInspectionAttributeScreen> {
  List<InspectionAttributeData> attributesListData = [];
  List<PropertyData> propertiesList = [];
  List<RequestAttribute> requestAttributes = [];
  List<Map<String, dynamic>> requestAttributesJson = [];

  PropertyData? selectedPropertyData;
  int? selectedTechnicianId;

  @override
  void initState() {
    super.initState();
    getProperties();
  }

  void getProperties() async {
    try {
      Map req = {'customer_id': widget.searchedOwner?.id};
      var res = await getAllProperties(req);
      propertiesList.clear();
      propertiesList.addAll(res);
      setState(() {});
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void getAllAttributes() async {
    try {
      Map req = {
        'customer_id': appStore.userId,
        'property_id': selectedPropertyData?.id
      };
      var res = await getAttributes(req);

      setState(() {
        attributesListData.clear();
        attributesListData.addAll(res);
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void createInspections() async {
    try {
      Map req = {
        'provider_id': appStore.userId,
        'customer_id': widget.searchedOwner?.id,
        'technician_id': selectedTechnicianId,
        'property_id': selectedPropertyData?.id,
        'inspection_attributes': requestAttributesJson
      };
      await createInspectionApi(req);
      ProviderDashboardScreen(
        index: 2,
        isRedirect: true,
      ).launch(context, isNewTask: true);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void addIfChanged(List<RequestAttribute> resultAttributes) {
    for (int i = 0; i < resultAttributes.length; i++) {
      int existingIndex = requestAttributes.indexWhere(
          (item) => item.attributeId == resultAttributes[i].attributeId);

      if (existingIndex != -1) {
        // Update particular item in requestAttributes list
        requestAttributes[existingIndex] = resultAttributes[i];
      } else {
        // Add new item to requestAttributes list
        requestAttributes.add(resultAttributes[i]);
      }
    }
    requestAttributesJson =
        requestAttributes.map((attribute) => attribute.toJson()).toList();

    setState(() {});

    for (var i = 0; i < requestAttributes.length; i++) {
      debugPrint(
          'Back Items:${requestAttributes[i].attributeId} ${requestAttributes[i].value}');
    }
    debugPrint(requestAttributesJson.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        'HomeOwner',
        textColor: white,
        elevation: 0.0,
        color: context.primaryColor,
        backWidget: BackWidget(),
      ),
      body: appStore.isLoading
          ? LoaderWidget()
          : Stack(
              children: [
                Container(
                  height: context.height() * 1,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: listViewItems(),
                ),
                if (attributesListData.isNotEmpty)
                  Positioned(
                    bottom: 0,
                    child: AppButton(
                      text: 'Create Inspection',
                      color: primaryColor,
                      textColor: white,
                      width: context.width() * 0.9,
                      onTap: () async {
                        // if (selectedTechnicianId == null) {
                        //   toast('Select a trade');
                        // } else
                        if (requestAttributesJson.isEmpty) {
                          toast('Choose or update any attribute.');
                        } else {
                          createInspections();
                        }

                        // CreateInspectionScreen(
                        //         homeOwnerName: widget.searchedOwner)
                        //     .launch(context);
                      },
                    ).paddingSymmetric(horizontal: 16),
                  ),
              ],
            ),
    );
  }

  Widget listViewItems() {
    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      scrollDirection: Axis.vertical,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          rowDetailedWidget(
            leftTitle: 'Home-Owner',
            leftSubtitle:
                '${widget.searchedOwner?.firstName.validate()} ${widget.searchedOwner?.lastName.validate()}',
            rightTitle: 'Address',
            rightSubtitle: widget.searchedOwner?.address ?? '',
          ),
          26.height,
          rowDetailedWidget(
            leftTitle: 'Last Inspected on',
            leftSubtitle: widget.searchedOwner?.lastNotificationSeen == null
                ? ''
                : DateFormat('dd-MM-yyyy').format(DateTime.parse(
                    widget.searchedOwner?.lastNotificationSeen ??
                        DateTime.now().toString())), // '16-11-2023',
            rightTitle: 'Project Manager',
            rightSubtitle: appStore.userFullName,
          ),
          26.height,
          DropdownButtonFormField<PropertyData>(
            decoration: inputDecoration(context, hint: 'Select Property'),
            isExpanded: true,
            value: selectedPropertyData,
            dropdownColor: white,
            items: propertiesList.map((PropertyData e) {
              return DropdownMenuItem<PropertyData>(
                value: e,
                child: Text(e.address ?? '',
                    style: primaryTextStyle(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              );
            }).toList(),
            onChanged: (PropertyData? value) async {
              hideKeyboard(context);
              setState(() {
                selectedPropertyData = value;
              });
              if (selectedPropertyData != null) {
                getAllAttributes();
              }
            },
          ),
          // 26.height,
          // SearchTechnicianWidget(
          //   onSelectingTechnician: (userData) {
          //     selectedTechnicianId = userData.id;
          //     setState(() {});
          //   },
          // ),
          24.height,
          expansionBody(),
        ],
      ),
    );
  }

  Widget rowDetailedWidget(
      {required String leftTitle,
      required String leftSubtitle,
      String? rightTitle,
      String? rightSubtitle}) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                leftTitle,
                style: primaryTextStyle(
                    size: 10, weight: FontWeight.w500, color: gray),
              ),
            ),
            if (rightTitle != null) Spacer(),
            if (rightTitle != null)
              Expanded(
                child: Text(
                  rightTitle,
                  textAlign: TextAlign.end,
                  style: primaryTextStyle(
                      size: 10, weight: FontWeight.w500, color: gray),
                ),
              ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                leftSubtitle,
                style: primaryTextStyle(
                    size: 14,
                    weight: FontWeight.w500,
                    color: black,
                    fontStyle: FontStyle.italic),
              ),
            ),
            if (rightSubtitle != null)
              Expanded(
                child: Text(
                  rightSubtitle,
                  textAlign: TextAlign.end,
                  style: primaryTextStyle(
                      size: 14,
                      weight: FontWeight.w500,
                      color: black,
                      fontStyle: FontStyle.italic),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget expansionBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (attributesListData.isNotEmpty)
          Text(
            'Inspection Attributes',
            style: primaryTextStyle(color: gray, weight: FontWeight.bold),
          ),
        12.height,
        AnimatedListView(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: attributesListData.length,
            itemBuilder: (context, index) {
              return areaListItem(index, attributesListData)
                  .paddingOnly(bottom: 12);
            }),
        60.height,
      ],
    );
  }

  Widget areaListItem(int index, List<InspectionAttributeData> areaList) {
    return Container(
      padding: EdgeInsets.all(10),
      width: context.width() * 0.1,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12), color: cardColor),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SizedBox(
                    child: Text(
                      '${areaList[index].tagName}',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: primaryTextStyle(weight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              Icon(
                Icons.keyboard_arrow_right,
                color: black,
                size: 28,
              )
            ],
          ),
        ],
      ),
    ).onTap(() async {
      var result = await AttributeDetailsServicesScreen(
        attributeValuesList: areaList[index].value ?? [],
        areaDetails: areaList[index],
      ).launch(context);
      if (result != null || result != []) {
        addIfChanged(result);
      }
    });
  }
}
