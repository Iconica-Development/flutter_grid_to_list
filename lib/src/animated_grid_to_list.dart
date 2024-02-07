// SPDX-FileCopyrightText: 2022 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:flutter/material.dart';
import 'package:flutter_grid_to_list/src/animated_grid_to_list_item_builder.dart';
import 'package:flutter_grid_to_list/src/animated_grid_to_list_type.dart';

export 'animated_grid_to_list_item_builder.dart';

class AnimatedGridToList extends StatefulWidget {
  const AnimatedGridToList({
    required this.itemBuilder,
    required this.controller,
    super.key,
    this.startWithGrid = true,
    this.onTap,
  });

  final AnimatedGridToListItemBuilder itemBuilder;
  final AnimatedGridToListController controller;
  final bool startWithGrid;
  final Function(int)? onTap;

  @override
  State<AnimatedGridToList> createState() => _AnimatedGridToListState();
}

class _AnimatedGridToListState extends State<AnimatedGridToList>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    widget.controller._itemBuilder = widget.itemBuilder;
    widget.controller._type =
        widget.startWithGrid ? GridToListType.grid : GridToListType.list;
    widget.controller._vsync = this;
    widget.controller.addListener(listenerFunction);
  }

  void listenerFunction() {
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    widget.controller.removeListener(listenerFunction);
  }

  @override
  Widget build(BuildContext context) {
    widget.controller._context = context;
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: SingleChildScrollView(
        // physics: MagnetScrollPhysics(
        //   itemSize: widget.controller._boxHeight ??
        //       widget.itemBuilder.gridItemSize.height,
        // ),
        controller: widget.controller._scrollController,
        child: widget.controller._type.render(
          spacing: widget.controller._spacing,
          boxWidth: widget.controller._boxWidth,
          boxHeight: widget.controller._boxHeight,
          tappedItem: widget.controller._tappedItem,
          isAnimating: widget.controller._isAnimating,
          wrapAlignment: widget.controller._wrapAlignment,
          onTap: widget.onTap,
          context: context,
          itemBuilder: widget.itemBuilder,
        ),
      ),
    );
  }
}

class AnimatedGridToListController extends ChangeNotifier {
  final ScrollController _scrollController = ScrollController();

  late AnimationController _controller;
  late Animation<double> _widthAnimation;
  late Animation<double> _heightAnimation;
  late AnimatedGridToListItemBuilder _itemBuilder;
  late BuildContext _context;
  late TickerProvider _vsync;
  late GridToListType _type;

  double? _boxWidth;
  double? _boxHeight;
  double? _initalHeight;
  double? _initialWidth;
  double? _previousScrollOffset;
  late double? _previousScrollOffsetCopy;
  double _spacing = 0;

  bool _isAnimating = false;
  bool _isExpanded = false;

  int? _tappedItem;
  late int? _prevIndex;

  WrapAlignment _wrapAlignment = WrapAlignment.center;

