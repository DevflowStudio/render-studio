import 'package:flutter/material.dart';

import '../../../rehmat.dart';

class MagicDesignPage extends StatelessWidget {

  const MagicDesignPage({super.key, required this.onSelect, required this.promptCtrl, this.promptError, required this.prompts});

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
        ]
      ),
    );
  }
}