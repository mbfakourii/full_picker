import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:ahille/screen/splash/splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'generated/l10n.dart';
import 'screen/bloc/language_cubit.dart';
import 'package:sizer/sizer.dart';

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
        return AdaptiveTheme(
          light: ThemeData(
            brightness: ThemeData.light().brightness,
            useMaterial3: true,
          ),
          dark: ThemeData(
            brightness: ThemeData.dark().brightness,
            useMaterial3: true,
          ),
          initial: savedThemeMode ?? AdaptiveThemeMode.light,
          builder: (theme, darkTheme) => Sizer(
            builder: (context, orientation, deviceType) {
              return MaterialApp(
                title: 'Localizations Sample App',
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
                home: const Splash(),
              );
            },
          ),
        );
      }),
    );
  }
}
