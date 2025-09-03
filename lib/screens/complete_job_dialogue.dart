import 'dart:io';

import 'package:flutter/material.dart';
import 'package:trade/components/custom_image_picker.dart';
import 'package:trade/models/attachment_model.dart';
import 'package:nb_utils/nb_utils.dart';

class CompleteJobDialogue extends StatefulWidget {
  final void Function(
          List<File> images, List<Attachments> attachments, String description)
      onComplete;
  final VoidCallback onCancel;

  const CompleteJobDialogue({super.key, required this.onComplete, required this.onCancel});

  @override
  _CompleteJobDialogueState createState() => _CompleteJobDialogueState();
}

class _CompleteJobDialogueState extends State<CompleteJobDialogue> {
  final TextEditingController descriptionController = TextEditingController();
  UniqueKey uniqueKey = UniqueKey();
  List<File> imageFiles = [];
  List<Attachments> tempAttachments = [];
  bool isUpdate = false;

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Do you want to end this service?'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              textFieldType: TextFieldType.MULTILINE,
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Description (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ).withWidth(MediaQuery.of(context).size.width * 1),
            10.height,
            CustomImagePicker(
              key: uniqueKey,
              isGridTypeView: false,
              onRemoveClick: (value) {
                if (tempAttachments.validate().isNotEmpty &&
                    imageFiles.isNotEmpty) {
                  showConfirmDialogCustom(
                    context,
                    dialogType: DialogType.DELETE,
                    positiveText: 'Delete',
                    negativeText: 'Cancel',
                    onAccept: (p0) {
                      imageFiles
                          .removeWhere((element) => element.path == value);
                      // removeAttachment(id: tempAttachments.validate().firstWhere((element) => element.url == value).id.validate());
                    },
                  );
                } else {
                  showConfirmDialogCustom(
                    context,
                    dialogType: DialogType.DELETE,
                    positiveText: 'Delete',
                    negativeText: 'Cancel',
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
              selectedImages:
                  imageFiles.validate().map((e) => e.path.validate()).toList(),
              onFileSelected: (List<File> files) async {
                imageFiles = files;
                setState(() {});
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.onCancel();
            hideKeyboard(context);
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            widget.onComplete(
                imageFiles, tempAttachments, descriptionController.text);
            hideKeyboard(context);
            Navigator.of(context).pop();
          },
          child: Text('Complete'),
        ),
      ],
    );
  }
}
