import 'dart:async';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'rehmat.dart';

Future<void> main() async {
  await run(Flavor.production);
}

Future<void> run(Flavor flavor) async {

  print('Starting app with flavor: $flavor');

  WidgetsFlutterBinding.ensureInitialized();

  DateTime start = DateTime.now();

  await Firebase.initializeApp();

  print('Firebase initialization took ${DateTime.now().difference(start).inSeconds} seconds');

  app = await App.build(flavor);

  print('App initialization took ${DateTime.now().difference(start).inMilliseconds} milliseconds');

  /// Adds a license for fonts used from fonts.google.com. This prevents copyright problems
  /// when publishing the app
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: app.auth
        ),
      ],
      child: Render()
    )
  );

}

class Render extends StatelessWidget {

  Render({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AuthState auth = Provider.of<AuthState>(context);
    return DynamicColorBuilder(
      builder: (light, dark) {
        return MaterialApp(
          title: app.remoteConfig.appTitle,
          theme: AppTheme.build(brightness: Brightness.light, colorScheme: light),
          darkTheme: AppTheme.build(brightness: Brightness.dark, colorScheme: dark),
          home: auth.isLoggedIn ? Home() : Onboarding(),
          scrollBehavior: CupertinoScrollBehavior(),
          builder: (context, widget) {
            if (!app.remoteConfig.isAppAvailable) return AppUnavailableScreen();
            if (app.remoteConfig.isAppOutdated) return AppUpdateScreen();
            ErrorWidget.builder = (errorDetails) {
              if (widget is Scaffold || widget is Navigator) {
                return ErrorScreen(
                  errorDetails: errorDetails
                );
              } else return SizedBox.square(
                dimension: 50,
                child: Container(
                  color: Palette.of(context).errorContainer,
                  child: Center(
                    child: Icon(
                      RenderIcons.error,
                      color: Palette.of(context).onErrorContainer,
                    ),
                  ),
                ),
              );
            };
            if (widget != null) return widget;
            else return Container();
          },
        );
      }
    );
  }
}