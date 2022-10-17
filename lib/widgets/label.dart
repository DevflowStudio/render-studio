import 'package:flutter/material.dart';

import '../rehmat.dart';

class Label extends StatefulWidget {

  const Label({
    Key? key,
    required this.label,
    this.subtitle = false
  }) : super(key: key);

  final String label;
  final bool subtitle;

  @override
  _LabelState createState() => _LabelState();
}

class _LabelState extends State<Label> {
  @override
  Widget build(BuildContext context) {
    return Text(
      widget.label,
      style: (widget.subtitle ? Theme.of(context).textTheme.subtitle1 : Theme.of(context).textTheme.headlineSmall)!.copyWith(
        color: Palette.of(context).onSurfaceVariant
      ),
    );
  }
}

class FormGroup extends StatefulWidget {

  const FormGroup({
    Key? key,
    this.margin,
    this.padding = 12,
    this.title,
    this.description,
    required this.textField
  }) : super(key: key);

  final String? title;
  
  final String? description;

  /// Margin around the widget
  final EdgeInsets? margin;

  /// Padding between the children of group
  final double padding;

  final TextFormField textField;

  @override
  _FormGroupState createState() => _FormGroupState();
}

class _FormGroupState extends State<FormGroup> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.margin ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.title != null) Label(label: widget.title ?? ''),
          if (widget.description != null) Text(
            widget.description ?? '',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          Container(height: 10,),
          widget.textField
        ],
      ),
    );
  }
}