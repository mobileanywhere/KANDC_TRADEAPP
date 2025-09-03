import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:trade/locale/applocalizations.dart';
import 'package:trade/locale/base_language.dart';
import 'package:trade/locale/language_en.dart';
import 'package:trade/models/add_extra_charges_model.dart';
import 'package:trade/models/booking_detail_response.dart';
import 'package:trade/models/notification_list_response.dart';
import 'package:trade/models/remote_config_data_model.dart';
import 'package:trade/models/revenue_chart_data.dart';
import 'package:trade/models/service_detail_response.dart';
import 'package:trade/models/total_earning_response.dart';
import 'package:trade/models/user_data.dart';
import 'package:trade/models/user_data_model.dart';
import 'package:trade/models/wallet_history_list_response.dart';
import 'package:trade/networks/firebase_services/auth_services.dart';
import 'package:trade/networks/firebase_services/chat_messages_service.dart';
import 'package:trade/networks/firebase_services/notification_service.dart';
import 'package:trade/networks/firebase_services/user_services.dart';
import 'package:trade/provider/jobRequest/models/post_job_detail_response.dart';
import 'package:trade/screens/splash_screen.dart';
import 'package:trade/services/notification_handler.dart';
import 'package:trade/store/AppStore.dart';
import 'package:trade/utils/common.dart';
import 'package:trade/utils/configs.dart';
import 'package:trade/utils/constant.dart';
import 'package:nb_utils/nb_utils.dart';

import 'app_theme.dart';
import 'models/booking_list_response.dart';
import 'models/booking_status_response.dart';
import 'models/dashboard_response.dart';
import 'models/handyman_dashboard_response.dart';
import 'models/payment_list_reasponse.dart';
import 'provider/timeSlots/timeSlotStore/time_slot_store.dart';

//region Mobx Stores
AppStore appStore = AppStore();
TimeSlotStore timeSlotStore = TimeSlotStore();
//endregion

//region Firebase Services
UserService userService = UserService();
AuthService authService = AuthService();

ChatServices chatServices = ChatServices();
NotificationService notificationService = NotificationService();
//endregion

//region Global Variables
Languages languages = LanguageEn();
List<RevenueChartData> chartData = [];
RemoteConfigDataModel remoteConfigDataModel = RemoteConfigDataModel();
List<AddExtraChargesModel> chargesList = [];
//endregion

//region Cached Response Variables for Dashboard Tabs
DashboardResponse? cachedProviderDashboardResponse;
HandymanDashBoardResponse? cachedHandymanDashboardResponse;
List<BookingData>? cachedBookingList;
List<BookingData>? cachedBookingListInspection;
List<PaymentData>? cachedPaymentList;
List<NotificationData>? cachedNotifications;
List<UserDataHomeOwner>? cachedUserDataHomeOwner;
List<BookingStatusResponse>? cachedBookingStatusDropdown;
List<(int serviceId, ServiceDetailResponse)?> listOfCachedData = [];
List<BookingDetailResponse> cachedBookingDetailList = [];
List<(int postJobId, PostJobDetailResponse)?> cachedPostJobList = [];
List<UserData>? cachedHandymanList;
List<TotalData>? cachedTotalDataList;
List<WalletHistory>? cachedWalletList;

//endregion

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!isDesktop) {
    // Firebase.initializeApp().then((value) {
    //   FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    //
    //   setupFirebaseRemoteConfig();
    // }).catchError((e) {
    //   log(e.toString());
    // });
    NotificationHandler.initializeFirebaseAndNotifications();
    NotificationHandler();
  }

  defaultSettings();

  await initialize();

  localeLanguageList = languageList();

  appStore.setLanguage(getStringAsync(SELECTED_LANGUAGE_CODE, defaultValue: DEFAULT_LANGUAGE));

  await appStore.setLoggedIn(getBoolAsync(IS_LOGGED_IN));

  await setLoginValues();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    // OneSignal.shared.setNotificationOpenedHandler((OSNotificationOpenedResult notification) {
    //   try {
    //     if (notification.notification.additionalData == null) return;

    //     if (notification.notification.additionalData!.containsKey('id')) {
    //       String? notId = notification.notification.additionalData!["id"].toString();
    //       if (notId.validate().isNotEmpty) {
    //         push(BookingDetailScreen(bookingId: notId.toString().toInt()));
    //       }
    //     } else if (notification.notification.additionalData!.containsKey('sender_uid')) {
    //       String? notId = notification.notification.additionalData!["sender_uid"];
    //       if (notId.validate().isNotEmpty) {
    //         push(ChatListScreen());
    //       }
    //     }
    //   } catch (e) {
    //     throw errorSomethingWentWrong;
    //   }
    // });
    afterBuildCreated(() {
      int val = getIntAsync(THEME_MODE_INDEX, defaultValue: THEME_MODE_SYSTEM);

      if (val == THEME_MODE_LIGHT) {
        appStore.setDarkMode(false);
      } else if (val == THEME_MODE_DARK) {
        appStore.setDarkMode(true);
      }
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RestartAppWidget(
      child: Observer(
        builder: (_) => MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey,
          home: SplashScreen(),
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: appStore.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          supportedLocales: LanguageDataModel.languageLocales(),
          localizationsDelegates: [
            AppLocalizations(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          localeResolutionCallback: (locale, supportedLocales) => locale,
          locale: Locale(appStore.selectedLanguageCode),
        ),
      ),
    );
  }
}
