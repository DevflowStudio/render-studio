import 'package:flutter/services.dart';
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

  bool isLoading = false;

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
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Text('Create From Image'),
                value: 'image-palette',
              ),
            ],
            onSelected: (value) async {
              switch (value) {
                case 'image-palette':
                  try {
                    File? file = await FilePicker.pick(context: context, crop: false, type: FileType.image);
                    if (file == null) return;
                    PaletteGenerator? paletteGenerator;
                    await Spinner.fullscreen(
                      context,
                      task: () async {
                        print(await file.exists());
                        Uint8List bytes = await file.readAsBytes();
                        Image image = Image.memory(bytes);
                        paletteGenerator = await PaletteGenerator.fromImageProvider(image.image);
                      },
                    );
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
                    print(e);
                    Alerts.snackbar(context, text: 'Oops! Something went wrong.');
                  }
                  break;
                default:
              }
            },
          )
        ],
      ),
      body: Column(
        children: [
          Spacer(),
          SizedBox(
            height: MediaQuery.of(context).size.height/2,
            child: _PaletteViewModal(palette: palette),
          ),
          Spacer(),
          Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom,
              left: 12,
              right: 12
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: PrimaryButton(
                    isLoading: isLoading,
                    child: Text('Generate'),
                    onPressed: () async {
                      setState(() {
                        isLoading = true;
                      });
                      palette = await ColorPalette.generate();
                      setState(() {
                        isLoading = false;
                      });
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
                        await paletteManager.add(palette);
                      },
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
        borderRadius: BorderRadius.circular(30),
        child: Column(
          children: List.generate(
            palette.colors.length,
            (index) => Flexible(
              child: Container(
                decoration: BoxDecoration(
                  color: palette.colors[index],
                  border: Border.all(
                    color: palette.colors[index],
                    width: 0
                  ),
                ),
              )
            )
          ),
        ),
      ),
    );
  }
}