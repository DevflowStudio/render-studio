import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:render_studio/rehmat.dart';
import 'package:url_launcher/url_launcher.dart';

class ErrorScreen extends StatefulWidget {

  const ErrorScreen({
    super.key,
    this.errorDetails
  });

  final FlutterErrorDetails? errorDetails;

  @override
  State<ErrorScreen> createState() => _ErrorScreenState();
}

class _ErrorScreenState extends State<ErrorScreen> {

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
                'Something\'s wrong',
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
                'An unexpected error has occurred. Please restart the app and try again.',
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
              child: TextButton.icon(
                onPressed: () async {
                  if (!(await launchUrl(Uri.parse('mailto:help@devflowstud.io')))) {
                    Alerts.snackbar(context, text: 'The issue has been reported. We will get back to you soon.');
                  }
                },
                label: Text('Report Error'),
                icon: Icon(RenderIcons.error),
              )
            )
          ],
        ),
      )
    );
  }

}