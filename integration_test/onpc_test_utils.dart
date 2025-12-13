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

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onpc/constants/Strings.dart';
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

  static const int NORMAL_DELAY = 5;
  static const int LONG_DELAY = 10;
  static const int HUGE_DELAY = 15;

  static const Offset LIST_DRAG_OFFSET = Offset(0, -200);
  static const Offset LIST_DRAG_OFFSET_UP = Offset(0, 300);

  OnpcTestUtils(final WidgetTester tester) : super(tester);

  //***********************************
  // Simple actions
  //***********************************

  Future<void> openDrawer() async {
    log("Open application drawer");
    await tester.tapAt(Offset(30, 30));
    await ensureVisible(() => find.text("Enhanced Music Controller"));
  }

  Future<void> previousScreen() async {
    log("Open previous screen");
    await tester.tapAt(Offset(30, 30));
    await stepDelayMs();
  }

  //***********************************
  // Methods
  //***********************************

  Future<void> connect(String device, String searchFor) async {
    startMethod("Connect to: " + device);
    await stepDelayMs();
    if (find.textContaining(searchFor).evaluate().isEmpty) {
      await openDrawer();
      await findAndTap(() => find.text(device), delay: OnpcTestUtils.HUGE_DELAY);
    }
    endMethod();
  }

  Future<void> openDrawerMenu(String text, {OnFind? ensureAfter}) async {
    startMethod("Open driver menu: " + text);
    await openDrawer();
    await tester.dragUntilVisible(find.text(text), find.byType(ListView), OnpcTestUtils.LIST_DRAG_OFFSET);
    await findAndTap(() => find.text(text), ensureAfter: ensureAfter);
    endMethod();
  }

  Future<void> openSettings(String text) async {
    startMethod("Open settings: " + text);
    await openDrawerMenu("Settings", ensureAfter: () => find.text("Theme"));
    await tester.ensureVisible(find.text(text));
    await findAndTap(() => find.text(text));
    endMethod();
  }

  Future<void> openTab(String s, {bool swipeLeft = false, bool swipeRight = false, OnFind? ensureAfter}) async {
    startMethod("Open tab: " + s);
    if (swipeLeft) {
      await tester.drag(find.widgetWithText(Tab, "SHORTCUTS"), Offset(200, 0), warnIfMissed: false);
      await stepDelayMs();
    }
    if (swipeRight) {
      await tester.drag(find.widgetWithText(Tab, "SHORTCUTS"), Offset(-200, 0), warnIfMissed: false);
      await stepDelayMs();
    }
    await findAndTap(() => find.widgetWithText(Tab, s), ensureAfter: ensureAfter);
    endMethod();
  }

  Future<void> navigateToMedia(List<String> list,
      {bool waitFor = true, bool ensureVisible = false, OnFind? ensureAfter}) async {
    startMethod("Navigate to media");
    log("Path: " + list.toString());
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
          log("Split: " + tags.toString());
        }
        final String item = tags.length == 2 ? tags.first : list[i];
        final String postItem = tags.length == 2 ? tags.last : list[i];
        if (ensureVisible) {
          await ensureVisibleInList(postItem, find.byType(ListView), () => find.text(postItem), Offset(0, -300));
        }
        await findAndTap(() => find.widgetWithText(ListTile, item),
            waitFor: waitFor, ensureAfter: () => find.text("Return"));
      }
    }
    if (ensureAfter != null) {
      await ensureVisibleInList("Final item", find.byType(ListView), ensureAfter, OnpcTestUtils.LIST_DRAG_OFFSET);
    }
    endMethod();
  }

  Future<void> contextMenu(String item, String menu,
      {bool waitFor = false, OnFind? ensureAfter, List<String>? checkItems, int num = 1, int idx = 0}) async {
    startMethod("Open context menu: " + item);
    await findAndTap(() => find.text(item),
        waitFor: waitFor, rightClick: true, num: num, idx: idx, ensureAfter: () => find.text(menu));
    if (checkItems != null) {
      checkItems.forEach((element) {
        expect(find.text(element), findsOneWidget);
      });
    }
    await findAndTap(() => find.text(menu), ensureAfter: ensureAfter);
    endMethod();
  }

  Future<void> changeFriendlyName(String name) async {
    startMethod("Change friendly name: " + name);
    await setText(1, 0, name);
    await findAndTap(() => find.byTooltip("Change friendly name"));
    await stepDelaySec(OnpcTestUtils.NORMAL_DELAY);
    expect(find.text(name), findsExactly(2));
    endMethod();
  }

  Future<void> ensureAvInfo(String input, String output, {bool video = true}) async {
    startMethod("Ensure Audio/Video info");
    await findAndTap(() => find.byTooltip("Audio/Video info"), ensureAfter: () => find.text("Audio/Video info"));
    await stepDelayMs();
    await ensureVisible(() => find.textContaining("Input: " + input));
    await ensureVisible(() => find.textContaining("Output: " + output));
    if (video) {
      expect(find.text("Input: ---"), findsOneWidget);
      expect(find.text("Output: ---"), findsOneWidget);
    }
    await findAndTap(() => find.text("OK"));
    endMethod();
  }

  Future<void> playShortcut(String shortcut, String statusPanel,
      {String ensureTop = "", String waitPlaying = "", String ensureItem = ""}) async {
    startMethod("Play shortcut: " + shortcut);
    if (ensureItem.isNotEmpty) {
      await openTab("SHORTCUTS");
      await stepDelayMs();
      await ensureVisibleInList(
          ensureItem, find.byType(ReorderableListView), () => find.text(ensureItem), OnpcTestUtils.LIST_DRAG_OFFSET);
    } else {
      await openTab("SHORTCUTS", ensureAfter: () => find.text(shortcut));
      await stepDelayMs();
    }
    await findAndTap(() => find.text(shortcut), ensureAfter: () => find.textContaining(statusPanel + " | items:"));
    if (ensureTop.isNotEmpty) {
      await ensureVisibleInList("List top", find.byType(ListView), () => find.text(ensureTop), LIST_DRAG_OFFSET_UP);
    }
    if (waitPlaying.isNotEmpty) {
      await waitMediaItemPlaying(waitPlaying);
    }
    endMethod();
  }

  Future<void> testAudioSlider(final AudioSliderParameters p) async {
    startMethod("Test slider: " + p.name);
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
    endMethod();
  }

  Future<void> changeParameter(String PARAM_NAME, String PARAM_VALUE,
      {bool pressOk = false, bool ignoreMissing = false, bool scroll = true}) async {
    startMethod("Change parameter: " + PARAM_NAME);
    if (scroll) {
      await tester.dragUntilVisible(find.text(PARAM_NAME), find.byType(ListView), OnpcTestUtils.LIST_DRAG_OFFSET);
    }
    if (find.textContaining(PARAM_VALUE).evaluate().isEmpty) {
      await findAndTap(() => find.text(PARAM_NAME));
      await stepDelayMs();
      if (ignoreMissing && find.textContaining(PARAM_VALUE).evaluate().isEmpty) {
        await findAndTap(() => find.text("CANCEL"));
        return;
      }
      await findAndTap(() => find.textContaining(PARAM_VALUE));
      if (pressOk) {
        await findAndTap(() => find.text("OK"));
      }
      await stepDelayMs();
      expect(find.textContaining(PARAM_VALUE), findsOneWidget);
    }
    endMethod();
  }

  Future<void> saveConnection(final String name, String address, {bool isDCP = false}) async {
    startMethod("Save connection: " + name + "/" + address);
    await openDrawerMenu("Connect", ensureAfter: () => find.text("Onkyo/Pioneer/Integra"));
    expect(find.text("Connect"), findsOneWidget);
    expect(find.text("Denon/Marantz"), findsOneWidget);
    expect(find.text("Address"), findsOneWidget);
    expect(find.text("Port (optional)"), findsOneWidget);
    await setText(3, 0, address);
    final Finder fab = find.byWidgetPredicate((widget) => widget is Radio);
    expect(fab, findsNWidgets(2));
    await findAndTap(() => fab.at(isDCP ? 1 : 0));
    await findAndTap(() => find.text("Save connection"));
    await setText(3, 2, name);
    await findAndTap(() => find.text("OK"), delay: OnpcTestUtils.LONG_DELAY);
    endMethod();
  }

  Future<void> changeServices(List<Pair<String, bool>> items) async {
    startMethod("Change services");
    await openSettings("Network services");
    for (int i = 0; i < items.length; i++) {
      final Pair<String, bool> item = items[i];
      await changeReorderableItem(item.item1, state: item.item2);
      await dragReorderableItem(item.item1, Offset(0, item.item2 ? -600 : 600));
    }
    await previousScreen();
    await previousScreen();
    endMethod();
  }

  Future<void> changeInputs(List<Pair<String, String>> items) async {
    startMethod("Change inputs");
    await openSettings("Input selectors");
    for (int i = 0; i < items.length; i++) {
      final Pair<String, String> item = items[i];
      if (item.item2.isEmpty) {
        await changeReorderableItem(item.item1);
        await dragReorderableItem(item.item1, Offset(0, 600));
      } else {
        await contextMenu(item.item1, "Edit", ensureAfter: () => find.text("CANCEL"));
        await setText(1, 0, item.item2);
        await findAndTap(() => find.text("OK"));
      }
    }
    await previousScreen();
    await previousScreen();
    endMethod();
  }

  Future<void> changeListeningModes(List<Pair<String, bool>> items) async {
    startMethod("Change listening modes");
    await openSettings("Listening modes");
    for (int i = 0; i < items.length; i++) {
      final Pair<String, bool> item = items[i];
      await tester.ensureVisible(find.text(item.item1));
      await changeReorderableItem(item.item1, state: item.item2);
      if (item.item2) {
        await dragReorderableItem(item.item1, Offset(0, -600));
      }
    }
    await previousScreen();
    await previousScreen();
    endMethod();
  }

  Future<void> setMaxVolume(final AudioSliderParameters p) async {
    startMethod("Set maximum volume");
    await openTab("LISTEN", ensureAfter: () => find.byTooltip(Strings.audio_control));
    await findAndTap(() => find.byTooltip(Strings.audio_control),
        ensureAfter: () => find.byTooltip(Strings.audio_control_max_level));
    await findAndTap(() => find.byTooltip(Strings.audio_control_max_level),
        ensureAfter: () => find.text(Strings.master_volume_max));
    await stepDelayMs();
    await testAudioSlider(p);
    await findAndTap(() => find.text("OK"));
    endMethod();
  }

  Future<void> renameZone(int zone, String newName) async {
    startMethod("Rename zone[" + zone.toString() + "] to " + newName);
    await openDrawer();
    await findAndTap(() => find.byTooltip("Edit"), num: 2, idx: zone);
    expect(find.text("Edit"), findsOneWidget);
    await setText(1, 0, newName);
    await findAndTap(() => find.text("OK"));
    await previousScreen();
    await openDrawerMenu(newName, ensureAfter: () => find.textContaining("Denon AVR/" + newName));
    endMethod();
  }
}
