import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:render_studio/widgets/projects.dart';
import 'package:universal_io/io.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:octo_image/octo_image.dart';
import '../../../rehmat.dart';

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
    projects = projectSaves.projects;
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
          RenderAppBar(
            title: Text(
              'Render',
              style: GoogleFonts.dmSerifDisplay()
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 6),
            sliver: ProjectsView()
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Project.create(context),
        tooltip: 'Create Project',
        child: Icon(
          Iconsax.add_circle5,
          color: Palette.of(context).onPrimaryContainer,
        ),
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
              icon: Icon(Iconsax.grid_2),
              label: 'Projects'
            ),
            NavigationDestination(
              icon: Icon(Iconsax.discover),
              label: 'Templates'
            ),
            NavigationDestination(
              icon: Icon(Iconsax.shapes),
              label: 'Studio Lab'
            ),
            NavigationDestination(
              icon: Icon(Iconsax.share),
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
    );
  }

  void onProjectsUpdate() {
    List<ProjectGlance> newProjects = projectSaves.projects;

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

    projects.sort((a, b) => b.edited!.compareTo(a.edited!),);

    setState(() { });
  }

}