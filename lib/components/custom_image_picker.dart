import 'dart:io';

import 'package:flutter/material.dart';
import 'package:trade/components/cached_image_widget.dart';
import 'package:trade/main.dart';
import 'package:trade/utils/common.dart';
import 'package:trade/utils/constant.dart';
import 'package:trade/utils/extensions/string_extension.dart';
import 'package:trade/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

class CustomImagePicker extends StatefulWidget {
  final Function(List<File> files) onFileSelected;
  final Function(String value)? onRemoveClick;
  final List<String>? selectedImages;
  final bool isGridTypeView;

  const CustomImagePicker({
    super.key,
    required this.onFileSelected,
    this.selectedImages,
    this.onRemoveClick,
    this.isGridTypeView = false,
  });

  @override
  _CustomImagePickerState createState() => _CustomImagePickerState();
}

class _CustomImagePickerState extends State<CustomImagePicker> {
  List<File> imageFiles = [];

  @override
  void initState() {
    super.initState();
    afterBuildCreated(() {
      init();
    });
  }

  void init() async {
    if (widget.selectedImages.validate().isNotEmpty) {
      widget.selectedImages.validate().forEach((element) {
        if (element.validate().contains("http")) {
          imageFiles.add(File(element.validate()));
        } else {
          imageFiles.add(File(element.validate()));
          widget.onFileSelected.call(imageFiles);
        }
      });
      setState(() {});
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  void showFun() async {
    await showInDialog(
      context,
      contentPadding: EdgeInsets.symmetric(vertical: 16),
      title: Text(languages.chooseAction, style: boldTextStyle()),
      builder: (p0) {
        return FilePickerDialog(isSelected: (false));
      },
    ).then((file) async {
      if (file != null) {
        if (file == GalleryFileTypes.CAMERA) {
          await getCameraImage().then((value) {
            if (imageFiles.validate().isNotEmpty) {
              imageFiles.insert(0, value);
            } else {
              imageFiles.add(value);
            }
            setState(() {});
          });
        } else if (file == GalleryFileTypes.GALLERY) {
          await getMultipleImageSource().then((value) {
            if (imageFiles.validate().isNotEmpty) {
              for (var element in value) {
                imageFiles.add(element);
              }
            } else {
              imageFiles = value;
            }
            setState(() {});
          });
        }
        widget.onFileSelected.call(imageFiles);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.isGridTypeView
        ? imageFiles.isEmpty
            ? DottedBorderWidget(
                color: context.primaryColor,
                radius: defaultRadius,
                child: Container(
                  padding: EdgeInsets.all(15),
                  alignment: Alignment.center,
                  decoration: boxDecorationWithShadow(
                      blurRadius: 0,
                      backgroundColor: context.cardColor,
                      borderRadius: radius()),
                  child: Column(
                    children: [
                      ic_add_image.iconImage(size: 30),
                      8.height,
                      Text(languages.chooseImage, style: secondaryTextStyle()),
                    ],
                  ),
                ),
              ).onTap(() {
                showFun();
              })
            : GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                ),
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: imageFiles.length + 1,
                itemBuilder: (context, index) {
                  return (imageFiles.length > index)
                      ? Stack(
                          clipBehavior: Clip.none,
                          children: [
                            if (imageFiles[index].path.contains("http"))
                              CachedImageWidget(
                                url: imageFiles[index].path,
                                height: 80,
                                width: 80,
                                fit: BoxFit.cover,
                                radius: defaultRadius,
                              )
                            else
                              Image.file(
                                File(imageFiles[index].path),
                                height: 80,
                                width: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return PlaceHolderWidget(
                                      height: 80, alignment: Alignment.center);
                                },
                              ).cornerRadiusWithClipRRect(defaultRadius),
                            Positioned(
                              top: -22,
                              right: -20,
                              child: IconButton(
                                onPressed: () {
                                  widget.onRemoveClick!
                                      .call(imageFiles[index].path);
                                },
                                icon: Icon(Icons.dangerous_outlined,
                                    color: Colors.red),
                              ),
                            )
                          ],
                        )
                      : DottedBorderWidget(
                          color: context.primaryColor,
                          radius: defaultRadius,
                          child: Container(
                            padding: EdgeInsets.all(15),
                            alignment: Alignment.center,
                            decoration: boxDecorationWithShadow(
                                blurRadius: 0,
                                backgroundColor: context.cardColor,
                                borderRadius: radius()),
                            child: ic_add_image.iconImage(size: 30),
                          ),
                        ).onTap(() {
                          showFun();
                        });
                },
              )
        : Column(
            key: widget.key,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () async {
                  await showInDialog(
                    context,
                    contentPadding: EdgeInsets.symmetric(vertical: 16),
                    title: Text(languages.chooseAction, style: boldTextStyle()),
                    builder: (p0) {
                      return FilePickerDialog(isSelected: (false));
                    },
                  ).then((file) async {
                    if (file != null) {
                      if (file == GalleryFileTypes.CAMERA) {
                        await getCameraImage().then((value) {
                          if (imageFiles.validate().isNotEmpty) {
                            imageFiles.insert(0, value);
                          } else {
                            imageFiles.add(value);
                          }
                          setState(() {});
                        });
                      } else if (file == GalleryFileTypes.GALLERY) {
                        await getMultipleImageSource().then((value) {
                          if (imageFiles.validate().isNotEmpty) {
                            for (var element in value) {
                              imageFiles.add(element);
                            }
                          } else {
                            imageFiles = value;
                          }
                          setState(() {});
                        });
                      }
                      widget.onFileSelected.call(imageFiles);
                    }
                  });
                },
                child: DottedBorderWidget(
                  color: context.primaryColor,
                  radius: defaultRadius,
                  child: Container(
                    padding: EdgeInsets.all(26),
                    alignment: Alignment.center,
                    decoration: boxDecorationWithShadow(
                        blurRadius: 0,
                        backgroundColor: context.cardColor,
                        borderRadius: radius()),
                    child: Column(
                      children: [
                        ic_no_photo.iconImage(size: 46),
                        8.height,
                        Text(languages.chooseImage,
                            style: secondaryTextStyle()),
                      ],
                    ),
                  ),
                ),
              ),
              16.height,
              Text(languages.selectImgNote,
                  style: secondaryTextStyle(size: 10)),
              16.height,
              HorizontalList(
                itemCount: imageFiles.length,
                spacing: 16,
                itemBuilder: (context, index) {
                  bool isNetworkImage = imageFiles[index].path.contains("http");
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      if (isNetworkImage)
                        CachedImageWidget(
                          url: imageFiles[index].path,
                          height: 80,
                          width: 80,
                          fit: BoxFit.cover,
                          radius: defaultRadius,
                        )
                      else
                        Image.file(
                          File(imageFiles[index].path),
                          height: 80,
                          width: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return PlaceHolderWidget(
                                height: 80, alignment: Alignment.center);
                          },
                        ).cornerRadiusWithClipRRect(defaultRadius),
                      Positioned(
                        top: -22,
                        right: -20,
                        child: IconButton(
                          onPressed: () {
                            widget.onRemoveClick!.call(imageFiles[index].path);
                          },
                          icon:
                              Icon(Icons.dangerous_outlined, color: Colors.red),
                        ),
                      )
                    ],
                  );
                },
              ),
            ],
          );
  }
}

class FilePickerDialog extends StatelessWidget {
  final bool isSelected;

  const FilePickerDialog({super.key, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: context.width(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SettingItemWidget(
            title: languages.removeImage,
            titleTextStyle: primaryTextStyle(),
            leading: Icon(Icons.close, color: context.iconColor),
            onTap: () {
              finish(context, GalleryFileTypes.CANCEL);
            },
          ).visible(isSelected),
          SettingItemWidget(
            title: languages.camera,
            titleTextStyle: primaryTextStyle(),
            leading: Icon(LineIcons.camera, color: context.iconColor),
            onTap: () {
              finish(context, GalleryFileTypes.CAMERA);
            },
          ).visible(!isWeb),
          SettingItemWidget(
            title: languages.lblGallery,
            titleTextStyle: primaryTextStyle(),
            leading: Icon(LineIcons.image_1, color: context.iconColor),
            onTap: () {
              finish(context, GalleryFileTypes.GALLERY);
            },
          ),
        ],
      ),
    );
  }
}
