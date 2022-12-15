import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import '../../../rehmat.dart';

class Home extends StatefulWidget {

  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

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
              label: 'Projects'
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
    );
  }

}