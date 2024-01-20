import 'package:flutter/material.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:smooth_corner/smooth_corner.dart';
import '../../../../rehmat.dart';

class Home extends StatefulWidget {

  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  bool isViewingTemplates = false;
  
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        cacheExtent: MediaQuery.of(context).size.height * 3,
        slivers: [
          RenderAppBar(
            title: PullDownButton(
              itemBuilder: (context) => [
                PullDownMenuItem.selectable(
                  selected: !isViewingTemplates,
                  onTap: () {
                    setState(() {
                      isViewingTemplates = false;
                    });
                  },
                  title: 'Projects',
                ),
                PullDownMenuItem.selectable(
                  selected: isViewingTemplates,
                  onTap: () {
                    setState(() {
                      isViewingTemplates = true;
                    });
                  },
                  title: 'Templates',
                ),
              ],
              buttonBuilder: (context, showMenu) {
                return GestureDetector(
                  onTap: showMenu,
                  child: Text(
                    app.remoteConfig.appTitle,
                    style: TextStyle(
                      fontFamily: 'Helvetica',
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                );
              }
            ),
            titleSpacing: 12,
            actions: [
              PullDownButton(
                itemBuilder: (context) => [
                  PullDownMenuItem(
                    onTap: () => AppRouter.push(context, page: MyPalettes()),
                    title: 'My Palettes',
                    icon: RenderIcons.palette,
                  ),
                  PullDownMenuItem(
                    onTap: () => AppRouter.push(context, page: Settings()),
                    title: 'Settings',
                    icon: RenderIcons.settings,
                  ),
                ],
                buttonBuilder: (context, showMenu) {
                  return GestureDetector(
                    onTap: showMenu,
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
                  );
                }
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
            sliver: ProjectsView(
              showOnlyTemplates: isViewingTemplates,
            )
          ),
        ],
      ),
      floatingActionButton: (app.remoteConfig.allowCreateProject) ? FloatingActionButton.extended(
        onPressed: () => AppRouter.push(context, page: CreateProject()),
        tooltip: 'Create Project',
        icon: Icon(
          RenderIcons.add,
          color: Palette.of(context).background,
          size: 20,
        ),
        label: Text(
          'Create Project',
          style: TextStyle(
            fontFamily: 'SF Pro Rounded',
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Palette.of(context).onBackground,
        foregroundColor: Palette.of(context).background,
        shape: SmoothRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          smoothness: 0.6,
        ),
      ) : null,
    );
  }

}