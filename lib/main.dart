import 'dart:async';
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

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  app = await App.build(flavor);

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
    return MaterialApp(
      title: 'Render',
      theme: AppTheme.build(brightness: Brightness.light),
      darkTheme: AppTheme.build(brightness: Brightness.dark),
      home: LandingPage(),
      scrollBehavior: CupertinoScrollBehavior(),
      builder: (context, widget) {
        Widget error = Text(
          'oops! something went wrong',
          style: Theme.of(context).textTheme.headlineMedium,
        );
        if (widget is Scaffold || widget is Navigator) {
          error = Scaffold(body: Center(child: error));
        }
        ErrorWidget.builder = (errorDetails) => error;
        if (widget != null) return widget;
        else return Container();
      },
    );
  }
}