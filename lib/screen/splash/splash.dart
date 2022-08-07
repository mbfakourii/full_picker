import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../login/login.dart';
import '../navigation/navigation.dart';

late String accessToken;
late String refreshToken;

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> with TickerProviderStateMixin {

  // Future<bool> initParse() async {
  //   await Parse().initialize(parseAppId, serverUrl,
  //       clientKey: kIsWeb ? null : parseClientKey,
  //       autoSendSessionId: true,
  //       debug: true,
  //       clientCreator: ({securityContext, required sendSessionId}) =>
  //           ParseDioClient(
  //               securityContext: ParseCoreData.instance.securityContext,
  //               sendSessionId: ParseCoreData.instance.autoSendSessionId),
  //       liveQueryUrl: serverUrl,
  //       coreStore: await CoreStoreSembastImp.getInstance());
  //
  //   try {
  //     mainUser = await ParseUser.currentUser();
  //     mainUser2 = convertParseUserToUser(mainUser!);
  //
  //     if (mainUser == null) {
  //       return false;
  //     } else {
  //       return true;
  //     }
  //   } catch (e) {
  //     return false;
  //   }
  // }

  bool showError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // await initParse();
      checkApplication();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
          height: double.infinity,
          width: double.infinity,
          color: Colors.white,
          // Start Main col
          child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image(
                    image: const AssetImage("assets/images/logo.png"),
                    width: 40.w,
                    height: 40.h,
                  ),
                  Visibility(
                    visible: showError,
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        const Text(
                          "خطا در اتصال ! \nاینترنت خود را بررسی کنید",
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                          style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: 40.w,
                          child: TextButton(
                              style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      const Color(0xff47bf73)),
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18.0),
                                      ))),
                              onPressed: () async {
                                setState(() {
                                  showError = false;
                                });

                                checkApplication();
                              },
                              child: const Padding(
                                padding: EdgeInsets.only(right: 5, left: 5),
                                child: Text(
                                  "تلاش مجدد",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              )),
                        ),
                      ],
                    ),
                  )
                ],
              ))),
    );
  }


  // Future<bool> getApplication() async {
  //   ParseResponse application = await mainReq.getApplication();
  //   if (application.success) {
  //     PackageInfo packageInfo = await PackageInfo.fromPlatform();
  //     if (packageInfo.version.toString() ==
  //         application.result['appVersion'].toString()) {
  //       return true;
  //     } else {
  //       if (application.result['updateImportant']) {
  //         await showDialog(
  //             context: context,
  //             builder: (context) => YesNoDialog(
  //                 "بروز رسانی",
  //                 "این نسخه دیگر پشتیبانی نمیشود لطفا به نسخه جدید بروزرسانی کنید",
  //                 "دانلود",
  //                     () async {
  //                   exitApplication();
  //                   openLink(application.result['links']['URL'], context);
  //                 },
  //                 "انصراف",
  //                     () {
  //                   exitApplication();
  //                 }));
  //
  //         return false;
  //       } else {
  //         await showDialog(
  //             context: context,
  //             builder: (context) {
  //               return YesNoDialog(
  //                   "بروز رسانی",
  //                   "ورژن جدیدی از برنامه موجود است لطفا بروزرسانی کنید",
  //                   "دانلود",
  //                       () async {
  //                     Navigator.of(context).pop();
  //                     openLink(application.result['links']['URL'], context);
  //                   },
  //                   "انصراف",
  //                       () {
  //                     Navigator.of(context).pop();
  //                   });
  //             });
  //
  //         return true;
  //       }
  //     }
  //   } else {
  //     return false;
  //   }
  // }

  void checkApplication() async {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => Navigation()));
    // if (await getApplication()) {
    //   if (await initParse()) {
    //     Navigator.pushReplacement(
    //         context, MaterialPageRoute(builder: (context) => Navigation()));
    //   } else {
    //     isReject().then((value) {
    //       if (value == false) {
    //         Navigator.pushReplacement(context,
    //             MaterialPageRoute(builder: (context) => const WelcomeScreen()));
    //       } else {
    //         Navigator.pushReplacement(
    //             context, MaterialPageRoute(builder: (context) => Navigation()));
    //       }
    //     });
    //   }
    // } else {
    //   setState(() {
    //     showError = true;
    //   });
    // }
  }
}
