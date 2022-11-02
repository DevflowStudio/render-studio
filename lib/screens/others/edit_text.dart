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
          SliverAppBar(
            leading: NewBackButton(
              data: text,
            ),
            pinned: true,
            centerTitle: false,
            expandedHeight: Constants.appBarExpandedHeight,
            flexibleSpace: RenderFlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              centerTitle: false,
              title: Text('Text'),
              titlePaddingTween: EdgeInsetsTween(
                begin: const EdgeInsets.only(
                  left: 12.0,
                  bottom: 16
                ),
                end: const EdgeInsets.only(
                  left: 72.0,
                  bottom: 16
                ),
              ),
            ),
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