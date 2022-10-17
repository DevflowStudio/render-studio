import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'rehmat.dart';

Future<void> main() async {
  await run(Flavor.production);
}

Future<void> run(Flavor flavor) async {

  // runZonedGuarded<Future<void>>(() async {
    /// Initialize Hive local DB
    await Hive.initFlutter();

    handler = await ProjectManager.instance;

    // app = await App.build(flavor);

    /// Adds a license for fonts used from fonts.google.com. This prevents copyright problems
    /// when publishing the app
    LicenseRegistry.addLicense(() async* {
      final license = await rootBundle.loadString('google_fonts/OFL.txt');
      yield LicenseEntryWithLineBreaks(['google_fonts'], license);
    });
    
    sharedPreferences = await SharedPreferences.getInstance();

    /// Initialise the saved projects
    projectSaves = await ProjectSaves.instance;

    WidgetsFlutterBinding.ensureInitialized();
    // await FirebaseManager.initialize();

    Widget child = Home();
    // Uncomment below line to add authentication
    // if (!Auth.isLoggedIn) child = Onboarding();

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(
            value: AppState()
          ),
        ],
        child: Render(
          child: child
        )
      )
    );
  // }, (error, stack) => FirebaseCrashlytics.instance.recordError(error, stack, fatal: flavor != Flavor.dev, printDetails: flavor == Flavor.dev));

}

class Render extends StatelessWidget {

  const Render({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Render',
      theme: AppTheme.build(brightness: Brightness.light),
      darkTheme: AppTheme.build(brightness: Brightness.dark),
      home: child,
      scrollBehavior: CupertinoScrollBehavior(),
    );
  }
}