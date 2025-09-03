import 'package:flutter/material.dart';
import 'package:trade/components/app_widgets.dart';
import 'package:trade/components/back_widget.dart';
import 'package:trade/main.dart';
import 'package:trade/models/estimation_response_details.dart';
import 'package:trade/models/invoice_data_model.dart';
import 'package:trade/models/line_item_response.dart';
import 'package:trade/networks/rest_apis.dart';
import 'package:trade/provider/services/stripe_service_singleton.dart';
import 'package:trade/screens/line_items_estimation_screen.dart';
import 'package:trade/utils/common.dart';
import 'package:trade/utils/configs.dart';
import 'package:trade/utils/constant.dart';
import 'package:nb_utils/nb_utils.dart';

class FinalInvoiceScreen extends StatefulWidget {
  final int bookingId;
  final int serviceId;
  final int categoryId;
  final int subCategoryId;
  final int customerId;
  final bool isViewInvoice;
  const FinalInvoiceScreen(
      {super.key,
      required this.bookingId,
      required this.serviceId,
      required this.categoryId,
      required this.subCategoryId,
      required this.customerId,
      required this.isViewInvoice});

  @override
  State<FinalInvoiceScreen> createState() => _FinalInvoiceScreenState();
}

class _FinalInvoiceScreenState extends State<FinalInvoiceScreen> {
  InvoiceDataModel? invoiceDataModel;
  final StripeService _stripeService = StripeService();
  TextEditingController? descriptionTextController;
  TextEditingController? amountTextController;
  bool isEntringAmount = false;
  String enteredAmount = '0';
  bool isLoading = false;

  //endregion
  List<LineItemData> comingDataList = [];
  Map<String, dynamic>? totalInfo;
  List<EstimationLineItemData> listOfLineItems = [];
  EstimationDetailsResponse? estimationDetailsResponse;
  List<LineItemData>? resultParticulars;
  double lineItemsTotal = 0;

  Widget paymentItem(
      {String? name, int? quantity, double? price, bool showQuantity = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$name${showQuantity ? ' x $quantity' : ''}',style: boldTextStyle(size: 12)),
          Text('\$${(price ?? 0) * (quantity ?? 0)}',style: boldTextStyle(size: 12)),
        ],
      ),
    );
  }

  Widget totalAmount({String? text, double? totalAmount}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(text ?? 'Total Amount',
              style: boldTextStyle(size: 12)),
          Text('\$${totalAmount?.toStringAsFixed(2)}',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: greenColor.withOpacity(0.6))),
        ],
      ),
    );
  }

  @override
  void initState() {
    descriptionTextController = TextEditingController();
    generateInvoice();
    super.initState();
  }

  @override
  void dispose() {
    descriptionTextController?.dispose();
    amountTextController?.dispose();
    super.dispose();
  }

