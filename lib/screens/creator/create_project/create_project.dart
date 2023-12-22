import 'package:flutter/material.dart';
import 'package:render_studio/screens/creator/create_project/custom_new_project.dart';
import 'package:render_studio/screens/creator/create_project/magic_design_page.dart';
import '../../../rehmat.dart';

class CreateProject extends StatefulWidget {
  const CreateProject({super.key});

  @override
  State<CreateProject> createState() => _CreateProjectState();
}

class _CreateProjectState extends State<CreateProject> with TickerProviderStateMixin {

  TextEditingController promptCtrl = TextEditingController();
  TextEditingController titleCtrl = TextEditingController();
  TextEditingController descriptionCtrl = TextEditingController();

  final BlurredEdgesController blurredEdgesCtrl = BlurredEdgesController();

  bool titleError = false;
  bool hasTitleChanged = false;

  String? promptError;

  bool isTemplate = false;

  bool isTemplateX = true;

  int page = 0;

  PostSizePresets sizePreset = PostSizePresets.square;

  bool isAIAvaliable = true;

  List<ProjectGlance> templates = [];
  String? selectedTemplate;

  late TabController tabCtrl;

  bool isLoading = false;

  final List<Map<String, dynamic>> prompts = [
    {
      "short-description": "Halloween",
      "prompt": "Create a halloween themed post for Instagram",
      "variables": [
        {
          "widget": "text",
          "uid": "ej94UoF",
          "type": "string",
          "value": "LinkedIn announces company wide layoffs"
        },
        {
          "widget": "text",
          "uid": "gNH0nNC",
          "type": "string",
          "value": "Microsoft owned LinkedIn has announced that it will be laying off 6% of its workforce. The company has 16,000 employees and the layoffs will affect 960 people. The company has said that the layoffs are due to the coronavirus pandemic."
        }
      ]
    },
    {
      "short-description": "LinkedIn Layoffs",
      "prompt": "Create an Instagram news post to announce the layoffs at LinkedIn.",
      "variables": [
        {
          "widget": "text",
          "uid": "ej94UoF",
          "type": "string",
          "value": "Layoffs at LinkedIn"
        },
        {
          "widget": "text",
          "uid": "gNH0nNC",
          "type": "string",
          "value": "Microsoft owned LinkedIn has announced that it will be laying off 6% of its workforce. The company has 16,000 employees and the layoffs will affect 960 people."
        }
      ]
    },
  ];

