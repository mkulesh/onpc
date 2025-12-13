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

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onpc/constants/Version.dart';
import 'package:onpc/utils/Logging.dart';
import 'package:onpc/utils/Pair.dart';
import 'package:onpc/widgets/CustomTextButton.dart';

import 'onpc_gui_actions.dart';

class AudioSliderParameters {
  String name = "";
  String initialValue = "";
  double initialValueStep = 0;
  String secondValue = "";
  double secondValueStep = 0;
  String buttonUp = "";
  String buttonUpValue = "";
  String buttonDown = "";
}

class OnpcTestUtils extends OnpcGuiActions {
  static const String TOP_LAYER = "_MEDIA_LIST_TOP_LAYER";
  static const String STEP_HEADER = "=================================> ";

  static const int NORMAL_DELAY = 5;
  static const int LONG_DELAY = 10;
  static const int HUGE_DELAY = 15;

  static const Offset LIST_DRAG_OFFSET = Offset(0, -200);
  static const Offset LIST_DRAG_OFFSET_UP = Offset(0, 300);

  OnpcTestUtils(final WidgetTester tester) : super(tester);

  Future<void> connect(String device, String searchFor) async {
    await stepDelayMs();
    if (find.textContaining(searchFor).evaluate().isEmpty) {
      await openDrawer();
      await findAndTap(() => find.text(device), delay: OnpcTestUtils.HUGE_DELAY);
    }
    Logging.logSize = 5000; // After reconnect, increase log size
  }

  Future<void> openDrawer() async {
    Logging.info(this, STEP_HEADER + "Open application drawer");
    await tester.tapAt(Offset(30, 30));
    await ensureVisible(() => find.text("Enhanced Music Controller"));
  }

  Future<void> openDrawerMenu(String text, {OnFind? ensureAfter}) async {
    await openDrawer();
    await tester.dragUntilVisible(find.text(text), find.byType(ListView), OnpcTestUtils.LIST_DRAG_OFFSET);
    await findAndTap(() => find.text(text), ensureAfter: ensureAfter);
  }

  Future<void> openSettings(String text) async {
    await openDrawerMenu("Settings", ensureAfter: () => find.text("Theme"));
    await tester.ensureVisible(find.text(text));
    await findAndTap(() => find.text(text));
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
    await findAndTap(() => find.widgetWithText(Tab, s), ensureAfter: ensureAfter);
  }

  Future<void> navigateToMedia(List<String> list,
      {bool waitFor = true, bool ensureVisible = false, OnFind? ensureAfter}) async {
    for (int i = 0; i < list.length; i++) {
      if (list[i] == TOP_LAYER) {
        if (i + 1 < list.length) {
          await findAndTap(() => find.byTooltip("Top Menu"), ensureAfter: () => find.text(list[i + 1]));
        } else {
          await findAndTap(() => find.byTooltip("Top Menu"));
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
        await findAndTap(() => find.widgetWithText(ListTile, item),
            waitFor: waitFor, ensureAfter: () => find.text("Return"));
      }
    }
    if (ensureAfter != null) {
      await ensureVisibleInList("Ensure item ", find.byType(ListView), ensureAfter, OnpcTestUtils.LIST_DRAG_OFFSET);
    }
  }

  Future<void> contextMenu(String item, String menu,
      {bool waitFor = false, OnFind? ensureAfter, List<String>? checkItems, int num = 1, int idx = 0}) async {
    await findAndTap(() => find.text(item),
        waitFor: waitFor, rightClick: true, num: num, idx: idx, ensureAfter: () => find.text(menu));
    if (checkItems != null) {
      checkItems.forEach((element) {
        expect(find.text(element), findsOneWidget);
      });
    }
    await findAndTap(() => find.text(menu), ensureAfter: ensureAfter);
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

  Future<void> changeFriendlyName(OnpcTestUtils tu, String name) async {
    await tu.setText(1, 0, name);
    await tu.findAndTap(() => find.byTooltip("Change friendly name"));
    await tu.stepDelaySec(OnpcTestUtils.NORMAL_DELAY);
    expect(find.text(name), findsExactly(2));
  }

  Future<void> ensureAvInfo(String input, String output, {bool video = true}) async {
    await findAndTap(() => find.byTooltip("Audio/Video info"), ensureAfter: () => find.text("Audio/Video info"));
    await stepDelayMs();
    await ensureVisible(() => find.textContaining("Input: " + input));
    await ensureVisible(() => find.textContaining("Output: " + output));
    if (video) {
      expect(find.text("Input: ---"), findsOneWidget);
      expect(find.text("Output: ---"), findsOneWidget);
    }
    await findAndTap(() => find.text("OK"));
  }

  Future<void> playShortcut(String shortcut, String statusPanel,
      {String ensureTop = "", String waitPlaying = "", String ensureItem = ""}) async {
    if (ensureItem.isNotEmpty) {
      await openTab("SHORTCUTS");
      await stepDelayMs();
      await ensureVisibleInList("Ensure " + ensureItem, find.byType(ReorderableListView), () => find.text(ensureItem),
          OnpcTestUtils.LIST_DRAG_OFFSET);
    } else {
      await openTab("SHORTCUTS", ensureAfter: () => find.text(shortcut));
      await stepDelayMs();
    }
    await findAndTap(() => find.text(shortcut), ensureAfter: () => find.textContaining(statusPanel + " | items:"));
    if (ensureTop.isNotEmpty) {
      await ensureVisibleInList(
          "Ensure list top", find.byType(ListView), () => find.text(ensureTop), LIST_DRAG_OFFSET_UP);
    }
    if (waitPlaying.isNotEmpty) {
      await waitMediaItemPlaying(waitPlaying);
    }
  }

  Future<void> testAudioSlider(final AudioSliderParameters p) async {
    Pair<Finder, Finder> slider;
    // Stepwise down
    while (find.text(p.name + " " + p.initialValue).evaluate().isEmpty) {
      slider = findSliderByName(p.name);
      await slideByValue(slider.item1, p.initialValueStep);
    }
    // Up by value
    slider = findSliderByName(p.name + " " + p.initialValue);
    await slideByValue(slider.item1, p.secondValueStep);
    // Up using button
    slider = findSliderByName(p.name + " " + p.secondValue, withButtons: true);
    assert(slider.item2.evaluate().length == 2);
    assert((slider.item2.evaluate().first.widget as CustomTextButton).text.contains(p.buttonDown));
    assert((slider.item2.evaluate().last.widget as CustomTextButton).text.contains(p.buttonUp));
    await findAndTap(() => slider.item2, num: 2, idx: 1, ensureAfter: () => find.text(p.name + " " + p.buttonUpValue));
    // Down using button
    slider = findSliderByName(p.name + " " + p.buttonUpValue, withButtons: true);
    await findAndTap(() => slider.item2, num: 2, idx: 0, ensureAfter: () => find.text(p.name + " " + p.secondValue));
  }
}
