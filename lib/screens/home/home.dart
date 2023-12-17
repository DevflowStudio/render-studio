import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import '../../../../rehmat.dart';

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
                if (app.remoteConfig.allowCreateProject) IconButton.outlined(
                  onPressed: () => AppRouter.push(context, page: CreateProject()),
                  icon: Icon(RenderIcons.create),
                ),
                IconButton.filledTonal(
                  onPressed: () async {
                    String json = '''
{"id":"kpbYJ24","title":"Project (11) (copy)","description":"","images":["/Render Projects/kpbYJ24/page-IFjb.png"],"thumbnail":"/Render Projects/kpbYJ24/page-IFjb.png","size":{"type":"Custom","height":1080.0,"width":1080.0},"pages":[{"widgets":[{"id":"background","uid":"PzEwrUN","name":"Background","asset":null,"group":null,"properties":{"is-universal-build":true,"position":{"dx":0.0,"dy":0.0},"angle":0.0,"opacity":1.0,"size":{"width":2990.7692307692305,"height":2990.7692307692305},"vertical-expand-direction":"both","horizontal-expand-direction":"both"},"variables":null,"color":"#ffc35e9e","gradient":null,"padding":{"vertical":62.67857142857141,"horizontal":62.67857142857141},"image-provider":null},{"id":"group","uid":"106Fd70","name":"Group Widget","asset":null,"group":null,"properties":{"is-universal-build":true,"position":{"dx":2.7449535500805076,"dy":173.18084572078348},"angle":0.0,"opacity":1.0,"size":{"width":960.1327642430182,"height":608.2811657012902},"vertical-expand-direction":"up","horizontal-expand-direction":"right"},"variables":null,"widgets":[{"id":"text","uid":"4a0h7iK","name":"Text","asset":null,"group":"106Fd70","properties":{"is-universal-build":true,"position":{"dx":-88.04819131991455,"dy":-167.68048224527269},"angle":0.0,"opacity":1.0,"size":{"width":784.036381603189,"height":272.9202012107449},"vertical-expand-direction":"both","horizontal-expand-direction":"right"},"variables":{"type":"string","value":"Sam Altman returns to OpenAI after 4 day coup"},"text":{"text":"Sam Altman returns to OpenAI after 4 day coup","font":"Oswald","auto-size":true,"font-size":110.76923076923077,"line-height":1.0},"_span-size":{"width":954.6428571428572,"height":332.3076923076923},"color":{"background":"#00000000"},"primary-style":{"bold":false,"italics":false,"underline":false,"strikethrough":false,"overline":false,"color":"#ffe9f3fb"},"secondary-style":null,"widget":{"color":null,"radius":27.692307692307693},"container-provider":{"color":null,"gradient":null,"border-color":null,"border-width":null,"border-radius":0.0,"blur":0.0,"padding":{"vertical":0.0,"horizontal":0.0},"shadow":null},"alignment":0,"shadows":[{"color":"#66000000","offset":{"dx":2.293276337663782,"dy":1.5126966232128867},"blur":0.0}],"padding":{"vertical":0.0,"horizontal":0.0},"spacing":{"word":0.0,"letter":2.769230769230769}},{"id":"text","uid":"4EMziD0","name":"Text","asset":null,"group":"106Fd70","properties":{"is-universal-build":true,"position":{"dx":2.513026499598053,"dy":128.46955764182866},"angle":0.0,"opacity":1.0,"size":{"width":955.1067112438221,"height":260.1664812633087},"vertical-expand-direction":"both","horizontal-expand-direction":"right"},"variables":{"type":"string","value":"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce nisi dui, convallis et vulputate bibendum, mollis eu risus. Sed augue urna, suscipit a massa a, finibus scelerisque ipsum. Mauris lobortis."},"text":{"text":"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce nisi dui, convallis et vulputate bibendum, mollis eu risus. Sed augue urna, suscipit a massa a, finibus scelerisque ipsum. Mauris lobortis.","font":"Merriweather","auto-size":true,"font-size":110.76923076923077,"line-height":1.291536999172634},"_span-size":{"width":2643.218406753826,"height":720.0},"color":{"background":"#00000000"},"primary-style":{"bold":false,"italics":false,"underline":false,"strikethrough":false,"overline":false,"color":"#ffe9f3fb"},"secondary-style":null,"widget":{"color":null,"radius":27.692307692307693},"container-provider":{"color":null,"gradient":null,"border-color":null,"border-width":null,"border-radius":0.0,"blur":0.0,"padding":{"vertical":0.0,"horizontal":0.0},"shadow":null},"alignment":0,"shadows":null,"padding":{"vertical":0.0,"horizontal":0.0},"spacing":{"word":0.0,"letter":2.769230769230769}},{"id":"text","uid":"FoDjuqZ","name":"Text","asset":null,"group":"106Fd70","properties":{"is-universal-build":true,"position":{"dx":-160.71182003535873,"dy":289.0089963544741},"angle":0.0,"opacity":1.0,"size":{"width":628.6570181739086,"height":30.263172992341943},"vertical-expand-direction":"up","horizontal-expand-direction":"right"},"variables":{"type":"string","value":"cardinal.news/articles/sama-openai-row"},"text":{"text":"cardinal.news/articles/sama-openai-row","font":"Montserrat","auto-size":true,"font-size":110.76923076923077,"line-height":1.0},"_span-size":{"width":2301.0096905048076,"height":110.76923076923077},"color":{"background":"#00000000"},"primary-style":{"bold":false,"italics":false,"underline":false,"strikethrough":false,"overline":false,"color":"#ffe9f3fb"},"secondary-style":null,"widget":{"color":null,"radius":27.692307692307693},"container-provider":{"color":null,"gradient":null,"border-color":null,"border-width":null,"border-radius":0.0,"blur":0.0,"padding":{"vertical":0.0,"horizontal":0.0},"shadow":null},"alignment":0,"shadows":null,"padding":{"vertical":0.0,"horizontal":0.0},"spacing":{"word":0.0,"letter":2.769230769230769}}],"_group":"106Fd70","_demographics":{"version":"piHALeF","4a0h7iK":{"overlaps":[],"above":[],"below":["4EMziD0","FoDjuqZ"],"left":[],"right":[],"original-size":{"width":283.1242489122627,"height":98.5545171038801}},"4EMziD0":{"overlaps":[],"above":["4a0h7iK"],"below":["FoDjuqZ"],"left":[],"right":[],"original-size":{"width":344.8996457269358,"height":93.94900712286147}},"FoDjuqZ":{"overlaps":[],"above":["4a0h7iK","4EMziD0"],"below":[],"left":[],"right":[],"original-size":{"width":227.0150343405781,"height":10.928368025012368}}}},{"id":"box","uid":"UOGi1T9","name":"Box","asset":null,"group":null,"properties":{"is-universal-build":false,"position":{"dx":142.0507540515136,"dy":-142.0507540515136},"angle":0.0,"opacity":1.0,"size":{"width":60.63063475411573,"height":60.63063475411573},"vertical-expand-direction":"down","horizontal-expand-direction":"left"},"variables":null,"container-provider":{"color":"#ff362360","gradient":null,"border-color":null,"border-width":null,"border-radius":0.0,"blur":0.0,"padding":{"vertical":0.0,"horizontal":0.0},"shadow":null}},{"id":"box","uid":"q9RJJzq","name":"Box","asset":null,"group":null,"properties":{"is-universal-build":false,"position":{"dx":158.7220700623263,"dy":158.7220700623263},"angle":0.0,"opacity":1.0,"size":{"width":27.288002732490252,"height":27.288002732490252},"vertical-expand-direction":"up","horizontal-expand-direction":"left"},"variables":null,"container-provider":{"color":"#ff362360","gradient":null,"border-color":null,"border-width":null,"border-radius":0.0,"blur":0.0,"padding":{"vertical":0.0,"horizontal":0.0},"shadow":null}},{"id":"box","uid":"hM2IDjw","name":"Box","asset":null,"group":null,"properties":{"is-universal-build":false,"position":{"dx":-158.7220700623263,"dy":-60.9350175520285},"angle":0.0,"opacity":1.0,"size":{"width":27.288002732490252,"height":27.288002732490252},"vertical-expand-direction":"down","horizontal-expand-direction":"right"},"variables":null,"container-provider":{"color":"#ff362360","gradient":null,"border-color":null,"border-width":null,"border-radius":0.0,"blur":0.0,"padding":{"vertical":0.0,"horizontal":0.0},"shadow":null}}],"palette":{"id":"#0045","colors":["#ffe9f3fb","#ffc3aed9","#ff84a6d3","#ffc35e9e","#ff362360"],"primary":"#ffc3aed9","secondary":"#ff362360","tertiary":"#ff84a6d3","background":"#ffc35e9e","onBackground":"#ffe9f3fb","surface":"#ffe9f3fb"},"assets":{}}],"meta":{"version":"1.1","created":1701636269179,"edited":1701636780521},"is-template":false,"variables":[{"widget":"text","uid":"4a0h7iK","type":"string","value":"Sam Altman returns to OpenAI after 4 day coup"},{"widget":"text","uid":"4EMziD0","type":"string","value":"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce nisi dui, convallis et vulputate bibendum, mollis eu risus. Sed augue urna, suscipit a massa a, finibus scelerisque ipsum. Mauris lobortis."},{"widget":"text","uid":"FoDjuqZ","type":"string","value":"cardinal.news/articles/sama-openai-row"}]}
''';
                    Map<String, dynamic> data = jsonDecode(json);
                    Project? project = await Project.fromJSON(data, context: context);
                    if (project != null) {
                      AppRouter.push(context, page: Studio(project: project));
                    }
                  },
                  icon: Icon(RenderIcons.lab),
                ),
                SizedBox(width: 6,),
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
            // if (app.remoteConfig.allowCreateProject) SliverToBoxAdapter(
            //   child: CreateProjectBanner(),
            // ),
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
        // bottomNavigationBar: NavigationBar(
        //   destinations: [
        //     NavigationDestination(
        //       icon: Icon(RenderIcons.home),
        //       label: 'Home',
        //     ),
        //     NavigationDestination(
        //       icon: Icon(RenderIcons.search),
        //       label: 'Discover',
        //     ),
        //     NavigationDestination(
        //       icon: Icon(RenderIcons.settings),
        //       label: 'Bookmarks',
        //     ),
        //     NavigationDestination(
        //       icon: Icon(RenderIcons.user),
        //       label: 'Profile',
        //     ),
        //   ],
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
                  icon: Icon(RenderIcons.close),
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
                  child: ClipOval(
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