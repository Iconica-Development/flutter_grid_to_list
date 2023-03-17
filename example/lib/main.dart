// SPDX-FileCopyrightText: 2022 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:flutter/material.dart';
import 'dart:math';

import 'package:flutter_grid_to_list/flutter_grid_to_list.dart';

void main() {
  runApp(const MaterialApp(
    home: GridToList(),
  ));
}

class GridToList extends StatefulWidget {
  const GridToList({super.key});

  @override
  State<GridToList> createState() => _GridToListState();
}

class _GridToListState extends State<GridToList> {
  late AnimatedGridToListController controller;
  @override
  void initState() {
    super.initState();
    controller = AnimatedGridToListController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  var containers = <Container>[
    ...List.generate(80, (index) => index)
        .map((e) => Container(
              width: 100,
              height: 100,
              color: Color((Random().nextDouble() * 0xFFFFFF).toInt())
                  .withOpacity(1.0),
            ))
        .toList(),
  ];

  @override
  Widget build(BuildContext context) {
    //get size
    return Scaffold(
        body: AnimatedGridToList(
            controller: controller,
            onTap: (i) {
              if (!controller.isExpanded) {
                controller.expand(i, const Duration(seconds: 1));
              } else {
                controller.shrink(const Duration(seconds: 0));
              }
            },
            itemBuilder: AnimatedGridToListItemBuilder(
              wrapAlignment: WrapAlignment.start,
              animatedItemBuilder: (context, index) => Container(
                height: MediaQuery.of(context).size.height * 0.6,
                width: MediaQuery.of(context).size.width * 0.8,
                color: containers[index].color,
                padding: const EdgeInsets.all(8),
                child: Text('Item $index IS ANIMATING'),
              ),
              gridItemBuilder: (context, index) {
                return containers[index];
              },
              listItemBuilder: (context, index) => Container(
                height: MediaQuery.of(context).size.height * 0.6,
                width: MediaQuery.of(context).size.width * 0.8,
                color: containers[index].color,
                padding: const EdgeInsets.all(8),
                child: Text('Item $index'),
              ),
              listItemSize: Size(
                MediaQuery.of(context).size.width * 0.8,
                MediaQuery.of(context).size.height * 0.6,
              ),
              gridItemSize: const Size(50, 50),
              itemCount: containers.length,
            )));
  }
}
