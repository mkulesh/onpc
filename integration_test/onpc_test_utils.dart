/*
 * Enhanced Music Controller
 * Copyright (C) 2019-2024 by Mikhail Kulesh
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

import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onpc/constants/Dimens.dart';
import 'package:onpc/constants/Version.dart';
import 'package:onpc/utils/Logging.dart';
import 'package:onpc/utils/Pair.dart';
import 'package:onpc/widgets/CustomImageButton.dart';
import 'package:onpc/widgets/CustomTextLabel.dart';
import 'package:onpc/widgets/ReorderableItem.dart';
import 'package:onpc/utils/Platform.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

typedef OnFind = Finder Function();

class OnpcTestUtils {
  static const String STEP_HEADER = "=================================> ";

  static const String TOP_LAYER = "_MEDIA_LIST_TOP_LAYER";
  static const int _DEFAULT_DELAY_MS = 500;
  static const int _WAITING_DURATION = 1000 * 60; // 60 seconds waiting duration

  static const int NORMAL_DELAY = 5;
  static const int LONG_DELAY = 10;
  static const int HUGE_DELAY = 15;

  static const Offset LIST_DRAG_OFFSET = Offset(0, -200);
  static const Offset LIST_DRAG_OFFSET_UP = Offset(0, 300);

  final WidgetTester tester;
  final int _stepDelay = 1;

  OnpcTestUtils(this.tester);

  Future<void> connect(String device, String searchFor) async {
    await stepDelayMs();
    if (find.textContaining(searchFor).evaluate().isEmpty) {
      await openDrawer();
      await findAndTap("Find and connect", () => find.text(device), delay: OnpcTestUtils.HUGE_DELAY);
    }
    Logging.logSize = 5000; // After reconnect, increase log size
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

  Future<void> ensureDeleted(OnFind finder) async {
    final int start = DateTime.now().millisecondsSinceEpoch;
    while (finder().evaluate().isNotEmpty) {
      await tester.pumpAndSettle();
      await Future.delayed(Duration(milliseconds: 100));
      assert(DateTime.now().millisecondsSinceEpoch < start + _WAITING_DURATION);
    }
  }

  Future<void> openDrawer() async {
    Logging.info(this, STEP_HEADER + "Open application drawer");
    await tester.tapAt(Offset(30, 30));
    await ensureVisible(() => find.text("Enhanced Music Controller"));
  }

  Future<void> openDrawerMenu(String text, {OnFind? ensureAfter}) async {
    await openDrawer();
    await tester.dragUntilVisible(find.text(text), find.byType(ListView), OnpcTestUtils.LIST_DRAG_OFFSET);
    await findAndTap("Open drawer menu: " + text, () => find.text(text), ensureAfter: ensureAfter);
  }

  Future<void> openSettings(String text) async {
    await openDrawerMenu("Settings", ensureAfter: () => find.text("Theme"));
    await tester.ensureVisible(find.text(text));
    await findAndTap("Change setting " + text, () => find.text(text));
  }

  Future<void> previousScreen() async {
    Logging.info(this, STEP_HEADER + "Open previous screen");
    await tester.tapAt(Offset(30, 30));
    await stepDelayMs();
  }

  Future<void> openTab(String s, {bool swipeLeft = false, bool swipeRight = false, OnFind? ensureAfter}) async {
    if (swipeLeft) {
      await tester.drag(find.widgetWithText(Tab, "SHORTCUTS"), Offset(200, 0), warnIfMissed: false);
      await stepDelayMs();
    }
    if (swipeRight) {
      await tester.drag(find.widgetWithText(Tab, "SHORTCUTS"), Offset(-200, 0), warnIfMissed: false);
      await stepDelayMs();
    }
    await findAndTap("Open " + s + " tab", () => find.widgetWithText(Tab, s), ensureAfter: ensureAfter);
  }

  Future<void> findAndTap(String title, OnFind finder,
      {bool rightClick = false,
      bool waitFor = false,
      int num = 1,
      int idx = 0,
      int? delay,
      OnFind? ensureAfter}) async {
    if (waitFor) {
      await ensureVisible(finder);
    }
    Logging.info(this, STEP_HEADER + title);
    final Finder fab = finder();
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

  Future<void> navigateToMedia(List<String> list,
      {bool waitFor = true, bool ensureVisible = false, OnFind? ensureAfter}) async {
    for (int i = 0; i < list.length; i++) {
      if (list[i] == TOP_LAYER) {
        if (i + 1 < list.length) {
          await findAndTap("Select top level", () => find.byTooltip("Top Menu"),
              ensureAfter: () => find.text(list[i + 1]));
        } else {
          await findAndTap("Select top level", () => find.byTooltip("Top Menu"));
        }
        await stepDelaySec(1);
      } else {
        final List<String> tags = list[i].split("<S>");
        if (tags.length == 2) {
          Logging.info(this, STEP_HEADER + "Split: " + tags.toString());
        }
        final String item = tags.length == 2 ? tags.first : list[i];
        final String postItem = tags.length == 2 ? tags.last : list[i];
        if (ensureVisible) {
          await ensureVisibleInList(
              "Ensure item " + postItem, find.byType(ListView), () => find.text(postItem), Offset(0, -300));
        }
        await findAndTap("Navigate to: " + item, () => find.text(item),
            waitFor: waitFor, ensureAfter: () => find.text("Return"));
      }
    }
    if (ensureAfter != null) {
      await ensureVisibleInList("Ensure item ", find.byType(ListView), ensureAfter, OnpcTestUtils.LIST_DRAG_OFFSET);
    }
  }

  Future<void> contextMenu(String item, String menu,
      {bool waitFor = false, OnFind? ensureAfter, List<String>? checkItems}) async {
    await findAndTap("Select item: " + item, () => find.text(item),
        waitFor: waitFor, rightClick: true, ensureAfter: () => find.text(menu));
    if (checkItems != null) {
      checkItems.forEach((element) {
        expect(find.text(element), findsOneWidget);
      });
    }
    await findAndTap("Open context menu: " + menu, () => find.text(menu), ensureAfter: ensureAfter);
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
      await findAndTap("Change checkbox", () => taps[i], delay: 0);
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

  Future<void> ensureVisibleInList(String title, final Finder list, OnFind finder, Offset dragOffset) async {
    Logging.info(this, STEP_HEADER + title);
    expect(list, findsOneWidget);
    while (finder().evaluate().isEmpty) {
      await tester.drag(list, dragOffset, warnIfMissed: false);
      await tester.pumpAndSettle();
    }
    await stepDelayMs();
  }

  Future<void> writeLog(String tName) async {
    Logging.logSize = 5000;
    await stepDelaySec(NORMAL_DELAY);
    Logging.info(this, STEP_HEADER + "Test PASSED");
    final StringBuffer outContent = StringBuffer();
    final DateTime now = DateTime.now();
    Logging.latestLogging.forEach((str) => outContent.writeln(str.substring(6)));
    final String fName = tName + "_" + Version.NAME + "_" + now.toString().replaceAll(":", "-") + ".log";
    await File(fName).writeAsString(outContent.toString());
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

  Future<void> changeFriendlyName(OnpcTestUtils tu, String name) async {
    await tu.setText(1, 0, name);
    await tu.findAndTap("Change friendly name", () => find.byTooltip("Change friendly name"));
    await tu.stepDelaySec(OnpcTestUtils.NORMAL_DELAY);
    expect(find.text(name), findsExactly(2));
  }
}
