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
          SliverAppBar(
            pinned: true,
            centerTitle: false,
            expandedHeight: Constants.appBarExpandedHeight,
            titleTextStyle: const TextStyle(
              fontSize: 14
            ),
            flexibleSpace: RenderFlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              centerTitle: false,
              title: Text(
                'Palettes',
                // style: AppTheme.flexibleSpaceBarStyle
              ),
              titlePaddingTween: EdgeInsetsTween(
                begin: const EdgeInsets.only(
                  left: 16.0,
                  bottom: 16
                ),
                end: const EdgeInsets.symmetric(
                  horizontal: 55,
                  vertical: 15
                )
              ),
              stretchModes: const [
                StretchMode.fadeTitle,
              ],
            ),
            actions: [
              TextButton(
                child: Text('Create Palette'),
                onPressed: () async {
                  await AppRouter.push(context, page: CreatePalette());
                  setState(() { });
                },
              )
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.only(
              left: 16,
              bottom: 10
            ),
            sliver: SliverToBoxAdapter(
              child: Label(label: 'Random (Default)'),
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
              bottom: 10
            ),
            sliver: SliverToBoxAdapter(
              child: Label(label: 'Inspiration'),
            ),
          ),
          SliverToBoxAdapter(
            child: Builder(
              builder: (context) {
                ColorPalette palette = ColorPalette.offlineGenerator();
                return Slidable(
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    dragDismissible: false,
                    children: [
                      SlidableAction(
                        onPressed: (context) async {
                          await paletteManager.add(palette);
                          setState(() { });
                          Alerts.snackbar(context, text: 'Saved palette');
                        },
                        borderRadius: BorderRadius.horizontal(
                          left: Radius.circular(20)
                        ),
                        backgroundColor: palette.primary,
                        foregroundColor: palette.primary.computeThemedTextColor(180),
                        icon: Icons.add_circle,
                        label: 'Save',
                      ),
                    ],
                  ),
                  child: _PaletteViewModal(palette: palette)
                );
              },
            )
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
                        icon: Icons.delete,
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
                style: Theme.of(context).textTheme.subtitle2,
              ),
            ),
          )
        ],
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