// Usage example with error handling in a UI context
  void handlePayment(BuildContext context, String amount, String currency,
      String userEmail, String userName, String paymentType) async {
    try {
      final paymentResult = await _stripeService.stripePay(
        context: context,
        amount: amount,
        currency: currency,
        userEmail: userEmail,
        userName: userName,
      );

      if (paymentResult['status'] == 'success' ||
          paymentResult['status'] == 'processing') {
        // Handle successful payment
        Map req = {
          'booking_id': '${widget.bookingId}',
          'customer_id': '${appStore.userId}',
          'total_amount': '${paymentResult['amount']}',
          'datetime': '${paymentResult['datetime']}',
          'txn_id': '${paymentResult['transactionId']}',
          'payment_status': '${paymentResult['status']}',
          'payment_type': '${paymentResult['paymentType']}',
          'other_transaction_detail': '',
          'discount': '0',
        };

        try {
          // await savePayment(req).then((v) {
          //   showDialog(
          //     context: context,
          //     builder: (context) {
          //       return AlertDialog(
          //         title: Text('Payment Success'),
          //         content: Text(v.message ??
          //             'Transaction ID: ${paymentResult['transactionId']}'),
          //         actions: [
          //           TextButton(
          //             onPressed: () {
          //               generateInvoice();
          //               Navigator.pop(context);
          //             },
          //             child: Text('Okay'),
          //           ),
          //         ],
          //       );
          //     },
          //   );
          // });
        } catch (e) {
          toast('Something went wrong');
        }
      } else {
        // Handle payment error
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Payment Failed'),
              content: Text('Error: ${paymentResult['error']}'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Okay'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      // Handle general errors
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Payment Failed'),
            content: Text('Error: $e'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Okay'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> generateInvoice() async {
    setState(() {
      appStore.setLoading(true);
    });
    try {
      var request = {
        "customer_id": widget.customerId,
        "booking_id": widget.bookingId
      };
      var response = await getInvoice(request);
      invoiceDataModel = response;
      enteredAmount =
          '${invoiceDataModel?.bookingData?.booking?.amount ?? '0'}';
      amountTextController = TextEditingController(
          text: '${invoiceDataModel?.bookingData?.booking?.amount ?? '0'}');
    } finally {
      setState(() {
        appStore.setLoading(false);
      });
    }
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
      "amount": amountTextController?.text ?? '',
      "desc": descriptionTextController?.text ?? '',
      "lineitems": populateSList() == [] ? comList : populateSList()
    };

    // Conditionally add subcategoryId if it's not null
    req['sub_category_id'] = widget.subCategoryId ?? '0';
  
    // Conditionally add categoryId if it's not null
    req['category_id'] = widget.categoryId ?? '0';
  
    try {
      var res = await saveEstimationLists(req).then((value) {
        toast('Invoice generated successfully!');
        // setState(() {
        //   // comingDataList.clear();
        //   // listOfLineItems.clear();
        // });
        Navigator.of(context).pop(true);
      });
      // toast(res.message);
    } catch (e) {
      debugPrint(e.toString());
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget('Final Invoice',
          color: context.primaryColor,
          textColor: Colors.white,
          showBack: true,
          backWidget: BackWidget(),
          actions: [
            if (!widget.isViewInvoice)
              TextButton(
                onPressed: () async {
                  resultParticulars = await Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return LineItemsEstimationScreen(
                      serviceId: '${widget.serviceId}',
                      bookingId: widget.bookingId.toString(),
                      categoryId: widget.categoryId.toString(),
                      subCategoryId: widget.subCategoryId.toString(),
                      editableList: comingDataList,
                    );
                  }));
                  if (resultParticulars != null) {
                    for (var i = 0; i < resultParticulars!.length; i++) {
                      debugPrint(
                          'result items: $i = ${resultParticulars![i].name} ${resultParticulars![i].qty}');
                    }
                    setState(() {
                      comingDataList = resultParticulars ?? [];
                      lineItemsTotal = comingDataList.fold(0.0, (total, item) {
                        final itemPrice =
                            double.tryParse(item.price ?? '0') ?? 0.0;
                        final itemQty = item.qty ?? 0;
                        final itemTotal = itemPrice * itemQty;

                        // Debug prints to track calculations
                        print(
                            'Item: $item, Price: $itemPrice, Quantity: $itemQty, Item Total: $itemTotal');

                        return total + itemTotal;
                      });
                      print('lineItemsTotal: $lineItemsTotal');
                    });
                  }
                },
                child: Text(
                    comingDataList.isEmpty
                        ? 'Add Estimation'
                        : 'Edit Estimation',
                    style: boldTextStyle(color: white)),
              ).paddingRight(8),
          ]),
      body: appStore.isLoading
          ? Center(
              child: LoaderWidget(),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          invoiceDataModel?.bookingData?.booking?.serviceName ?? '',
                          style: boldTextStyle(size: 16)),
                      Row(
                        children: [
                          if (!widget.isViewInvoice)
                            if (!isEntringAmount)
                              IconButton(
                                icon: Icon(Icons.edit),
                                iconSize: 20,
                                onPressed: () {
                                  setState(() {
                                    isEntringAmount = true;
                                  });
                                },
                              ),
                          Text(
                              '\$${enteredAmount.isEmpty ? '0' : enteredAmount}',
                              style: boldTextStyle(size: 16)),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 6,
                  ),
                  Text(
                      invoiceDataModel?.bookingData?.booking?.date != null ? '(${formatDate(invoiceDataModel?.bookingData?.booking?.date.validate())})' : '',
                      style: secondaryTextStyle(
                        color: Colors.white,
                          size: 12, fontStyle: FontStyle.italic)),
                  SizedBox(
                    height: isEntringAmount ? 20 : 10,
                  ),
                  if (isEntringAmount)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Amount',
                            style: boldTextStyle(size: LABEL_TEXT_SIZE)),
                        SizedBox(
                          height: 10,
                        ),
                        AppTextField(
                          textFieldType: TextFieldType.NUMBER,
                          controller: amountTextController,
                          onChanged: (v) {
                            setState(() {
                              enteredAmount = v;
                            });
                          },
                          onFieldSubmitted: (v) {
                            setState(() {
                              isEntringAmount = false;
                            });
                          },
                          keyboardType: TextInputType.number,
                          decoration: inputDecoration(context).copyWith(
                            hintText: 'Enter Amount',
                            hintStyle: secondaryTextStyle(),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  Divider(),
                  SizedBox(
                    height: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Particulars',
                          style: boldTextStyle(size: LABEL_TEXT_SIZE)),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (widget.isViewInvoice)
                              if (invoiceDataModel?.lineitemData != null &&
                                  invoiceDataModel!.lineitemData!.isNotEmpty)
                                for (var item
                                    in invoiceDataModel!.lineitemData!)
                                  paymentItem(
                                    name: item.lineItemName,
                                    quantity: item.lineItemQty,
                                    price: item.lineItemPrice.toDouble(),
                                  )
                              else
                                Text('No Items Found!',style: boldTextStyle(size: 12)),
                            if (!widget.isViewInvoice)
                              if (comingDataList.isNotEmpty)
                                for (var item in comingDataList)
                                  paymentItem(
                                    name: item.name,
                                    quantity: item.qty,
                                    price: item.price.toDouble(),
                                  )
                              else
                                Text('No Items Found!',style: boldTextStyle(size: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Divider(),
                  SizedBox(
                    height: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Payment Summary',
                          style: boldTextStyle(size: LABEL_TEXT_SIZE)),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // for (var item in paymentSummaryList)
                            paymentItem(
                                name: 'Sub Total',
                                quantity: 1,
                                price: widget.isViewInvoice
                                    ? (invoiceDataModel?.bookingData?.booking
                                                ?.finalSubTotal ??
                                            0)
                                        .toDouble()
                                    : (enteredAmount
                                                .toDouble() + // Ensure enteredAmount is double
                                            lineItemsTotal // Ensure total price is double
                                        ) // (invoiceDataModel?.bookingData?.booking?.totalAmount?.toDouble() ?? 0.0) // Ensure totalAmount is double or default to 0.0
                                        .toDouble(),
                                showQuantity: false),
                            paymentItem(
                                name: 'Taxes and Fee',
                                quantity: 1,
                                price: (invoiceDataModel
                                        ?.bookingData?.booking?.finalTotalTax
                                        ?.toDouble() ??
                                    0.0),
                                showQuantity: false),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Divider(),
                  totalAmount(
                      totalAmount: widget.isViewInvoice
                          ? (invoiceDataModel
                                      ?.bookingData?.booking?.totalAmount ??
                                  0)
                              .toDouble()
                          : (enteredAmount.toDouble() +
                              lineItemsTotal +
                              (invoiceDataModel
                                      ?.bookingData?.booking?.finalTotalTax
                                      ?.toDouble() ??
                                  0.0))),
                  Divider(),
                  SizedBox(
                    height: 20,
                  ),
                  Text('Description',
                      style: boldTextStyle(size: LABEL_TEXT_SIZE)),
                  SizedBox(
                    height: 10,
                  ),
                  widget.isViewInvoice
                      ? Text(
                          invoiceDataModel?.bookingData?.booking?.description ??
                              '',
                          style: secondaryTextStyle(
                              size: 12, fontStyle: FontStyle.italic))
                      : AppTextField(
                          textFieldType: TextFieldType.OTHER,
                          controller: descriptionTextController,
                          onTap: () {},
                          maxLines: 3,
                          keyboardType: TextInputType.text,
                          decoration: inputDecoration(context).copyWith(
                            hintText: 'Enter Description',
                            hintStyle: secondaryTextStyle(),
                            labelStyle:  boldTextStyle(size: 12)
                          ),
                        ),
                  SizedBox(
                    height: 40,
                  ),
                  if (!widget.isViewInvoice)
                    AppButton(
                      onTap: () async {
                        setState(() {
                          isLoading = true;
                        });
                        await saveEstimationLineItems(
                          customerId: '${widget.customerId}',
                          bookingId: '${widget.bookingId}',
                          serviceId: '${widget.serviceId}',
                        ).then((value) {
                          // estimationDetailsData();
                        });
                      },
                      width: context.width(),
                      color: primaryColor,
                      text: 'Generate Invoice',
                      child: isLoading ? Loader() : null,
                    ),
                ],
              ).paddingAll(16),
            ),
    );
  }
}
