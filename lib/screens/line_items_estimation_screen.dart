import 'package:flutter/material.dart';
import 'package:trade/components/app_widgets.dart';
import 'package:trade/components/back_widget.dart';
import 'package:trade/models/line_item_response.dart';
import 'package:trade/networks/rest_apis.dart';
import 'package:trade/screens/add_estimated_line_item.dart';
import 'package:trade/utils/configs.dart';
import 'package:nb_utils/nb_utils.dart';

class LineItemsEstimationScreen extends StatefulWidget {
  final Map<String, dynamic>? editableCountMap;
  final String serviceId;
  final String bookingId;
  final String? categoryId;
  final String? subCategoryId;
  final List<LineItemData> editableList;
  const LineItemsEstimationScreen(
      {super.key,
      required this.serviceId,
      required this.bookingId,
      this.categoryId,
      this.subCategoryId,
      this.editableCountMap,
      required this.editableList});

  @override
  State<LineItemsEstimationScreen> createState() =>
      _LineItemsEstimationScreenState();
}

class _LineItemsEstimationScreenState extends State<LineItemsEstimationScreen> {
  List<LineItemData> lineItemsData = [];
  List<LineItemData> savedItems = [];
  bool loader = false;

  void _incrementItemCount(int index) {
    setState(() {
      lineItemsData[index].qty = (lineItemsData[index].qty ?? 0) + 1;
      debugPrint('increment data: ${lineItemsData[index].qty}');
    });
  }

  void _decrementItemCount(int index) {
    if (lineItemsData[index].qty! > 0) {
      setState(() {
        lineItemsData[index].qty = (lineItemsData[index].qty ?? 0) - 1;
        debugPrint('decrement data: ${lineItemsData[index].qty}');
      });
    }
  }

  void getAllLineItemsData() async {
    setState(() {
      loader = true;
    });
    var req = {
      'service_id': widget.serviceId,
      'booking_id': widget.bookingId,
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
      var res = await getAllLineItems(req);

      setState(() {
        // Clear the existing data in lineItemsData
        lineItemsData.clear();

        // Add items from res list
        if (res.isNotEmpty) {
          lineItemsData.addAll(res);
        }

        // Add or update items from editableList
        if (widget.editableList.isNotEmpty) {
          for (var editableItem in widget.editableList) {
            var existingIndex = lineItemsData.indexWhere(
              (item) => item.id == editableItem.id,
            );

            if (existingIndex != -1) {
              // Update the data for the existing item
              lineItemsData[existingIndex] = editableItem;
            } else {
              // Add the item to lineItemsData if it doesn't exist
              lineItemsData.add(editableItem);
            }
          }
        }
      });
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() {
        loader = false;
      });
    }
  }

  Future<void> addNewLineItem(
      {required String item,
      required double price,
      required int quantity,
      String? description}) async {
    setState(() {
      loader = true;
    });
    var req = {
      'booking_id': widget.bookingId,
      'name': item,
      'price': '$price',
      'qty': '$quantity',
      'description': description ?? ''
    };
    try {
      await addLineItem(req).then((value) {
        getAllLineItemsData();
      });
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() {
        loader = false;
      });
    }
  }

  Future<void> deleteNewLineItem({required String id}) async {
    setState(() {
      loader = true;
    });
    var req = {'booking_id': widget.bookingId, 'id': id};
    try {
      await deleteLineItem(req).then((value) {
        getAllLineItemsData();
      });
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() {
        loader = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getAllLineItemsData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget('Estimated Items',
          textColor: white,
          elevation: 0.0,
          color: context.primaryColor,
          backWidget: BackWidget(),
          actions: [
            GestureDetector(
              onTap: () async {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AddEstimatedLineItemDialogue(
                      onAdd: (
                          {required String item,
                          required double price,
                          required int quantity,
                          String? description}) async {
                        await addNewLineItem(
                            item: item,
                            price: price,
                            quantity: quantity,
                            description: description);
                      },
                      onCancel: () {
                        // Handle cancel action
                      },
                    );
                  },
                );
              },
              child: Container(
                  decoration: boxDecorationDefault(color: white),
                  margin: EdgeInsets.symmetric(horizontal: 12),
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.add,
                        color: primaryColor,
                      ),
                      5.width,
                      Text(
                        'Add Item',
                        style: primaryTextStyle(
                            color: primaryColor, weight: FontWeight.bold),
                      ),
                    ],
                  )),
            ),
          ]),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: ListView.builder(
                      itemCount: lineItemsData.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: EdgeInsets.all(8.0),
                          child: ListTile(
                            title: Text(
                              lineItemsData[index].name ?? '',
                              style: primaryTextStyle(weight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              '\$${lineItemsData[index].price.toDouble().toStringAsFixed(2)}',
                              style: secondaryTextStyle(size: 16),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.remove),
                                  onPressed: () {
                                    _decrementItemCount(index);
                                  },
                                ),
                                Text(
                                  lineItemsData[index].qty.toString(),
                                  style: primaryTextStyle(),
                                ),
                                IconButton(
                                  icon: Icon(Icons.add),
                                  onPressed: () {
                                    _incrementItemCount(index);
                                  },
                                ),
                                if (lineItemsData[index].categoryId == null ||
                                    lineItemsData[index].categoryId == 0)
                                  Icon(
                                    Icons.delete_rounded,
                                    color: redColor,
                                    size: 20,
                                  ).onTap(() async {
                                    await deleteNewLineItem(
                                        id: '${lineItemsData[index].id}');
                                  }),
                              ],
                            ),
                          ),
                        );
                      }),
                ),
                AppButton(
                  onTap: () {
                    setState(() {
                      savedItems.addAll(
                          lineItemsData.where((element) => element.qty! > 0));
                    });
                    for (var i = 0; i < lineItemsData.length; i++) {
                      debugPrint(
                          'lineItemsData items: $i = ${lineItemsData[i].name} ${lineItemsData[i].qty}');
                    }
                    for (var i = 0; i < savedItems.length; i++) {
                      debugPrint(
                          'saved items: $i = ${savedItems[i].name} ${savedItems[i].qty}');
                    }
                    Navigator.of(context).pop(savedItems);
                  },
                  width: context.width(),
                  color: primaryColor,
                  text: 'Save',
                ),
              ],
            ),
            if (loader) Positioned.fill(child: Center(child: LoaderWidget()))
          ],
        ),
      ),
    );
  }
}
