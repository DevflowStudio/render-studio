import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../rehmat.dart';

class PermissionScreen extends StatefulWidget {

  const PermissionScreen({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  _PermissionScreenState createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Allow Permission',
                style: Theme.of(context).textTheme.headline3,
              ),
              Text(
                'Please allow the requested permissions to continue',
                style: Theme.of(context).textTheme.headline6,
                textAlign: TextAlign.center,
              ),
              Container(height: 20,),
              SizedBox(
                width: double.maxFinite,
                child: SecondaryButton(
                  child: Text('Allow'),
                  onPressed: () => PermissionManager.request(context, widget.child),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _PermissionWidget extends StatefulWidget {

  const _PermissionWidget({Key? key, required this.permission}) : super(key: key);

  final Permission permission;

  @override
  __PermissionWidgetState createState() => __PermissionWidgetState();
}

class __PermissionWidgetState extends State<_PermissionWidget> {

  late Permission permission;

  @override
  void initState() {
    permission = widget.permission;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          Text(
            permission.status.toString(),
          )
        ],
      ),
    );
  }

}