import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:render_studio/rehmat.dart';
import 'package:universal_io/io.dart';

class RenderSearchBar extends StatelessWidget {

  const RenderSearchBar({
    super.key,
    this.controller,
    this.onSuffixTap,
    this.onSubmitted,
    this.onChanged,
    this.placeholder
  });

  final TextEditingController? controller;
  final Function()? onSuffixTap;
  final Function(String value)? onSubmitted;
  final Function(String value)? onChanged;
  final String? placeholder;

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) return CupertinoSearchTextField(
      controller: controller,
      placeholder: placeholder,
      prefixInsets: EdgeInsets.only(
        left: 9,
      ),
      style: TextStyle(
        color: Palette.of(context).onSurface
      ),
      onSuffixTap: onSuffixTap,
      onSubmitted: onSubmitted,
      onChanged: onChanged,
      padding: EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 9
      ),
    );
    else return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
          borderSide: BorderSide.none
        ),
        prefixIcon: Icon(RenderIcons.search),
        prefixIconColor: Palette.of(context).onSurface,
        suffixIcon: IconButton(
          onPressed: onSuffixTap,
          icon: Icon(RenderIcons.clear)
        ),
        hintText: placeholder,
        hintStyle: TextStyle(
          fontFamily: 'Google Sans',
        ),
      ),
      onFieldSubmitted: onSubmitted,
      onChanged: onChanged,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.search,
    );
  }
  
}