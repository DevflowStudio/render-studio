import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:render_studio/models/cloud.dart';
import 'package:render_studio/models/project/category.dart';
import 'package:sprung/sprung.dart';

import '../../rehmat.dart';

class TemplateKit {

  static Future<List<Project>> generate(BuildContext context, {
    required String prompt
  }) async {
    List<Project> projects = [];

    DateTime start = DateTime.now();
    Response response = await Cloud.post(
      'template/generate',
      data: FormData.fromMap({'prompt': prompt})
    );
    print('Template generation took ${DateTime.now().difference(start).inSeconds} seconds');

    List<Map> templates = List.from(response.data['templates']).toDataType<Map>();

    // Create a list of Futures for each project generation
    List<Future<Project?>> projectFutures = templates.map((Map data) {
      return Project.fromTemplateKit(
        context: context,
        data: data.toDataType<String, dynamic>(),
      );
    }).toList();

    // Wait for all project generation tasks to complete
    List<Project?> projectResults = await Future.wait(projectFutures);

    print('Project compilation took ${DateTime.now().difference(start).inSeconds} seconds');

    for (Project? project in projectResults) {
      if (project != null) projects.add(project);
    }

    return projects;
  }


  static (List<Map<String, dynamic>>, List<String>) buildTemplateData(Project project, {
    required List<ProjectCategory> categories,
  }) {
    List<Map<String, dynamic>> pageData = [];
    List<String> projectFeatures = [];

    for (CreatorPage page in project.pages.pages) {

      List<String> features = [];
      List<Map<String, dynamic>> variables = [];

      void _handleWidget(CreatorWidget widget) {
        try {
          List<String>? widgetFeatures = widget.getFeatures();
          Map<String, dynamic>? widgetVariables = widget.getVariables();
          if (!widget.isVariableWidget) widgetVariables = null;
          if (widgetFeatures != null) features.addAll(widgetFeatures);
          if (widgetVariables != null) variables.add(widgetVariables);
        } catch (e) {
          project.pages.controller.animateToPage(
            project.pages.pages.indexOf(page),
            duration: Duration(milliseconds: 500),
            curve: Sprung(),
          );
          page.widgets.select(widget);
          throw 'Error: $e. The widget has been selected. Please fix the error before proceeding.';
        }
      }

      for (CreatorWidget widget in page.widgets.widgets) {
        if (widget is WidgetGroup) {
          for (CreatorWidget child in widget.widgets) {
            _handleWidget(child);
          }
        } else {
          _handleWidget(widget);
        }
      }

      features.addAll([project.size.type.name, '${project.size.size.width.toInt()}x${project.size.size.height.toInt()}']);
      
      projectFeatures.addAll(features);
      pageData.add({
        'id': page.id,
        'type': page.pageType?.name,
        'features': features,
        'variables': variables,
        'comments': page.pageTypeComment,
        'categories': categories.map((category) => category.id).toList(),
        'named_categories': categories.map((category) => category.name).toList(),
      });
    }

    return (pageData, projectFeatures);
  }

}

class _ConfirmationDialog extends StatefulWidget {
  const _ConfirmationDialog();

  @override
  State<_ConfirmationDialog> createState() => __ConfirmationDialogState();
}

class __ConfirmationDialogState extends State<_ConfirmationDialog> {

  bool _tos = false;
  bool _privacy = false;
  bool _testing = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CheckboxListTile.adaptive(
          value: _testing,
          onChanged: (value) => setState(() {
            _testing = value ?? false;
          }),
          title: Text('I have properly tested the template'),
        ),
        CheckboxListTile.adaptive(
          value: _privacy,
          onChanged: (value) => setState(() {
            _privacy = value ?? false;
          }),
          title: Text('I have read and agree to the privacy policy'),
        ),
        CheckboxListTile.adaptive(
          value: _tos,
          onChanged: (value) => setState(() {
            _tos = value ?? false;
          }),
          title: Text('I have read and agree to the terms and conditions'),
        ),
        SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: PrimaryButton(
            child: Text('Publish'),
            disabled: !_tos || !_privacy || !_testing,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        )
      ],
    );
  }
}