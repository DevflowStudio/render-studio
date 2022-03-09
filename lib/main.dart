import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'rehmat.dart';

Future<void> main() async {

  /// Initialize Hive local DB
  await Hive.initFlutter();

  handler = await ProjectManager.instance;

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
  await FirebaseManager.initialize();

  Widget child = Home();
  // Uncomment below line to add authentication
  // if (!Auth.isLoggedIn) child = Onboarding();

  runApp(
    Render(
      child: child
    )
  );

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
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: child,
      scrollBehavior: CupertinoScrollBehavior(),
    );
  }
}