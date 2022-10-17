import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

import '../rehmat.dart';

class InteractiveCard extends StatefulWidget {

  const InteractiveCard({
    Key? key,
    required this.child,
    this.margin,
    this.padding,
    this.onTap,
    this.onLongPress,
  }) : super(key: key);

  final Widget child;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final Function()? onTap;
  final Function()? onLongPress;

  @override
  _InteractiveCardState createState() => _InteractiveCardState();
}

class _InteractiveCardState extends State<InteractiveCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: Constants.borderRadius,
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        child: widget.child,
      ),
    );
  }
}

class OpenCard extends StatefulWidget {

  const OpenCard({
    Key? key,
    required this.child,
    required this.navigationRoute,
    this.margin,
    this.padding,
  }) : super(key: key);

  final Widget child;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final Widget navigationRoute;

  @override
  _OpenCardState createState() => _OpenCardState();
}

class _OpenCardState extends State<OpenCard> {
  @override
  Widget build(BuildContext context) {
    return _OpenContainerWrapper(
      route: widget.navigationRoute,
      child: widget.child,
    );
  }
}

// ignore: unused_element
class _OpenContainerWrapper extends StatelessWidget {
  const _OpenContainerWrapper({
    required this.route,
    required this.child
  });

  final Widget route;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return OpenContainer(
      openBuilder: (context, closedContainer) {
        return route;
      },
      openColor: theme.cardColor,
      closedShape: RoundedRectangleBorder(
        borderRadius: Constants.borderRadius,
      ),
      closedElevation: 0,
      closedColor: theme.cardColor,
      closedBuilder: (context, openContainer) {
        return InkWell(
          onTap: () {
            openContainer();
          },
          child: child,
        );
      },
    );
  }
}