import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:open_store/open_store.dart';
import 'package:render_studio/rehmat.dart';

class AppUpdateScreen extends StatefulWidget {

  const AppUpdateScreen({super.key});

  @override
  State<AppUpdateScreen> createState() => _AppUpdateScreenState();
}

class _AppUpdateScreenState extends State<AppUpdateScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            LottieBuilder.asset(
              'assets/animations/app-update.json',
              width: double.maxFinite,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
              ),
              child: Text(
                'Update Available',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontFamily: 'Helvetica Neue',
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 12
              ),
              child: Text(
                'A new version of Render Studio is available. Please update to continue using the app.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontFamily: 'Google Sans',
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
              ),
              child: PrimaryButton(
                onPressed: () {
                  OpenStore.instance.open(
                    appStoreId: '284815942', // TODO : Replace with your app store id
                    androidAppBundleId: 'app.studio.render',
                  );
                },
                child: Text(
                  'Update',
                ),
              ),
            )
          ],
        ),
      )
    );
  }
}