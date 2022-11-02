// import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
// import 'package:octo_image/octo_image.dart';
// 
// import '../rehmat.dart';

class ProfilePage extends StatefulWidget {
  
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SizedBox(
          //   width: 100,
          //   height: 100,
          //   child: ClipRRect(
          //     borderRadius: BorderRadius.circular(35),
          //     child: OctoImage(
          //       width: 100,
          //       height: 100,
          //       image: CachedNetworkImageProvider(Auth.user.photoURL!),
          //       fit: BoxFit.cover,
          //     ),
          //   ),
          // )
        ],
      ),
    );
  }
}