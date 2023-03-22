import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import '../../../rehmat.dart';
import 'dart:convert' as convert;

class Home extends StatefulWidget {

  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final AdvancedDrawerController drawerCtrl = AdvancedDrawerController();
  
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AdvancedDrawer(
      controller: drawerCtrl,
      backdropColor: Theme.of(context).drawerTheme.backgroundColor,
      animateChildDecoration: true,
      openRatio: 0.75,
      openScale: 1,
      drawer: _Drawer(
        controller: drawerCtrl,
      ),
      rtlOpening: true,
      child: Scaffold(
        body: CustomScrollView(
          cacheExtent: MediaQuery.of(context).size.height * 3,
          slivers: [
            RenderAppBar(
              title: Text(
                app.remoteConfig.appTitle,
                style: TextStyle(
                  fontFamily: 'Helvetica',
                  fontWeight: FontWeight.w800,
                ),
              ),
              titleSpacing: 12,
              actions: [
                FilledTonalIconButton(
                  onPressed: () async {
                    String json = """
{
  "id": "pO29KfT",
  "title": "Project (24)",
  "description": "",
  "images": [
    "/Render Projects/pO29KfT/page-TQDw.png"
  ],
  "thumbnail": "/Render Projects/pO29KfT/page-TQDw.png",
  "size": {
    "type": "Instagram Landscape",
    "height": 1080.0,
    "width": 1350.0
  },
  "pages": [
    {
      "widgets": [
        {
          "id": "background",
          "uid": "R1oonid",
          "name": "Background",
          "asset": null,
          "group": null,
          "properties": {
            "position": {
              "dx": 0.0,
              "dy": 0.0
            },
            "angle": 0.0,
            "opacity": 1.0,
            "size": {
              "width": 1350.0,
              "height": 1080.0
            }
          },
          "color": "#ff0537b2",
          "gradient": null,
          "padding": {
            "vertical": 20.0,
            "horizontal": 20.0
          },
          "image-provider": null
        },
        {
          "id": "text",
          "uid": "kCQPJ6V",
          "name": "Text",
          "asset": null,
          "group": null,
          "properties": {
            "position": {
              "dx": 0.0,
              "dy": 0.0
            },
            "angle": 0.0,
            "opacity": 1.0,
            "size": {
              "width": 200.0,
              "height": 93.0
            }
          },
          "text": {
            "text": "Double tap to edit text",
            "font": "Inter",
            "auto-size": true,
            "font-size": 40.0,
            "line-height": 0.77
          },
          "_span-size": {
            "width": 200.0,
            "height": 93.0
          },
          "color": {
            "background": "#00000000"
          },
          "primary-style": {
            "bold": false,
            "italics": false,
            "underline": false,
            "strikethrough": false,
            "overline": false,
            "color": "#ffc6b1ab"
          },
          "secondary-style": null,
          "widget": {
            "color": null,
            "radius": 10.0
          },
          "container-provider": {
            "color": null,
            "gradient": null,
            "border-color": null,
            "border-width": null,
            "border-radius": 0.0,
            "blur": 0.0,
            "shadow": null
          },
          "alignment": 2,
          "shadows": null,
          "padding": {
            "vertical": 0.0,
            "horizontal": 0.0
          },
          "spacing": {
            "word": 0.0,
            "letter": 1.0
          }
        },
        {
          "id": "qr_code",
          "uid": "o0yCYTs",
          "name": "QR Code",
          "asset": null,
          "group": null,
          "properties": {
            "position": {
              "dx": -76.56087183421337,
              "dy": -69.93912816578663
            },
            "angle": 0.0,
            "opacity": 1.0,
            "size": {
              "width": 46.878256331573255,
              "height": 46.878256331573255
            }
          },
          "data": "google",
          "backgroundColor": "#ffffffff",
          "dataColor": "#ff000000",
          "gapless": true,
          "padding": {
            "vertical": 4.380952380952378,
            "horizontal": 4.380952380952378
          }
        },
        {
          "id": "shape",
          "uid": "CRkHXVg",
          "name": "Shape",
          "asset": null,
          "group": null,
          "properties": {
            "position": {
              "dx": 168.30563136471116,
              "dy": -131.90596084332694
            },
            "angle": 0.0,
            "opacity": 1.0,
            "size": {
              "width": 48.72208077643705,
              "height": 45.72206551764798
            }
          },
          "color": "#ffc6b1ab",
          "shape": "heart",
          "shadow": null
        },
        {
          "id": "pie-chart",
          "uid": "mpQfkh5",
          "name": "Pie Chart",
          "asset": null,
          "group": null,
          "properties": {
            "position": {
              "dx": -141.83043536338107,
              "dy": 99.96491711836741
            },
            "angle": 0.0,
            "opacity": 1.0,
            "size": {
              "width": 219.00578576737846,
              "height": 131.40347875154643
            }
          },
          "data": [
            {
              "title": "Section 1",
              "value": 25.0,
              "color": "#ff838392"
            },
            {
              "title": "Section 2",
              "value": 15.0,
              "color": "#ff000000"
            },
            {
              "title": "Section 3",
              "value": 10.0,
              "color": "#fffee3c3"
            },
            {
              "title": "Section 4",
              "value": 30.0,
              "color": "#ffffe6e7"
            }
          ],
          "show-legend": false,
          "show-chart-values": false,
          "show-chart-values-outside": true,
          "show-chart-value-background": true,
          "show-chart-values-in-percentage": false,
          "decimal-places": 0,
          "chart-type": 0,
          "stroke-width": 20.0,
          "initial-angle": 0.0,
          "legend-spacing": 20.0
        }
      ],
      "palette": {
        "id": "color-palette-sXdy7fT",
        "colors": [
          "#ff102050",
          "#ff0537b2",
          "#ff1f62eb",
          "#ff3da1d2",
          "#ffc6b1ab"
        ],
        "primary": "#ffc6b1ab",
        "secondary": "#ff3da1d2",
        "tertiary": "#ff1f62eb",
        "background": "#ff0537b2",
        "onBackground": "#ffc6b1ab",
        "surface": "#ff102050"
      },
      "assets": {
        
      }
    }
  ],
  "meta": {
    "version": "1.1",
    "created": 1679190672828,
    "edited": 1679190890431
  }
}
""";
                    Map<String, dynamic> data = convert.json.decode(json);
                    Project? project = await Project.fromJSON(data, context: context);
                    if (project != null) {
                      AppRouter.push(context, page: Studio(project: project));
                    }
                  },
                  icon: Icon(RenderIcons.add)
                ),
                GestureDetector(
                  onTap: () => drawerCtrl.toggleDrawer(),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 12,
                      bottom: 12,
                      right: 12
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: ProfilePhoto()
                    ),
                  ),
                ),
              ],
              isExpandable: false,
              pinned: false,
              floating: false,
            ),
            if (app.remoteConfig.allowCreateProject) SliverPadding(
              padding: const EdgeInsets.only(top: 12),
              sliver: SliverToBoxAdapter(
                child: CreateProjectBanner(),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.only(
                bottom: Constants.of(context).bottomPadding,
                left: 6,
                right: 6,
              ),
              sliver: ProjectsView()
            ),
          ],
        ),
        // floatingActionButton: FloatingActionButton.extended(
        //   onPressed: () => Project.create(context),
        //   tooltip: 'Create Project',
        //   icon: Icon(
        //     RenderIcons.add,
        //     color: Palette.of(context).onPrimaryContainer,
        //   ),
        //   label: Text('Create Project'),
        // ),
      ),
    );
  }

}

