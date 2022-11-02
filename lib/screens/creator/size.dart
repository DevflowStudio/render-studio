// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:image_cropper/image_cropper.dart';
// 
// import '../../rehmat.dart';
// 
// 
// 
// 
// 
// class SelectSize extends StatefulWidget {
// 
//   const SelectSize({Key? key, required this.project}) : super(key: key);
// 
//   final Project project;
// 
//   @override
//   _SelectSizeState createState() => _SelectSizeState();
// }
// 
// class _SelectSizeState extends State<SelectSize> {
// 
//   late Project project;
// 
//   @override
//   void initState() {
//     project = widget.project;
//     super.initState();
//   }
// 
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: CustomScrollView(
//         slivers: [
//           SliverAppBar(
//             leading: NewBackButton(),
//             pinned: true,
//             centerTitle: false,
//             expandedHeight: Constants.appBarExpandedHeight,
//             titleTextStyle: const TextStyle(
//               fontSize: 14
//             ),
//             flexibleSpace: RenderFlexibleSpaceBar(
//               collapseMode: CollapseMode.pin,
//               centerTitle: false,
//               title: Text(
//                 'Size',
//                 // style: AppTheme.flexibleSpaceBarStyle
//               ),
//               titlePaddingTween: EdgeInsetsTween(
//                 begin: const EdgeInsets.only(
//                   left: 16.0,
//                   bottom: 16
//                 ),
//                 end: const EdgeInsets.symmetric(
//                   horizontal: 55,
//                   vertical: 15
//                 )
//               ),
//               stretchModes: const [
//                 StretchMode.fadeTitle,
//               ],
//             ),
//             actions: [
//               PopupMenuButton(
//                 itemBuilder: (context) => [
//                   const PopupMenuItem(
//                     child: Text('Custom Size'),
//                     value: 'custom-size',
//                   )
//                 ],
//                 onSelected: (value) {
//                   switch (value) {
//                     case 'custom-size':
//                       showModalBottomSheet(
//                         context: context,
//                         backgroundColor: Palette.of(context).surface,
//                         isScrollControlled: true,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.vertical(top: Constants.borderRadius.bottomLeft)
//                         ),
//                         builder: (context) {
//                           TextEditingController widthCtrl = TextEditingController(text: '1080');
//                           TextEditingController heightCtrl = TextEditingController(text: '1080');
//                           return Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 25),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Label(
//                                   label: 'Custom Size'
//                                 ),
//                                 Container(height: 10,),
//                                 Row(
//                                   children: [
//                                     Flexible(
//                                       flex: 1,
//                                       child: TextFormField(
//                                         controller: widthCtrl,
//                                         decoration: const InputDecoration(
//                                           labelText: 'Width'
//                                         ),
//                                         keyboardType: TextInputType.number,
//                                       ),
//                                     ),
//                                     Container(width: 10,),
//                                     Flexible(
//                                       flex: 1,
//                                       child: TextFormField(
//                                         controller: heightCtrl,
//                                         decoration: const InputDecoration(
//                                           labelText: 'Height'
//                                         ),
//                                         keyboardType: TextInputType.number,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 Container(height: 10,),
//                                 Padding(
//                                   padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
//                                   child: SizedBox(
//                                     width: double.maxFinite,
//                                     child: PrimaryButton(
//                                       child: Text('Select'),
//                                       // background: App.getThemedObject(context, light: Colors.black, dark: Colors.grey[800]),
//                                       onPressed: () {
//                                         Navigator.of(context).pop();
//                                         project.size = PostSize.custom(width: double.tryParse(widthCtrl.text) ?? 1080, height: double.tryParse(heightCtrl.text) ?? 1080);
//                                         AppRouter.replace(context, page: Create(project: project));
//                                       },
//                                     ),
//                                   ),
//                                 )
//                               ]
//                             ),
//                           );
//                         },
//                       );
//                       break;
//                     default:
//                   }
//                 },
//               )
//             ]
//           ),
//           SliverPadding(
//             padding: const EdgeInsets.symmetric(horizontal: 5),
//             sliver: SliverGrid(
//               delegate: SliverChildBuilderDelegate(
//                 (context, index) => SizedBox.fromSize(
//                   size: Constants.of(context).gridSize,
//                   child: InteractiveCard(
//                     onTap: () {
//                       project.size = PostSizePresets.values[index].toSize();
//                       AppRouter.replace(context, page: Create(project: project));
//                     },
//                     child: Column(
//                       children: [
//                         const Spacer(),
//                         Icon(PostSizePresets.values[index].icon),
//                         const Spacer(),
//                         Text(
//                           PostSizePresets.values[index].title,
//                           style: Theme.of(context).textTheme.caption,
//                         ),
//                         Container(height: 10,)
//                       ],
//                     ),
//                   )
//                 ),
//                 childCount: PostSizePresets.values.length
//               ),
//               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: Constants.of(context).crossAxisCount,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }