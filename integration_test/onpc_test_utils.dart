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
import 'package:onpc/constants/Version.dart';
import 'package:onpc/utils/Logging.dart';
import 'package:onpc/widgets/CustomTextLabel.dart';
import 'package:onpc/widgets/ReorderableItem.dart';

typedef OnFind = Finder Function();

class OnpcTestUtils {
  static const String STEP_HEADER = "=================================> ";

  static const int SHORT_DELAY = 2;
  static const int NORMAL_DELAY = 5;
  static const int LONG_DELAY = 10;
  static const int HUGE_DELAY = 15;

  static const Offset LIST_DRAG_OFFSET = Offset(0, -100);

  int _stepDelay = NORMAL_DELAY;

  void setStepDelay(int value) {
    _stepDelay = value;
  }

  Future<void> stepDelay(WidgetTester tester, {int? delay}) async {
    for (int i = 0; i < (delay ?? _stepDelay); i++) {
      await tester.pumpAndSettle();
      await Future.delayed(Duration(milliseconds: 900));
    }
  }

  Future<void> openDrawer(WidgetTester tester, {int? delay}) async {
    Logging.info(tester, STEP_HEADER + "Open application drawer");
    await tester.tapAt(Offset(30, 30));
    await stepDelay(tester, delay: delay ?? _stepDelay);
  }

  Future<void> previousScreen(WidgetTester tester, {int? delay}) async {
    Logging.info(tester, STEP_HEADER + "Open previous screen");
    await tester.tapAt(Offset(30, 30));
    await stepDelay(tester, delay: delay ?? _stepDelay);
  }

  Future<void> openTab(WidgetTester tester, String s, {int? delay}) async {
    await findAndTap(tester, "Open " + s + " tab", () => find.widgetWithText(Tab, s), delay: delay ?? _stepDelay);
  }

  Future<void> findAndTap(WidgetTester tester, String title, OnFind finder,
      {bool rightClick = false, bool waitFor = false, int? delay}) async {
    while (waitFor && finder().evaluate().isEmpty) {
      await stepDelay(tester, delay: 1);
    }
    Logging.info(tester, STEP_HEADER + title);
    final Finder fab = finder();
    expect(fab, findsOneWidget);
    await tester.tap(fab, buttons: rightClick ? 0x02 : 0x01, warnIfMissed: false);
    await stepDelay(tester, delay: delay ?? _stepDelay);
  }

  Future<void> setText(WidgetTester tester, int num, int idx, String name, {int? delay}) async {
    final Finder fab = find.byWidgetPredicate((widget) => widget is TextFormField);
    expect(fab, findsNWidgets(num));
    await tester.enterText(fab.at(idx), name);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await stepDelay(tester, delay: delay ?? _stepDelay);
  }

  Future<void> changeReorderableItem(WidgetTester tester, key, {bool state = false, int? delay}) async {
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
      await findAndTap(tester, "Change checkbox", () => taps[i], delay: delay ?? _stepDelay);
    }
  }

  Future<void> dragReorderableItem(WidgetTester tester, String drag, Offset dragOffset, {int? delay}) async {
    final Finder list = find.byType(ReorderableItem);
    final List<Finder> drags = [];
    list.evaluate().forEach((element) {
      final widget = element.widget;
      if (widget is ReorderableItem) {
        final Finder dragHandle = find.descendant(of: find.byWidget(widget), matching: find.byType(SizedBox));
        expect(dragHandle, findsOneWidget);
        final Finder text = find.descendant(of: find.byWidget(widget), matching: find.byType(CustomTextLabel));
        expect(text, findsOneWidget);
        final name = (text.evaluate().first.widget as CustomTextLabel).description;
        if (name == drag) {
          Logging.info(widget, " " + name + " -> drag " + dragOffset.toString());
          drags.add(dragHandle);
        }
      }
    });
    for (int i = 0; i < drags.length; i++) {
      await tester.drag(drags[i], dragOffset, warnIfMissed: false);
      await stepDelay(tester, delay: delay ?? _stepDelay);
    }
  }

  Future<void> ensureVisibleInList(
      WidgetTester tester, String title, final Finder list, OnFind finder, Offset dragOffset,
      {int? delay}) async {
    Logging.info(tester, STEP_HEADER + title);
    expect(list, findsOneWidget);
    while (finder().evaluate().isEmpty) {
      await tester.drag(list, dragOffset, warnIfMissed: false);
      await stepDelay(tester, delay: delay ?? _stepDelay);
    }
  }

  Future<void> writeLog(String tName) async {
    final StringBuffer outContent = StringBuffer();
    final DateTime now = DateTime.now();
    Logging.latestLogging.forEach((str) => outContent.writeln(str.substring(6)));
    final String fName = tName + "_" + Version.NAME + "_" + now.toString().replaceAll(":", "-") + ".log";
    await File(fName).writeAsString(outContent.toString());
  }
}
