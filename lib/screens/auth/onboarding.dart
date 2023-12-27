import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mesh_gradient/mesh_gradient.dart';
import 'package:smooth_corner/smooth_corner.dart';
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
    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: AnimatedMeshGradient(
              colors: [
                HexColor.fromHex('#C6DEA6'),
                HexColor.fromHex('#7EBDC3'),
                HexColor.fromHex('#CED097'),
                HexColor.fromHex('#DFF2D8'),
              ],
              options: AnimatedMeshGradientOptions(),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(),
              Text(
                'Render Studio',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontFamily: 'SF Pro Rounded',
                  fontWeight: FontWeight.bold,
                  color: Colors.black
                ),
              ),
              Spacer(),
              SmoothClipRRect(
                borderRadius: BorderRadius.circular(46),
                smoothness: 0.6,
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 12,
                    sigmaY: 12
                  ),
                  child: Container(
                    padding: EdgeInsets.only(
                      left: 12,
                      right: 12,
                      top: 12,
                      bottom: Constants.of(context).bottomPadding
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5)
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (Platform.isIOS) Padding(
                          padding: const EdgeInsets.only(
                            bottom: 9
                          ),
                          child: Button(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Icon(
                                  RenderIcons.apple,
                                  color: Colors.white,
                                  size: 19
                                ),
                                SizedBox(width: 12),
                                Text('Continue with Apple', style: TextStyle(height: 0.77),)
                              ],
                            ),
                            backgroundColor: Colors.black,
                            textColor: Colors.white,
                            autoLoading: true,
                            onPressed: () async {
                              try {
                                await AuthState.of(context).signInWithApple();
                              } catch (e) {
                                Alerts.dialog(
                                  context,
                                  title: 'Error',
                                  content: 'There was an error signing in. Please try again later'
                                );
                              }
                            },
                          ),
                        ),
                        Button(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                RenderIcons.google,
                                color: Colors.white,
                                size: 19
                              ),
                              SizedBox(width: 12),
                              Text('Continue with Google')
                            ],
                          ),
                          backgroundColor: Colors.blue,
                          textColor: Colors.white,
                          autoLoading: true,
                          onPressed: () async {
                            try {
                              await AuthState.of(context).signInWithGoogle();
                            } catch (e) {
                              Alerts.dialog(
                                context,
                                title: 'Error',
                                content: 'There was an error signing in. Please try again later'
                              );
                            }
                          },
                        ),
                        if (app.flavor == Flavor.dev) Padding(
                          padding: const EdgeInsets.only(
                            top: 9
                          ),
                          child: Button(
                            onPressed: () async {
                              try {
                                await AuthState.of(context).signInAnonymously();
                              } catch (e) {
                                Alerts.dialog(
                                  context,
                                  title: 'Error',
                                  content: 'There was an error signing in. Please try again later'
                                );
                              }
                            },
                            child: Text('Work Anonymously'),
                            autoLoading: true,
                            backgroundColor: Colors.white,
                            textColor: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}