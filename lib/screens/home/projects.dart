import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../rehmat.dart';

class MyProjects extends StatefulWidget {

  const MyProjects({super.key});

  @override
  State<MyProjects> createState() => MyProjectsState();
}

class MyProjectsState extends State<MyProjects> {

  final scrollController = ScrollController();

  @override
  void initState() {
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
            actions: [
              IconButton(
                onPressed: () => AppRouter.push(context, page: Settings()),
                icon: Icon(RenderIcons.settings)
              )
            ],
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
          RenderIcons.add,
          color: Palette.of(context).onPrimaryContainer,
        ),
      ),
    );
  }

}