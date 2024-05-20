import 'package:flutter/material.dart';
import 'package:render_studio/screens/creator/create_project/template_glance.dart';

import '../../../rehmat.dart';

class CustomNewProjectPage extends StatelessWidget {

  CustomNewProjectPage({
    super.key,
    required this.templates,
    required this.selectedTemplate,
    required this.onSelect,
    required this.titleCtrl,
    required this.descriptionCtrl,
    required this.onTitleChange,
    required this.titleError,
    required this.isTemplate,
    required this.onTemplateChanged,
    required this.isTemplateKit,
    required this.onTemplateKitChanged,
  });

  final List<ProjectGlance> templates;
  final String? selectedTemplate;
  final Function(String? uid) onSelect;

  final TextEditingController titleCtrl;
  final TextEditingController descriptionCtrl;

  final void Function() onTitleChange;

  final bool titleError;

  final bool isTemplateKit;
  final void Function(bool value) onTemplateKitChanged;

  final bool isTemplate;
  final void Function(bool value) onTemplateChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextFormField(
              controller: titleCtrl,
              decoration: InputDecoration(
                labelText: 'Title',
                errorText: titleError ? 'A title is required to create a new project' : null
              ),
              onTapOutside: (event) {
                FocusScope.of(context).unfocus();
              },
            ),
          ),
          SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextFormField(
              controller: descriptionCtrl,
              decoration: const InputDecoration(
                labelText: 'Description',
                floatingLabelBehavior: FloatingLabelBehavior.always,
                helperText: '(optional)'
              ),
              maxLines: 7,
              minLines: 3,
              maxLength: 2000,
              onTapOutside: (event) {
                FocusScope.of(context).unfocus();
              },
            ),
          ),
          ListTile(
            title: Text(
              'Template',
              style: Theme.of(context).textTheme.bodyLarge
            ),
            subtitle: Text(
              'Create this project as a template to remix later',
              style: Theme.of(context).textTheme.bodyMedium
            ),
            contentPadding: EdgeInsets.only(top: 12, left: 12, right: 12, ),
            trailing: Switch.adaptive(
              value: isTemplate,
              onChanged: (value) {
                onTemplateChanged(value);
              },
            ),
          ),
          if (isTemplate && app.remoteConfig.enableTemplateKit) ListTile(
            title: Text(
              'Template Kit',
              style: Theme.of(context).textTheme.bodyLarge
            ),
            subtitle: Text(
              'Create AI remixable template',
              style: Theme.of(context).textTheme.bodyMedium
            ),
            contentPadding: EdgeInsets.only(top: 12, left: 12, right: 12, ),
            trailing: Switch.adaptive(
              value: isTemplateKit,
              onChanged: (value) {
                onTemplateKitChanged(value);
              },
            ),
          ),
          if (!isTemplate && templates.isNotEmpty) Padding(
            padding: EdgeInsets.only(
              bottom: 6,
              top: 12,
              left: 12,
              right: 12,
            ),
            child: Text(
              'Choose a starter template',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          if (!isTemplate) SizedBox(
            height: MediaQuery.of(context).size.width / 3,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(
                horizontal: 8,
              ),
              itemBuilder: (context, index) {
                bool isSelected = selectedTemplate == templates[index].id;
                return TemplateGlance(
                  key: ValueKey(templates[index].id),
                  glance: templates[index],
                  isSelected: isSelected,
                  onTap: () => onSelect(isSelected ? null : templates[index].id),
                );
              },
              itemCount: templates.length,
              shrinkWrap: true,
            ),
          )
        ]
      ),
    );
  }
}