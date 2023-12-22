import 'package:sprung/sprung.dart';

import '../../rehmat.dart';

class TemplateX {

  static Map<String, dynamic> buildTemplateData(Project project) {
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

    return {
      'page': pageData,
      'features': projectFeatures,
    };
  }

}