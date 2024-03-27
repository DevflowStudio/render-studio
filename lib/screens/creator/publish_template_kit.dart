import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lottie/lottie.dart';
import 'package:octo_image/octo_image.dart';
import 'package:provider/provider.dart';
import 'package:render_studio/models/cloud.dart';
import 'package:render_studio/models/project/category.dart';
import 'package:smooth_corner/smooth_corner.dart';
import 'package:universal_io/io.dart';

import '../../models/project/templatex.dart';
import '../../rehmat.dart';

class PublishTemplateKit extends StatefulWidget {

  const PublishTemplateKit({super.key, required this.project});

  final Project project;

  @override
  State<PublishTemplateKit> createState() => _PublishTemplateKitState();
}

class _PublishTemplateKitState extends State<PublishTemplateKit> {

  late Project project;

  bool _tos = false;
  bool _privacy = false;
  bool _testing = false;

  _ProgessStatus _saveStatus = _ProgessStatus.done;
  _ProgessStatus _assetUploadStatus = _ProgessStatus.done;
  _ProgessStatus _publishStatus = _ProgessStatus.done;

  bool get isLoading => !(_saveStatus == _ProgessStatus.done && _assetUploadStatus == _ProgessStatus.done && _publishStatus == _ProgessStatus.done);

  bool published = false;

  Future<List<CategoryGroup>> _getCategories = CategoryGroup.getGroups();

  List<ProjectCategory> selectedCategories = [];

  @override
  void initState() {
    super.initState();
    project = widget.project;
  }

