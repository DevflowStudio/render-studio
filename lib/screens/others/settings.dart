// import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
// import 'package:octo_image/octo_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../rehmat.dart';

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
          RenderAppBar(
            title: Text('Settings')
          ),
          SliverList(
            delegate: SliverChildListDelegate([

              ListTile(
                title: const Text('Snap'),
                subtitle: const Text('Automatically snap widgets to with reference to others'),
                trailing: Switch.adaptive(
                  value: preferences.snap,
                  onChanged: (value) async {
                    preferences.snap = value;
                    setState(() { });
                  },
                ),
              ),
              ListTile(
                title: const Text('Vibrate on Snap'),
                subtitle: const Text('Make a vibration when snapping widgets'),
                trailing: Switch.adaptive(
                  value: preferences.vibrateOnSnap,
                  onChanged: (value) async {
                    preferences.vibrateOnSnap = value;
                    setState(() { });
                  },
                ),
              ),
              ListTile(
                title: const Text('Action Bar'),
                subtitle: const Text('Show an action bar for quick access to some options'),
                trailing: Switch.adaptive(
                  value: preferences.showActionBar,
                  onChanged: (value) async {
                    preferences.showActionBar = value;
                    setState(() { });
                  },
                ),
              ),
              ListTile(
                title: const Text('Collect Usage Data'),
                trailing: Switch.adaptive(
                  value: preferences.allowAnalytics,
                  onChanged: (value) async {
                    preferences.allowAnalytics = value;
                    setState(() { });
                  },
                ),
              ),

              ListTile(
                title: const Text(
                  'Sign Out',
                  style: TextStyle(
                    color: Colors.red
                  ),
                ),
                onTap: () async {
                  bool signout = await Alerts.showConfirmationDialog(
                    context,
                    title: 'Sign Out',
                    message: 'Are you sure you want to sign out?',
                    confirmButtonText: 'Sign Out',
                    isDestructive: true
                  );
                  if (signout) {
                    await AuthState.of(context).signOut();
                    Navigator.of(context).pop();
                  }
                },
              ),

              Divider(),
              ListTile(
                title: const Text('About Us'),
                contentPadding: EdgeInsets.only(
                  left: 18,
                  right: 6
                ),
                trailing: FilledTonalIconButton(
                  secondary: true,
                  onPressed: () async {
                    if (await canLaunchUrl(Uri.parse('https://renderstudio.app/about'))) {
                      await launchUrl(Uri.parse('https://renderstudio.app/about'));
                    } else {
                      Alerts.snackbar(context, text: 'Failed to launch url');
                    }
                  },
                  icon: Icon(RenderIcons.openInBrowser)
                ),
              ),
              ListTile(
                title: const Text('Devflow Studios'),
                contentPadding: EdgeInsets.only(
                  left: 18,
                  right: 6
                ),
                trailing: FilledTonalIconButton(
                  secondary: true,
                  onPressed: () async {
                    if (await canLaunchUrl(Uri.parse('https://renderstudio.app/about'))) {
                      await launchUrl(Uri.parse('https://renderstudio.app/about'));
                    } else {
                      Alerts.snackbar(context, text: 'Failed to launch url');
                    }
                  },
                  icon: Icon(RenderIcons.openInBrowser)
                ),
              ),
              ListTile(
                title: const Text('Terms of Use'),
                contentPadding: EdgeInsets.only(
                  left: 18,
                  right: 6
                ),
                trailing: FilledTonalIconButton(
                  secondary: true,
                  onPressed: () async {
                    if (await canLaunchUrl(Uri.parse('https://renderstudio.app/terms'))) {
                      await launchUrl(Uri.parse('https://renderstudio.app/terms'));
                    } else {
                      Alerts.snackbar(context, text: 'Failed to launch url');
                    }
                  },
                  icon: Icon(RenderIcons.openInBrowser)
                ),
              ),
              const ListTile(
                title: Text('Made with ❤️ in India'),
                contentPadding: EdgeInsets.only(
                  left: 18,
                  right: 6
                ),
              ),
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
    padding: const EdgeInsets.only(
      left: 15,
      bottom: 6
    ),
    child: Text(
      title,
      style: Theme.of(context).textTheme.bodySmall,
    ),
  );

}