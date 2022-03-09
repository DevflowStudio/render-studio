import 'package:flutter/material.dart';

import '../rehmat.dart';

class Lab extends StatefulWidget {

  const Lab({Key? key}) : super(key: key);

  @override
  State<Lab> createState() => _LabState();
}

class _LabState extends State<Lab> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            centerTitle: false,
            expandedHeight: Constants.appBarExpandedHeight,
            titleTextStyle: const TextStyle(
              fontSize: 14
            ),
            flexibleSpace: RenderFlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              centerTitle: false,
              title: Text(
                'Lab',
                style: AppTheme.flexibleSpaceBarStyle
              ),
              titlePaddingTween: EdgeInsetsTween(
                begin: const EdgeInsets.only(
                  left: 16.0,
                  bottom: 16
                ),
                end: const EdgeInsets.symmetric(
                  horizontal: 55,
                  vertical: 15
                )
              ),
              stretchModes: const [
                StretchMode.fadeTitle,
              ],
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              
            ])
          )
        ],
      ),
    );
  }

}