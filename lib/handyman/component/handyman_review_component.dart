import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:trade/components/app_widgets.dart';
import 'package:trade/components/review_list_view_component.dart';
import 'package:trade/components/view_all_label_component.dart';
import 'package:trade/main.dart';
import 'package:trade/models/booking_detail_response.dart';
import 'package:trade/screens/rating_view_all_screen.dart';
import 'package:nb_utils/nb_utils.dart';

class HandymanReviewComponent extends StatefulWidget {
  final List<RatingData>? reviews;

  const HandymanReviewComponent({super.key, this.reviews});

  @override
  _HandymanReviewComponentState createState() =>
      _HandymanReviewComponentState();
}

class _HandymanReviewComponentState extends State<HandymanReviewComponent> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ViewAllLabel(
              label: languages.review,
              list: widget.reviews!,
              onTap: () {
                RatingViewAllScreen(
                        handymanId: appStore.userId,
                        title: languages.review,
                        showServiceName: true)
                    .launch(context);
              },
            ).paddingSymmetric(horizontal: 16),
            ReviewListViewComponent(
              ratings: widget.reviews!,
              physics: NeverScrollableScrollPhysics(),
              showServiceName: true,
              isCustomer: true,
              padding: EdgeInsets.only(left: 16, right: 16, bottom: 8, top: 16),
            ),
            Observer(
              builder: (_) => Text(
                languages.lblNoReviewYet,
                style: secondaryTextStyle(),
              )
                  .center()
                  .visible(!appStore.isLoading && widget.reviews!.isEmpty),
            ),
          ],
        ),
        Observer(
          builder: (_) => LoaderWidget().center().visible(appStore.isLoading),
        ),
      ],
    );
  }
}
