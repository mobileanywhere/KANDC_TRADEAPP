import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nb_utils/nb_utils.dart';

class AddEstimatedLineItemDialogue extends StatefulWidget {
  final void Function(
      {required String item,
      required double price,
      required int quantity,
      String? description}) onAdd;
  final VoidCallback onCancel;

  const AddEstimatedLineItemDialogue({super.key, required this.onAdd, required this.onCancel});

  @override
  _AddEstimatedLineItemDialogueState createState() =>
      _AddEstimatedLineItemDialogueState();
}

class _AddEstimatedLineItemDialogueState
    extends State<AddEstimatedLineItemDialogue> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController itemController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Estimated Line Item'),
      content: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                textFieldType: TextFieldType.USERNAME,
                controller: itemController,
                decoration: InputDecoration(
                  labelText: 'Enter Item',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value == '') {
                    return 'Item should not be empty';
                  }
                  return null;
                },
                maxLines: 1,
              ).withWidth(MediaQuery.of(context).size.width * 1),
              10.height,
              AppTextField(
                textFieldType: TextFieldType.MULTILINE,
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description (Optional)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  return null;
                },
                maxLines: 3,
              ).withWidth(MediaQuery.of(context).size.width * 1),
              10.height,
              AppTextField(
                textFieldType: TextFieldType.NUMBER,
                controller: priceController,
                decoration: InputDecoration(
                  labelText: 'Enter Price',
                  border: OutlineInputBorder(),
                ),
                maxLines: 1,
                validator: (value) {
                  if (value == null || value == '') {
                    return 'Price should not be empty';
                  }
                  return null;
                },
              ).withWidth(MediaQuery.of(context).size.width * 1),
              10.height,
              AppTextField(
                textFieldType: TextFieldType.NUMBER,
                controller: quantityController,
                decoration: InputDecoration(
                  labelText: 'Enter Quantity',
                  border: OutlineInputBorder(),
                ),
                maxLines: 1,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value == '' || value == 0) {
                    return 'Quantity should not be empty';
                  }
                  return null;
                },
              ).withWidth(MediaQuery.of(context).size.width * 1),
            ],
          ),
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
            if (formKey.currentState!.validate()) {
              formKey.currentState!.save();
              hideKeyboard(context);
              Navigator.pop(context);
              widget.onAdd(
                  item: itemController.text,
                  price: priceController.text.toDouble(),
                  quantity: quantityController.text.toInt(),
                  description: descriptionController.text);
            }
          },
          child: Text('Add'),
        ),
      ],
    );
  }
}
