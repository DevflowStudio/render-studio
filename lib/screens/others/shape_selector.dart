import 'package:flutter/material.dart';

import '../../rehmat.dart';

class ShapeSelectorScreen extends StatefulWidget {

  const ShapeSelectorScreen({super.key});

  static Future<String?> select(BuildContext context) => AppRouter.push(context, page: ShapeSelectorScreen());

  @override
  State<ShapeSelectorScreen> createState() => _ShapeSelectorScreenState();
}

class _ShapeSelectorScreenState extends State<ShapeSelectorScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          RenderAppBar(
            title: Text('Shapes'),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: 6
            ),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, index) => InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => Navigator.of(context).pop(RenderShapeAbstract.names[index]),
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: CustomPaint(
                      painter: CreativeShape(
                        name: RenderShapeAbstract.names[index],
                        color: Palette.of(context).onBackground
                      ),
                    ),
                  ),
                ),
                childCount: RenderShapeAbstract.names.length,
              ),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5),
            ),
          )
        ],
      ),
    );
  }

}