import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sprung/sprung.dart';
import 'package:universal_io/io.dart';

import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

import '../../../rehmat.dart';

class CreatePalette extends StatefulWidget {

  CreatePalette({Key? key}) : super(key: key);

  @override
  State<CreatePalette> createState() => _CreatePaletteState();
}

class _CreatePaletteState extends State<CreatePalette> {

  late ColorPalette palette;

  @override
  void initState() {
    super.initState();
    palette = ColorPalette.offlineGenerator();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: NewBackButton(),
        title: Text('Create Palette'),
      ),
      body: Column(
        children: [
          Spacer(),
          SizedBox(
            height: MediaQuery.of(context).size.height/2,
            child: _PaletteViewModal(
              palette: palette,
              onDelete: (color) {
                palette.colors.remove(color);
                setState(() { });
              },
            ),
          ),
          if (palette.colors.length <= 8) Padding(
            padding: const EdgeInsets.only(top: 12),
            child: FilledTonalIconButton(
              onPressed: () async {
                Color? color = await ColorTool.openTool(context);
                if (color == null) return;
                palette.colors.add(color);
                setState(() { });
              },
              icon: Icon(
                RenderIcons.add,
                size: 20,
              ),
              padding: EdgeInsets.all(12),
            ),
          ),
          Spacer(),
          Padding(
            padding: EdgeInsets.only(
              bottom: Constants.of(context).bottomPadding,
              left: 12,
              right: 12
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: PrimaryButton(
                    child: Text('Generate'),
                    autoLoading: true,
                    onPressed: () async {
                      palette = await ColorPalette.generate();
                      setState(() { });
                    },
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: SecondaryButton(
                      child: Text('Save'),
                      onPressed: () async {
                        if (palette.colors.length < 3) {
                          Alerts.snackbar(context, text: 'Palette must have at least 3 colors.');
                          return false;
                        }
                        await paletteManager.add(palette);
                        TapFeedback.tap();
                        return true;
                      },
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: IconButton(
                      onPressed: extractFromImage,
                      icon: Icon(RenderIcons.upload),
                      tooltip: 'Extract palette from image',
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Future<void> extractFromImage() async {
    try {
      File? file;
      PaletteGenerator? paletteGenerator;
      await Spinner.fullscreen(
        context,
        task: () async {
          file = await FilePicker.pick(context: context, crop: false, type: FileType.image);
          if (file == null) return;
          Uint8List bytes = await file!.readAsBytes();
          Image image = Image.memory(bytes);
          paletteGenerator = await PaletteGenerator.fromImageProvider(image.image);
        },
      );
      if (file == null) return;
      if (paletteGenerator == null) return;
      palette = ColorPalette(
        id: Constants.generateID(),
        colors: [
          paletteGenerator!.dominantColor!.color,
          paletteGenerator!.lightVibrantColor?.color ?? Colors.white,
          paletteGenerator!.vibrantColor?.color ?? Colors.white,
          paletteGenerator!.darkVibrantColor?.color ?? Colors.white,
          paletteGenerator!.darkMutedColor?.color ?? Colors.white,
        ],
      );
      // if (paletteGenerator != null) palette = ColorPalette(id: Constants.generateID(), colors: paletteGenerator!.colors.toList());
      setState(() { });
    } catch (e) {
      Alerts.snackbar(context, text: 'Oops! Something went wrong.');
    }
  }

}

class _PaletteViewModal extends StatelessWidget {

  const _PaletteViewModal({
    Key? key,
    required this.palette,
    required this.onDelete
  }) : super(key: key);

  final ColorPalette palette;
  final void Function(Color color) onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: AnimatedSize(
          duration: kAnimationDuration,
          child: Scrollable(
            viewportBuilder: (context, offset) {
              return Column(
                children: List.generate(
                  palette.colors.length,
                  (index) => Flexible(
                    child: AnimatedSize(
                      duration: kAnimationDuration,
                      curve: Sprung.overDamped,
                      child: Slidable(
                        key: UniqueKey(),
                        groupTag: 'palette',
                        endActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          dismissible: DismissiblePane(
                            onDismissed: () async {
                              onDelete(palette.colors[index]);
                            }
                          ),
                          children: [
                            SlidableAction(
                              onPressed: (context) async {
                                onDelete(palette.colors[index]);
                              },
                              backgroundColor: Palette.of(context).errorContainer,
                              foregroundColor: Palette.of(context).onErrorContainer,
                              icon: RenderIcons.delete,
                              label: 'Delete',
                            ),
                          ],
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: palette.colors[index],
                            border: Border.all(
                              color: palette.colors[index],
                              width: 0
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ),
              );
            }
          ),
        ),
      ),
    );
  }

}