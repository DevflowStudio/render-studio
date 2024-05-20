import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:octo_image/octo_image.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:universal_io/io.dart';
import '../../rehmat.dart';

class IconFinderScreen extends StatefulWidget {
  
  IconFinderScreen({
    Key? key,
    required this.project
  }) : super(key: key);
  
  final Project project;

  @override
  State<IconFinderScreen> createState() => _IconFinderScreenState();
}

class _IconFinderScreenState extends State<IconFinderScreen> {

  TextEditingController searchCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          RenderAppBar(
            title: Text('Icons'),
            isExpandable: false,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: RenderSearchBar(
                controller: searchCtrl,
                onSubmitted: (value) => setState(() {}),
              ),
            ),
          ),
          IconFinderResults(
            query: searchCtrl.text,
            onSelect: (file) {
              if (file != null) Navigator.of(context).pop(file);
            },
          )
        ],
      ),
    );
  }

}

class IconFinderResults extends StatefulWidget {
  
  const IconFinderResults({
    super.key,
    required this.query,
    required this.onSelect
  });

  final String query;
  final Function(File? file) onSelect;

  @override
  State<IconFinderResults> createState() => _IconFinderResultsState();
}

class _IconFinderResultsState extends State<IconFinderResults> {

  late final IconFinder finder;

  void onUpdate() => setState(() {});

  String? query;

  @override
  void initState() {
    super.initState();
    query = widget.query;
    finder = IconFinder(query: query);
    finder.addListener(onUpdate);
  }

  @override
  void dispose() {
    finder.removeListener(onUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.query != query) {
      query = widget.query;
      finder.search(query!);
    }
    return MultiSliver(
      children: [
        if (finder.error != null) SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: ListTile(
              tileColor: Palette.of(context).errorContainer,
              title: Text(
                finder.error!,
                style: TextStyle(
                  color: Palette.of(context).onErrorContainer
                ),
              ),
            ),
          ),
        ),
        if (finder.isLoading) SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: SizedBox(
              width: 50,
              height: 50,
              child: Center(
                child: Spinner(
                  adaptive: true,
                  strokeWidth: 2,
                )
              )
            ),
          ),
        ) else SliverPadding(
          padding: EdgeInsets.symmetric(vertical: 24, horizontal: 12),
          sliver: SliverMasonryGrid.count(
            crossAxisCount: 4,
            itemBuilder: (context, index) => _IconFinderIconWidget(
              icon: finder.icons[index],
              onSelect: widget.onSelect,
            ),
            childCount: finder.icons.length,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6
          ),
        )
      ],
    );
  }

}

class _IconFinderIconWidget extends StatefulWidget {

  _IconFinderIconWidget({
    Key? key,
    required this.icon,
    required this.onSelect
  }) : super(key: key);

  final IconFinderIcon icon;
  final Function(File? file) onSelect;

  @override
  State<_IconFinderIconWidget> createState() => __IconFinderIconWidgetState();
}

class __IconFinderIconWidgetState extends State<_IconFinderIconWidget> {

  late IconFinderIcon icon;

  bool isLoading = false;

  @override
  void initState() {
    icon = widget.icon;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        setState(() {
          isLoading = true;
        });
        try {
          File file = await icon.download(context);
          widget.onSelect(file);
        } catch (e) {
          Alerts.dialog(
            context,
            title: 'Failed to download',
            content: 'Could not download the icon. Please try again later.',
          );
        }
        setState(() {
          isLoading = true;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: Palette.isDark(context) ? Palette.of(context).surfaceContainerLow : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: SizedBox.square(
          dimension: MediaQuery.of(context).size.width/5,
          child: isLoading ? Center(
            child: Spinner(
              adaptive: true,
              value: icon.progress,
              strokeWidth: 2,
            ),
          ) : OctoImage(
            image: NetworkImage(icon.previewURLs.reversed.toList()[2]),
            fit: BoxFit.cover,
            // TODO: Add placeholder and error builders
            // placeholderBuilder: (context) => SkeletonAvatar(
            //   style: SkeletonAvatarStyle(
            //     shape: BoxShape.rectangle
            //   ),
            // ),
            errorBuilder: (context, error, stackTrace) => Icon(
              RenderIcons.error
            ),
          ),
        ),
      ),
    );
  }

  void onIconUpdate() => setState(() {});

}