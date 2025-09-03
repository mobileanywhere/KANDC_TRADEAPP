import 'package:flutter/material.dart';
import 'package:trade/components/app_widgets.dart';
import 'package:trade/main.dart';
import 'package:trade/models/estimation_response_details.dart';
import 'package:trade/models/line_item_response.dart';
import 'package:trade/networks/rest_apis.dart';
import 'package:trade/screens/final_invocie_screen.dart';
import 'package:trade/screens/line_items_estimation_screen.dart';
import 'package:trade/utils/configs.dart';
import 'package:nb_utils/nb_utils.dart';

class LineItemsModule extends StatefulWidget {
  final String bookingId;
  final String serviceId;
  final String customerId;
  final String? categoryId;
  final String? subCategoryId;
  const LineItemsModule({
    super.key,
    required this.bookingId,
    required this.serviceId,
    this.categoryId,
    this.subCategoryId,
    required this.customerId,
  });

  @override
  State<LineItemsModule> createState() => _LineItemsModuleState();
}

class _LineItemsModuleState extends State<LineItemsModule> {
  //endregion
  List<LineItemData> comingDataList = [];
  Map<String, dynamic>? totalInfo;
  List<EstimationLineItemData> listOfLineItems = [];
  EstimationDetailsResponse? estimationDetailsResponse;

  @override
  void initState() {
    super.initState();
    estimationDetailsData();
  }

  void addLineItemsToList(List<EstimationLineItemData> listOfLineItems) {
    for (EstimationLineItemData estimationLineItem in listOfLineItems) {
      debugPrint(estimationLineItem.lineItemName);
      debugPrint(estimationLineItem.lineItemPrice.toString());
      debugPrint(estimationLineItem.lineItemQty.toString());
      LineItemData lineItemData = LineItemData(
        id: estimationLineItem.lineItemId,
        name: estimationLineItem.lineItemName,
        price: estimationLineItem.lineItemPrice.toString(),
        qty: estimationLineItem.lineItemQty,
      );
      comingDataList.add(lineItemData);
    }
    setState(() {});
    debugPrint(
        'comingDataList in addLineItemsToList Function: ${comingDataList[0].name}');
  }

