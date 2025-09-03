import 'package:flutter/material.dart';
import 'package:trade/main.dart';
import 'package:trade/models/user_data.dart';
import 'package:trade/networks/rest_apis.dart';
import 'package:trade/utils/common.dart';
import 'package:nb_utils/nb_utils.dart';

class SearchTechnicianWidget extends StatefulWidget {
  final Function(UserData) onSelectingTechnician;
  final bool isFromBookingFragment;
  final String? initialValue;
  const SearchTechnicianWidget(
      {super.key,
      required this.onSelectingTechnician,
      this.initialValue,
      this.isFromBookingFragment = false});

  @override
  State<SearchTechnicianWidget> createState() => _SearchTechnicianWidgetState();
}

class _SearchTechnicianWidgetState extends State<SearchTechnicianWidget> {
  TextEditingController? _textFieldController;
  List<UserData> technicianList = [];
  int page = 1;
  bool isLastPage = false;
  bool isSearched = false;

  @override
  void initState() {
    super.initState();
    _textFieldController = TextEditingController(text: widget.initialValue);
  }

  Future<void> _fetchData(String key) async {
    try {
      getHandyman(
              key: _textFieldController?.text,
              providerId: appStore.userId,
              list: technicianList,
              page: 1)
          .then((value) {
        technicianList = value;
        setState(() {});
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.isFromBookingFragment ? context.width() * 0.9 : null,
      height: technicianList.isEmpty ? null : context.height() * 0.3,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          AppTextField(
            scrollPadding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 14 * 4),
            textFieldType: TextFieldType.OTHER,
            controller: _textFieldController,
            onChanged: (value) {
              if (value.length == 3) {
                appStore.setLoading(true);
                _fetchData(value);
              } else if (value.isEmpty) {
                setState(() {
                  isSearched = false;
                  technicianList = [];
                });
              }
            },
            decoration: inputDecoration(context,
                hint: 'Search Trade', fillColor: context.cardColor),
          ),
          if (technicianList.isNotEmpty) SizedBox(height: 10),
          technicianList.isEmpty
              ? SizedBox()
              : SizedBox(
                  width: context.width() * 0.9,
                  height: context.height() * 0.2,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        appStore.isLoading
                            ? Loader()
                            : (technicianList.isEmpty && isSearched)
                                ? Center(
                                    child: Column(
                                      children: [
                                        50.height,
                                        Text(
                                          'Trade Not Found!',
                                          style: primaryTextStyle(),
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: technicianList.length,
                                    physics: NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      return ListTile(
                                        title: Text(
                                            '${technicianList[index].firstName.validate()} ${technicianList[index].lastName.validate()}'),
                                        onTap: () {
                                          widget.onSelectingTechnician(
                                              technicianList[index]);
                                          _textFieldController?.text =
                                              '${technicianList[index].firstName.validate()} ${technicianList[index].lastName.validate()}';
                                          technicianList.clear();
                                          setState(() {});
                                        },
                                      );
                                    }),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
