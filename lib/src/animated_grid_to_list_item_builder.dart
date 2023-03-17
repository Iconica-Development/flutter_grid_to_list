// SPDX-FileCopyrightText: 2022 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:flutter/material.dart';

/// Class required by [AnimatedGridToList] to build items.
/// Requires [gridItemBuilder] which is an [IndexedWidgetBuilder] to build items in [AnimatedGridToList] grid state.
///
/// Requires [listItemBuilder] which is an [IndexedWidgetBuilder] to build items in [AnimatedGridToList] list state.
///
/// Requires [gridItemSize] which is of type [Size] to build the items and handle the scrolling accordingly.
///
/// Requires [listItemSize] which is of type [Size] to build the items and handle the scrolling accordingly.
///
/// It also requires an [itemCount], which is of type [int].
class AnimatedGridToListItemBuilder {
  AnimatedGridToListItemBuilder({
    required this.gridItemBuilder,
    required this.listItemBuilder,
    required this.itemCount,
    required this.gridItemSize,
    required this.listItemSize,
    this.animatedItemBuilder,
    this.wrapAlignment = WrapAlignment.center,
  });

  /// [IndexedWidgetBuilder] which build the items in grid state.
  final IndexedWidgetBuilder gridItemBuilder;

  /// [IndexedWidgetBuilder] which build the items in list state.
  final IndexedWidgetBuilder listItemBuilder;

  /// [IndexedWidgetBuilder] which build the items in animated state.
  final IndexedWidgetBuilder? animatedItemBuilder;

  /// A [Size] to build the items in the correct manner and handle scrolling in grid state.
  final Size gridItemSize;

  /// A [Size] to build the items in the correct manner and handle scrolling in list state.
  final Size listItemSize;

  /// A [WrapAlignment] to align the items in the correct manner.
  final WrapAlignment wrapAlignment;

  /// A [int] of the amount of items to build.
  int itemCount;
}
