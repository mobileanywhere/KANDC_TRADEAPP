import 'package:flutter/material.dart';
import 'package:trade/main.dart';
import 'package:trade/models/caregory_response.dart';
import 'package:trade/models/main_types_model.dart';
import 'package:trade/models/service_model.dart';
import 'package:trade/networks/rest_apis.dart';
import 'package:trade/utils/common.dart';
import 'package:nb_utils/nb_utils.dart';

class CategorySubCatDropDown extends StatefulWidget {
  final int? categoryId;
  final int? subCategoryId;
  final int? serviceId;
  final int? mainTypeId;
  final int? mainSubTypeId;
  final Function(int? val) onCategorySelect;
  final Function(int? val) onSubCategorySelect;
  final Function(int? val) onServiceSelect;
  final Function(int? val) onMainTypeSelect;
  final Function(int? val) onMainSubTypeSelect;
  final bool? isCategoryValidate;
  final bool? isSubCategoryValidate;
  final bool? isServiceValidate;
  final bool? isMainTypeValidate;
  final bool? isMainSubTypeValidate;
  final Color? fillColor;
  final String? hintCategory;
  final String? hintService;
  final String? hintSubCategory;
  final String? hintMainType;
  final String? hintMainSubType;

  const CategorySubCatDropDown({super.key, 
    this.categoryId,
    this.subCategoryId,
    this.serviceId,
    this.mainTypeId,
    this.mainSubTypeId,
    required this.onSubCategorySelect,
    required this.onCategorySelect,
    required this.onServiceSelect,
    required this.onMainTypeSelect,
    required this.onMainSubTypeSelect,
    this.isSubCategoryValidate,
    this.isCategoryValidate,
    this.isServiceValidate,
    this.isMainTypeValidate,
    this.isMainSubTypeValidate,
    this.fillColor,
    this.hintService,
    this.hintCategory,
    this.hintSubCategory,
    this.hintMainType,
    this.hintMainSubType,
  });

  @override
  State<CategorySubCatDropDown> createState() => _CategorySubCatDropDownState();
}

class _CategorySubCatDropDownState extends State<CategorySubCatDropDown> {
  List<CategoryData> categoryList = [];
  List<CategoryData> subCategoryList = [];
  List<ServiceData> serviceList = [];
  List<MainTypesData> mainTypesList = [];
  List<MainTypesData> mainSubTypesList = [];

