import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:render_studio/models/cloud.dart';
import 'package:sprung/sprung.dart';

import '../../rehmat.dart';

class TemplateX {

  static (List<Map<String, dynamic>>, List<String>) buildTemplateData(Project project) {
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
      
      projectFeatures.addAll(features);
      pageData.add({
        'type': page.pageType?.name,
        'features': features,
        'variables': variables,
        'comments': page.pageTypeComment,
      });
    }

    return (pageData, projectFeatures);
  }

  static Future<void> publish(BuildContext context, {
    required Project project
  }) async {
    if (!await _showConfirmationDialog(context)) return;

    bool isSuccessful = true;

    await Spinner.fullscreen(
      context,
      task: () async {
        try {
          var (pageData, features) = buildTemplateData(project);
          Map<String, dynamic> data = await project.getJSON(publish: true, context: context, quality: ExportQuality.twox);
          data['features'] = features;
          data['template-x'] = pageData;

          Map<String, dynamic> formData = {
            "template": json.encode(data),
            "images": []
          };

          for (String _path in project.images) {
            String path = await pathProvider.generateRelativePath('${project.imagesSavePath}$_path');
            formData['images'].add(await MultipartFile.fromFile(path, filename: 'image-${Constants.generateID()}.png'));
          }

          print(formData);

          await Cloud.post(
            'template/publish',
            data: FormData.fromMap(formData),
          );
        } catch (e, stacktrace) {
          analytics.logError(e, cause: 'publish failed', stacktrace: stacktrace);
          isSuccessful = false;
        }
      }
    );
    
    if (isSuccessful) {
      TapFeedback.normal();
      Alerts.showSuccess(context, message: 'Published');
    }
    else Alerts.dialog(
      context,
      title: 'Error',
      content: 'An error occurred while publishing the template. Please try again later.',
    );
  }

  static Future<bool> _showConfirmationDialog(BuildContext context) async {
    return await Alerts.modal<bool>(
      context,
      title: 'Publish Template',
      childBuilder: (context, setState) => _ConfirmationDialog(),
    ) ?? false;
  }

}

class _ConfirmationDialog extends StatefulWidget {
  const _ConfirmationDialog({super.key});

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