import 'package:flutter/material.dart';

import '../rehmat.dart';

class Information extends StatefulWidget {

  const Information({
    Key? key,
    required this.project,
    this.isNewPost = false,
  }) : super(key: key);

  final Project project;
  final bool isNewPost;

  @override
  _InformationState createState() => _InformationState();
}

class _InformationState extends State<Information> {
  
  TextEditingController titleCtrl = TextEditingController();
  TextEditingController descriptionCtrl = TextEditingController();

  late Project project;

  bool titleError = false;

  @override
  void initState() {
    project = widget.project;
    titleCtrl.text = project.title ?? '';
    descriptionCtrl.text = project.description ?? '';
    super.initState();
  }

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
                widget.isNewPost ? 'Project' : 'Metadata',
                style: AppTheme.flexibleSpaceBarStyle
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
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              FormGroup(
                title: 'Title',
                description: 'Add a title to your project',
                textField: TextFormField(
                  controller: titleCtrl,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    errorText: titleError ? 'Please add a title' : null
                  ),
                  maxLength: 80,
                ),
              ),
              const Divider(),
              FormGroup(
                title: 'Description',
                description: 'Add a description to your project',
                textField: TextFormField(
                  controller: descriptionCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    helperText: '(optional)'
                  ),
                  maxLines: 7,
                  minLines: 4,
                  maxLength: 2000,
                ),
              ),
              Button(
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                text: widget.isNewPost ? 'Next' : 'Save',
                onPressed: next,
              )
            ])
          )
        ],
      ),
    );
  }

  void next() {
    String title = titleCtrl.text.trim();
    String description = descriptionCtrl.text.trim();
    project.title = title;
    project.description = description;

    if (title.trim().isEmpty) {
      setState(() {
        titleError = true;
      });
      return;
    }

    if (widget.isNewPost) {
      AppRouter.replace(context, page: SelectSize(project: project));
    } else {
      Navigator.of(context).pop();
    }
  }

}