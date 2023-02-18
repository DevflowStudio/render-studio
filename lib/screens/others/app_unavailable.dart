import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AppUnavailableScreen extends StatefulWidget {

  const AppUnavailableScreen({super.key});

  @override
  State<AppUnavailableScreen> createState() => _AppUnavailableScreenState();
}

class _AppUnavailableScreenState extends State<AppUnavailableScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            LottieBuilder.asset(
              'assets/animations/app-maintenance.json',
              width: double.maxFinite,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
              ),
              child: Text(
                'Maintenance',
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
                'We understand that you are facing some issues with the app. We are working on it and will be back soon.',
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
              child: Text(
                '© Devflow Studio',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontFamily: 'Helvetica Neue',
                  fontWeight: FontWeight.w600,
                ),
              )
            )
          ],
        ),
      )
    );
  }
}