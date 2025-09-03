import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:trade/fragments/booking_fragment.dart';
import 'package:trade/fragments/notification_fragment.dart';
import 'package:trade/main.dart';
import 'package:trade/provider/fragments/provider_home_fragment.dart';
import 'package:trade/provider/fragments/provider_profile_fragment.dart';
import 'package:trade/utils/colors.dart';
import 'package:trade/utils/configs.dart';
import 'package:trade/utils/constant.dart';
import 'package:trade/utils/extensions/string_extension.dart';
import 'package:trade/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

class ProviderDashboardScreen extends StatefulWidget {
  final int? index;
  final bool isRedirect;

  const ProviderDashboardScreen({super.key, this.index, this.isRedirect = false});

  @override
  ProviderDashboardScreenState createState() => ProviderDashboardScreenState();
}

class ProviderDashboardScreenState extends State<ProviderDashboardScreen> {
  int currentIndex = 0;

  DateTime? currentBackPressTime;

  List<String> screenName = [];

  void switchToFragment(int index, {String? statusType}) {
    currentIndex = index;
    if (fragmentList[index] is BookingFragment) {
      // If the fragment is a BookingFragment, set the statusType if provided
      if (statusType == null) {
        (fragmentList[index] as BookingFragment).statusType = '';
      } else {
        (fragmentList[index] as BookingFragment).statusType = statusType;
      }
    }
    setState(() {});
  }

  late List<Widget> fragmentList = [];

  @override
  void initState() {
    super.initState();
    fragmentList = [
      ProviderHomeFragment(switchToFragmentCallback: switchToFragment),
      BookingFragment(isRequests: true),
      BookingFragment(isRequests: false),
      ProviderProfileFragment(),
    ];
    init();
  }

  Future<void> init() async {
    if (widget.isRedirect.validate(value: false)) {
      currentIndex = widget.index ?? 1;
    }
    afterBuildCreated(
      () async {
        if (getIntAsync(THEME_MODE_INDEX) == THEME_MODE_SYSTEM) {
          appStore.setDarkMode(context.platformBrightness() == Brightness.dark);
        }

        window.onPlatformBrightnessChanged = () async {
          if (getIntAsync(THEME_MODE_INDEX) == THEME_MODE_SYSTEM) {
            appStore
                .setDarkMode(context.platformBrightness() == Brightness.light);
          }
        };
        // OneSignal.shared
        //     .sendTag(ONESIGNAL_TAG_KEY, ONESIGNAL_TAG_PROVIDER_VALUE);
      },
    );

    LiveStream().on(LIVESTREAM_PROVIDER_ALL_BOOKING, (index) {
      currentIndex = index as int;
      setState(() {});
    });

    LiveStream().on(LIVESTREAM_PROVIDER_ALL_INSPECTION, (index) {
      currentIndex = index as int;
      setState(() {});
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
    LiveStream().dispose(LIVESTREAM_PROVIDER_ALL_BOOKING);
  }

  TextEditingController homeOwnerController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        DateTime now = DateTime.now();

        if (currentBackPressTime == null ||
            now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
          currentBackPressTime = now;
          toast(languages.lblCloseAppMsg);
          return Future.value(false);
        }
        return Future.value(true);
      },
      child: Scaffold(
        appBar: appBarWidget(
          [
            'K&C Services',
            'Service Requests',
            'Inspections',
            // languages.lblPayment,
            languages.lblProfile,
          ][currentIndex],
          color: primaryColor,
          textColor: Colors.white,
          showBack: false,
          actions: [
            IconButton(
              tooltip: 'Notifications',
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  ic_notification.iconImage(color: white, size: 20),
                  Positioned(
                    top: -14,
                    right: -6,
                    child: Observer(
                      builder: (context) {
                        if (appStore.notificationCount.validate() > 0) {
                          return Container(
                            padding: EdgeInsets.all(4),
                            decoration: boxDecorationDefault(
                                color: Colors.red, shape: BoxShape.circle),
                            child: FittedBox(
                              child: Text(appStore.notificationCount.toString(),
                                  style: primaryTextStyle(
                                      size: 12, color: Colors.white)),
                            ),
                          );
                        }

                        return Offstage();
                      },
                    ),
                  )
                ],
              ),
              onPressed: () async {
                NotificationFragment().launch(context);
              },
            ),
          ],
        ),
        body: PageStorage(
          key: PageStorageKey<String>('page$currentIndex'),
          bucket: PageStorageBucket(),
          child: fragmentList[currentIndex],
        ),
        bottomNavigationBar: Blur(
          blur: 30,
          borderRadius: radius(0),
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              backgroundColor: context.primaryColor.withOpacity(0.02),
              indicatorColor: context.primaryColor.withOpacity(0.1),
              labelTextStyle:
                  WidgetStateProperty.all(primaryTextStyle(size: 12)),
              surfaceTintColor: Colors.transparent,
              shadowColor: Colors.transparent,
            ),
            child: NavigationBar(
              selectedIndex: currentIndex,
              destinations: [
                NavigationDestination(
                  icon: ic_home.iconImage(color: appTextSecondaryColor),
                  selectedIcon:
                      ic_fill_home.iconImage(color: context.primaryColor),
                  label: languages.home,
                ),
                NavigationDestination(
                  icon: ic_requests.iconImage(color: appTextSecondaryColor),
                  selectedIcon:
                      ic_requests.iconImage(color: context.primaryColor),
                  label: 'Requests',
                ),
                NavigationDestination(
                  icon: ic_inspection.iconImage(color: appTextSecondaryColor),
                  selectedIcon:
                      ic_inspection.iconImage(color: context.primaryColor),
                  label: 'Inspections',
                ),
                NavigationDestination(
                  icon: profile.iconImage(color: appTextSecondaryColor),
                  selectedIcon:
                      ic_fill_profile.iconImage(color: context.primaryColor),
                  label: languages.lblProfile,
                ),
              ],
              onDestinationSelected: (index) {
                switchToFragment(index);
              },
            ),
          ),
        ),
      ),
    );
  }
}
