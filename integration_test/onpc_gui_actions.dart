/*
 * Enhanced Music Controller
 * Copyright (C) 2019-2025 by Mikhail Kulesh
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU
 * General Public License as published by the Free Software Foundation, either version 3 of the License,
 * or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
 * even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details. You should have received a copy of the GNU General
 * Public License along with this program.
 */

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onpc/constants/Dimens.dart';
import 'package:onpc/iscp/StateManager.dart';
import 'package:onpc/main.dart' as app;
import 'package:onpc/utils/Logging.dart';
import 'package:onpc/utils/Pair.dart';
import 'package:onpc/utils/Platform.dart';
import 'package:onpc/widgets/CustomImageButton.dart';
import 'package:onpc/widgets/CustomProgressBar.dart';
import 'package:onpc/widgets/CustomTextButton.dart';
import 'package:onpc/widgets/CustomTextLabel.dart';
import 'package:onpc/widgets/ReorderableItem.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

typedef OnFind = Finder Function();

class OnpcGuiActions {
  static const String STEP_HEADER = "=================================> ";
  static const int _DEFAULT_DELAY_MS = 500;
  static const int _WAITING_DURATION = 1000 * 60; // 60 seconds waiting duration
  final int _stepDelay = 1;

  final WidgetTester tester;

  OnpcGuiActions(this.tester);

  StateManager getStateManager() {
    final Finder fab = find.byType(app.MusicControllerApp);
    expect(fab, findsOneWidget);
    final app.MusicControllerApp mainWidget = fab.evaluate().first.widget as app.MusicControllerApp;
    return mainWidget.viewContext.stateManager;
  }

  Future<void> stepDelaySec(int delay) async {
    await stepDelayMs(delay: 1000 * delay);
  }

  Future<void> stepDelayMs({int? delay}) async {
    for (int i = 0; i < (delay ?? _DEFAULT_DELAY_MS); i += 100) {
      await tester.pumpAndSettle();
      await Future.delayed(Duration(milliseconds: 100));
    }
  }

  Future<void> ensureVisible(OnFind finder) async {
    final int start = DateTime.now().millisecondsSinceEpoch;
    while (finder().evaluate().isEmpty) {
      await tester.pumpAndSettle();
      await Future.delayed(Duration(milliseconds: 100));
      assert(DateTime.now().millisecondsSinceEpoch < start + _WAITING_DURATION);
    }
  }

  Future<void> ensureVisibleInList(String title, final Finder list, OnFind finder, Offset dragOffset) async {
    Logging.info(this, STEP_HEADER + title);
    expect(list, findsOneWidget);
    while (finder().evaluate().isEmpty) {
      await tester.drag(list, dragOffset, warnIfMissed: false);
      await tester.pumpAndSettle();
    }
    await stepDelayMs();
  }

  Future<void> ensureDeleted(OnFind finder) async {
    final int start = DateTime.now().millisecondsSinceEpoch;
    while (finder().evaluate().isNotEmpty) {
      await tester.pumpAndSettle();
      await Future.delayed(Duration(milliseconds: 100));
      assert(DateTime.now().millisecondsSinceEpoch < start + _WAITING_DURATION);
    }
  }

  // Extract and clean the finder description
  String cleanFinderDescription(final Finder fab) {
    String fabDesc = fab.toString();
    if (fabDesc.startsWith("Found ")) {
      fabDesc = fabDesc.substring(6); // Remove "Found "
    }
    if (fabDesc.startsWith("1 ")) {
      fabDesc = fabDesc.substring(2); // Remove "1 "
    }
    final int endIdx = fabDesc.indexOf(": [");
    if (endIdx != -1) {
      fabDesc = fabDesc.substring(0, endIdx); // Remove everything starting from ": ["
    }
    return fabDesc;
  }

  Future<void> findAndTap(OnFind finder,
      {bool rightClick = false,
      bool waitFor = false,
      int num = 1,
      int idx = 0,
      int? delay,
      OnFind? ensureAfter}) async {
    if (waitFor) {
      await ensureVisible(finder);
    }
    final Finder fab = finder();
    //log("Tap: " +
    //    cleanFinderDescription(fab) +
    //    (num > 1 ? ", index " + idx.toString() : "") +
    //    (delay != null ? ", delay = " + delay.toString() : ""));
    expect(fab, findsExactly(num));
    if (rightClick && Platform.isDesktop) {
      await tester.tap(fab.at(idx), buttons: 0x02, warnIfMissed: false);
    } else if (rightClick && Platform.isMobile) {
      await tester.longPress(fab.at(idx), warnIfMissed: false);
    } else {
      await tester.tap(fab.at(idx), buttons: 0x01, warnIfMissed: false);
    }
    if (ensureAfter != null) {
      await ensureVisible(ensureAfter);
    } else {
      for (int i = 0; i < (delay ?? _stepDelay); i++) {
        await tester.pumpAndSettle();
        await Future.delayed(Duration(milliseconds: 900));
      }
    }
  }