  CategoryData? selectedCategory;
  CategoryData? selectedSubCategory;
  ServiceData? selectedService;
  MainTypesData? selectedMainType;
  MainTypesData? selectedMainSubType;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    getTypes();
  }

  Future<void> getTypes() async {
    await getMainTypes().then((value) {
      mainTypesList = value;
      setState(() {});
    }).catchError((e) {
      log(e.toString());
    });
  }

  Future<void> getSubTypes({required int typeId}) async {
    await getMainSubTypes(typeId: typeId.toInt()).then((value) {
      mainSubTypesList = value.validate();
      setState(() {});
    }).catchError((e) {
      log(e.toString());
    });
  }

  Future<void> getServices(
      {required int categoryId, required int subcategoryId}) async {
    await searchServiceList(categoryId, subcategoryId).then((value) {
      serviceList = value;
      setState(() {});
    }).catchError((e) {
      log(e.toString());
    });
  }

  Future<void> getSubCategory({required int categoryId}) async {
    await getSubCategoryList(catId: categoryId.toInt()).then((value) {
      subCategoryList = value.data.validate();

      if (widget.subCategoryId != null) {
        selectedSubCategory = value.data!
            .firstWhere((element) => element.id == widget.subCategoryId);
        widget.onSubCategorySelect.call(selectedSubCategory?.id.validate());
      }

      setState(() {});
    }).catchError((e) {
      log(e.toString());
    });
  }

  Future<void> getCategory({required int id}) async {
    appStore.setLoading(true);

    await getCategoryList(id: id, perPage: 'all').then((value) {
      categoryList = value.data!;

      ///
      if (widget.categoryId != null) {
        ///
        selectedCategory = value.data!
            .firstWhere((element) => element.id == widget.categoryId);
        widget.onCategorySelect.call(selectedCategory?.id.validate());

        ///
        if (widget.subCategoryId != null) {
          getSubCategory(categoryId: selectedCategory!.id.validate());
        }
      }
      setState(() {});
    }).catchError((e) {
      toast(e.toString(), print: true);
    });

    appStore.setLoading(false);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  String getStringValue() {
    if (selectedCategory == null) {
      return languages.hintSelectCategory;
    } else {
      return languages.lblSelectSubCategory;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          DropdownButtonFormField<MainTypesData>(
            decoration: inputDecoration(context,
                fillColor: widget.fillColor ?? context.scaffoldBackgroundColor,
                hint: widget.hintMainType ?? languages.hintSelectCategory),
            value: selectedMainType,
            dropdownColor: context.scaffoldBackgroundColor,
            items: mainTypesList.map((data) {
              return DropdownMenuItem<MainTypesData>(
                value: data,
                child: Text(data.name.validate(), style: primaryTextStyle()),
              );
            }).toList(),
            validator: widget.isMainTypeValidate.validate(value: true)
                ? (value) {
                    if (value == null) return errorThisFieldRequired;
                    return null;
                  }
                : null,
            onChanged: (MainTypesData? value) async {
              selectedMainType = value!;
              widget.onMainTypeSelect.call(selectedMainType!.id.validate());

              if (widget.mainTypeId != null) {
                selectedMainSubType = null;
                mainSubTypesList.clear();
                widget.onMainSubTypeSelect.call(null);
              }
              setState(() {});
              getSubTypes(typeId: selectedMainType?.id ?? 0);
              setState(() {});
            },
          ),
          16.height,
          DropdownButtonFormField<MainTypesData>(
            decoration: inputDecoration(context,
                fillColor: widget.fillColor ?? context.scaffoldBackgroundColor,
                hint: widget.hintMainSubType ?? languages.hintSelectCategory),
            value: selectedMainSubType,
            dropdownColor: context.scaffoldBackgroundColor,
            items: mainSubTypesList.map((data) {
              return DropdownMenuItem<MainTypesData>(
                value: data,
                child: Text(data.name.validate(), style: primaryTextStyle()),
              );
            }).toList(),
            validator: widget.isMainSubTypeValidate.validate(value: true)
                ? (value) {
                    if (value == null) return errorThisFieldRequired;
                    return null;
                  }
                : null,
            onChanged: (MainTypesData? value) async {
              selectedMainSubType = value!;
              widget.onMainSubTypeSelect
                  .call(selectedMainSubType!.id.validate());

              if (selectedCategory != null) {
                selectedCategory = null;
                categoryList.clear();
                widget.onCategorySelect.call(null);
              }
              getCategory(id: value.id ?? 0);
              setState(() {});
            },
          ),
          16.height,
          DropdownButtonFormField<CategoryData>(
            decoration: inputDecoration(context,
                fillColor: widget.fillColor ?? context.scaffoldBackgroundColor,
                hint: widget.hintCategory ?? languages.hintSelectCategory),
            value: selectedCategory,
            dropdownColor: context.scaffoldBackgroundColor,
            items: categoryList.map((data) {
              return DropdownMenuItem<CategoryData>(
                value: data,
                child: Text(data.name.validate(), style: primaryTextStyle()),
              );
            }).toList(),
            validator: widget.isCategoryValidate.validate(value: true)
                ? (value) {
                    if (value == null) return errorThisFieldRequired;

                    return null;
                  }
                : null,
            onChanged: (CategoryData? value) async {
              selectedCategory = value!;
              widget.onCategorySelect.call(selectedCategory!.id.validate());

              if (selectedSubCategory != null) {
                selectedSubCategory = null;
                subCategoryList.clear();
                widget.onSubCategorySelect.call(null);
              }
              getSubCategory(categoryId: value.id.validate());
              setState(() {});
            },
          ),
          16.height,
          DropdownButtonFormField<CategoryData>(
            decoration: inputDecoration(context,
                fillColor: widget.fillColor ?? context.scaffoldBackgroundColor,
                hint: widget.hintSubCategory ?? getStringValue()),
            value: selectedSubCategory,
            dropdownColor: context.scaffoldBackgroundColor,
            validator: widget.isSubCategoryValidate.validate(value: false)
                ? (value) {
                    if (value == null) return errorThisFieldRequired;

                    return null;
                  }
                : null,
            items: subCategoryList.map((data) {
              return DropdownMenuItem<CategoryData>(
                value: data,
                child: Text(data.name.validate(), style: primaryTextStyle()),
              );
            }).toList(),
            onChanged: (CategoryData? value) async {
              selectedSubCategory = value!;
              widget.onSubCategorySelect
                  .call(selectedSubCategory!.id.validate());
              await getServices(
                  categoryId: selectedCategory?.id ?? 0,
                  subcategoryId: value.id!);
              setState(() {});
            },
          ),
          16.height,
          DropdownButtonFormField<ServiceData>(
            decoration: inputDecoration(context,
                fillColor: widget.fillColor ?? context.scaffoldBackgroundColor,
                hint: widget.hintService ?? getStringValue()),
            value: selectedService,
            dropdownColor: context.scaffoldBackgroundColor,
            items: serviceList.map((data) {
              return DropdownMenuItem<ServiceData>(
                value: data,
                child: Text(data.name.validate(), style: primaryTextStyle()),
              );
            }).toList(),
            onChanged: (ServiceData? value) async {
              selectedService = value!;
              widget.onServiceSelect.call(selectedService!.id.validate());
              setState(() {});
            },
            validator: widget.isServiceValidate.validate(value: false)
                ? (value) {
                    if (value == null) return errorThisFieldRequired;

                    return null;
                  }
                : null,
          ),
          16.height,
        ],
      ),
    );
  }
}
