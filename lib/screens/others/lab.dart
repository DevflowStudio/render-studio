import 'package:flutter/material.dart';
import '../../../rehmat.dart';

class Lab extends StatefulWidget {

  const Lab({Key? key}) : super(key: key);

  @override
  State<Lab> createState() => _LabState();
}

class _LabState extends State<Lab> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          RenderAppBar(
            title: Text('Studio Lab'),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              divider,
              ListTile(
                leading: Icon(Icons.design_services),
                title: Text(
                  'Design System',
                ),
                subtitle: Text('Create and edit design systems for your projects'),
              ),
              divider,
              ListTile(
                leading: Icon(Icons.palette),
                title: Text(
                  'Color Palettes',
                ),
                subtitle: Text('View and Create Color Palettes'),
                onTap: () => AppRouter.push(context, page: MyPalettes()),
              ),
            ])
          )
        ],
      ),
    );
  }

  Widget get divider => Divider(
    height: 0,
    endIndent: 0,
    indent: 0,
  );

}