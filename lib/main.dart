import 'dart:io';

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:auto_updater/auto_updater.dart';
import 'package:window_manager/window_manager.dart';

import 'infrastructure/dal/database/powersync.dart';
import 'infrastructure/navigation/navigation.dart';
import 'infrastructure/navigation/routes.dart';
import 'infrastructure/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // HttpOverrides.global = MyHttpOverrides();

  var initialRoute = await Routes.initialRoute;

  // String feedURL = 'https://api.menantikan.com/releases/appcast.xml';
  // await autoUpdater.setFeedURL(feedURL);
  // await autoUpdater.checkForUpdates();
  // await autoUpdater.setScheduledCheckInterval(3600);

  // windowManager.waitUntilReadyToShow(null, () async {
  //   await windowManager.show();
  //   await windowManager.focus();
  // });

  await openDatabase();
  await Hive.initFlutter();

  runApp(Main(initialRoute));
}

class Main extends StatelessWidget {
  final String initialRoute;
  const Main(this.initialRoute, {super.key});

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

// class MyHttpOverrides extends HttpOverrides {
//   @override
//   HttpClient createHttpClient(SecurityContext? context) {
//     return super.createHttpClient(context)
//       ..badCertificateCallback =
//           (X509Certificate cert, String host, int port) => true;
//   }
// }
