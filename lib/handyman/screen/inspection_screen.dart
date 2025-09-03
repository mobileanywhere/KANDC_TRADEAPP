import 'package:flutter/material.dart';
import 'package:trade/components/app_widgets.dart';
import 'package:trade/components/back_widget.dart';
import 'package:trade/handyman/screen/inspection_add_area.dart';
import 'package:trade/handyman/screen/item_details_screen.dart';
import 'package:trade/main.dart';
import 'package:trade/models/house_inspection_model.dart';
import 'package:trade/networks/rest_apis.dart';
import 'package:trade/utils/colors.dart';
import 'package:trade/utils/common.dart';
import 'package:trade/utils/configs.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../models/caregory_response.dart';
import '../../models/inspection_attributes_response.dart';
import '../../models/inspection_details_response_model.dart';
import '../../models/property_model.dart';
import '../../models/request_inspection_attribute_model.dart';
import '../../provider/fragments/search_technician_widget.dart';
import '../../utils/constant.dart';
import 'attribute_details_services_screen.dart';

class InspectionScreen extends StatefulWidget {
  final String searchedOwner;
  final String? lastInspectedDate;
  final String? projectManager;
  final int? bookingId;
  final String? ownerAddress;
  const InspectionScreen({
    super.key,
    required this.searchedOwner,
    this.lastInspectedDate,
    this.projectManager,
    this.bookingId,
    this.ownerAddress,
  });

  @override
  State<InspectionScreen> createState() => _InspectionScreenState();
}

class _InspectionScreenState extends State<InspectionScreen> {
  List<CategoryData> staticList = [
    CategoryData(name: 'Add Area', categoryImage: 'assets/images/add_area.png'),
    CategoryData(name: 'Add Item', categoryImage: 'assets/images/add_items.png')
  ];
  List<HouseInspectionAreaData> houseInspectionAreaData = [];
  List<PropertyData> propertiesList = [];
  List<HouseInspectionData> houseInspectionData = [];
  List<InspectionAttributeData> attributesListData = [];

  HouseInspectionData? selectedFloor;
  String? selectedFloorId;
  int? selectedTechnicianId;
  PropertyData? selectedPropertyData;
  InspectionDetailsResponse? inspectionDetailsResponse;

