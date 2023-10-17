import 'package:align_positioned/align_positioned.dart';
import 'package:flutter/material.dart';
import 'package:octo_image/octo_image.dart';
import 'package:universal_io/io.dart';
import '../../../rehmat.dart';

class Onboarding extends StatefulWidget {
  
  const Onboarding({Key? key}) : super(key: key);

  @override
  _OnboardingState createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {

  Widget? background;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size logoSize = Size(MediaQuery.of(context).size.width / 3, MediaQuery.of(context).size.width / 3);
    return Scaffold(
      body: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.4,
                width: double.maxFinite,
                decoration: BoxDecoration(
                  color: Palette.of(context).primary,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(55)
                  )
                ),
              ),
              SizedBox.fromSize(
                size: logoSize,
                child: AlignPositioned(
                  dy: MediaQuery.of(context).size.height * 0.4 - logoSize.height / 2,
                  dx: MediaQuery.of(context).size.width / 2 - logoSize.width / 2,
                  alignment: Alignment.center,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 6,
                          offset: Offset(0, 0)
                        )
                      ]
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: OctoImage(
                        image: AssetImage('assets/icon.png'),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: logoSize.height/2 + 20),
          Text(
            'Welcome',
            style: Theme.of(context).textTheme.displayMedium
          ),
          SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Sign in and unleash your creativity with Render Studio',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
          ),
          Spacer(),
          Padding(
            padding: EdgeInsets.only(
              left: Constants.horizontalPadding,
              right: Constants.horizontalPadding,
              bottom: Constants.of(context).bottomPadding
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (app.flavor == Flavor.dev) Button(
                  onPressed: () async {
                    try {
                      await AuthState.of(context).signInAnonymously();
                    } catch (e) {
                      Alerts.snackbar(context, text: 'There was an error signing in anonymously.');
                    }
                  },
                  border: Border.all(
                    color: Palette.of(context).outline,
                    width: 2
                  ),
                  child: Text('Sign in Anonymously'),
                  autoLoading: true,
                ),
                SizedBox(height: 10,),
                SizedBox(
                  width: double.maxFinite,
                  child: Button(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          RenderIcons.google,
                          color: Colors.white,
                          size: 19
                        ),
                        SizedBox(width: 12),
                        Text('Sign in with Google')
                      ],
                    ),
                    backgroundColor: Colors.blue,
                    textColor: Colors.white,
                    autoLoading: true,
                    onPressed: () async {
                      try {
                        await AuthState.of(context).signInWithGoogle();
                      } catch (e) {
                        Alerts.snackbar(context, text: 'There was an error signing in with Google.');
                      }
                    },
                  ),
                ),
                SizedBox(height: 10,),
                if (Platform.isIOS) SizedBox(
                  width: double.maxFinite,
                  child: Button(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          RenderIcons.apple,
                          color: Colors.white,
                          size: 19
                        ),
                        SizedBox(width: 12),
                        Text('Sign in with Apple')
                      ],
                    ),
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                    autoLoading: true,
                    onPressed: () async {
                      try {
                        await AuthState.of(context).signInWithApple();
                      } catch (e) {
                        Alerts.snackbar(context, text: 'There was an error signing in with Apple.');
                      }
                    },
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}