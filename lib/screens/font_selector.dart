import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../rehmat.dart';

class FontSelector extends StatefulWidget {
  const FontSelector({Key? key}) : super(key: key);

  @override
  _FontSelectorState createState() => _FontSelectorState();
}

class _FontSelectorState extends State<FontSelector> {

  late Map<String, TextStyle> data;

  late int totalFonts;

  @override
  void initState() {
    totalFonts = GoogleFonts.asMap().length;
    data = {};
    for (int i = 0; i < 30; i++) {
      String font = GoogleFonts.asMap().keys.toList()[i];
      data[font] = GoogleFonts.asMap()[font]!.call();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: NewBackButton(),
        title: const Text('Select Font'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              child: TextFormField(
                decoration: InputDecoration(
                  filled: true,
                  hintText: 'Search over $totalFonts fonts'
                ),
                onChanged: (value) {
                  if (value.trim().length > 1) filter(value);
                },
              ),
            ),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) => ListTile(
                title: Text(data.keys.toList()[index]),
                subtitle: Text(
                  data.keys.toList()[index],
                  style: data.values.toList()[index],
                ),
                onTap: () => Navigator.of(context).pop(data.keys.toList()[index]),
              ),
              itemCount: data.length > 30 ? 30 : data.length,
              separatorBuilder: (context, index) => const Divider(),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Text(
                'Showing ${data.length > 30 ? 30 : data.length} of $totalFonts fonts\nSource: Google Fonts',
                style: Theme.of(context).textTheme.caption,
                textAlign: TextAlign.center
              ),
            )
          ],
        ),
      ),
    );
  }

  void filter(String _query) {
    data = {};
    for (String _font in GoogleFonts.asMap().keys) {
      String font = _font.toLowerCase().trim();
      String query = _query.toLowerCase().trim();
      if (font.contains(query) || font.startsWith(query) || font.endsWith(query)) {
        data[_font] = GoogleFonts.asMap()[_font]!.call();
      }
    }
    setState(() { });
  }

}