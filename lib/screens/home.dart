import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
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
      rtlOpening: true,
      child: Scaffold(
        body: CustomScrollView(
          cacheExtent: MediaQuery.of(context).size.height * 3,
          slivers: [
            RenderAppBar(
              // leading: Padding(
              //   padding: const EdgeInsets.all(12),
              //   child: GestureDetector(
              //     onTap: () => drawerCtrl.toggleDrawer(),
              //     child: CircleAvatar(
              //       child: ClipRRect(
              //         borderRadius: BorderRadius.circular(20),
              //         child: ProfilePhoto()
              //       )
              //     ),
              //   ),
              // ),
              title: AppTitle(),
              // title: Text(
              //   'render',
              //   // [rye, henny penny, libre barcode]
              //   style: GoogleFonts.racingSansOne(
              //     fontSize: 30
              //   ),
              // ),
              // centerTitle: true,
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
              // backgroundColor: Palette.of(context).surfaceVariant,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(kBorderRadius)
                )
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.only(
                top: 12,
                left: 6,
                right: 6
              ),
              sliver: SliverToBoxAdapter(
                child: CreateProjectBanner(),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.only(
                top: 24,
                left: 12,
                right: 12,
              ),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'Projects',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1,
                    color: Palette.of(context).onSurfaceVariant
                  )
                )
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.only(
                top: 12,
                bottom: MediaQuery.of(context).padding.bottom + 12,
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
                        style: Theme.of(context).textTheme.subtitle1,
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
                  leadingIcon: RenderIcons.palette,
                  title: 'Palettes',
                  onTap: () => AppRouter.push(context, page: MyPalettes()),
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
                  onTap: () => AuthState.of(context).signOut(),
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

class AppTitle extends StatefulWidget {
  AppTitle({Key? key}) : super(key: key);

  @override
  State<AppTitle> createState() => _AppTitleState();
}

class _AppTitleState extends State<AppTitle> {

  bool isAnimating = false;

  late final String title;

  @override
  void initState() {
    showAnimation();
    title = {
      'Render': 0.9,
      'Studio': 0.9,
      'Render Studio': 0.2,
      'Wow! This title is rare': 0.01,
      'Hey!': 0.1,
      'Let\'s design': 0.2,
      'Studio Render': 0.05,
      'Not Canva': 0.01,
      'Better than Canva?': 0.01,
    }.getRandomWithProbabilities();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedSwitcher(
          duration: Constants.animationDuration,
          child: isAnimating ? AnimatedTextKit(
            animatedTexts: [
              RotateAnimatedText(
                'render',
                textStyle: textStyle('Racing Sans One'),
                duration: Duration(milliseconds: 500)
              ),
              RotateAnimatedText(
                'render',
                textStyle: textStyle('Rye'),
                duration: Duration(milliseconds: 500)
              ),
              RotateAnimatedText(
                'render',
                textStyle: textStyle('Henny Penny'),
                duration: Duration(milliseconds: 500)
              ),
              RotateAnimatedText(
                'render',
                textStyle: textStyle('Libre Barcode 39'),
                duration: Duration(milliseconds: 500)
              ),
            ],
            totalRepeatCount: 1,
            pause: const Duration(seconds: 0),
            displayFullTextOnTap: false,
            onFinished: () => setState(() => isAnimating = false),
          ) : FadeInDown(
            duration: Duration(milliseconds: 400),
            child: Text(
              title,
              style: TextStyle(
                fontFamily: 'Helvetica',
                fontWeight: FontWeight.w800,
                fontSize: 25
              ),
            ),
          ),
        ),
      ],
    );
  }

  void showAnimation() {
    isAnimating = true;
  }

  TextStyle textStyle(String font) => GoogleFonts.getFont(font).copyWith(
    fontSize: 25
  );

}