import 'dart:developer';

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
    log('sort pages: $nextPageIndex');
    final pages = <Widget>[];
    for (var i = nextPageIndex; i < _children.length; i++) {
      log('add next page $i');
      pages.add(_children[i]);
    }
    for (var i = 0; i < nextPageIndex; i++) {
      log('add previous page $i');
      pages.add(_children[i]);
    }
    setState(() {
      _children = pages;
    });
  }

  _flipLeft() {
    log('flip left');
    _animationController?.forward();
    int nextPageIndex = 1;
    if (nextPageIndex >= _children.length) {
      nextPageIndex = 0;
    }
    _sortPages(nextPageIndex);
  }

  _flipRight() {
    log('flip right');
    _animationController?.reverse();
    int nextPageIndex = _children.length - 1;
    _sortPages(nextPageIndex);
  }

  _flipUp() {
    log('flip up');
    _animationController?.forward();
    int nextPageIndex = 1;
    _sortPages(nextPageIndex);
  }

  _flipDown() {
    log('flip down');
    _animationController?.reverse();
    int nextPageIndex = _children.length - 1;
    _sortPages(nextPageIndex);
  }

  void _updateAnimation(AnimationStatus status) {
    if (status == AnimationStatus.completed ||
        status == AnimationStatus.dismissed) {
      log('animation status: $status');
    }
  }

  _generateStack() {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        log('horizontal drag end: ${details.velocity.pixelsPerSecond.dx}');
        if (details.velocity.pixelsPerSecond.dx < 0) {
          _flipLeft();
        } else {
          _flipRight();
        }
      },
      onVerticalDragEnd: (details) {
        log('vertical drag end: ${details.velocity.pixelsPerSecond.dy}');
        if (details.velocity.pixelsPerSecond.dy < 0) {
          _flipUp();
        } else {
          _flipDown();
        }
      },
      child: _children[0],
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
