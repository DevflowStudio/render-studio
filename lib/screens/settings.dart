// import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
// import 'package:octo_image/octo_image.dart';
import 'package:url_launcher/url_launcher.dart';

import '../rehmat.dart';

class Settings extends StatefulWidget {

  const Settings({Key? key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            centerTitle: false,
            expandedHeight: Constants.appBarExpandedHeight,
            titleTextStyle: const TextStyle(
              fontSize: 14
            ),
            flexibleSpace: RenderFlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              centerTitle: false,
              title: Text(
                'Settings',
                style: AppTheme.flexibleSpaceBarStyle
              ),
              titlePaddingTween: EdgeInsetsTween(
                begin: const EdgeInsets.only(
                  left: 16.0,
                  bottom: 16
                ),
                end: const EdgeInsets.symmetric(
                  horizontal: 55,
                  vertical: 15
                )
              ),
              stretchModes: const [
                StretchMode.fadeTitle,
              ],
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Card(
                margin: EdgeInsets.symmetric(horizontal: Constants.horizontalPadding),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                        child: SizedBox(
                          height: 50,
                          width: 50,
                          // child: ClipOval(
                          //   child: OctoImage(
                          //     image: CachedNetworkImageProvider(Auth.user.photoURL!)
                          //   ),
                          // ),
                        ),
                      ),
                      Container(width: 10,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          // Text(
                          //   Auth.user.displayName ?? 'Me',
                          //   style: Theme.of(context).textTheme.headline5,
                          // ),
                          // Text(
                          //   Auth.user.email ?? 'Me',
                          //   style: Theme.of(context).textTheme.caption,
                          // ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              Container(height: 10,),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Label(
                  label: 'Preferences'
                ),
              ),
              Card(
                margin: EdgeInsets.symmetric(horizontal: Constants.horizontalPadding),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: const Text('Send Usage Data'),
                      trailing: Switch(
                        value: preferences.allowAnalytics,
                        onChanged: (value) async {
                          await preferences.update(allowAnalytics: value);
                          setState(() { });
                        },
                      ),
                    ),
                    const Divider(height: 0,),
                    ListTile(
                      title: const Text('Snap'),
                      subtitle: const Text('Automatically snap widgets to with reference to others'),
                      trailing: Switch(
                        value: preferences.snap,
                        onChanged: (value) async {
                          await preferences.update(snap: value);
                          setState(() { });
                        },
                      ),
                    ),
                    const Divider(height: 0,),
                    ListTile(
                      title: const Text('Vibrate on Snap'),
                      subtitle: const Text('Make a vibration when snapping widgets'),
                      trailing: Switch(
                        value: preferences.vibrateOnSnap,
                        onChanged: (value) async {
                          await preferences.update(vibrateOnSnap: value);
                          setState(() { });
                        },
                      ),
                    )
                  ],
                ),
              ),
              Container(height: 10,),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: const Label(
                  label: 'About'
                ),
              ),
              Card(
                margin: EdgeInsets.symmetric(horizontal: Constants.horizontalPadding),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: const Text('About Us'),
                      trailing: IconButton(
                        onPressed: () async {
                          if (await canLaunch('https://devflow.studio/about')) {
                            await launch('https://devflow.studio/about');
                          } else {
                            Alerts.snackbar(context, text: 'Failed to launch url');
                          }
                        },
                        icon: const Icon(Icons.open_in_new)
                      ),
                    ),
                    const Divider(height: 0,),
                    ListTile(
                      title: const Text('Devflow Studios'),
                      trailing: IconButton(
                        onPressed: () async {
                          if (await canLaunch('https://devflow.studio')) {
                            await launch('https://devflow.studio');
                          } else {
                            Alerts.snackbar(context, text: 'Failed to launch url');
                          }
                        },
                        icon: const Icon(Icons.open_in_new)
                      ),
                    ),
                    const Divider(height: 0,),
                    ListTile(
                      title: const Text('Terms of Use'),
                      trailing: IconButton(
                        onPressed: () async {
                          if (await canLaunch('https://devflow.studio/terms-of-use')) {
                            await launch('https://devflow.studio/terms-of-use');
                          } else {
                            Alerts.snackbar(context, text: 'Failed to launch url');
                          }
                        },
                        icon: const Icon(Icons.open_in_new)
                      ),
                    ),
                    const Divider(height: 0,),
                    const ListTile(
                      title: Text('Made with ❤️ in India'),
                    ),
                  ],
                ),
              )
            ])
          )
        ],
      ),
    );
  }
}