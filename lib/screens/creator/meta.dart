import 'package:flutter/material.dart';
import '../../../rehmat.dart';

class ProjectMeta extends StatefulWidget {

  const ProjectMeta({
    Key? key,
    this.project,
    this.size
  }) : assert(size != null || project != null), super(key: key);

  final Project? project;
  final PostSize? size;

  @override
  _ProjectMetaState createState() => _ProjectMetaState();
}

class _ProjectMetaState extends State<ProjectMeta> {
  
  TextEditingController titleCtrl = TextEditingController();
  TextEditingController descriptionCtrl = TextEditingController();

  bool titleError = false;
  bool hasTitleChanged = false;

  bool isCreatingProject = false;

  bool isTemplate = false;

  @override
  void initState() {
    if (widget.project == null) {
      isCreatingProject = true;
      setTitle();
    } else {
      titleCtrl.text = widget.project?.title ?? '';
      descriptionCtrl.text = widget.project?.description ?? '';
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          RenderAppBar(
            title: Text(
              isCreatingProject ? 'New Project' : 'Metadata'
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
                  onChanged: (value) {
                    hasTitleChanged = true;
                  },
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
              if (isCreatingProject) Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Label(
                      label: 'Template',
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Create this project as a template to remix later',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Palette.of(context).onSurfaceVariant
                            ),
                          ),
                        ),
                        Switch.adaptive(
                          value: isTemplate,
                          onChanged: (value) {
                            setState(() {
                              isTemplate = value;
                              setTitle();
                            });
                          },
                        )
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: 12,
                  right: 12,
                  top: 12,
                  bottom: Constants.of(context).bottomPadding
                ),
                child: PrimaryButton(
                  child: Text(isCreatingProject ? 'Let\'s Go' : 'Save'),
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

    if (title.trim().isEmpty) {
      setState(() {
        titleError = true;
      });
      return;
    }

    if (isCreatingProject) {
      Project project = Project.create(
        context,
        title: title,
        description: description,
        size: widget.size,
        isTemplate: isTemplate
      );
      AppRouter.replace(context, page: Studio(project: project));
    } else {
      widget.project!.title = title;
      widget.project!.description = description;
      widget.project!.isTemplate = isTemplate;
      Navigator.of(context).pop();
    }
  }

  void setTitle() {
    if (hasTitleChanged) return;
    if (manager.projects.isEmpty) {
      if (isTemplate) {
        titleCtrl.text = 'My First Template';
      } else {
        titleCtrl.text = 'My First Project';
      }
    }
    else {
      String prefix = isTemplate ? 'Template' : 'Project';
      int n = manager.projects.length + 1;
      titleCtrl.text = '$prefix ($n)';
      while (manager.projects.where((glance) => glance.title == titleCtrl.text).isNotEmpty) {
        n++;
        titleCtrl.text = '$prefix ($n)';
      }
    }
  }

}