  @override
  void initState() {
    tabCtrl = TabController(length: 2, vsync: this);
    templates = manager.projects.where((glance) => glance.isTemplate).toList();
    if (templates.isEmpty) {
      tabCtrl.index = 1;
      isAIAvaliable = false;
    }
    setTitle();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          RenderAppBar(title: Text('Create Project')),
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 6),
            sliver: SliverToBoxAdapter(
              child: _CustomTabBar(tabCtrl: tabCtrl),
            ),
          )
        ],
        body: Stack(
          children: [
            TabBarView(
              controller: tabCtrl,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                MagicDesignPage(
                  templates: templates,
                  promptCtrl: promptCtrl,
                  selectedTemplate: selectedTemplate,
                  onSelect: (uid) {
                    TapFeedback.light();
                    setState(() {
                      selectedTemplate = uid;
                    });
                  },
                  promptError: promptError,
                  prompts: prompts,
                ),
                CustomNewProjectPage(
                  templates: templates,
                  selectedTemplate: selectedTemplate,
                  onSelect: (uid) {
                    TapFeedback.light();
                    setState(() {
                      selectedTemplate = uid;
                    });
                  },
                  titleCtrl: titleCtrl,
                  descriptionCtrl: descriptionCtrl,
                  titleError: titleError,
                  isTemplate: isTemplate,
                  onTitleChange: () {
                    setState(() {
                      hasTitleChanged = true;
                      titleError = false;
                    });
                  },
                  onTemplateChanged: (value) {
                    TapFeedback.light();
                    setState(() {
                      isTemplate = value;
                      setTitle();
                    });
                  },
                  isTemplateX: isTemplateX,
                  onTemplateXChanged: (value) {
                    TapFeedback.light();
                    setState(() {
                      isTemplateX = value;
                    });
                  },
                ),
              ],
            ),
            Positioned(
              bottom: Constants.of(context).bottomPadding,
              left: 12,
              right: 12,
              child: PrimaryButton(
                onPressed: create,
                child: Text("Next"),
                autoLoading: true,
              ),
            ),
          ],
        ),
      ),
    );
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

  Future<void> create() async {
    Project? project;

    String title = titleCtrl.text.trim();
    String description = descriptionCtrl.text.trim();
    String prompt = promptCtrl.text.trim();
    
    bool isMagicMode = tabCtrl.index == 0;

    if (isMagicMode) {
      if (selectedTemplate == null) {
        Alerts.snackbar(context, text: 'Please select a template that you want to remix');
        return;
      }
      if (prompt.isEmpty) {
        setState(() {
          promptError = 'Please enter a prompt';
        });
        return;
      }
      await Future.delayed(Duration(seconds: 2));
      project = await Project.fromTemplate(
        context,
        uid: selectedTemplate!,
        title: title,
        description: description,
        variableValues: [
          {
            "widget": "text",
            "uid": "ej94UoF",
            "type": "string",
            "value": "LinkedIn Layoffs"
          },
          {
            "widget": "text",
            "uid": "gNH0nNC",
            "type": "string",
            "value": "Microsoft owned LinkedIn has announced that it will be laying off 6% of its workforce. The company has said that the layoffs are due to the coronavirus pandemic."
          }
        ]
      );
    } else {
      if (title.isEmpty) {
        setState(() {
          titleError = true;
        });
        return;
      }
      if (isTemplate || selectedTemplate == null) {
        project = Project.create(context, title: title, description: description, isTemplate: isTemplate, isTemplateX: isTemplateX && isTemplate);
      } else {
        project = await Project.fromTemplate(context, uid: selectedTemplate!, title: title, description: description);
      }
    }

    if (project != null) {
      AppRouter.replace(context, page: Studio(project: project));
    } else {
      Alerts.snackbar(context, text: 'An error occured while creating the project. Please try again later.');
    }
  }

}

class _CustomTabBar extends StatefulWidget {

  const _CustomTabBar({required this.tabCtrl});

  final TabController tabCtrl;

  @override
  State<_CustomTabBar> createState() => _Custom_TabBarState();
}

class _Custom_TabBarState extends State<_CustomTabBar> {
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12
      ),
      child: Row(
        children: [
          chipBuilder(
            label: 'Magic',
            icon: RenderIcons.magic,
            isSelected: widget.tabCtrl.index == 0,
            onSelect: (value) {
              TapFeedback.light();
              widget.tabCtrl.animateTo(0);
              setState(() { });
            }
          ),
          SizedBox(width: 6),
          chipBuilder(
            label: 'Custom',
            isSelected: widget.tabCtrl.index == 1,
            onSelect: (value) {
              TapFeedback.light();
              widget.tabCtrl.animateTo(1);
              setState(() { });
            }
          )
        ],
      ),
    );
  }

  Widget chipBuilder({
    required String label,
    IconData? icon,
    bool isSelected = false,
    void Function(bool value)? onSelect
  }) {
    Color background = Palette.of(context).onBackground;
    Color foreground = Palette.of(context).background;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? foreground : Palette.of(context).onSurfaceVariant
        ),
      ),
      selected: isSelected,
      onSelected: onSelect,
      avatar: icon != null ? Icon(
        icon,
        color: isSelected ? foreground : Palette.of(context).onSurfaceVariant,
      ) : null,
      color: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return background;
        }
        return Palette.of(context).background;
      }),
      shape: StadiumBorder(),
      labelPadding: EdgeInsets.only(left: 6),
      showCheckmark: false,
      padding: EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8
      ),
    );
  }

}