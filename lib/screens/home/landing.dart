import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import '../../rehmat.dart';

// import 'package:firebase_auth/firebase_auth.dart';
// 
// class LandingPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<FirebaseUser>(
//       stream: FirebaseAuth.instance.onAuthStateChanged,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.active) {
//           FirebaseUser user = snapshot.data;
//           if (user == null) {
//             return SignInPage();
//           }
//           return HomePage();
//         } else {
//           return Scaffold(
//             body: Center(
//               child: CircularProgressIndicator(),
//             ),
//           );
//         }
//       },
//     );
//   }
// }

class LandingPage extends StatefulWidget {

  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {

  Future<void> initialize() async {

    await Hive.initFlutter();

    environment = await Environment.instance;
    device = await DeviceInfo.instance;
    preferences = await Preferences.instance;
    analytics = await Analytics.instance;
    manager = await ProjectManager.instance;
    paletteManager = await PaletteManager.instance;
    projectSaves = await ProjectSaves.instance;
    pathProvider = await PathProvider.instance;

    await Crashlytics.init();

    setState(() {
      isLoading = false;
    });

  }

  bool isLoading = true;

  @override
  void initState() {
    initialize();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AuthState auth = Provider.of<AuthState>(context);
    if (isLoading) {
      return Scaffold(
        body: Center(
          child: Spinner(),
        ),
      );
    } else if (auth.isLoggedIn) {
      return Home();
    } else {
      return Onboarding();
    }
  }
  
}