import 'package:flutter/material.dart';
import 'package:render_studio/models/project/templatex.dart';
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

  List<Map> generated_templates = [
    {
      "features": [
        "image",
        "heading",
        "body",
        "square",
        "1080x1080"
      ],
      "description": "",
      "thumbnail": "https://storage.googleapis.com/app-render-studio.appspot.com/5nB6pUuVIEMiwIEJeJHLdF4dDiN2/template/WImHXUf/images/image-xJIwLAU.png.raw",
      "id": "WImHXUf",
      "publisher": {
        "uid": "5nB6pUuVIEMiwIEJeJHLdF4dDiN2",
        "email": "rehmatsinghgill@gmail.com",
        "name": "Rehmat Singh Gill"
      },
      "is_template": true,
      "images": [
        "https://storage.googleapis.com/app-render-studio.appspot.com/5nB6pUuVIEMiwIEJeJHLdF4dDiN2/template/WImHXUf/images/image-xJIwLAU.png.raw"
      ],
      "meta": {
        "version": "1.1",
        "created": 1704638350280,
        "edited": 1704733401794
      },
      "template-kit": {
        "pages": [
          {
            "features": [
              "image",
              "heading",
              "body",
              "square",
              "1080x1080"
            ],
            "type": null,
            "variables": [
              {
                "uid": "OLMXiWH",
                "type": "asset",
                "size": "1024x1024",
                "asset-type": "image",
                "widget": "background",
                "comments": null,
                "url": "https://oaidalleapiprodscus.blob.core.windows.net/private/org-EEXhYyLtt3voEVKznbEjI6Jj/user-g9zwh7cOYe4aRED7KByBvXqk/img-NtLfL6CrMcaTurQA4gunw926.png?st=2024-01-09T01%3A57%3A53Z&se=2024-01-09T03%3A57%3A53Z&sp=r&sv=2021-08-06&sr=b&rscd=inline&rsct=image/png&skoid=6aaadede-4fb3-4698-a8f6-684d7786b067&sktid=a48cca56-e6da-484e-a814-9c849652bcb3&skt=2024-01-08T18%3A00%3A27Z&ske=2024-01-09T18%3A00%3A27Z&sks=b&skv=2021-08-06&sig=bhvn7jMdfzWFYCvr/vD6lsOiZrwk0BDQP5sjr57FxgE%3D",
                "search_tags": [
                  "business",
                  "professional",
                  "neutrality"
                ],
                "prompt": "Create a professional and respectful image representing the news of Sam Altman's departure as the result of a decision by OpenAI's board. Consider conveying a sense of gravity and importance while maintaining a balanced and neutral visual composition. Avoid using any imagery that might appear celebratory or disrespectful. Include minimalistic and muted tones that provide a somber and respectful backdrop. Focus on elements that exude professionalism and neutrality."
              },
              {
                "uid": "kApBRui",
                "type": "string",
                "text-type": "heading",
                "widget": "text",
                "comments": null,
                "value": "Sam Altman's Departure"
              },
              {
                "uid": "3M4RGd4",
                "type": "string",
                "text-type": "body",
                "widget": "text",
                "comments": null,
                "value": "OpenAI's board has announced the departure of Sam Altman. We wish him the best in his future endeavors."
              }
            ],
            "id": "page#DiuhJ",
            "comments": null
          }
        ],
        "size": {
          "height": 1080.0,
          "width": 1080.0,
          "name": "1080.0x1080.0"
        },
        "id": "WImHXUf"
      },
      "is_template_kit": true,
      "pages": [
        {
          "palette": {
            "background": "#ffffffff",
            "secondary": "#ff838392",
            "primary": "#fffee3c3",
            "id": "#0000",
            "surface": "#ffffe6e7",
            "tertiary": "#ff000000",
            "onBackground": "#ff000000",
            "colors": [
              "#ffffffff",
              "#fffee3c3",
              "#ffffe6e7",
              "#ff838392",
              "#ff000000"
            ]
          },
          "widgets": [
            {
              "gradient": null,
              "uid": "OLMXiWH",
              "padding": {
                "horizontal": 55.38461538461539,
                "vertical": 55.38461538461539
              },
              "group": null,
              "id": "background",
              "asset": "jkKcO",
              "variable-comment": null,
              "image-provider": {
                "flipVertical": false,
                "filter": null,
                "flipHorizontal": false,
                "contrast": 0.0,
                "sepia": null,
                "saturation": 0.0,
                "hue": 0.0,
                "visibility": 0.0,
                "brightness": 0.0,
                "exposure": 0.0
              },
              "properties": {
                "size": {
                  "height": 2990.7692307692305,
                  "width": 2990.7692307692305
                },
                "opacity": 1.0,
                "angle": 0.0,
                "vertical-expand-direction": "both",
                "horizontal-expand-direction": "both",
                "position": {
                  "dx": 0.0,
                  "dy": 0.0
                },
                "is-universal-build": true
              },
              "color": "#ffffffff",
              "is-variable-widget": true,
              "name": "Background"
            },
            {
              "uid": "EKW41vg",
              "container-provider": {
                "padding": {
                  "horizontal": 0.0,
                  "vertical": 0.0
                },
                "shadow": null,
                "blur": 0.0,
                "border-width": null,
                "border-radius": 0.0,
                "color": "#ff838392",
                "border-color": null,
                "gradient": {
                  "end": "0.00,1.00",
                  "colors": [
                    "#00000000",
                    "#ff000000"
                  ],
                  "begin": "0.00,-1.00"
                }
              },
              "group": null,
              "id": "box",
              "asset": null,
              "variable-comment": null,
              "properties": {
                "size": {
                  "height": 623.3863321394416,
                  "width": 1107.5573128143349
                },
                "opacity": 1.0,
                "angle": 0.0,
                "vertical-expand-direction": "down",
                "horizontal-expand-direction": "both",
                "position": {
                  "dx": 0.0,
                  "dy": 228.68456552704592
                },
                "is-universal-build": true
              },
              "is-variable-widget": false,
              "name": "Box"
            },
            {
              "uid": "Sioe2C8",
              "group": null,
              "id": "group",
              "asset": null,
              "_group": "Sioe2C8",
              "_demographics": {
                "version": "nr9Tu1P",
                "kApBRui": {
                  "left": [],
                  "overlaps": [],
                  "right": [],
                  "above": [],
                  "below": [
                    "3M4RGd4",
                    "7CFPNlN"
                  ],
                  "original-size": {
                    "height": 64.15237862723214,
                    "width": 280.6666564941406
                  }
                },
                "3M4RGd4": {
                  "left": [],
                  "overlaps": [],
                  "right": [],
                  "above": [
                    "kApBRui"
                  ],
                  "below": [
                    "7CFPNlN"
                  ],
                  "original-size": {
                    "height": 117.2153250928221,
                    "width": 351.0729370117188
                  }
                },
                "7CFPNlN": {
                  "left": [],
                  "overlaps": [],
                  "right": [],
                  "above": [
                    "kApBRui",
                    "3M4RGd4"
                  ],
                  "below": [],
                  "original-size": {
                    "height": 13.948571473440508,
                    "width": 97.99174800952672
                  }
                }
              },
              "variable-comment": null,
              "widgets": [
                {
                  "primary-style": {
                    "strikethrough": false,
                    "italics": false,
                    "color": "#ffffffff",
                    "bold": false,
                    "underline": false,
                    "overline": false
                  },
                  "uid": "kApBRui",
                  "id": "text",
                  "secondary-style": null,
                  "_span-size": {
                    "height": 221.53846153846155,
                    "width": 969.2307692307692
                  },
                  "alignment": 0,
                  "widget": {
                    "color": null,
                    "radius": 27.692307692307693
                  },
                  "properties": {
                    "size": {
                      "height": 177.6527408138736,
                      "width": 777.2307410606971
                    },
                    "opacity": 1.0,
                    "angle": 0.0,
                    "vertical-expand-direction": "both",
                    "horizontal-expand-direction": "right",
                    "position": {
                      "dx": -97.48561917818517,
                      "dy": -197.89450710422392
                    },
                    "is-universal-build": true
                  },
                  "color": {
                    "background": "#00000000"
                  },
                  "name": "Text",
                  "text": {
                    "text": "Are we heading into a recession?",
                    "font": "Lato",
                    "line-height": 1.0,
                    "font-size": 110.76923076923077,
                    "auto-size": true
                  },
                  "container-provider": {
                    "padding": {
                      "horizontal": 0.0,
                      "vertical": 0.0
                    },
                    "shadow": null,
                    "blur": 0.0,
                    "border-width": null,
                    "border-radius": 0.0,
                    "color": null,
                    "border-color": null,
                    "gradient": null
                  },
                  "padding": {
                    "horizontal": 0.0,
                    "vertical": 0.0
                  },
                  "group": "Sioe2C8",
                  "asset": null,
                  "variable-comment": null,
                  "shadows": [
                    {
                      "blur": 0.0,
                      "offset": {
                        "dx": 2.142676192201348,
                        "dy": 0.037400568087243166
                      },
                      "color": "#ff000000"
                    }
                  ],
                  "spacing": {
                    "word": 0.0,
                    "letter": 2.769230769230769
                  },
                  "is-variable-widget": true,
                  "variable-type": "heading"
                },
                {
                  "primary-style": {
                    "strikethrough": false,
                    "italics": false,
                    "color": "#ffffffff",
                    "bold": false,
                    "underline": false,
                    "overline": false
                  },
                  "uid": "3M4RGd4",
                  "id": "text",
                  "secondary-style": null,
                  "_span-size": {
                    "height": 764.3076923076923,
                    "width": 2289.1865556540793
                  },
                  "alignment": 0,
                  "widget": {
                    "color": null,
                    "radius": 27.692307692307693
                  },
                  "properties": {
                    "size": {
                      "height": 324.59628487243043,
                      "width": 972.2019794170675
                    },
                    "opacity": 1.0,
                    "angle": 0.0,
                    "vertical-expand-direction": "both",
                    "horizontal-expand-direction": "right",
                    "position": {
                      "dx": 0.0,
                      "dy": 72.73041329760169
                    },
                    "is-universal-build": true
                  },
                  "color": {
                    "background": "#00000000"
                  },
                  "name": "Text",
                  "text": {
                    "text": "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.",
                    "font": "Lato",
                    "line-height": 1.1477116748706706,
                    "font-size": 110.76923076923077,
                    "auto-size": true
                  },
                  "container-provider": {
                    "padding": {
                      "horizontal": 0.0,
                      "vertical": 0.0
                    },
                    "shadow": null,
                    "blur": 0.0,
                    "border-width": null,
                    "border-radius": 0.0,
                    "color": null,
                    "border-color": null,
                    "gradient": null
                  },
                  "padding": {
                    "horizontal": 0.0,
                    "vertical": 0.0
                  },
                  "group": "Sioe2C8",
                  "asset": null,
                  "variable-comment": null,
                  "shadows": null,
                  "spacing": {
                    "word": 0.0,
                    "letter": 2.769230769230769
                  },
                  "is-variable-widget": true,
                  "variable-type": "body"
                },
                {
                  "primary-style": {
                    "strikethrough": false,
                    "italics": false,
                    "color": "#ffffffff",
                    "bold": false,
                    "underline": false,
                    "overline": false
                  },
                  "uid": "7CFPNlN",
                  "id": "text",
                  "secondary-style": null,
                  "_span-size": {
                    "height": 127.38461538461539,
                    "width": 894.9046255258413
                  },
                  "alignment": 0,
                  "widget": {
                    "color": null,
                    "radius": 27.692307692307693
                  },
                  "properties": {
                    "size": {
                      "height": 38.62681331106602,
                      "width": 271.36176371868936
                    },
                    "opacity": 1.0,
                    "angle": 0.0,
                    "vertical-expand-direction": "up",
                    "horizontal-expand-direction": "right",
                    "position": {
                      "dx": -350.42010784918904,
                      "dy": 267.4074708556277
                    },
                    "is-universal-build": true
                  },
                  "color": {
                    "background": "#00000000"
                  },
                  "name": "Text",
                  "text": {
                    "text": "©️ Cardinal Media",
                    "font": "Lato",
                    "line-height": 1.1477116748706706,
                    "font-size": 110.76923076923077,
                    "auto-size": true
                  },
                  "container-provider": {
                    "padding": {
                      "horizontal": 0.0,
                      "vertical": 0.0
                    },
                    "shadow": null,
                    "blur": 0.0,
                    "border-width": null,
                    "border-radius": 0.0,
                    "color": null,
                    "border-color": null,
                    "gradient": null
                  },
                  "padding": {
                    "horizontal": 0.0,
                    "vertical": 0.0
                  },
                  "group": "Sioe2C8",
                  "asset": null,
                  "variable-comment": null,
                  "shadows": null,
                  "spacing": {
                    "word": 0.0,
                    "letter": 2.769230769230769
                  },
                  "is-variable-widget": false,
                  "variable-type": "constant"
                }
              ],
              "properties": {
                "size": {
                  "height": 573.4417550223214,
                  "width": 972.2019794170675
                },
                "opacity": 1.0,
                "angle": 0.0,
                "vertical-expand-direction": "up",
                "horizontal-expand-direction": "right",
                "position": {
                  "dx": 1.4856050931491172,
                  "dy": 197.8945071042239
                },
                "is-universal-build": true
              },
              "is-variable-widget": false,
              "name": "Group Widget"
            }
          ],
          "id": "page#DiuhJ",
          "page-type-comment": null,
          "page-type": null
        }
      ],
      "assets": {
        "jkKcO": {
          "file-type": "image",
          "file": null,
          "asset-type": "url",
          "created-at": 1704638406076,
          "url": "https://storage.googleapis.com/app-render-studio.appspot.com/5nB6pUuVIEMiwIEJeJHLdF4dDiN2/template/WImHXUf/assets/jkKcO.raw",
          "id": "jkKcO"
        }
      },
      "size": {
        "height": 1080.0,
        "type": "square",
        "width": 1080.0
      },
      "publish_time": 1704733424926,
      "title": "My First Template"
    }
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
      // try {
        List<Project> projects = await TemplateKit.generate(context, prompt: prompt);
        AppRouter.push(context, page: GeneratedTemplatesView(templates: projects));
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
        project = await Project.fromTemplate(context, uid: selectedTemplate!, title: title, description: description);
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