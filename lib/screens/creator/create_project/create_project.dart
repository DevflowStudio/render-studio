import 'package:flutter/material.dart';
import 'package:render_studio/screens/creator/create_project/custom_new_project.dart';
import 'package:render_studio/screens/creator/create_project/generated_templates_view.dart';
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

  bool isTemplateKit = true;

  int page = 0;

  PostSizePresets sizePreset = PostSizePresets.square;

  bool isAIAvaliable = false;

  List<ProjectGlance> templates = [];
  String? selectedTemplate;

  late TabController tabCtrl;

  bool isLoading = false;

  final List<Map<String, dynamic>> prompts = [
    {
      "short-description": "Halloween",
      "prompt": "Create a halloween themed post for Instagram"
    },
    {
      "short-description": "LinkedIn Layoffs",
      "prompt": "Create an Instagram news post to announce the layoffs at LinkedIn."
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
    if (isAIAvaliable) {
      tabCtrl.index = 0;
    } else {
      tabCtrl.index = 1;
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
          if (isAIAvaliable) SliverPadding(
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
                  promptCtrl: promptCtrl,
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
                  isTemplateKit: isTemplateKit,
                  onTemplateKitChanged: (value) {
                    TapFeedback.light();
                    setState(() {
                      isTemplateKit = value;
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
      if (prompt.isEmpty) {
        setState(() {
          promptError = 'Please enter a prompt';
        });
        return;
      }
      AppRouter.push(context, page: GeneratedTemplatesView(prompt: prompt));
      // try {
      //   List<Project> projects = await TemplateKit.generate(context, prompt: prompt);
      //   AppRouter.push(context, page: GeneratedTemplatesView(templates: projects));
      // } catch (e) {
      //   print(e);
      //   Alerts.dialog(
      //     context,
      //     title: 'Error',
      //     content: 'Failed to generate templates. Please try again later'
      //   );
      // }
    } else {
      if (title.isEmpty) {
        setState(() {
          titleError = true;
        });
        return;
      }
      if (isTemplate || selectedTemplate == null) {
        project = Project.create(context, title: title, description: description, isTemplate: isTemplate, isTemplateKit: isTemplateKit && isTemplate);
      } else {
        project = await Project.fromTemplate(context, id: selectedTemplate!, title: title, description: description);
      }
      if (project != null) {
        AppRouter.replace(context, page: Studio(project: project));
      } else {
        Alerts.snackbar(context, text: 'An error occured while creating the project. Please try again later.');
      }
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
    Color background = Palette.of(context).onSurface;
    Color foreground = Palette.of(context).surface;
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
      color: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return background;
        }
        return Palette.of(context).surface;
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