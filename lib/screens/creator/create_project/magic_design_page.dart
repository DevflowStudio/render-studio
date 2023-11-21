import 'package:flutter/material.dart';
import 'package:render_studio/screens/creator/create_project/template_glance.dart';

import '../../../rehmat.dart';

class MagicDesignPage extends StatelessWidget {

  const MagicDesignPage({super.key, required this.templates, this.selectedTemplate, required this.onSelect, required this.promptCtrl, this.promptError, required this.prompts});

  final List<ProjectGlance> templates;
  final String? selectedTemplate;
  final Function(String uid) onSelect;
  final TextEditingController promptCtrl;
  final String? promptError;
  final List<Map<String, dynamic>> prompts;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: TextFormField(
              controller: promptCtrl,
              decoration: InputDecoration(
                labelText: 'Prompt',
                floatingLabelBehavior: FloatingLabelBehavior.always,
                hintText: 'Write a detailed prompt for the social media post that you want to create',
                errorText: promptError
              ),
              onTapOutside: (event) {
                FocusScope.of(context).unfocus();
              },
              maxLines: 7,
              minLines: 4,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: SizedBox(
              height: 38,
              child: ListView.separated(
                itemBuilder: (context, index) => GestureDetector(
                  onTap: () {
                    TapFeedback.light();
                    promptCtrl.text = prompts[index]['prompt'];
                  },
                  child: Chip(
                    label: Text(prompts[index]['short-description']),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)
                    ),
                  ),
                ),
                separatorBuilder: (context, index) => SizedBox(width: 3),
                itemCount: prompts.length,
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(
                  horizontal: 12
                )
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              bottom: 6,
              left: 12,
              right: 12,
              top: 12
            ),
            child: Text(
              'Choose a template',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.width / 3,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(
                horizontal: 7
              ),
              itemBuilder: (context, index) => TemplateGlance(
                key: ValueKey(templates[index].id),
                glance: templates[index],
                isSelected: selectedTemplate == templates[index].id,
                onTap: () => onSelect(templates[index].id),
              ),
              itemCount: templates.length,
              shrinkWrap: true,
            ),
          )
        ]
      ),
    );
  }
}