  Pair<Finder, Finder> findSliderByName(String s, {bool withButtons = false}) {
    Pair<Finder, Finder>? retValue;
    final Finder list = find.byType(CustomProgressBar);
    for (var element in list.evaluate()) {
      final widget = element.widget;
      if (widget is CustomProgressBar) {
        final Finder slider = find.descendant(of: find.byWidget(widget), matching: find.byType(SfSlider));
        expect(slider, findsOneWidget);
        final Finder text = find.descendant(of: find.byWidget(widget), matching: find.byType(CustomTextLabel));
        if (text.evaluate().isNotEmpty) {
          final String name = (text.evaluate().first.widget as CustomTextLabel).description;
          if (name.startsWith(s)) {
            final Finder buttons = find.descendant(of: find.byWidget(widget), matching: find.byType(CustomTextButton));
            if (withButtons) {
              expect(buttons, findsNWidgets(2));
            }
            retValue = Pair(slider, buttons);
          }
        }
      }
    }
    assert(retValue != null);
    return retValue!;
  }

  Future<void> slideByValue(Finder slider, double value) async {
    final widget = slider.evaluate().first.widget;
    if (widget is SfSlider) {
      Logging.info(
          widget,
          "SfSlider: min = " +
              widget.min.toString() +
              ", max = " +
              widget.max.toString() +
              ", value = " +
              widget.value.toString());

      final double totalWidth = tester.getSize(slider).width - (2 * ActivityDimens.progressBarRadius);
      final double start = totalWidth * (widget.value - widget.min) / (widget.max - widget.min);
      final double end = totalWidth * (widget.value + value - widget.min) / (widget.max - widget.min);

      final zeroPoint = tester.getTopLeft(slider) +
          Offset(ActivityDimens.progressBarRadius + start, tester.getSize(slider).height / 2);
      await tester.flingFrom(zeroPoint, Offset(end - start, 0), 80);
      await stepDelayMs();
    }
  }

  Future<void> setText(int num, int idx, String name) async {
    final Finder fab = find.byWidgetPredicate((widget) => widget is TextFormField);
    expect(fab, findsNWidgets(num));
    await tester.enterText(fab.at(idx), name);
    await stepDelayMs();
  }

  Future<void> changeReorderableItem(key, {bool state = false}) async {
    final Finder list = find.byType(ReorderableItem);
    final List<Finder> taps = [];
    list.evaluate().forEach((element) {
      final widget = element.widget;
      if (widget is ReorderableItem) {
        final Finder checkbox = find.descendant(of: find.byWidget(widget), matching: find.byType(Checkbox));
        expect(checkbox, findsOneWidget);
        final Finder text = find.descendant(of: find.byWidget(widget), matching: find.byType(CustomTextLabel));
        expect(text, findsOneWidget);
        final Finder dragHandle = find.descendant(of: find.byWidget(widget), matching: find.byType(SizedBox));
        expect(dragHandle, findsOneWidget);
        final name = (text.evaluate().first.widget as CustomTextLabel).description;
        final bool? val = (checkbox.evaluate().first.widget as Checkbox).value;
        if (val != null) {
          final bool newVal = key == name ? state : val;
          if (newVal != val) {
            Logging.info(widget, " " + name + ", " + val.toString() + " -> " + newVal.toString());
            taps.add(checkbox);
          }
        }
      }
    });
    for (int i = 0; i < taps.length; i++) {
      await findAndTap(() => taps[i], delay: 0);
      await stepDelayMs();
    }
  }

  Future<void> dragReorderableItem(String drag, Offset dragOffset, {int dragIndex = 0}) async {
    final Finder list = find.byType(ReorderableItem);
    final List<Finder> drags = [];
    list.evaluate().forEach((element) {
      final widget = element.widget;
      if (widget is ReorderableItem) {
        final Finder dragHandle = find.descendant(of: find.byWidget(widget), matching: find.byType(SizedBox));
        expect(dragHandle, findsNWidgets(dragIndex + 1));
        final Finder text = find.descendant(of: find.byWidget(widget), matching: find.byType(CustomTextLabel));
        expect(text, findsOneWidget);
        final name = (text.evaluate().first.widget as CustomTextLabel).description;
        if (name == drag) {
          Logging.info(widget, " " + name + " -> drag " + dragOffset.toString());
          drags.add(dragHandle.at(dragIndex));
        }
      }
    });
    for (int i = 0; i < drags.length; i++) {
      await tester.drag(drags[i], dragOffset, warnIfMissed: false);
      await stepDelayMs();
    }
  }

  List<Pair<String, String>> getListContent() {
    final List<Pair<String, String>> retValue = [];
    final Finder list = find.byWidgetPredicate((widget) => widget is ListTile);
    list.evaluate().forEach((element) {
      if (element.widget is ListTile) {
        final ListTile widget = element.widget as ListTile;
        if (widget.leading is CustomImageButton && widget.title is CustomTextLabel) {
          final String icon = (widget.leading as CustomImageButton).icon;
          final String title = (widget.title as CustomTextLabel).description;
          retValue.add(Pair(icon, title));
        }
      }
    });
    return retValue;
  }

  Future<void> waitMediaItemPlaying(String name) async {
    final int start = DateTime.now().millisecondsSinceEpoch;
    while (true) {
      await tester.pumpAndSettle();
      final Pair<String, String>? bob =
          getListContent().firstWhereOrNull((s) => s.item1.contains("media_item_play") && s.item2.contains(name));
      if (bob != null) {
        break;
      }
      await Future.delayed(Duration(milliseconds: 100));
      assert(DateTime.now().millisecondsSinceEpoch < start + _WAITING_DURATION);
    }
  }
}
