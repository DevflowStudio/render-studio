import 'package:flutter/material.dart';
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