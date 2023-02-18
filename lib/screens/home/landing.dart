import 'package:animate_do/animate_do.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import '../../rehmat.dart';

class LandingPage extends StatefulWidget {

  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {

  Future<void> initialize() async {

    DateTime start = DateTime.now();

    MobileAds.instance.initialize();

    // Add Rehmat's iPhone for testing
    // TODO: Remove this before publishing
    RequestConfiguration configuration = RequestConfiguration(testDeviceIds: ['6c8a2f17950b8ca93295b564b7439715']);
    MobileAds.instance.updateRequestConfiguration(configuration);

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

    DateTime end = DateTime.now();

    Duration animationDuration = Duration(seconds: 1, milliseconds: 800);

    if (end.difference(start).inMilliseconds < animationDuration.inMilliseconds) {
      await Future.delayed(animationDuration - end.difference(start));
    }

    setState(() {
      isLoading = false;
    });

  }

  bool isLoading = true;

  bool isAnimating = true;

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
        body: AnimatedSwitcher(
          duration: Constants.animationDuration,
          child: Center(
            child: isAnimating ? AnimatedTextKit(
              animatedTexts: [
                RotateAnimatedText(
                  'Render',
                  textStyle: textStyle('Racing Sans One'),
                  duration: Duration(milliseconds: 300)
                ),
                RotateAnimatedText(
                  'Render',
                  textStyle: textStyle('Rye'),
                  duration: Duration(milliseconds: 300)
                ),
                RotateAnimatedText(
                  'Render',
                  textStyle: textStyle('Henny Penny'),
                  duration: Duration(milliseconds: 300)
                ),
                RotateAnimatedText(
                  'Render',
                  textStyle: textStyle('Libre Barcode 39'),
                  duration: Duration(milliseconds: 300)
                ),
              ],
              totalRepeatCount: 1,
              pause: const Duration(seconds: 0),
              displayFullTextOnTap: false,
              onFinished: () {
                setState(() {
                  isAnimating = false;
                });
              },
            ) : FadeInDown(
              duration: Duration(milliseconds: 300),
              from: 50,
              child: Hero(
                tag: 'app-title',
                child: Text(
                  'Render',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontFamily: 'Helvetica',
                    fontWeight: FontWeight.w800,
                  ),
                )
              ),
            ),
          )
        ),
      );
    } else if (auth.isLoggedIn) {
      return Home();
    } else {
      return Onboarding();
    }
  }

  TextStyle textStyle(String font) => GoogleFonts.getFont(font).copyWith(
    fontSize: Theme.of(context).textTheme.displayMedium!.fontSize,
  );
  
}