import 'package:flutter/material.dart';

import '../../rehmat.dart';

class TextEditorScreen extends StatefulWidget {

  TextEditorScreen({
    Key? key,
    this.text
  }) : super(key: key);

  /// Pass default text to the editor
  final String? text;

  @override
  State<TextEditorScreen> createState() => _EditTTextEditorScreen();
}

class _EditTTextEditorScreen extends State<TextEditorScreen> {

  late TextEditingController textCtrl;

  String? text;

  @override
  void initState() {
    textCtrl = TextEditingController(text: widget.text);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          RenderAppBar(
            title: Text('Text'),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            sliver: SliverToBoxAdapter(
              child: TextFormField(
                controller: textCtrl,
                decoration: InputDecoration(),
                minLines: 3,
                maxLines: 7,
                onChanged: (value) => setState(() {
                  text = value;
                }),
              ),
            ),
          )
        ],
      ),
    );
  }

}