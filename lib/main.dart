import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:ahille/dialogs/country_code/view/update_country_code.dart';
import 'package:ahille/screen/navigation/update_navigation.dart';
import 'package:ahille/screen/splash/splash.dart';
import 'package:ahille/widgets/phone_textfield.dart';
import 'package:ahille/widgets/searchbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'config/colors.dart';
import 'generated/l10n.dart';
import 'bloc/language_cubit.dart';
import 'package:responsive_framework/responsive_framework.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final savedThemeMode = await AdaptiveTheme.getThemeMode();
  runApp(MyApp(savedThemeMode: savedThemeMode));
}

class MyApp extends StatelessWidget {
  final AdaptiveThemeMode? savedThemeMode;

  const MyApp({super.key, this.savedThemeMode});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LanguageCubit(),
      child: BlocBuilder<LanguageCubit, Locale>(builder: (context, lang) {
        // Set Language
        context.read<LanguageCubit>().changeStartLanguage();

        return AdaptiveTheme(
          light: ThemeData(
              useMaterial3: true,
              fontFamily: 'IRANSans',
              navigationBarTheme: NavigationBarThemeData(
                iconTheme: MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.selected)) {
                    return const IconThemeData(
                      color: antiFlashWhite,
                    );
                  }
                  return const IconThemeData(
                    color: darkCharcoal,
                  );
                }),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                  style: ElevatedButton.styleFrom(
                primary: darkCharcoal,
                onPrimary: white,
              )),
              outlinedButtonTheme: OutlinedButtonThemeData(
                  style: OutlinedButton.styleFrom(
                primary: darkCharcoal,
                backgroundColor: white,
                side: const BorderSide(color: grayX11, width: 2.5),
              )),
              textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                primary: darkCharcoal,
              )),
              inputDecorationTheme: const InputDecorationTheme(
                fillColor: white,
                filled: true,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: darkCharcoal),
                ),
              ),
              dialogBackgroundColor: antiFlashWhite,
              iconTheme: const IconThemeData(
                color: darkCharcoal,
              ),
              textTheme: const TextTheme(
                bodyText2: TextStyle(),
              ).apply(
                bodyColor: darkCharcoal,
              ),
              scaffoldBackgroundColor: white,
              backgroundColor: white,
              cardTheme: const CardTheme(
                color: antiFlashWhite,
                elevation: 0,
              ),
              colorScheme: ThemeData().colorScheme.copyWith(
                  secondaryContainer: darkCharcoal,
                  primary: darkCharcoal,
                  brightness: ThemeData.light().brightness,
                  secondary: antiFlashWhite)),
          dark: ThemeData(
            brightness: ThemeData.dark().brightness,
            useMaterial3: true,
          ),
          initial: savedThemeMode ?? AdaptiveThemeMode.light,
          builder: (theme, darkTheme) => ResponsiveSizer(
            builder: (context, orientation, deviceType) {
              return ResponsiveSizer(
                builder: (context, orientation, screenType) {
                  return MultiProvider(
                    providers: [
                      ChangeNotifierProvider.value(
                        value: UpdateNavigation(),
                      ),
                      ChangeNotifierProvider.value(
                        value: UpdateSearchbar(),
                      ),
                      ChangeNotifierProvider.value(
                        value: UpdatePhoneTextField(),
                      ),
                      ChangeNotifierProvider.value(
                        value: UpdateCountryCode(),
                      ),
                    ],
                    child: OKToast(
                      child: MaterialApp(
                        title: 'Ahille',
                        localizationsDelegates: const [
                          S.delegate,
                          GlobalMaterialLocalizations.delegate,
                          GlobalCupertinoLocalizations.delegate,
                          GlobalWidgetsLocalizations.delegate,
                        ],
                        supportedLocales: S.delegate.supportedLocales,
                        locale: lang,
                        theme: theme,
                        debugShowCheckedModeBanner: false,
                        darkTheme: darkTheme,
                        builder: (context, widget) => ResponsiveWrapper.builder(
                          ClampingScrollWrapper.builder(context, widget!),
                          defaultScale: true,
                          minWidth: 360,
                          defaultName: MOBILE,
                          breakpoints: [
                            const ResponsiveBreakpoint.resize(360),
                            const ResponsiveBreakpoint.resize(480, name: MOBILE),
                            const ResponsiveBreakpoint.resize(640, name: 'MOBILE_LARGE'),
                            const ResponsiveBreakpoint.resize(850, name: TABLET),
                            const ResponsiveBreakpoint.resize(1080, name: DESKTOP),
                          ],
                        ),
                        home: const Splash(),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      }),
    );
  }
}
