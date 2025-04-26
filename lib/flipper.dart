import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

enum FlipperDirection { vertical, horizontal }

class Flipper extends StatefulWidget {
  const Flipper({
    super.key,
    required this.children,
    this.direction = FlipperDirection.horizontal,
  });

  final List<Widget> children;
  final FlipperDirection direction;

  @override
  State<Flipper> createState() => _FlipperState();
}

class _FlipperState extends State<Flipper> with TickerProviderStateMixin {
  AnimationController? _animationController;
  List<Widget> _children = [];

  _sortPages(nextPageIndex) {
    final pages = <Widget>[];
    for (var i = nextPageIndex; i < _children.length; i++) {
      pages.add(_children[i]);
    }
    for (var i = 0; i < nextPageIndex; i++) {
      pages.add(_children[i]);
    }
    setState(() {
      _children = pages;
    });
  }

  _flipLeft() {
    _animationController?.forward();
    int nextPageIndex = 1;
    if (nextPageIndex >= _children.length) {
      nextPageIndex = 0;
    }
    _sortPages(nextPageIndex);
  }

  _flipRight() {
    _animationController?.reverse();
    int nextPageIndex = _children.length - 1;
    _sortPages(nextPageIndex);
  }

  _flipUp() {
    _animationController?.forward();
    int nextPageIndex = 1;
    _sortPages(nextPageIndex);
  }

  _flipDown() {
    _animationController?.reverse();
    int nextPageIndex = _children.length - 1;
    _sortPages(nextPageIndex);
  }

  void _updateAnimation(AnimationStatus status) {
    if (status == AnimationStatus.completed ||
        status == AnimationStatus.dismissed) {}
  }

  _generateStack() {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.velocity.pixelsPerSecond.dx < 0) {
          _flipLeft();
        } else {
          _flipRight();
        }
      },
      onVerticalDragEnd: (details) {
        if (details.velocity.pixelsPerSecond.dy < 0) {
          _flipUp();
        } else {
          _flipDown();
        }
      },
      child: Listener(
        onPointerSignal: (event) {
          if (event is PointerScrollEvent) {
            if (event.scrollDelta.dy != 0) {
              if (event.scrollDelta.dy < 0) {
                _flipDown();
              } else {
                _flipUp();
              }
            }
            if (event.scrollDelta.dx != 0) {
              if (event.scrollDelta.dx < 0) {
                _flipRight();
              } else {
                _flipLeft();
              }
            }
          }
        },
        child: _children[0],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _children = widget.children;
    _sortPages(0);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..addStatusListener(_updateAnimation);
  }

  @override
  void dispose() {
    _animationController?.removeStatusListener(_updateAnimation);
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _generateStack();
  }
}
