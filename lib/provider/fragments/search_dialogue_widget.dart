import 'package:flutter/material.dart';
import 'package:trade/main.dart';
import 'package:trade/models/user_data_model.dart';
import 'package:trade/networks/rest_apis.dart';
import 'package:trade/provider/fragments/create_service_request.dart';
import 'package:trade/utils/common.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../handyman/screen/create_inspection_attribute_screen.dart';

class SearchDialogueWidget extends StatefulWidget {
  final bool createRequest;
  const SearchDialogueWidget({super.key, required this.createRequest});

  @override
  State<SearchDialogueWidget> createState() => _SearchDialogueWidgetState();
}

class _SearchDialogueWidgetState extends State<SearchDialogueWidget> {
  final TextEditingController _textFieldController = TextEditingController();
  List<UserDataHomeOwner> homeOwnerUserList = [];
  int page = 1;
  bool isLastPage = false;
  bool isSearched = false;

  Future<void> _fetchData(String key) async {
    try {
      final response = await fetchUserList(
          page: page,
          perPage: 10,
          key: key,
          userDataHomeOwnerList: homeOwnerUserList,
          lastPageCallback: (b) {
            isLastPage = b;
          });
      setState(() {
        homeOwnerUserList = response;
        isSearched = true;
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: context.height() * 0.3,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          10.height,
          Text('Search Home-Owner',style: boldTextStyle(size: 12,color: Colors.black)),
          5.height,
          AppTextField(
            textFieldType: TextFieldType.OTHER,
            controller: _textFieldController,
            onChanged: (value) {
              if (value.length == 3) {
                appStore.setLoading(true);
                _fetchData(value);
              } else if (value.isEmpty) {
                setState(() {
                  isSearched = false;
                });
              }
            },
            decoration: inputDecoration(context,

           ),
          ),
          SizedBox(height: 10),
          SizedBox(
            width: context.width() * 0.9,
            height: context.height() * 0.2,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  appStore.isLoading
                      ? Loader()
                      : (homeOwnerUserList.isEmpty && isSearched)
                          ? Center(
                              child: Column(
                                children: [
                                  50.height,
                                  Text(
                                    'Home-Owner Not Found!',
                                    style: primaryTextStyle(),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: homeOwnerUserList.length,
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  title: Text(
                                      '${homeOwnerUserList[index].firstName.validate()} ${homeOwnerUserList[index].lastName.validate()}'),
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    if (widget.createRequest) {
                                      CreateServiceRequest(
                                              customerId:
                                                  homeOwnerUserList[index]
                                                      .id
                                                      .toString(),
                                              customerAddress:
                                                  homeOwnerUserList[index]
                                                      .address,
                                              customerName:
                                                  '${homeOwnerUserList[index].firstName} ${homeOwnerUserList[index].lastName}')
                                          .launch(context);
                                    } else {
                                      // InspectionScreen(
                                      //   isFromSearching: true,
                                      //   projectManager: appStore.userFullName,
                                      //   ownerAddress: homeOwnerUserList[index]
                                      //       .address
                                      //       .validate(),
                                      //   searchedOwner:
                                      //       '${homeOwnerUserList[index].firstName.validate()} ${homeOwnerUserList[index].lastName.validate()}',
                                      // ).launch(context);
                                      CreateInspectionAttributeScreen(
                                        searchedOwner: homeOwnerUserList[index],
                                      ).launch(context);
                                    }
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
