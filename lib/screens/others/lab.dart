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
              Card(
                margin: EdgeInsets.symmetric(horizontal: 6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: centerListTileIcon(
                        child: Icon(
                          RenderIcons.design_kit
                        )
                      ),
                      visualDensity: VisualDensity.compact,
                      title: Text(
                        'Design Kit',
                      ),
                      subtitle: Text('Create and edit design kits for your brand'),
                    ),
                    ListTile(
                      leading: centerListTileIcon(child: Icon(RenderIcons.palette)),
                      visualDensity: VisualDensity.compact,
                      title: Text(
                        'Color Palettes',
                      ),
                      subtitle: Text('View and create color palettes'),
                      onTap: () => AppRouter.push(context, page: MyPalettes()),
                    ),
                    ListTile(
                      leading: centerListTileIcon(child: Icon(RenderIcons.lab)),
                      visualDensity: VisualDensity.compact,
                      title: Text(
                        'Custom Widgets',
                      ),
                      subtitle: Text('View and create color palettes'),
                      onTap: () => AppRouter.push(context, page: HTMLWidgetCreator()),
                    ),
                  ],
                ),
              ),
            ])
          )
        ],
      ),
    );
  }

  Widget centerListTileIcon({
    required Widget child
  }) => SizedBox(
    height: double.maxFinite,
    child: child
  );

  Widget get divider => Divider(
    height: 0,
    endIndent: 0,
    indent: 0,
  );

}