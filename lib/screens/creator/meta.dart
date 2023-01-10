import 'package:flutter/material.dart';
import '../../../rehmat.dart';

class Information extends StatefulWidget {

  const Information({
    Key? key,
    required this.project,
    this.isNewProject = false
  }) : super(key: key);

  final Project project;
  final bool isNewProject;

  @override
  _InformationState createState() => _InformationState();
}

class _InformationState extends State<Information> {
  
  TextEditingController titleCtrl = TextEditingController();
  TextEditingController descriptionCtrl = TextEditingController();

  PostSizePresets size = PostSizePresets.square;

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
          RenderAppBar(
            title: Text(
              widget.isNewProject ? 'New Project' : 'Metadata'
            )
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
              SizedBox(height: 10,),
              SizedBox(height: 22,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: PrimaryButton(
                  child: Text(widget.isNewProject ? 'Next' : 'Save'),
                  onPressed: next,
                ),
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

    if (widget.isNewProject) AppRouter.replace(context, page: Create(project: project));
    else Navigator.of(context).pop();
  }

}