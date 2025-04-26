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
  String msg = '';

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

  _generateStack(context) {
    // Future.delayed(const Duration(milliseconds: 10000), () {
    //   setState(() {
    //     msg = '';
    //   });
    // });
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.velocity.pixelsPerSecond.dx < 0) {
          setState(() {
            msg = 'drag left - flip left';
          });
          _flipLeft();
        } else {
          setState(() {
            msg = 'drag right - flip right';
          });
          _flipRight();
        }
      },
      onVerticalDragEnd: (details) {
        if (details.velocity.pixelsPerSecond.dy < 0) {
          setState(() {
            msg = 'drag up - flip up';
          });
          _flipUp();
        } else {
          setState(() {
            msg = 'drag down - flip down';
          });
          _flipDown();
        }
      },
      child: Listener(
        onPointerSignal: (event) {
          if (event is PointerScrollEvent) {
            if (event.scrollDelta.dy != 0) {
              if (event.scrollDelta.dy < 0) {
                setState(() {
                  msg = 'scroll up - flip down';
                });
                _flipDown();
              } else {
                setState(() {
                  msg = 'scroll down - flip up';
                });
                _flipUp();
              }
            }
            if (event.scrollDelta.dx != 0) {
              if (event.scrollDelta.dx < 0) {
                setState(() {
                  msg = 'scroll left - flip right';
                });
                _flipRight();
              } else {
                setState(() {
                  msg = 'scroll right - flip left';
                });
                _flipLeft();
              }
            }
          }
        },
        child: Stack(
          children: [
            ..._children,
            Positioned(
              top: MediaQuery.of(context).size.height * 0.25,
              left: 0,
              right: 0,

              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(100),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    msg.isNotEmpty ? msg : 'waiting for action...',
                    style: Theme.of(
                      context,
                    ).textTheme.labelLarge?.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
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
    return _generateStack(context);
  }
}
