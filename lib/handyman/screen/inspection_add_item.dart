import 'dart:io';

import 'package:flutter/material.dart';
import 'package:trade/components/app_widgets.dart';
import 'package:trade/components/back_widget.dart';
import 'package:trade/components/custom_image_picker.dart';
import 'package:trade/main.dart';
import 'package:trade/models/inspection_area_items_model.dart';
import 'package:trade/networks/rest_apis.dart';
import 'package:trade/utils/common.dart';
import 'package:trade/utils/configs.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../models/attachment_model.dart';

class InspectionAddItem extends StatefulWidget {
  final String areaId;
  final String floor;
  const InspectionAddItem({super.key, required this.areaId, required this.floor});

  @override
  State<InspectionAddItem> createState() => _InspectionAddItemState();
}

class _InspectionAddItemState extends State<InspectionAddItem> {
  UniqueKey uniqueKey = UniqueKey();
  TextEditingController descriptionController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  FocusNode focusArea = FocusNode();
  FocusNode focusItems = FocusNode();

  // AreaData? selectedArea;
  // int? selectedAreaId;
  // List<AreaData> inspectionAreasList = [];

  AreaItem? selectedItem;
  int? selectedItemId;
  List<AreaItem> inspectionAreaItemsList = [];

  List<File> imageFiles = [];
  List<Attachments> tempAttachments = [];
  bool isUpdate = false;

  //region Remove Attachment
  Future<void> removeAttachment({required int id}) async {
    appStore.setLoading(true);
    tempAttachments.validate().removeWhere((element) => element.id == id);
    setState(() {});

    uniqueKey = UniqueKey();

    appStore.setLoading(false);
  }

  Future<void> getListOfAreas() async {
    try {
      await getListOfInspectionAreas();
      // inspectionAreasList.clear();
      // inspectionAreasList.addAll(res);
      setState(() {});
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> getListOfItems() async {
    try {
      var res = await getListOfInspectionAreaItems();
      inspectionAreaItemsList.clear();
      inspectionAreaItemsList.addAll(res);
      setState(() {});
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> futureList() async {
    Future.wait([getListOfItems()]);
  }

  Future<void> saveHouseItem() async {
    try {
      if ((!isUpdate && imageFiles.isEmpty) ||
          (isUpdate && imageFiles.isEmpty)) {
        toast(languages.pleaseSelectImages);
        return;
      }

      appStore.setLoading(true);
      setState(() {});
      hideKeyboard(context);

      Map<String, dynamic> req = {
        "customer_id": appStore.userId,
        "area_id": widget.areaId,
        "item_id": '$selectedItemId',
        "size": '',
        "description": descriptionController.text,
        'floor': widget.floor,
        "attachment_count": '${imageFiles.length}'
      };

      await addSaveHouseAreaItem(value: req, imageFiles: imageFiles);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    futureList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget('Add Item',
          textColor: white,
          elevation: 0.0,
          color: context.primaryColor,
          backWidget: BackWidget()),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: (appStore.isLoading)
                ? LoaderWidget().paddingTop(context.height() * 0.35)
                : Column(
                    children: [
                      // DropdownButtonFormField<AreaData>(
                      //   decoration: inputDecoration(context, hint: 'Area Name'),
                      //   style: primaryTextStyle(color: primaryColor),
                      //   isExpanded: true,
                      //   dropdownColor: context.cardColor,
                      //   menuMaxHeight: 300,
                      //   value: selectedArea,
                      //   items: inspectionAreasList.map((AreaData e) {
                      //     return DropdownMenuItem<AreaData>(
                      //       value: e,
                      //       child: Text(e.name ?? '',
                      //           style: primaryTextStyle(),
                      //           maxLines: 1,
                      //           overflow: TextOverflow.ellipsis),
                      //     );
                      //   }).toList(),
                      //   onChanged: (AreaData? value) async {
                      //     selectedAreaId = value?.id ?? 0;
                      //     setState(() {});
                      //   },
                      //   focusNode: focusArea,
                      //   validator: (value) {
                      //     if (value == null) {
                      //       return 'This is required field';
                      //     }
                      //     return null;
                      //   },
                      // ),
                      // 16.height,
                      DropdownButtonFormField<AreaItem>(
                        decoration: inputDecoration(context, hint: 'Items'),
                        style: primaryTextStyle(color: primaryColor),
                        isExpanded: true,
                        dropdownColor: context.cardColor,
                        menuMaxHeight: 300,
                        value: selectedItem,
                        items: inspectionAreaItemsList.map((AreaItem e) {
                          return DropdownMenuItem<AreaItem>(
                            value: e,
                            child: Text(e.name ?? '',
                                style: primaryTextStyle(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          );
                        }).toList(),
                        onChanged: (AreaItem? value) async {
                          selectedItemId = value?.id ?? 0;
                          setState(() {});
                        },
                        focusNode: focusItems,
                        validator: (value) {
                          if (value == null) {
                            return 'This is required field';
                          }
                          return null;
                        },
                      ),
                      16.height,
                      TextFormField(
                        controller: descriptionController,
                        maxLines: 4,
                        onChanged: (value) {},
                        decoration:
                            inputDecoration(context, hint: 'Description'),
                      ),
                      16.height,
                      CustomImagePicker(
                        isGridTypeView: true,
                        onRemoveClick: (value) {
                          if (tempAttachments.validate().isNotEmpty &&
                              imageFiles.isNotEmpty) {
                            showConfirmDialogCustom(
                              context,
                              dialogType: DialogType.DELETE,
                              positiveText: languages.lblDelete,
                              negativeText: languages.lblCancel,
                              onAccept: (p0) {
                                imageFiles.removeWhere(
                                    (element) => element.path == value);
                                removeAttachment(
                                    id: tempAttachments
                                        .validate()
                                        .firstWhere(
                                            (element) => element.url == value)
                                        .id
                                        .validate());
                              },
                            );
                          } else {
                            showConfirmDialogCustom(
                              context,
                              dialogType: DialogType.DELETE,
                              positiveText: languages.lblDelete,
                              negativeText: languages.lblCancel,
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
                      16.height,
                      appStore.isLoading
                          ? Loader()
                          : AppButton(
                              text: 'Save',
                              width: context.width(),
                              color: primaryColor,
                              onTap: () async {
                                hideKeyboard(context);
                                if (_formKey.currentState!.validate()) {
                                  _formKey.currentState!.save();
                                  if (imageFiles.isEmpty) {
                                    toast('Please select image.');
                                  } else {
                                    await saveHouseItem();
                                  }
                                }
                              },
                            )
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
