import 'package:flutter/material.dart';
import 'package:trade/components/app_widgets.dart';
import 'package:trade/handyman/screen/inspection_add_item.dart';
import 'package:trade/handyman/screen/item_details_screen.dart';
import 'package:trade/main.dart';
import 'package:trade/models/house_inspection_model.dart';
import 'package:trade/networks/rest_apis.dart';
import 'package:trade/provider/fragments/create_service_request.dart';
import 'package:trade/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/back_widget.dart';

class AreaDetailsScreen extends StatefulWidget {
  final HouseInspectionAreaData? areaDetails;
  final bool isFromSearching;
  final String floor;
  const AreaDetailsScreen(
      {super.key,
      this.areaDetails,
      required this.floor,
      required this.isFromSearching});

  @override
  State<AreaDetailsScreen> createState() => _AreaDetailsScreenState();
}

class _AreaDetailsScreenState extends State<AreaDetailsScreen> {
  List<HouseInspectionItemsData> houseInspectionItems = [];

  Widget listViewItems() {
    return AnimatedListView(
        physics: AlwaysScrollableScrollPhysics(),
        itemCount: houseInspectionItems.length,
        itemBuilder: (context, index) {
          return itemListItem(index, houseInspectionItems)
              .paddingOnly(bottom: 12);
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
            itemList[index].item ?? '',
            maxLines: 1,
            style: primaryTextStyle(weight: FontWeight.bold),
          ),
          8.height,
          Text(
            itemList[index].description ?? '',
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: primaryTextStyle(
                weight: FontWeight.bold, size: 12, color: gray),
          ),
        ],
      ),
    ).onTap(() {
      if (widget.isFromSearching) {
        CreateServiceRequest().launch(context);
      } else {
        ItemDetailsScreen(
          item: itemList[index],
        ).launch(context);
      }
    });
  }

  void getHouseItems() async {
    Map<String, dynamic> req = {
      "customer_id": appStore.userId,
      "area_id": widget.areaDetails?.houseareaId,
      "floor": widget.floor,
    };
    appStore.setLoading(true);
    setState(() {});
    try {
      var res = await getAllHouseItems(req: req);
      if (res.isNotEmpty) {
        houseInspectionItems.addAll(res);
        setState(() {});
      } else {
        houseInspectionItems = widget.areaDetails?.houseItems ?? [];
      }
      appStore.setLoading(false);
      setState(() {});
    } catch (e) {
      appStore.setLoading(false);
      setState(() {});
      print(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    getHouseItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        widget.areaDetails?.area ?? '',
        textColor: white,
        elevation: 0.0,
        color: context.primaryColor,
        backWidget: BackWidget(),
        actions: [
          if (!widget.isFromSearching)
            Padding(
              padding: const EdgeInsets.only(right: 20, top: 5),
              child: Icon(
                Icons.add_circle,
                color: white,
              ).onTap(() async {
                bool result = await InspectionAddItem(
                  areaId: '${widget.areaDetails?.houseareaId}',
                  floor: widget.floor,
                ).launch(context);
                if (result == true) {
                  houseInspectionItems.clear();
                  setState(() {});
                  getHouseItems();
                }
              }),
            ),
        ],
      ),
      body: appStore.isLoading
          ? LoaderWidget()
          : Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: listViewItems(),
            ),
    );
  }
}
