import 'package:skeletons/skeletons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:octo_image/octo_image.dart';
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

  IconFinder finder = IconFinder();

  TextEditingController searchCtrl = TextEditingController();

  @override
  void initState() {
    finder.addListener(onUpdate);
    super.initState();
  }

  @override
  void dispose() {
    finder.removeListener(onUpdate);
    super.dispose();
  }

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
              child: TextFormField(
                controller: searchCtrl,
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: Icon(RenderIcons.search),
                  suffixIcon: IconButton(
                    onPressed: () => searchCtrl.clear(),
                    icon: Icon(RenderIcons.clear)
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none
                  ),
                ),
                onFieldSubmitted: (value) {
                  finder.search(value);
                },
              ),
            ),
          ),
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
                child: Center(child: Spinner(adaptive: true))
              ),
            ),
          ) else SliverPadding(
            padding: EdgeInsets.symmetric(vertical: 24, horizontal: 12),
            sliver: SliverMasonryGrid.count(
              crossAxisCount: 4,
              itemBuilder: (context, index) => _IconFinderIconWidget(
                icon: finder.icons[index],
                project: widget.project
              ),
              childCount: finder.icons.length,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6
            ),
          )
        ],
      ),
    );
  }

  void onUpdate() => setState(() {});

}

class _IconFinderIconWidget extends StatefulWidget {

  _IconFinderIconWidget({
    Key? key,
    required this.icon,
    required this.project
  }) : super(key: key);

  final IconFinderIcon icon;
  final Project project;

  @override
  State<_IconFinderIconWidget> createState() => __IconFinderIconWidgetState();
}

class __IconFinderIconWidgetState extends State<_IconFinderIconWidget> {

  late IconFinderIcon icon;
  late Project project;

  @override
  void initState() {
    icon = widget.icon;
    project = widget.project;
    icon.addListener(onIconUpdate);
    super.initState();
  }

  @override
  void dispose() {
    icon.removeListener(onIconUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => icon.toAsset(context, project: project, onDownloadComplete: (asset) {
        if (mounted) Navigator.of(context).pop(asset);
      }),
      child: Container(
        decoration: BoxDecoration(
          color: Palette.isDark(context) ? Palette.of(context).surfaceVariant : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: SizedBox.square(
          dimension: MediaQuery.of(context).size.width/5,
          child: icon.isLoading ? Center(
            child: Spinner(
              adaptive: true,
              value: icon.progress,
            ),
          ) : OctoImage(
            image: NetworkImage(icon.previewURLs.reversed.toList()[2]),
            fit: BoxFit.cover,
            placeholderBuilder: (context) => SkeletonAvatar(
              style: SkeletonAvatarStyle(
                shape: BoxShape.rectangle
              ),
            ),
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