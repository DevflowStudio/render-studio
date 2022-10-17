import 'package:flutter/cupertino.dart';
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
          SliverAppBar(
            leading: NewBackButton(),
            pinned: true,
            centerTitle: false,
            expandedHeight: Constants.appBarExpandedHeight,
            flexibleSpace: RenderFlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              centerTitle: false,
              title: Text(
                widget.isNewPost ? 'Project' : 'Metadata',
                // style: AppTheme.flexibleSpaceBarStyle
              ),
              titlePaddingTween: EdgeInsetsTween(
                begin: const EdgeInsets.only(
                  left: 12.0,
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
              if (widget.isNewPost) ... [
                const Divider(),
                SizedBox(height: 10,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    alignment: WrapAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Label(label: 'Size'),
                          Text(
                            'Choose a size for your project',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: () {
                          showCupertinoModalPopup(
                            context: context,
                            builder: (_) => Container(
                              height: MediaQuery.of(context).size.height/4,
                              color: Palette.of(context).background,
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        onPressed: Navigator.of(context).pop,
                                        icon: Icon(Icons.check_circle)
                                      )
                                    ],
                                  ),
                                  Expanded(
                                    child: CupertinoPicker(
                                      backgroundColor: Palette.of(context).background,
                                      itemExtent: 30,
                                      scrollController: FixedExtentScrollController(initialItem: PostSizePresets.values.indexOf(size)),
                                      magnification: 1.1,
                                      diameterRatio: 1.3,
                                      squeeze: 1,
                                      children: List.generate(
                                        PostSizePresets.values.length,
                                        (index) => Text(
                                          PostSizePresets.values[index].title
                                        )
                                      ),
                                      onSelectedItemChanged: (value) {
                                        if (mounted) setState(() {
                                          size = PostSizePresets.values[value];
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            )
                          );
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5
                          ),
                          decoration: BoxDecoration(
                            color: Palette.of(context).surfaceVariant,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Palette.of(context).shadow.withOpacity(0.1),
                                blurRadius: 1,
                                spreadRadius: 0,
                                offset: Offset(0, 0)
                              )
                            ]
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                size.title,
                                style: TextStyle(
                                  color: Palette.of(context).onSurfaceVariant
                                ),
                              ),
                              Icon(
                                Icons.arrow_drop_down_rounded,
                                color: Palette.of(context).onSurfaceVariant
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              SizedBox(height: 22,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: PrimaryButton(
                  child: widget.isNewPost ? Text('Create') : Text('Save'),
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

    if (widget.isNewPost) {
      project.size = size.toSize();
      AppRouter.replace(context, page: Create(project: project));
    } else {
      Navigator.of(context).pop();
    }
  }

}