  void _setAnimation() {
    var endValueWidth = _itemBuilder.listItemSize.width;
    var endValueHeight = _itemBuilder.listItemSize.height == double.infinity
        ? _itemBuilder.gridItemSize.height
        : _itemBuilder.listItemSize.height;

    _initialWidth ??= _itemBuilder.gridItemSize.width;
    _initalHeight ??= _itemBuilder.gridItemSize.height;

    if (_type == GridToListType.list) {
      _widthAnimation =
          Tween<double>(begin: endValueWidth, end: _initialWidth).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeInQuint,
        ),
      );
      _heightAnimation =
          Tween<double>(begin: endValueHeight, end: _initalHeight).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeInQuint,
        ),
      );
    } else {
      _widthAnimation =
          Tween<double>(begin: _initialWidth, end: endValueWidth).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOutQuart,
        ),
      );
      _heightAnimation =
          Tween<double>(begin: _initalHeight, end: endValueHeight).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOutQuart,
        ),
      );
    }
  }

  void _handleScroll(int index) {
    switch (_type) {
      case GridToListType.grid:
        _scrollController.jumpTo(index * (_boxHeight ?? 0));
        if ([WrapAlignment.start, WrapAlignment.end].contains(_wrapAlignment) &&
            _controller.value > 0.5) {
          _wrapAlignment = WrapAlignment.center;
        }
        break;
      case GridToListType.list:
        _previousScrollOffset = null;
        _scrollController.jumpTo(index * (_boxHeight ?? 0));
        if ([WrapAlignment.start, WrapAlignment.end].contains(_wrapAlignment) &&
            _controller.value > 0.5) {
          _wrapAlignment = WrapAlignment.center;
        }
        break;
    }
  }

  void _finalize(double prevScrollOffset) {
    if (_controller.isCompleted) {
      switch (_type) {
        case GridToListType.grid:
          _type = _type.next;
          _handleScroll(_tappedItem!);

          break;
        case GridToListType.list:
          _wrapAlignment = WrapAlignment.center;
          _type = _type.next;

          _handleScroll(_tappedItem!);

          _scrollController.jumpTo(prevScrollOffset);
          _spacing = 0;
          break;
      }
      notifyListeners();
      _controller.removeListener(_listenerFunction);
    }
  }

  void _listenerFunction() {
    if (_itemBuilder.listItemSize.height == double.infinity) {
      _boxHeight = null;
    } else {
      _boxHeight = _heightAnimation.value;
    }

    _boxWidth = _widthAnimation.value;

    if (_context.size != null) {
      _spacing = _context.size!.width - _boxWidth!;
    } else {
      _spacing = 0;
    }

    _isAnimating = _controller.isAnimating;

    notifyListeners();

    _finalize(_previousScrollOffsetCopy!);
  }

  WrapAlignment _determineAlignment(
    int index,
    BuildContext context,
    AnimatedGridToListItemBuilder itemBuilder,
  ) {
    var amountOfItems =
        ((context.size?.width ?? 0) / itemBuilder.gridItemSize.width).floor();

    var determineSeq = amountOfItems % 3;
    var itemLowest = (amountOfItems / 3).floor();
    late int itemIndex;

    if (amountOfItems != 0) {
      itemIndex = index % amountOfItems;
    } else {
      itemIndex = 0;
    }

    late int itemsSide;
    late int itemsCenter;

    switch (determineSeq) {
      case 0:
        itemsSide = itemLowest;
        itemsCenter = itemLowest;
        break;

      case 1:
        itemsSide = itemLowest;
        itemsCenter = itemLowest + 1;
        break;

      case 2:
        itemsSide = itemLowest + 1;
        itemsCenter = itemLowest;
        break;
    }

    if ((itemIndex + 1) <= itemsSide) {
      return WrapAlignment.start;
    } else if ((itemIndex + 1) <= itemsSide + itemsCenter) {
      return WrapAlignment.center;
    } else {
      return WrapAlignment.end;
    }
  }

  /// Can be used to retrieve the status of the widget. This is only useful if
  /// you use [shrink] and [expand] methods
  bool get isExpanded => _isExpanded;

  /// Can be called to shrink to widget to it's grid state. Only works when the
  /// current state is of type [GridToListType.list]
  void shrink([Duration? duration]) {
    _isExpanded = false;
    if (_type == GridToListType.list) {
      resize(_prevIndex!, duration);
    }
  }

  /// Can be called to expand to widget to it's list state. Only works when the
  /// current state is of type [GridToListType.grid]
  ///
  /// Gets an index to determine which item it needs to transform.
  void expand(int index, [Duration? duration]) {
    _isExpanded = true;
    _prevIndex = index;
    if (_type == GridToListType.grid) {
      resize(index, duration);
    }
  }

  /// Can be called to dynamically change the state of the widget. Works in
  /// either [GridToListType.grid] or [GridToListType.list]
  ///
  /// Gets an index to determine which item it needs to transform.
  void resize(int index, Duration? duration) {
    if (!_isAnimating) {
      _previousScrollOffset ??= _scrollController.offset;
      _previousScrollOffsetCopy = _previousScrollOffset ?? 0;

      _controller = AnimationController(
        vsync: _vsync,
        duration: duration ?? const Duration(milliseconds: 200),
      );

      _tappedItem = index;
      _wrapAlignment = _determineAlignment(index, _context, _itemBuilder);
      notifyListeners();

      _setAnimation();

      _controller.addListener(_listenerFunction);

      _controller.forward();
      if (duration?.inMilliseconds == 0) {
        _controller.value = _controller.value > _controller.upperBound / 2
            ? _controller.upperBound
            : _controller.lowerBound;
      }
    }
  }
}
