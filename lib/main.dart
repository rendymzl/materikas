import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'infrastructure/dal/database/powersync.dart';
import 'infrastructure/navigation/navigation.dart';
import 'infrastructure/navigation/routes.dart';
import 'infrastructure/theme/app_theme.dart';

void main() async {
  var initialRoute = await Routes.initialRoute;
  await openDatabase();
  runApp(Main(initialRoute));
}

class Main extends StatelessWidget {
  final String initialRoute;
  Main(this.initialRoute);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Materikas',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: const Locale('en', 'US'),
      supportedLocales: const [
        Locale('id'),
      ],
      defaultTransition: Transition.noTransition,
      // transitionDuration: Duration(milliseconds: 150),
      theme: appTheme,
      initialRoute: initialRoute,
      getPages: Nav.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}
