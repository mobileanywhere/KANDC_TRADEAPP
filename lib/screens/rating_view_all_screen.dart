import 'package:flutter/material.dart';
import 'package:trade/components/back_widget.dart';
import 'package:trade/components/review_list_view_component.dart';
import 'package:trade/main.dart';
import 'package:trade/models/booking_detail_response.dart';
import 'package:trade/networks/rest_apis.dart';
import 'package:trade/screens/shimmer/review_shimmer.dart';
import 'package:trade/utils/model_keys.dart';
import 'package:nb_utils/nb_utils.dart';

import '../components/empty_error_state_widget.dart';

/// Pass serviceId if you want to get service reviews
/// Pass handymanId if you want to get handyman reviews
/// Pass any one at a time
class RatingViewAllScreen extends StatelessWidget {
  final int? serviceId;
  final int? handymanId;
  final String? title;
  final bool showServiceName;

  const RatingViewAllScreen({super.key, this.serviceId, this.handymanId, this.title, this.showServiceName = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(title ?? languages.lblServiceRatings, color: context.primaryColor, textColor: Colors.white, backWidget: BackWidget()),
      body: SnapHelperWidget<List<RatingData>>(
        future: serviceId != null ? serviceReviews({CommonKeys.serviceId: serviceId}) : handymanReviews({CommonKeys.handymanId: handymanId}),
        loadingWidget: ReviewShimmer(),
        onSuccess: (data) {
          if (data.isNotEmpty) {
            return ReviewListViewComponent(ratings: data, isCustomer: true, showServiceName: showServiceName);
          } else {
            return NoDataWidget(
              title: languages.getYourFirstReview,
              subTitle: languages.ratingViewAllSubtitle,
              imageWidget: EmptyStateWidget(),
            );
          }
        },
      ),
    );
  }
}