  List<RequestAttribute> requestAttributes = [];
  List<Map<String, dynamic>> requestAttributesJson = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    appStore.setLoading(true);
    await inspectionDetails();
    await getProperties();
    await getHouseInspection();
    await getAllAttributes(propertyId: selectedPropertyData?.id ?? 0);
    appStore.setLoading(false);
  }

  setInitialValues() {
    setState(() {
      selectedTechnicianId = inspectionDetailsResponse?.data?.technicianId;
    });
  }

  Future<void> getProperties() async {
    try {
      Map req = {'customer_id': inspectionDetailsResponse?.data?.customerId};
      var res = await getAllProperties(req);
      propertiesList.clear();
      propertiesList.addAll(res);
      selectedPropertyData = propertiesList.firstWhere((element) =>
          element.id == inspectionDetailsResponse?.data?.propertyId);
      setState(() {});
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> inspectionDetails() async {
    try {
      Map req = {'inspection_id': widget.bookingId};
      inspectionDetailsResponse = await inspectionDetailsApi(req);
      setInitialValues();
    } catch (e) {
      debugPrint('Screen, Catch Error: $e');
    }
  }

  Future<void> getHouseInspection() async {
    appStore.setLoading(true);
    try {
      Map<String, String> req = {'customer_id': '${appStore.userId}'};
      houseInspectionData = await getHouseInspectionData(req);
      setState(() {});
    } catch (e) {
      debugPrint(e.toString());
    }
    appStore.setLoading(false);
    setState(() {});
    searchServiceAPI(
        categoryId: 19.toString(),
        subCategory: 19.toString(),
        list: [],
        page: 1);
    setState(() {});
  }

  Future<void> saveInspectionToStart(int inspectionId) async {
    appStore.setLoading(true);
    Map req = {
      'inspection_id': '$inspectionId',
      'status': 'Completed',
      'property_id': selectedPropertyData?.id,
      'customer_id': inspectionDetailsResponse?.data?.customerId,
      'inspection_attributes': requestAttributesJson,
    };
    await saveInspection(req);
    appStore.setLoading(false);
  }

  Future<void> getAllAttributes({int? propertyId}) async {
    try {
      Map req = {'customer_id': appStore.userId, 'property_id': propertyId};
      var res = await getAttributes(req);

      setState(() {
        attributesListData.clear();
        attributesListData.addAll(res);
      });
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
        'Inspection',
        textColor: white,
        elevation: 0.0,
        color: context.primaryColor,
        backWidget: BackWidget(),
        actions: [
          if (houseInspectionAreaData.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 20, top: 5),
              child: Icon(
                Icons.add_circle,
                color: white,
              ).onTap(() async {
                var result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InspectionAddArea(),
                  ),
                );
                if (result == true) {
                  setState(() {
                    selectedFloor = null;
                    selectedFloorId = null;
                  });
                  await getHouseInspection();
                }
              }),
            ),
        ],
      ),
      body: appStore.isLoading
          ? LoaderWidget()
          : Stack(
              children: [
                Container(
                  height: context.height() * 1,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: (houseInspectionData.isEmpty)
                      ? gridViewItems()
                      : listViewItems(),
                ),
                if (selectedPropertyData != null &&
                    selectedTechnicianId != null)
                  Positioned(
                    bottom: 0,
                    child: AppButton(
                      text: 'Save Inspection',
                      color: primaryColor,
                      textColor: white,
                      width: context.width() * 0.9,
                      onTap: () async {
                        // selectedFloor = null;
                        // selectedFloorId = null;
                        // houseInspectionAreaData.clear();
                        // setState(() {});
                        await saveInspectionToStart(widget.bookingId ?? 0);
                        appStore.setLoading(false);
                        Navigator.of(context).pop();
                        LiveStream().emit(LIVESTREAM_HANDYMAN_ALL_BOOKING, 1);
                      },
                    ).paddingSymmetric(horizontal: 16),
                  ),
              ],
            ),
    );
  }

  Widget inspectionItem({String? image, String? name}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border:
            Border.all(width: 1, color: const Color.fromARGB(66, 112, 83, 83)),
      ),
      child: Center(
        child: Column(
          children: [
            4.height,
            SizedBox(
              width: context.width() * 0.27,
              height: context.height() * 0.13,
              child: Image.asset(
                image ?? '',
                fit: BoxFit.cover,
              ),
            ),
            8.height,
            Text(
              name ?? '',
              style: primaryTextStyle(
                  size: 18, weight: FontWeight.bold, color: black),
            )
          ],
        ),
      ),
    );
  }

  Widget gridViewItems() {
    return GridView.builder(
        itemCount: staticList.length,
        physics: AlwaysScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
        ),
        itemBuilder: (context, index) => inspectionItem(
                    image: staticList[index].categoryImage.toString(),
                    name: staticList[index].name.toString())
                .onTap(() {
              if (staticList[index].name == 'Add Item') {
                // InspectionAddItem().launch(context);
              } else {
                InspectionAddArea().launch(context);
              }
            }));
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
            leftSubtitle: '${inspectionDetailsResponse?.data?.customerName}',
            rightTitle: 'Last Inspected on',
            rightSubtitle: DateFormat('dd-MM-yyyy').format(DateTime.parse(
                inspectionDetailsResponse?.data?.date ??
                    DateTime.now().toString())), // '16-11-2023',
          ),
          26.height,
          rowDetailedWidget(
              leftTitle: 'Address',
              leftSubtitle: inspectionDetailsResponse?.data?.address ?? ''),
          30.height,
          DropdownButtonFormField<PropertyData>(
            decoration: inputDecoration(context, hint: 'Select Property'),

            isExpanded: true,
            value: selectedPropertyData,
            dropdownColor: context.cardColor,
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
                getAllAttributes(propertyId: selectedPropertyData?.id ?? 0);
              }
            },
          ),
          24.height,
          SearchTechnicianWidget(
            onSelectingTechnician: (userData) {
              selectedTechnicianId = userData.id;
              setState(() {});
            },
            initialValue: inspectionDetailsResponse?.data?.technicianName,
          ),
          24.height,
          if (selectedPropertyData != null) expansionBody(),
        ],
      ),
    );
  }

  Widget expansionBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                      style: primaryTextStyle(weight: FontWeight.bold,color: Colors.black),
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

  Widget itemListItem(int index, List<HouseInspectionItemsData> itemList) {
    return Container(
      padding: EdgeInsets.all(10),
      width: context.width() * 0.1,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12), color: cardColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${itemList[index].item}',
            maxLines: 1,
            style: primaryTextStyle(weight: FontWeight.bold),
          ),
          8.height,
          Text(
            '${itemList[index].description}',
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: primaryTextStyle(
                weight: FontWeight.bold, size: 12, color: gray),
          ),
        ],
      ),
    ).onTap(() {
      ItemDetailsScreen(
        item: itemList[index],
      ).launch(context);
    });
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

                    fontStyle: FontStyle.italic),
              ),
            ),
            if (rightTitle != null) Spacer(),
            if (rightSubtitle != null)
              Expanded(
                child: Text(
                  rightSubtitle,
                  style: primaryTextStyle(
                      size: 14,
                      weight: FontWeight.w500,

                      fontStyle: FontStyle.italic),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
