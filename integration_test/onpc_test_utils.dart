/*
 * Enhanced Music Controller
 * Copyright (C) 2019-2023 by Mikhail Kulesh
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

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onpc/constants/Dimens.dart';
import 'package:onpc/constants/Version.dart';
import 'package:onpc/utils/Logging.dart';
import 'package:onpc/widgets/CustomTextLabel.dart';
import 'package:onpc/widgets/ReorderableItem.dart';
import 'package:onpc/utils/Platform.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

typedef OnFind = Finder Function();

class OnpcTestUtils {
  static const String STEP_HEADER = "=================================> ";

  static const String TOP_LAYER = "_MEDIA_LIST_TOP_LAYER";
  static const int DELAY_MS = 500;
  static const int NORMAL_DELAY = 5;
  static const int LONG_DELAY = 10;
  static const int HUGE_DELAY = 15;

  static const Offset LIST_DRAG_OFFSET = Offset(0, -200);

  int _stepDelay = NORMAL_DELAY;

  void setStepDelay(int value) {
    _stepDelay = value;
  }

  Future<void> stepDelayMs(WidgetTester tester) async {
    for (int i = 0; i < DELAY_MS; i += 100) {
      await tester.pumpAndSettle();
      await Future.delayed(Duration(milliseconds: 100));
    }
  }

  Future<void> ensureElement(WidgetTester tester, OnFind finder) async {
    while (finder().evaluate().isEmpty) {
      await tester.pumpAndSettle();
      await Future.delayed(Duration(milliseconds: 100));
    }
  }

  Future<void> openDrawer(WidgetTester tester) async {
    Logging.info(tester, STEP_HEADER + "Open application drawer");
    await tester.tapAt(Offset(30, 30));
    await ensureElement(tester, () => find.text("Enhanced Music Controller"));
  }

  Future<void> openDrawerMenu(WidgetTester tester, String text, {OnFind? ensureAfter}) async {
    await openDrawer(tester);
    await tester.dragUntilVisible(find.text(text), find.byType(ListView), OnpcTestUtils.LIST_DRAG_OFFSET);
    await findAndTap(tester, "Open drawer menu: " + text, () => find.text(text), ensureAfter: ensureAfter);
  }

  Future<void> openSettings(WidgetTester tester, String s) async {
    await openDrawerMenu(tester, "Settings", ensureAfter: () => find.text("Theme"));
    await tester.ensureVisible(find.text(s));
    await findAndTap(tester, "Change " + s, () => find.text(s));
  }

  Future<void> previousScreen(WidgetTester tester) async {
    Logging.info(tester, STEP_HEADER + "Open previous screen");
    await tester.tapAt(Offset(30, 30));
    await stepDelayMs(tester);
  }

  Future<void> openTab(WidgetTester tester, String s,
      {bool swipeLeft = false, bool swipeRight = false, OnFind? ensureAfter}) async {
    if (swipeLeft) {
      await tester.drag(find.widgetWithText(Tab, "SHORTCUTS"), Offset(200, 0), warnIfMissed: false);
      await stepDelayMs(tester);
    }
    if (swipeRight) {
      await tester.drag(find.widgetWithText(Tab, "SHORTCUTS"), Offset(-200, 0), warnIfMissed: false);
      await stepDelayMs(tester);
    }
    await findAndTap(tester, "Open " + s + " tab", () => find.widgetWithText(Tab, s),
        ensureAfter : ensureAfter);
  }

  Future<void> findAndTap(WidgetTester tester, String title, OnFind finder,
      {bool rightClick = false, bool waitFor = false, int num = 1, int idx = 0,
       int? delay, OnFind? ensureAfter}) async {
    if (waitFor) {
      await ensureElement(tester, finder);
    }
    Logging.info(tester, STEP_HEADER + title);
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
      await ensureElement(tester, ensureAfter);
    } else {
      for (int i = 0; i < (delay ?? _stepDelay); i++) {
        await tester.pumpAndSettle();
        await Future.delayed(Duration(milliseconds: 900));
      }
    }
  }

  Future<void> navigateToMedia(WidgetTester tester, List<String> list,
      {bool waitFor = true, bool ensureVisible = false, OnFind? ensureAfter}) async {
    for (int i = 0; i < list.length; i++) {
      if (list[i] == TOP_LAYER) {
        if (i + 1 < list.length) {
          await findAndTap(tester, "Select top level", () => find.byTooltip("Top Menu"),
              ensureAfter: () => find.text(list[i + 1]));
        } else {
          await findAndTap(tester, "Select top level", () => find.byTooltip("Top Menu"));
        }
      } else {
        final List<String> tags = list[i].split("<S>");
        if (tags.length == 2) {
          Logging.info(tester, STEP_HEADER + "Split: " + tags.toString());
        }
        final String item = tags.length == 2 ? tags.first : list[i];
        final String postItem = tags.length == 2 ? tags.last : list[i];
        if (ensureVisible) {
          await ensureVisibleInList(
              tester, "Ensure item " + postItem, find.byType(ListView), () => find.text(postItem), Offset(0, -300));
        }
        await findAndTap(tester, "Navigate to: " + item, () => find.text(item),
            waitFor: waitFor, ensureAfter: () => find.text("Return"));
      }
    }
    if (ensureAfter != null) {
      await ensureVisibleInList(tester, "Ensure item ", find.byType(ListView), ensureAfter, OnpcTestUtils.LIST_DRAG_OFFSET);
    }
  }

  Future<void> contextMenu(WidgetTester tester, String item, String menu, {bool waitFor = false, OnFind? ensureAfter}) async {
    await findAndTap(tester, "Select item: " + item, () => find.text(item),
        waitFor: waitFor, rightClick: true, ensureAfter: () => find.text(menu));
    await findAndTap(tester, "Open context menu: " + menu, () => find.text(menu), ensureAfter: ensureAfter);
  }

  Future<void> slideByValue(WidgetTester tester, Finder slider, double value) async {
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
      await stepDelayMs(tester);
    }
  }

  Future<void> setText(WidgetTester tester, int num, int idx, String name) async {
    final Finder fab = find.byWidgetPredicate((widget) => widget is TextFormField);
    expect(fab, findsNWidgets(num));
    await tester.enterText(fab.at(idx), name);
    await stepDelayMs(tester);
  }

  Future<void> changeReorderableItem(WidgetTester tester, key, {bool state = false}) async {
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
      await findAndTap(tester, "Change checkbox", () => taps[i], delay: 0);
      await stepDelayMs(tester);
    }
  }

  Future<void> dragReorderableItem(WidgetTester tester, String drag, Offset dragOffset, {int dragIndex = 0}) async {
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
      await stepDelayMs(tester);
    }
  }

  Future<void> ensureVisibleInList(
      WidgetTester tester, String title, final Finder list, OnFind finder, Offset dragOffset) async {
    Logging.info(tester, STEP_HEADER + title);
    expect(list, findsOneWidget);
    while (finder().evaluate().isEmpty) {
      await tester.drag(list, dragOffset, warnIfMissed: false);
      await tester.pumpAndSettle();
    }
    await stepDelayMs(tester);
  }

  Future<void> writeLog(String tName) async {
    final StringBuffer outContent = StringBuffer();
    final DateTime now = DateTime.now();
    Logging.latestLogging.forEach((str) => outContent.writeln(str.substring(6)));
    final String fName = tName + "_" + Version.NAME + "_" + now.toString().replaceAll(":", "-") + ".log";
    await File(fName).writeAsString(outContent.toString());
  }
}
