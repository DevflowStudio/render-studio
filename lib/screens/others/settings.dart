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
                title: const Text('Export Quality'),
                trailing: PopupMenuButton<ExportQuality>(
                  itemBuilder: (context) => List.generate(
                    ExportQuality.values.length,
                    (index) => PopupMenuItem(
                      value: ExportQuality.values[index],
                      child: Text(ExportQuality.values[index].name.toTitleCase()),
                    ),
                  ),
                  onSelected: (value) async {
                    preferences.exportQuality = value;
                    setState(() { });
                  },
                  child: Chip(
                    label: Text(preferences.exportQuality.name.toTitleCase()),
                  ),
                ),
              ),
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
                title: const Text('Collect Usage Data'),
                trailing: Switch.adaptive(
                  value: preferences.allowAnalytics,
                  onChanged: (value) async {
                    preferences.allowAnalytics = value;
                    setState(() { });
                  },
                ),
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
                    if (await canLaunchUrl(Uri.parse('https://devflow.studio/about'))) {
                      await launchUrl(Uri.parse('https://devflow.studio/about'));
                    } else {
                      Alerts.snackbar(context, text: 'Failed to launch url');
                    }
                  },
                  icon: const Icon(RenderIcons.openInBrowser)
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
                    if (await canLaunchUrl(Uri.parse('https://devflow.studio'))) {
                      await launchUrl(Uri.parse('https://devflow.studio'));
                    } else {
                      Alerts.snackbar(context, text: 'Failed to launch url');
                    }
                  },
                  icon: const Icon(RenderIcons.openInBrowser)
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
                    if (await canLaunchUrl(Uri.parse('https://devflow.studio/terms-of-use'))) {
                      await launchUrl(Uri.parse('https://devflow.studio/terms-of-use'));
                    } else {
                      Alerts.snackbar(context, text: 'Failed to launch url');
                    }
                  },
                  icon: const Icon(RenderIcons.openInBrowser)
                ),
              ),
              const ListTile(
                title: Text('Made with ❤️ in India'),
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