class _Drawer extends StatefulWidget {

  const _Drawer({
    required this.controller
  });

  final AdvancedDrawerController controller;

  @override
  State<_Drawer> createState() => __DrawerState();
}

class __DrawerState extends State<_Drawer> {

  late final AdvancedDrawerController controller;

  @override
  void initState() {
    super.initState();
    controller = widget.controller;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).drawerTheme.backgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: AppBar().preferredSize.height,
              left: 6
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                FilledTonalIconButton(
                  onPressed: () => controller.toggleDrawer(),
                  icon: Icon(RenderIcons.arrow_left),
                  secondary: true,
                ),
              ],
            ),
          ),
          SizedBox(height: 6,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                SizedBox.square(
                  dimension: 50,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: ProfilePhoto(),
                  ),
                ),
                SizedBox(width: 9),
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AuthState.of(context).user!.displayName ?? 'Me',
                        style: Theme.of(context).textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (AuthState.of(context).user!.email != null) Text(
                        AuthState.of(context).user!.email!,
                        style: Theme.of(context).textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _DrawerItemBuilder(
                  leadingIcon: RenderIcons.templates,
                  title: 'Templates',
                  subtitle: 'Coming Soon',
                ),
                SizedBox(height: 6,),
                _DrawerItemBuilder(
                  leadingIcon: RenderIcons.palette,
                  title: 'Palettes',
                  onTap: () => AppRouter.push(context, page: MyPalettes()),
                ),
                SizedBox(height: 6,),
                _DrawerItemBuilder(
                  leadingIcon: RenderIcons.calendar,
                  title: 'Planner',
                  subtitle: 'Coming Soon',
                ),
                SizedBox(height: 6,),
                _DrawerItemBuilder(
                  leadingIcon: RenderIcons.settings,
                  title: 'Settings',
                  onTap: () => AppRouter.push(context, page: Settings())
                ),
              ],
            ),
          ),
          SizedBox(height: 12,),
          Spacer(),
          Divider(
            indent: 24,
            endIndent: 24,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 6,),
                _SecondaryDrawerItemBuilder(
                  leadingIcon: RenderIcons.help,
                  title: 'Help Center'
                ),
                SizedBox(height: 6,),
                _SecondaryDrawerItemBuilder(
                  leadingIcon: RenderIcons.error,
                  title: 'Report Issue'
                ),
                SizedBox(height: 6,),
                _SecondaryDrawerItemBuilder(
                  leadingIcon: RenderIcons.signOut,
                  title: 'Sign Out',
                  onTap: () => AuthState.of(context).signOut(),
                ),
              ],
            ),
          ),
          SizedBox(height: Constants.of(context).bottomPadding)
        ],
      ),
    );
  }
}