  Widget paymentItem({String? name, int? quantity, double? price}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$name x $quantity'),
          Text('\$${price?.toStringAsFixed(2)}'),
        ],
      ),
    );
  }

  Widget totalAmount({double? totalAmount}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Total Amount', style: TextStyle(fontWeight: FontWeight.bold)),
          Text('\$${totalAmount?.toStringAsFixed(2)}',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  double calculateTotalInfo() {
    double totalAmount = 0;

    for (var element in comingDataList) {
      if (element.qty! >= 1) {
        double itemTotal = element.qty! * double.parse(element.price ?? '0');
        totalAmount += itemTotal;
      }
    }

    return totalAmount;
  }

  List<Map<String, String>> populateSList() {
    List<Map<String, String>> s = [];
    for (var lineItem in comingDataList) {
      Map<String, String> lineItemMap = {
        "line_item_id": lineItem.id?.toString() ?? "",
        "line_item_name": lineItem.name ?? "",
        "line_item_qty": lineItem.qty?.toString() ?? "0",
        "line_item_price": lineItem.price ?? "0",
      };
      setState(() {
        s.add(lineItemMap);
      });
      debugPrint('aded item: ${s[0]['line_item_name']}');
    }
    return s;
  }

  Future<void> saveEstimationLineItems(
      {required String customerId,
      required String bookingId,
      required String serviceId,
      List<Map<String, String>>? comList}) async {
    for (var i = 0; i < populateSList().length; i++) {
      debugPrint('populate list: l:::::::::::::::::::: ${populateSList()[i]}');
    }

    Map req = {
      "customer_id": customerId,
      "booking_id": bookingId,
      "service_id": serviceId,
      "technician_id": "${appStore.userId}",
      "lineitems": populateSList() == [] ? comList : populateSList()
    };

    // Conditionally add subcategoryId if it's not null
    if (widget.subCategoryId != null) {
      req['sub_category_id'] = widget.subCategoryId ?? '0';
    }

    // Conditionally add categoryId if it's not null
    if (widget.categoryId != null) {
      req['category_id'] = widget.categoryId ?? '0';
    }

    try {
      var res = await saveEstimationLists(req).then((value) {
        setState(() {
          comingDataList.clear();
          listOfLineItems.clear();
        });
      });
      toast(res.message);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void estimationDetailsData() async {
    appStore.setLoading(true);
    Map req = {
      "customer_id": widget.customerId,
      "booking_id": widget.bookingId
    };
    try {
      var res = await estimationDetails(req);
      setState(() {
        listOfLineItems.clear();
        comingDataList.clear();
        estimationDetailsResponse = res;
        listOfLineItems.addAll(res.lineitemData ?? []);
        addLineItemsToList(listOfLineItems);
      });
    } catch (e) {
      debugPrint(e.toString());
    }
    appStore.setLoading(false);
  }

  void sendEstimationData() async {
    appStore.setLoading(true);
    Map req = {
      "customer_id": widget.customerId,
      "booking_id": widget.bookingId
    };
    try {
      await sendEstimation(req).then((value) {
        estimationDetailsData();
      });
    } catch (e) {
      debugPrint(e.toString());
    }
    appStore.setLoading(false);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            textRowButtonWidget(
              context: context,
              text: 'Line Items',
              buttonText:
                  comingDataList.isEmpty ? 'Add Estimation' : 'Edit Estimation',
              isLineItems: comingDataList.isNotEmpty,
              onTap: () async {
                List<LineItemData>? result = await Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return LineItemsEstimationScreen(
                    serviceId: widget.serviceId,
                    bookingId: widget.bookingId,
                    categoryId: widget.categoryId,
                    subCategoryId: widget.subCategoryId,
                    editableList: comingDataList,
                  );
                }));
                if (result != null) {
                  for (var i = 0; i < result.length; i++) {
                    debugPrint(
                        'result items: $i = ${result[i].name} ${result[i].qty}');
                  }
                  setState(() {
                    comingDataList = result;
                  });
                  await saveEstimationLineItems(
                    customerId: widget.customerId,
                    bookingId: widget.bookingId,
                    serviceId: widget.serviceId,
                  ).then((value) {
                    estimationDetailsData();
                  });
                }
              },
            ),
            if (comingDataList.isNotEmpty)
              SizedBox(
                height: 10,
              ),
            if (comingDataList.isNotEmpty)
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var item in comingDataList)
                      paymentItem(
                        name: item.name,
                        quantity: item.qty,
                        price: item.price.toDouble() *
                            num.parse(item.qty.toString()),
                      ),
                    Divider(),
                    totalAmount(totalAmount: calculateTotalInfo()),
                  ],
                ),
              ),
            if (estimationDetailsResponse?.estimation?.status == 0 ||
                // estimationDetailsResponse?.estimation?.status == 2 ||
                estimationDetailsResponse?.estimation?.status == 3)
              SizedBox(
                height: 10,
              ),
            if (estimationDetailsResponse?.estimation?.status == 0 ||
                // estimationDetailsResponse?.estimation?.status == 2 ||
                estimationDetailsResponse?.estimation?.status == 3)
              AppButton(
                onTap: () async {
                  estimationDetailsResponse?.estimation?.status == 2
                      ? {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => FinalInvoiceScreen(
                                  particulars: comingDataList)))
                        }
                      : estimationDetailsResponse?.estimation?.status == 3
                          ? {}
                          : {sendEstimationData()};
                },
                width: context.width(),
                color: primaryColor,
                text: estimationDetailsResponse?.estimation?.status == 2
                    ? 'View Invoice'
                    : estimationDetailsResponse?.estimation?.status == 3
                        ? 'Declined'
                        : 'Send Estimation',
              ),
          ],
        ).paddingOnly(left: 16, right: 16),
        Positioned.fill(
          child: appStore.isLoading ? LoaderWidget() : SizedBox(),
        ),
      ],
    );
  }
}
