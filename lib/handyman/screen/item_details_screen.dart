import 'dart:io';

import 'package:flutter/material.dart';
import 'package:trade/components/back_widget.dart';
import 'package:trade/components/custom_image_picker.dart';
import 'package:trade/main.dart';
import 'package:trade/models/attachment_model.dart';
import 'package:trade/models/house_inspection_model.dart';
import 'package:trade/networks/rest_apis.dart';
import 'package:trade/utils/common.dart';
import 'package:trade/utils/configs.dart';
import 'package:nb_utils/nb_utils.dart';

class ItemDetailsScreen extends StatefulWidget {
  final HouseInspectionItemsData? item;
  const ItemDetailsScreen({super.key, this.item});

  @override
  State<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  UniqueKey uniqueKey = UniqueKey();
  TextEditingController commentsController = TextEditingController();

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

  Future<void> submitInspectionItem() async {
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
        'customer_id': appStore.userId,
        'description': commentsController.text,
        'attachment_count': '${imageFiles.length}',
      };

      await saveInspectionItem(value: req, imageFiles: imageFiles);
      appStore.setLoading(false);
    } catch (e) {
      debugPrint(e.toString());
      appStore.setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(widget.item?.item ?? '',
          textColor: white,
          elevation: 0.0,
          color: context.primaryColor,
          backWidget: BackWidget()),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              12.height,
              Text(
                widget.item?.item ?? '',
                style: primaryTextStyle(color: black, weight: FontWeight.bold),
              ),
              12.height,
              Text(
                widget.item?.description ?? '',
                style: primaryTextStyle(
                  color: gray,
                ),
              ),
              16.height,
              TextFormField(
                controller: commentsController,
                maxLines: 4,
                onChanged: (v) {},
                decoration: inputDecoration(context, hint: 'Comments'),
              ),
              16.height,
              CustomImagePicker(
                onRemoveClick: (value) {
                  if (tempAttachments.validate().isNotEmpty &&
                      imageFiles.isNotEmpty) {
                    showConfirmDialogCustom(
                      context,
                      dialogType: DialogType.DELETE,
                      positiveText: languages.lblDelete,
                      negativeText: languages.lblCancel,
                      onAccept: (p0) {
                        imageFiles
                            .removeWhere((element) => element.path == value);
                        removeAttachment(
                            id: tempAttachments
                                .validate()
                                .firstWhere((element) => element.url == value)
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
                        imageFiles
                            .removeWhere((element) => element.path == value);
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
              AppButton(
                text: languages.lblSubmit,
                width: context.width(),
                color: primaryColor,
                onTap: () async {
                  if (imageFiles.isEmpty) {
                    toast('Please select image');
                  } else {
                    await submitInspectionItem();
                    Navigator.pop(context, true);
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
