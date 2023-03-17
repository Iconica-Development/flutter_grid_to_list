// SPDX-FileCopyrightText: 2022 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:flutter/material.dart';
import 'package:flutter_grid_to_list/src/animated_grid_to_list_item_builder.dart';

/// An enum to which offers the possibilties the [AnimatedGridToList] can be rendered in.
enum GridToListType {
  /// [grid] type of [GridToListType] which build a grid for [AnimatedGridToList]
  grid,

  /// [list] type of [GridToListType] which build a grid for [AnimatedGridToList]
  list,
}

extension NextType on GridToListType {
  /// Extenstion method on [GridToListType] which can be called to return the next value.
  get next =>
      this == GridToListType.grid ? GridToListType.list : GridToListType.grid;
}

extension Render on GridToListType {
  Widget render({
    required WrapAlignment wrapAlignment,
    required double spacing,
    required double? boxWidth,
    required double? boxHeight,
    required int? tappedItem,
    required AnimatedGridToListItemBuilder itemBuilder,
    required Function(int)? onTap,
    required BuildContext context,
    required bool isAnimating,
  }) {
    return !isAnimating
        ? Wrap(
            alignment: itemBuilder.wrapAlignment,
            spacing: spacing,
            children: [
              for (int i = 0; i < itemBuilder.itemCount; i++) ...[
                Opacity(
                  opacity: isAnimating && tappedItem == i
                      ? 1
                      : isAnimating && tappedItem != i
                          ? 0
                          : 1,
                  child: this == GridToListType.grid
                      ? SizedBox(
                          width: boxWidth ?? itemBuilder.gridItemSize.width,
                          height: boxHeight ?? itemBuilder.gridItemSize.height,
                          child: GestureDetector(
                            onTap: () => onTap?.call(i),
                            child: itemBuilder.gridItemBuilder(context, i),
                          ),
                        )
                      : SizedBox(
                          width: boxWidth ?? itemBuilder.listItemSize.width,
                          height: null,
                          child: GestureDetector(
                            onTap: () => onTap?.call(i),
                            child: itemBuilder.listItemBuilder(context, i),
                          ),
                        ),
                ),
              ],
            ],
          )
        : Align(
            alignment: tappedItem != itemBuilder.itemCount - 1
                ? Alignment.topCenter
                : Alignment.bottomCenter,
            child: SizedBox(
              width: boxWidth ?? itemBuilder.listItemSize.width,
              height: boxHeight ?? itemBuilder.listItemSize.height,
              child: GestureDetector(
                child: itemBuilder.animatedItemBuilder != null
                    ? itemBuilder.animatedItemBuilder!(context, tappedItem!)
                    : itemBuilder.listItemBuilder(context, tappedItem!),
              ),
            ),
          );
  }
}
