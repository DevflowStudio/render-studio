import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:octo_image/octo_image.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import '../../../rehmat.dart';

class Home extends StatefulWidget {

  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final AdvancedDrawerController drawerCtrl = AdvancedDrawerController();

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
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            RenderAppBar(
              leading: Padding(
                padding: const EdgeInsets.all(12),
                child: GestureDetector(
                  onTap: () => drawerCtrl.toggleDrawer(),
                  child: CircleAvatar(
                    child: OctoImage(
                      image: AssetImage('assets/images/avatar.png'),
                    ),
                  ),
                ),
              ),
              title: Text(
                'render',
                // [rye, henny penny, libre barcode]
                style: GoogleFonts.racingSansOne(
                  fontSize: 30
                ),
              ),
              centerTitle: true,
              titleSpacing: 12,
              // actions: [
              //   IconButton(
              //     onPressed: () => AppRouter.push(context, page: Settings()),
              //     icon: Icon(RenderIcons.settings)
              //   )
              // ],
              isExpandable: false,
              pinned: false,
              floating: true,
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              sliver: ProjectsView()
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Project.create(context),
          tooltip: 'Create Project',
          icon: Icon(
            RenderIcons.add,
            color: Palette.of(context).onPrimaryContainer,
          ),
          label: Text('Create Project'),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 0,
                blurRadius: 2,
              ),
            ],
          ),
          child: NavigationBar(
            destinations: [
              NavigationDestination(
                icon: Icon(RenderIcons.projects),
                label: 'Projects',
              ),
              NavigationDestination(
                icon: Icon(RenderIcons.templates),
                label: 'Templates'
              ),
              NavigationDestination(
                icon: Icon(RenderIcons.lab),
                label: 'Studio Lab'
              ),
              NavigationDestination(
                icon: Icon(RenderIcons.sharing),
                label: 'Sharing'
              ),
            ],
            onDestinationSelected: (value) {
              switch (value) {
                case 2:
                  AppRouter.push(context, page: Lab());
                  break;
                default:
              }
            },
          ),
        ),
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
              right: 6,
              top: AppBar().preferredSize.height - 5
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FilledTonalIconButton(
                  onPressed: () => controller.toggleDrawer(),
                  icon: Icon(RenderIcons.arrow_left),
                  secondary: true,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                SizedBox.square(
                  dimension: 50,
                  child: OctoImage(
                    image: AssetImage('assets/images/avatar.png'),
                  ),
                ),
                SizedBox(width: 9),
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'John Doe',
                        style: Theme.of(context).textTheme.subtitle1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'john.doe@example.com',
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
                  controller: controller,
                  leadingIcon: RenderIcons.user,
                  title: 'Profile'
                ),
                SizedBox(height: 6,),
                _DrawerItemBuilder(
                  controller: controller,
                  leadingIcon: RenderIcons.templates,
                  title: 'Templates'
                ),
                SizedBox(height: 6,),
                _DrawerItemBuilder(
                  controller: controller,
                  leadingIcon: RenderIcons.lab,
                  title: 'Studio Lab',
                  onTap: () => AppRouter.push(context, page: Lab()),
                ),
                SizedBox(height: 6,),
                _DrawerItemBuilder(
                  controller: controller,
                  leadingIcon: RenderIcons.calendar,
                  title: 'Planner'
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
                  controller: controller,
                  leadingIcon: RenderIcons.help,
                  title: 'Help Center'
                ),
                SizedBox(height: 6,),
                _SecondaryDrawerItemBuilder(
                  controller: controller,
                  leadingIcon: RenderIcons.error,
                  title: 'Report Issue'
                ),
                SizedBox(height: 6,),
                _SecondaryDrawerItemBuilder(
                  controller: controller,
                  leadingIcon: RenderIcons.signOut,
                  title: 'Sign Out',
                ),
                SizedBox(height: 6,),
                _SecondaryDrawerItemBuilder(
                  controller: controller,
                  leadingIcon: RenderIcons.settings,
                  title: 'Settings',
                  onTap: () => AppRouter.push(context, page: Settings())
                )
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 12,)
        ],
      ),
    );
  }
}

class _DrawerItemBuilder extends StatefulWidget {

  const _DrawerItemBuilder({
    required this.title,
    required this.controller,
    this.leadingIcon,
    this.onTap
  });

  final AdvancedDrawerController controller;
  final String title;
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
              Text(
                widget.title,
                style: Theme.of(context).textTheme.subtitle1
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
    required this.controller,
    this.leadingIcon,
    this.onTap
  });

  final AdvancedDrawerController controller;
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
        TapFeedback.light();
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
              style: Theme.of(context).textTheme.subtitle2
            ),
          ],
        ),
      ),
    );
  }
}