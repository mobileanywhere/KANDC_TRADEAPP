import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:trade/main.dart';
import 'package:trade/models/dashboard_response.dart';
import 'package:trade/networks/rest_apis.dart';
import 'package:trade/provider/components/chart_component.dart';
import 'package:trade/provider/components/handyman_list_component.dart';
import 'package:trade/provider/components/handyman_recently_online_component.dart';
import 'package:trade/provider/components/job_list_component.dart';
import 'package:trade/provider/components/services_list_component.dart';
import 'package:trade/provider/components/total_component.dart';
import 'package:trade/provider/fragments/search_dialogue_widget.dart';
import 'package:trade/provider/fragments/shimmer/provider_dashboard_shimmer.dart';
import 'package:trade/provider/subscription/pricing_plan_screen.dart';
import 'package:trade/screens/cash_management/component/today_cash_component.dart';
import 'package:trade/utils/common.dart';
import 'package:trade/utils/configs.dart';
import 'package:trade/utils/constant.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/app_widgets.dart';
import '../../components/empty_error_state_widget.dart';
import '../components/upcoming_booking_component.dart';

class ProviderHomeFragment extends StatefulWidget {
  final void Function(int, {String? statusType}) switchToFragmentCallback;
  const ProviderHomeFragment({super.key, required this.switchToFragmentCallback});
  @override
  _ProviderHomeFragmentState createState() => _ProviderHomeFragmentState();
}

class _ProviderHomeFragmentState extends State<ProviderHomeFragment> {
  int page = 1;

  int currentIndex = 0;

  late Future<DashboardResponse> future;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    future = providerDashboard();
  }

  Widget _buildHeaderWidget(DashboardResponse data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        16.height,
        Text("${languages.lblHello}, ${appStore.userFullName}",
                style: boldTextStyle(size: 16))
            .paddingLeft(16),
        8.height,
        Text(languages.lblWelcomeBack, style: secondaryTextStyle(size: 14))
            .paddingLeft(16),
        16.height,
      ],
    );
  }

  Widget planBanner(DashboardResponse data) {
    if (data.isPlanExpired.validate()) {
      return subSubscriptionPlanWidget(
        planBgColor:
            appStore.isDarkMode ? context.cardColor : Colors.red.shade50,
        planTitle: languages.lblPlanExpired,
        planSubtitle: languages.lblPlanSubTitle,
        planButtonTxt: languages.btnTxtBuyNow,
        btnColor: Colors.red,
        onTap: () {
          PricingPlanScreen().launch(context);
        },
      );
    } else if (data.userNeverPurchasedPlan.validate()) {
      return subSubscriptionPlanWidget(
        planBgColor:
            appStore.isDarkMode ? context.cardColor : Colors.red.shade50,
        planTitle: languages.lblChooseYourPlan,
        planSubtitle: languages.lblRenewSubTitle,
        planButtonTxt: languages.btnTxtBuyNow,
        btnColor: Colors.red,
        onTap: () {
          PricingPlanScreen().launch(context);
        },
      );
    } else if (data.isPlanAboutToExpire.validate()) {
      int days = getRemainingPlanDays();

      if (days != 0 && days <= PLAN_REMAINING_DAYS) {
        return subSubscriptionPlanWidget(
          planBgColor:
              appStore.isDarkMode ? context.cardColor : Colors.orange.shade50,
          planTitle: languages.lblReminder,
          planSubtitle: languages.planAboutToExpire(days),
          planButtonTxt: languages.lblRenew,
          btnColor: Colors.orange,
          onTap: () {
            PricingPlanScreen().launch(context);
          },
        );
      } else {
        return SizedBox();
      }
    } else {
      return SizedBox();
    }
  }

  Future<void> _showDialog(BuildContext context,
      {required bool createRequest}) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              content: SearchDialogueWidget(
                createRequest: createRequest,
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FutureBuilder<DashboardResponse>(
            initialData: cachedProviderDashboardResponse,
            future: future,
            builder: (context, snap) {
              if (snap.hasData) {
                return AnimatedScrollView(
                  padding: EdgeInsets.only(bottom: 16),
                  physics: AlwaysScrollableScrollPhysics(),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  listAnimationType: ListAnimationType.FadeIn,
                  fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
                  children: [
                    if ((snap.data!.earningType == EARNING_TYPE_SUBSCRIPTION))
                      planBanner(snap.data!),
                    _buildHeaderWidget(snap.data!),
                    TodayCashComponent(
                      todayCashAmount:
                          snap.data!.inprogessInspection!.validate(),
                      switchToFragmentCallback: widget.switchToFragmentCallback,
                    ),
                    TotalComponent(
                      snap: snap.data!,
                      switchToFragmentCallback: widget.switchToFragmentCallback,
                    ),
                    10.height,
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                              text: 'Create Request',
                              textStyle:
                                  primaryTextStyle(size: 13, color: white),
                              color: primaryColor,
                              onTap: () {
                                _showDialog(context, createRequest: true);
                              }),
                        ),
                        15.width,
                        Expanded(
                          child: AppButton(
                              text: 'Create Inspection',
                              textStyle:
                                  primaryTextStyle(size: 13, color: white),
                              color: primaryColor,
                              onTap: () {
                                _showDialog(context, createRequest: false);
                              }),
                        )
                      ],
                    ).paddingSymmetric(horizontal: 16),
                    Visibility(visible: false, child: ChartComponent()),
                    HandymanRecentlyOnlineComponent(
                        images: snap.data!.onlineHandyman.validate()),
                    HandymanListComponent(list: snap.data!.handyman.validate()),
                    UpcomingBookingComponent(
                        bookingData: snap.data!.upcomingBookings.validate()),
                    Visibility(
                      visible: false,
                      child: JobListComponent(
                              list: snap.data!.myPostJobData.validate())
                          .paddingOnly(left: 16, right: 16, top: 8),
                    ),
                    Visibility(
                        visible: false,
                        child: ServiceListComponent(
                            list: snap.data!.service.validate())),
                  ],
                  onSwipeRefresh: () async {
                    page = 1;
                    appStore.setLoading(true);

                    init();
                    setState(() {});

                    return await 2.seconds.delay;
                  },
                );
              }

              return snapWidgetHelper(
                snap,
                loadingWidget: ProviderDashboardShimmer(),
                errorBuilder: (error) {
                  return NoDataWidget(
                    title: error,
                    imageWidget: ErrorStateWidget(),
                    retryText: languages.reload,
                    onRetry: () {
                      page = 1;
                      appStore.setLoading(true);

                      init();
                      setState(() {});
                    },
                  );
                },
              );
            },
          ),
          Observer(
              builder: (context) => LoaderWidget().visible(appStore.isLoading))
        ],
      ),
    );
  }
}