class _DrawerItemBuilder extends StatefulWidget {

  const _DrawerItemBuilder({
    required this.title,
    this.subtitle,
    this.leadingIcon,
    this.onTap
  });

  final String title;
  final String? subtitle;
  final IconData? leadingIcon;
  final void Function()? onTap;

  @override
  State<_DrawerItemBuilder> createState() => __DrawerItemBuilderState();
}

class __DrawerItemBuilderState extends State<_DrawerItemBuilder> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        TapFeedback.light();
        widget.onTap?.call();
      },
      child: Card(
        color: Palette.of(context).background,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              if (widget.leadingIcon != null) ... [
                Icon(widget.leadingIcon),
                SizedBox(width: 12,),
              ],
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: Theme.of(context).textTheme.titleMedium
                  ),
                  if (widget.subtitle != null) Text(
                    widget.subtitle!.toUpperCase(),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              Spacer(),
              Icon(RenderIcons.arrow_right)
            ],
          ),
        )
      ),
    );
  }
}

class _SecondaryDrawerItemBuilder extends StatefulWidget {

  const _SecondaryDrawerItemBuilder({
    required this.title,
    this.leadingIcon,
    this.onTap
  });

  final String title;
  final IconData? leadingIcon;
  final void Function()? onTap;

  @override
  State<_SecondaryDrawerItemBuilder> createState() => __SecondaryDrawerItemBuilderState();
}

class __SecondaryDrawerItemBuilderState extends State<_SecondaryDrawerItemBuilder> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        widget.onTap?.call();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 9
        ),
        child: Row(
          children: [
            if (widget.leadingIcon != null) ... [
              Icon(
                widget.leadingIcon,
              ),
              SizedBox(width: 9),
            ],
            Text(
              widget.title,
              style: Theme.of(context).textTheme.titleSmall
            ),
          ],
        ),
      ),
    );
  }
}