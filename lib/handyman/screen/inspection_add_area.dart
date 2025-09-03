import 'dart:io';

import 'package:flutter/material.dart';
import 'package:trade/components/app_widgets.dart';
import 'package:trade/components/back_widget.dart';
import 'package:trade/components/custom_image_picker.dart';
import 'package:trade/main.dart';
import 'package:trade/models/inspection_areas_model.dart';
import 'package:trade/models/sample_area_name_response.dart';
import 'package:trade/networks/rest_apis.dart';
import 'package:trade/utils/common.dart';
import 'package:trade/utils/configs.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../models/attachment_model.dart';

class InspectionAddArea extends StatefulWidget {
  const InspectionAddArea({super.key});

  @override
  State<InspectionAddArea> createState() => _InspectionAddAreaState();
}

class _InspectionAddAreaState extends State<InspectionAddArea> {
  UniqueKey uniqueKey = UniqueKey();
  TextEditingController sizeController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  FocusNode focusFloor = FocusNode();
  FocusNode focusArea = FocusNode();

  AreaData? selectedArea;
  int? selectedAreaId;
  List<AreaData> inspectionAreasList = [];

  SampleAreaNameResponse? selectedFloor;
  String? selectedFloorId;
  List<SampleAreaNameResponse> floorNameList = [
    SampleAreaNameResponse(
      name: 'Basement',
      id: 1,
    ),
    SampleAreaNameResponse(
      name: 'Ground Floor',
      id: 2,
    ),
    SampleAreaNameResponse(
      name: 'First Floor',
      id: 3,
    ),
    SampleAreaNameResponse(
      name: 'Second Floor',
      id: 4,
    ),
    SampleAreaNameResponse(
      name: 'Third Floor',
      id: 5,
    ),
    SampleAreaNameResponse(
      name: 'Fourth Floor',
      id: 6,
    ),
    SampleAreaNameResponse(
      name: 'Fifth Floor',
      id: 7,
    ),
  ];

  List<File> imageFiles = [];
  List<Attachments> tempAttachments = [];
  bool isUpdate = false;

  //region Remove Attachment
  Future<void> removeAttachment({required int id}) async {
    appStore.setLoading(true);

    // Map req = {
    //   CommonKeys.type: BLOG_ATTACHMENT,
    //   CommonKeys.id: id,
    // };

    // await deleteImage(req).then((value) {
    tempAttachments.validate().removeWhere((element) => element.id == id);
    setState(() {});

    uniqueKey = UniqueKey();

    appStore.setLoading(false);
    //   toast(value.message.validate(), print: true);
    // }).catchError((e) {
    //   appStore.setLoading(false);
    //   toast(e.toString(), print: true);
    // });
  }

  Future<void> getListOfAreas() async {
    try {
      var res = await getListOfInspectionAreas();
      inspectionAreasList.clear();
      inspectionAreasList.addAll(res);
      setState(() {});
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> saveHouseArea() async {
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
        'area_id': '$selectedAreaId',
        'item_id': '',
        'size': sizeController.text,
        'description': descriptionController.text,
        'attachment_count': '${imageFiles.length}',
        'floor': selectedFloorId ?? ''
      };

      await addSaveHouseArea(value: req, imageFiles: imageFiles);
      appStore.setLoading(false);
    } catch (e) {
      debugPrint(e.toString());
      appStore.setLoading(false);
    }
  }

  @override
  void initState() {
    super.initState();
    getListOfAreas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget('Add Area',
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
            child: (appStore.isLoading && inspectionAreasList.isEmpty)
                ? LoaderWidget().paddingTop(context.height() * 0.35)
                : Column(
                    children: [
                      DropdownButtonFormField<SampleAreaNameResponse>(
                        decoration: inputDecoration(context, hint: 'Floor'),
                        style: primaryTextStyle(color: primaryColor),
                        isExpanded: true,
                        dropdownColor: context.cardColor,
                        menuMaxHeight: 300,
                        value: selectedFloor,
                        items: floorNameList.map((SampleAreaNameResponse e) {
                          return DropdownMenuItem<SampleAreaNameResponse>(
                            value: e,
                            child: Text(e.name ?? '',
                                style: primaryTextStyle(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          );
                        }).toList(),
                        onChanged: (SampleAreaNameResponse? value) async {
                          selectedFloorId = value?.name ?? '';
                          setState(() {});
                        },
                        focusNode: focusFloor,
                        validator: (value) {
                          if (value == null) {
                            return 'This field is required.';
                          }
                          return null;
                        },
                      ),
                      16.height,
                      DropdownButtonFormField<AreaData>(
                        decoration: inputDecoration(context, hint: 'Area Name'),
                        style: primaryTextStyle(color: primaryColor),
                        isExpanded: true,
                        dropdownColor: context.cardColor,
                        menuMaxHeight: 300,
                        value: selectedArea,
                        items: inspectionAreasList.map((AreaData e) {
                          return DropdownMenuItem<AreaData>(
                            value: e,
                            child: Text(e.name ?? '',
                                style: primaryTextStyle(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          );
                        }).toList(),
                        onChanged: (AreaData? value) async {
                          selectedAreaId = value?.id ?? 0;
                          setState(() {});
                        },
                        focusNode: focusArea,
                        validator: (value) {
                          if (value == null) {
                            return 'This field is required.';
                          }
                          return null;
                        },
                      ),
                      16.height,
                      AppTextField(
                        textFieldType: TextFieldType.NAME,
                        controller: sizeController,
                        isValidationRequired: false,
                        onChanged: (value) {},
                        decoration: inputDecoration(context, hint: 'Size'),
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
                                    toast('Please select image');
                                  } else {
                                    await saveHouseArea();
                                    Navigator.pop(context, true);
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
