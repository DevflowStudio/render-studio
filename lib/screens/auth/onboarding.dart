import 'package:align_positioned/align_positioned.dart';
import 'package:flutter/material.dart';
import 'package:octo_image/octo_image.dart';
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
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(MediaQuery.of(context).size.width/4),
                    bottomRight: Radius.circular(MediaQuery.of(context).size.width/4)
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
              bottom: MediaQuery.of(context).padding.bottom + 12
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.maxFinite,
                  child: Button(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          RenderIcons.google,
                          color: Colors.black,
                          size: 19
                        ),
                        SizedBox(width: 12),
                        Text('Sign in with Google')
                      ],
                    ),
                    border: Border.all(
                      color: Palette.of(context).outline,
                      width: 2
                    ),
                    backgroundColor: Colors.white,
                    textColor: Colors.black,
                    autoLoading: true,
                    onPressed: () async {
                      await AuthState.of(context).signInWithGoogle();
                    },
                  ),
                ),
                Container(height: 10,),
                SizedBox(
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
                      await AuthState.of(context).signInWithApple();
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