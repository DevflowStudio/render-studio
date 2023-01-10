import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:octo_image/octo_image.dart';
import 'package:provider/provider.dart';

import '../../rehmat.dart';

class ProfilePhoto extends StatefulWidget {

  const ProfilePhoto({super.key});

  @override
  State<ProfilePhoto> createState() => _ProfilePhotoState();
}

class _ProfilePhotoState extends State<ProfilePhoto> {
  @override
  Widget build(BuildContext context) {
    AuthState authState = Provider.of<AuthState>(context);
    if (!authState.isLoggedIn) return OctoImage(
      image: AssetImage('assets/images/avatar.png'),
    );
    return OctoImage(
      image: CachedNetworkImageProvider(authState.user!.photoURL ?? ''),
      errorBuilder: (context, error, stackTrace) => OctoImage(
        image: AssetImage('assets/images/avatar.png'),
      ),
      placeholderBuilder: (context) => OctoImage(
        image: AssetImage('assets/images/avatar.png'),
      ),
    );
  }
}