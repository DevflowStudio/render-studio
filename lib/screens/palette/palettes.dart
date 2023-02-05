import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../rehmat.dart';

class MyPalettes extends StatefulWidget {

  MyPalettes({Key? key}) : super(key: key);

  @override
  State<MyPalettes> createState() => _MyPalettesState();
}

class _MyPalettesState extends State<MyPalettes> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          RenderAppBar(
            title: Text('Palettes'),
          ),
          SliverPadding(
            padding: const EdgeInsets.only(
              left: 16,
              bottom: 10
            ),
            sliver: SliverToBoxAdapter(
              child: Label(label: 'Default'),
            ),
          ),
          SliverToBoxAdapter(
            child: _PaletteViewModal(palette: ColorPalette.defaultSet),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(vertical: 12),
            sliver: SliverToBoxAdapter(
              child: Divider(),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.only(
              left: 16,
              bottom: 4
            ),
            sliver: SliverToBoxAdapter(
              child: Label(label: 'My Palettes'),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Slidable(
                  key: UniqueKey(),
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    dismissible: DismissiblePane(
                      onDismissed: () async {
                        await paletteManager.delete(paletteManager.palettes[index]);
                        setState(() {});
                        Alerts.snackbar(context, text: 'Palette deleted');
                      }
                    ),
                    children: [
                      SlidableAction(
                        onPressed: (context) async {
                          await paletteManager.delete(paletteManager.palettes[index]);
                          setState(() {});
                          Alerts.snackbar(context, text: 'Palette deleted');
                        },
                        borderRadius: BorderRadius.horizontal(
                          left: Radius.circular(20)
                        ),
                        backgroundColor: Palette.of(context).errorContainer,
                        foregroundColor: Palette.of(context).onErrorContainer,
                        icon: RenderIcons.delete,
                        label: 'Delete',
                      ),
                    ],
                  ),
                  child: _PaletteViewModal(palette: paletteManager.palettes[index]),
                ),
              ),
              childCount: paletteManager.palettes.length
            )
          ),
          if (paletteManager.palettes.isEmpty) SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'No palettes yet. Create one by clicking the button above.',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          ),
          for (String collectionName in ColorPalette.collections.keys) ... [
            SliverPadding(
              padding: EdgeInsets.symmetric(vertical: 12),
              sliver: SliverToBoxAdapter(
                child: Divider(),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.only(
                left: 16,
                bottom: 4
              ),
              sliver: SliverToBoxAdapter(
                child: Label(label: collectionName),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: _PaletteViewModal(palette: ColorPalette.collections[collectionName]![index]),
                ),
                childCount: ColorPalette.collections[collectionName]!.length
              )
            ),
          ]
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await AppRouter.push(context, page: CreatePalette());
          setState(() { });
        },
        child: Icon(RenderIcons.create),
        tooltip: 'Create Palette',
      ),
    );
  }
}

class _PaletteViewModal extends StatelessWidget {

  const _PaletteViewModal({
    Key? key,
    required this.palette,
  }) : super(key: key);

  final ColorPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Row(
          children: List.generate(
            palette.colors.length,
            (index) => Flexible(
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                height: 100,
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 0,
                    color: palette.colors[index]
                  ),
                  color: palette.colors[index],
                ),
              )
            )
          ),
        ),
      ),
    );
  }
}