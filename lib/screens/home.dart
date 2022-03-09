import 'dart:io';
// import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:octo_image/octo_image.dart';
import '../rehmat.dart';

class Home extends StatefulWidget {

  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final scrollController = ScrollController();

  late List<ProjectGlance> projects;

  @override
  void initState() {
    projects = projectSaves.posts;
    projectSaves.stream.addListener(onProjectsUpdate);
    super.initState();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    } else {
      fn();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            centerTitle: false,
            expandedHeight: Constants.appBarExpandedHeight,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 13, top: 13, bottom: 13, left: 10),
                child: InkWell(
                  onTap: () => AppRouter.push(context, page: Settings()),
                  borderRadius: Constants.borderRadius,
                  child: SizedBox(
                    height: 30,
                    width: 30,
                    child: Icon(Icons.settings),
                    // child: ClipRRect(
                    //   borderRadius: Constants.borderRadius,
                    //   child: OctoImage(
                    //     width: 30,
                    //     height: 30,
                    //     fit: BoxFit.cover,
                    //     image: CachedNetworkImageProvider(Auth.user.photoURL!)
                    //   ),
                    // ),
                  ),
                ),
              )
            ],
            titleTextStyle: const TextStyle(
              fontSize: 14
            ),
            flexibleSpace: RenderFlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              centerTitle: false,
              title: Text(
                'Render',
                style: AppTheme.flexibleSpaceBarStyle.copyWith(
                  fontFamily: Fonts.main,
                  color: Palette.of(context).onBackground
                ),
              ),
              stretchModes: const [
                StretchMode.fadeTitle
              ],
              titlePadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            ),
          ),
          if (projects.isNotEmpty) SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            sliver: SliverMasonryGrid(
              gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: Constants.of(context).crossAxisCount,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => SizedBox(
                  child: InteractiveCard(
                    onTap: () {
                      ProjectGlance project = projects[index];
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => PostViewModal(project: project),
                      );
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width/2,
                          height: MediaQuery.of(context).size.width/2 * projects[index].size.size.height / projects[index].size.size.width,
                          child: Builder(
                            builder: (context) {
                              ProjectGlance project = projects[index];
                              Widget errorWidget = Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.warning),
                                    Container(height: 5,),
                                    const Text('Could not get thumbnail'),
                                  ],
                                )
                              );
                              if (project.thumbnails.isNotEmpty) {
                                File file = File(project.thumbnails.first);
                                return FutureBuilder<bool>(
                                  future: file.exists(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.done && snapshot.data == true) {
                                      return ClipRRect(
                                        borderRadius: BorderRadius.vertical(top: Constants.borderRadius.topLeft),
                                        child: OctoImage(
                                          image: FileImage(file),
                                          fit: BoxFit.cover,
                                        ),
                                      );
                                    } else if (snapshot.connectionState == ConnectionState.done && snapshot.data == false) {
                                      return errorWidget;
                                    }
                                    return const Center(
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: Spinner(
                                          strokeWidth: 2,
                                        )
                                      ),
                                    );
                                  },
                                );
                              }
                              else {
                                return errorWidget;
                              }
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Label(
                                label: projects[index].title!
                              ),
                              Text(
                                getTimeAgo(projects[index].edited ?? projects[index].created!),
                                style: Theme.of(context).textTheme.caption,
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                childCount: projects.length
              ),
            )
          )
          else SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: Constants.horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome,',
                    style: Theme.of(context).textTheme.headline5,
                  ),
                  Text(
                    'Create your first project',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  Container(height: 10,),
                  SizedBox(
                    width: 150,
                    child: Button(
                      text: 'Create Project',
                      onPressed: () => Project.create(context),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Project.create(context),
        tooltip: 'Create Project',
        child: Icon(
          Icons.add,
          color: Palette.of(context).onPrimaryContainer,
        ),
      ),
      bottomNavigationBar: RenderNavigationBar(
        backgroundColor: Palette.of(context).surface,
        destinations: const [
          NavigationBarDestination(
            icon: Icons.window,
            label: 'Projects'
          ),
          NavigationBarDestination(
            icon: Icons.explore_outlined,
            label: 'Templates'
          ),
          NavigationBarDestination(
            icon: Icons.science_outlined,
            label: 'Studio Lab'
          ),
          NavigationBarDestination(
            icon: Icons.people_outline,
            label: 'Sharing'
          ),
        ],
        onTap: (value) {
          switch (value) {
            case 2:
              AppRouter.push(context, page: Lab());
              break;
            default:
          }
        },
      ),
    );
  }

  void onProjectsUpdate() {
    List<ProjectGlance> newProjects = projectSaves.posts;

    List<String> added = [];
    List<ProjectGlance> _added = [];
    List<String> deleted = [];
    
    bool isAdded = projects.length < newProjects.length;

    List<String> ids = [];
    for (ProjectGlance overview in projects) {
      ids.add(overview.id);
    }
    List<String> _ids = [];
    for (ProjectGlance overview in newProjects) {
      _ids.add(overview.id);
    }

    if (isAdded) {
      added.addAll(_ids.where((id) => !ids.contains(id)));
      for (String id in added) {
        _added.addAll(newProjects.where((project) => project.id == id));
      }
    } else {
      deleted.addAll(ids.where((id) => !_ids.contains(id)));
    }

    projects.removeWhere((project) => deleted.contains(project.id));
    projects.addAll(_added);

    setState(() { });
  }

}