  @override
  Widget build(BuildContext context) {
    double ratio = project.size.size.width / project.size.size.height;
    AuthState authState = Provider.of<AuthState>(context);

    if (!authState.isLoggedIn) {
      return Scaffold(
        appBar: AppBar(
          leading: NewBackButton(),
          title: Text('Publish'),
          centerTitle: false,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  RenderIcons.error,
                  size: 50,
                ),
                Text(
                  'Access Denied',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                Text(
                  'You need to be signed in to publish a template',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (published) return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Spacer(flex: 3),
            Lottie.asset(
              'assets/animations/success.json',
              frameRate: FrameRate.max,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: FadeInUp(
                blur: true,
                child: Text(
                  'Published',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold
                  )
                ),
              ),
            ),
            Spacer(flex: 2),
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: SecondaryButton(
                padding: EdgeInsets.symmetric(
                  horizontal: 36,
                  vertical: 18
                ),
                child: Text('Go Back'),
                onPressed: () => Navigator.of(context).pop()
              ),
            ),
            SizedBox(height: Constants.of(context).bottomPadding)
          ],
        ),
      ),
    );

    var user = authState.user!;

    return Scaffold(
      appBar: AppBar(
        leading: NewBackButton(),
        title: Text('Publish'),
        centerTitle: false,
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 12,
              right: 12,
              bottom: 3
            ),
            child: Text(
              'Publishing as',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12
            ),
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Palette.of(context).surfaceVariant,
                borderRadius: BorderRadius.circular(10)
              ),
              child: Row(
                children: [
                  SizedBox(
                    height: 25,
                    width: 25,
                    child: ClipOval(
                      child: ProfilePhoto()
                    ),
                  ),
                  SizedBox(width: 10),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.displayName ?? 'Yourself',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      if (user.email != null) Text(
                        user.email!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 6),
          Divider(),

          Padding(
            padding: const EdgeInsets.only(
              left: 12,
              right: 12,
              bottom: 3
            ),
            child: Text(
              'Preview Thumbnails',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          SizedBox(
            height: 200,
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 12),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) => SizedBox(
                height: 200,
                width: ratio * 200,
                child: SmoothClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  smoothness: 0.6,
                  child: OctoImage(
                    image: FileImage(File(pathProvider.generateRelativePath('/Render Projects/${project.id}/images/${project.images[index]}'))),
                  ),
                ),
              ),
              itemCount: project.images.length,
            ),
          ),

          SizedBox(height: 6),
          Divider(),

          Padding(
            padding: const EdgeInsets.only(
              left: 12,
              right: 12,
              bottom: 3
            ),
            child: Text(
              'Category',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),

          FutureBuilder(
            future: _getCategories,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8
                    ),
                    child: SpinKitThreeInOut(
                      color: MediaQuery.of(context).platformBrightness == Brightness.light ? Colors.grey[800] : Colors.grey[200],
                      size: 20,
                    ),
                  ),
                ],
              );

              if (snapshot.connectionState != ConnectionState.done) return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12
                ),
                child: Row(
                  children: [
                    Icon(
                      RenderIcons.error,
                      size: 20,
                    ),
                    SizedBox(width: 6),
                    Text('Unable to fetch categories'),
                  ],
                ),
              );

              List<CategoryGroup> groups = snapshot.data as List<CategoryGroup>;

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select upto 5 categories that best describes your template. Minimum 2 categories are required.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    SizedBox(height: 6),
                    for (CategoryGroup group in groups) ... [
                      SizedBox(height: 6),
                      Text(
                        group.name,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      Wrap(
                        spacing: 6,
                        runSpacing: 0,
                        children: [
                          for (ProjectCategory category in group.types) ... [
                            ChoiceChip(
                              label: Text(category.name),
                              showCheckmark: false,
                              selected: selectedCategories.contains(category),
                              onSelected: (selected) {
                                if (selected) setState(() {
                                  if (selectedCategories.length < 5) selectedCategories.add(category);
                                  else Alerts.dialog(context, title: 'Uh oh!', content: 'You can only select upto 5 categories');
                                });
                                else setState(() {
                                  selectedCategories.remove(category);
                                });
                              },
                            )
                          ]
                        ],
                      )
                    ]
                  ],
                )
              );
            },
          ),

          SizedBox(height: 6),
          Divider(),

          if (isLoading) ... [
            progressReporter(
              status: _saveStatus,
              title: 'Saving project'
            ),
            progressReporter(
              status: _assetUploadStatus,
              title: 'Uploading assets'
            ),
            progressReporter(
              status: _publishStatus,
              title: 'Publishing'
            )
          ] else ... [
            CheckboxListTile.adaptive(
              value: _testing,
              onChanged: (value) => setState(() {
                _testing = value ?? false;
              }),
              visualDensity: VisualDensity.compact,
              title: Text(
                'I have properly tested the template',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            CheckboxListTile.adaptive(
              value: _privacy,
              onChanged: (value) => setState(() {
                _privacy = value ?? false;
              }),
              visualDensity: VisualDensity.compact,
              title: Text(
                'I have read and agree to the privacy policy',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            CheckboxListTile.adaptive(
              value: _tos,
              onChanged: (value) => setState(() {
                _tos = value ?? false;
              }),
              visualDensity: VisualDensity.compact,
              title: Text(
                'I have read and agree to the terms and conditions',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),

            SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12
              ),
              child: PrimaryButton(
                child: Text('Publish'),
                disabled: !_tos || !_privacy || !_testing || selectedCategories.length <= 2,
                onPressed: publish,
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget progressReporter({
    required _ProgessStatus status,
    required String title
  }) {
    Widget progressWidget;
    switch (status) {
      case _ProgessStatus.waiting:
        progressWidget = SpinKitPulse(
          color: Palette.of(context).primary,
        );
      case _ProgessStatus.processing:
        progressWidget = Spinner(adaptive: false, strokeWidth: 1.5,);
      case _ProgessStatus.done:
        progressWidget = Icon(CupertinoIcons.check_mark_circled_solid);
    }

    return ListTile(
      leading: SizedBox.square(
        dimension: 20,
        child: progressWidget
      ),
      minLeadingWidth: 0,
      title: Text(title),
    );
  }

  Future<void> publish() async {
    setState(() {
      _saveStatus = _ProgessStatus.processing;
      _assetUploadStatus = _ProgessStatus.processing;
      _publishStatus = _ProgessStatus.waiting;
    });

    try {
      var (pageData, features) = TemplateKit.buildTemplateData(project, categories: selectedCategories);

      Map<String, dynamic> rawData = await project.getJSON(publish: true, context: context);
      setState(() {
        _assetUploadStatus = _ProgessStatus.done;
        _saveStatus = _ProgessStatus.done;
        _publishStatus = _ProgessStatus.processing;
      });

      Map<String, dynamic> data = Map.from(rawData);
      data['assets'] = AssetManagerX.cleanFileFromAssets(data['assets']);

      data['features'] = features;
      data['template-kit'] = {
        'id': project.id,
        'size': {
          'width': project.size.size.width,
          'height': project.size.size.height,
          'name': '${project.size.size.width.toInt()}x${project.size.size.height.toInt()}'
        },
        if (project.pages.length > 1) 'pages': pageData
        else 'page': pageData.first,
        'is-multi-page': project.pages.length > 1,
      };

      Map<String, dynamic> formData = {
        "template": json.encode(data),
        "images": []
      };

      for (String _path in project.images) {
        String path = await pathProvider.generateRelativePath('${project.imagesSavePath}$_path');
        formData['images'].add(await MultipartFile.fromFile(path, filename: 'image-${Constants.generateID()}.png'));
      }

      await Cloud.post(
        'template/publish',
        data: FormData.fromMap(formData),
      );

      setState(() {
        _publishStatus = _ProgessStatus.done;
        published = true;
      });
    } catch (e, stacktrace) {
      analytics.logError(e, cause: 'publish failed', stacktrace: stacktrace);
      setState(() {
        _saveStatus = _ProgessStatus.done;
        _assetUploadStatus = _ProgessStatus.done;
        _publishStatus = _ProgessStatus.done;
      });
      Alerts.dialog(
        context,
        title: 'Error',
        content: 'An error occurred while publishing the template. Please try again later.',
      );
    }
  }

}

enum _ProgessStatus {
  waiting,
  processing,
  done
}