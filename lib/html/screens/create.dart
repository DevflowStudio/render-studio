import 'package:flutter/material.dart';
import 'package:code_editor/code_editor.dart';
import '../../rehmat.dart';

class HTMLWidgetCreator extends StatefulWidget {

  HTMLWidgetCreator({Key? key}) : super(key: key);

  @override
  State<HTMLWidgetCreator> createState() => _HTMLWidgetCreatorState();
}

class _HTMLWidgetCreatorState extends State<HTMLWidgetCreator> {

  TextEditingController htmlCtrl = TextEditingController();
  TextEditingController cssCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: NewBackButton(),
        title: Text('Web Widget Creator'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 6
            ),
            child: SizedBox(
              height: MediaQuery.of(context).size.height / 2,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CodeEditor(
                  model: EditorModel(
                    files: [
                      FileEditor(
                        language: 'html',
                        name: 'HTML',
                      )
                    ],
                    styleOptions: EditorModelStyleOptions(
                      toolbarOptions: ToolbarOptions(),
                      tabSize: 2,
                      
                    )
                  ),
                  disableNavigationbar: false,
                  onSubmit: (String? language, String? value) {},
                  textEditingController: htmlCtrl,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}