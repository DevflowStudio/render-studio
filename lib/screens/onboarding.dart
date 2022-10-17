import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:octo_image/octo_image.dart';
import '../rehmat.dart';

class Onboarding extends StatefulWidget {
  
  const Onboarding({Key? key}) : super(key: key);

  @override
  _OnboardingState createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {

  Widget? background;

  bool isGoogleAuthLoading = false;
  bool isAppleAuthLoading = false;
  bool isFacebookAuthLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      background = SizedBox.fromSize(
        size: MediaQuery.of(context).size,
        child: OctoImage(
          fit: BoxFit.cover,
          image: AssetImage(
            [
              'assets/intro/1.jpg',
              'assets/intro/2.jpg',
              'assets/intro/3.jpg',
              'assets/intro/4.jpg',
              'assets/intro/5.jpg',
            ].getRandom()
          )
        ),
      );
      setState(() { });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          background ?? Container(),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: Constants.horizontalPadding, vertical: 50),
                  child: Text(
                    'Render',
                    style: Theme.of(context).textTheme.headline1!.copyWith(
                      fontFamily: Fonts.main,
                      fontWeight: FontWeight.bold,
                      color: Colors.black
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: Constants.horizontalPadding, vertical: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: double.maxFinite,
                        child: TextButton.icon(
                          label: isGoogleAuthLoading ? Spinner(strokeWidth: 2,) : Text('Google'),
                          icon: Icon(FontAwesomeIcons.google),
                          onPressed: () async {
                            setState(() {
                              isGoogleAuthLoading = true;
                            });
                            // await Auth.signInWithGoogle(context);
                            setState(() {
                              isGoogleAuthLoading = false;
                            });
                          },
                          // background: Colors.red,
                        ),
                      ),
                      Container(height: 10,),
                      SizedBox(
                        width: double.maxFinite,
                        child: TextButton.icon(
                          label: isAppleAuthLoading ? Spinner(strokeWidth: 2,) : Text('Apple'),
                          icon: Icon(FontAwesomeIcons.apple),
                          onPressed: () async {
                            setState(() {
                              isGoogleAuthLoading = true;
                            });
                            // await Auth.signInWithApple(context);
                            setState(() {
                              isGoogleAuthLoading = false;
                            });
                          },
                        ),
                      ),
                      // Container(height: 10,),
                      // SizedBox(
                      //   width: double.maxFinite,
                      //   child: Button(
                      //     text: 'Facebook',
                      //     icon: FontAwesomeIcons.facebook,
                      //     isLoading: isFacebookAuthLoading,
                      //     onPressed: () async {
                      //       setState(() {
                      //         isGoogleAuthLoading = true;
                      //       });
                      //       await Auth.googleSignIn(context);
                      //       setState(() {
                      //         isGoogleAuthLoading = false;
                      //       });
                      //     },
                      //     background: Colors.blue,
                      //   ),
                      // )
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}