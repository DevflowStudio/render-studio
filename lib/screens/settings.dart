// import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:octo_image/octo_image.dart';
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
            leading: NewBackButton(),
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
                // style: AppTheme.flexibleSpaceBarStyle
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
              divider,
              ListTile(
                leading: SizedBox(
                  height: 50,
                  width: 50,
                  child: ClipOval(
                    child: OctoImage(
                      image: AssetImage('assets/images/avatar.png')
                    ),
                  ),
                ),
                title: Text(
                  'Me',
                  style: Theme.of(context).textTheme.headline5,
                ),
                subtitle: Text(
                  'email@example.com',
                  style: Theme.of(context).textTheme.caption,
                ),
                isThreeLine: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              divider,
              
              Container(height: 10,),
              label('Preferences'),
              divider,
              ListTile(
                title: const Text('Send Usage Data'),
                trailing: Switch.adaptive(
                  value: preferences.allowAnalytics,
                  onChanged: (value) async {
                    await preferences.update(allowAnalytics: value);
                    setState(() { });
                  },
                ),
              ),
              divider,
              ListTile(
                title: const Text('Snap'),
                subtitle: const Text('Automatically snap widgets to with reference to others'),
                trailing: Switch.adaptive(
                  value: preferences.snap,
                  onChanged: (value) async {
                    await preferences.update(snap: value);
                    setState(() { });
                  },
                ),
              ),
              divider,
              ListTile(
                title: const Text('Vibrate on Snap'),
                subtitle: const Text('Make a vibration when snapping widgets'),
                trailing: Switch.adaptive(
                  value: preferences.vibrateOnSnap,
                  onChanged: (value) async {
                    await preferences.update(vibrateOnSnap: value);
                    setState(() { });
                  },
                ),
              ),
              Container(height: 10,),
              label('About'),
              divider,
              ListTile(
                title: const Text('About Us'),
                trailing: IconButton(
                  onPressed: () async {
                    if (await canLaunchUrl(Uri.parse('https://devflow.studio/about'))) {
                      await launchUrl(Uri.parse('https://devflow.studio/about'));
                    } else {
                      Alerts.snackbar(context, text: 'Failed to launch url');
                    }
                  },
                  icon: const Icon(Icons.open_in_new)
                ),
              ),
              divider,
              ListTile(
                title: const Text('Devflow Studios'),
                trailing: IconButton(
                  onPressed: () async {
                    if (await canLaunchUrl(Uri.parse('https://devflow.studio'))) {
                      await launchUrl(Uri.parse('https://devflow.studio'));
                    } else {
                      Alerts.snackbar(context, text: 'Failed to launch url');
                    }
                  },
                  icon: const Icon(Icons.open_in_new)
                ),
              ),
              divider,
              ListTile(
                title: const Text('Terms of Use'),
                trailing: IconButton(
                  onPressed: () async {
                    if (await canLaunchUrl(Uri.parse('https://devflow.studio/terms-of-use'))) {
                      await launchUrl(Uri.parse('https://devflow.studio/terms-of-use'));
                    } else {
                      Alerts.snackbar(context, text: 'Failed to launch url');
                    }
                  },
                  icon: const Icon(Icons.open_in_new)
                ),
              ),
              divider,
              const ListTile(
                title: Text('Made with ❤️ in India'),
              ),
              divider
            ])
          )
        ],
      ),
    );
  }

  Widget get divider => Divider(
    height: 0,
    indent: 0,
    endIndent: 0,
  );

  Widget label(String title) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    child: Text(
      title,
      style: Theme.of(context).textTheme.bodySmall,
    ),
  );

}