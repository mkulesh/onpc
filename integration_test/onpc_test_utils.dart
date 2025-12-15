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

class OnpcTestProcedure {
  final Future<void> Function(OnpcTestUtils tu) procedure;
  final String name;

  OnpcTestProcedure(this.procedure, this.name);

  @override
  String toString() {
    return name;
  }

  Future<bool> run(OnpcTestUtils tu) async {
    tu.startMethod(name, clearStack: true);
    bool result = false;
    try {
      final DateTime startTime = DateTime.now();
      await procedure(tu);
      final DateTime endTime = DateTime.now();
      result = true;
      tu.log("Result: PASSED in " + endTime.difference(startTime).inSeconds.toString() + " seconds");
    } catch (e, stackTrace) {
      tu.log("Result: FAILED");
      tu.log(e.toString());
      tu.log(stackTrace.toString());
      result = false;
    }
    tu.endMethod();
    return result;
  }
}

class OnpcTestUtils extends OnpcGuiActions {
  static const String TOP_LAYER = "_MEDIA_LIST_TOP_LAYER";

  static const int SHORT_DELAY = 1;
  static const int NORMAL_DELAY = 5;
  static const int LONG_DELAY = 10;

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
      await findAndTap(() => find.text(device), delay: NORMAL_DELAY);
    }
    endMethod();
  }

  Future<void> openDrawerMenu(String text, {OnFind? ensureAfter}) async {
    startMethod("Open driver menu: " + text);
    await openDrawer();
    await tester.dragUntilVisible(find.text(text), find.byType(ListView), LIST_DRAG_OFFSET);
    await findAndTap(() => find.text(text), ensureAfter: ensureAfter);
    endMethod();
  }

  Future<void> openSettings(String text, {String? scrollTo}) async {
    startMethod("Open settings: " + text);
    await openDrawerMenu("Settings", ensureAfter: () => find.text("Theme"));
    await ensureVisibleInList(text, find.byType(ListView), () => find.text(scrollTo ?? text), LIST_DRAG_OFFSET);
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
    await findAndTap(() => find.widgetWithText(Tab, s), ensureAfter: ensureAfter, waitFor: true);
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
        await stepDelaySec(SHORT_DELAY);
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
        // Wait until title is changed
        final String titleBefore = getTitleString();
        await findAndTap(() => find.widgetWithText(ListTile, item), waitFor: waitFor, delay: 0);
        while (true) {
          await stepDelayMs();
          final String titleAfter = getTitleString();
          if (titleAfter.isNotEmpty && titleAfter != titleBefore) {
            break;
          }
        }
      }
    }
    if (ensureAfter != null) {
      await ensureVisibleInList("Final item", find.byType(ListView), ensureAfter, LIST_DRAG_OFFSET);
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
    await stepDelaySec(NORMAL_DELAY);
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
          ensureItem, find.byType(ReorderableListView), () => find.text(ensureItem), LIST_DRAG_OFFSET);
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

  Future<void> changeParameter(String paramName, String paramValue,
      {bool pressOk = false, bool ignoreMissing = false, String? scrollTo}) async {
    startMethod("Change parameter: " + paramName);
    await ensureVisibleInList(paramName, find.byType(ListView), () => find.text(scrollTo ?? paramName), LIST_DRAG_OFFSET);
    if (find.textContaining(paramValue).evaluate().isEmpty) {
      await findAndTap(() => find.text(paramName), ensureAfter: () => find.text("CANCEL"));
      if (ignoreMissing && find.textContaining(paramValue).evaluate().isEmpty) {
        await findAndTap(() => find.text("CANCEL"));
        return;
      }
      await findAndTap(() => find.textContaining(paramValue));
      if (pressOk) {
        await findAndTap(() => find.text("OK"));
      }
      expect(find.textContaining(paramValue), findsOneWidget);
    }
    endMethod();
  }

  Future<void> saveConnection(String name, String address, {bool isDCP = false}) async {
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
    await findAndTap(() => find.text("OK"), delay: NORMAL_DELAY);
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
    await openSettings("Listening modes", scrollTo: "Master volume unit");
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
    await stepDelaySec(NORMAL_DELAY);
    await openDrawerMenu("Main", ensureAfter: () => find.textContaining("Denon AVR"));
    await stepDelaySec(NORMAL_DELAY);
    endMethod();
  }

  Future<void> renameShortcuts(final List<Pair<String, String>> items, final List<String> path, final listeningMode,
      {String ensureItem = ""}) async {
    startMethod("Rename shortcuts");
    await openTab("SHORTCUTS");
    await stepDelaySec(SHORT_DELAY);
    if (ensureItem.isNotEmpty) {
      await ensureVisibleInList(
          ensureItem, find.byType(ReorderableListView), () => find.text(ensureItem), LIST_DRAG_OFFSET);
    }
    if (path.isNotEmpty) {
      assert(items.length == path.length);
    }
    for (int i = 0; i < items.length; i++) {
      await ensureVisibleInList(
          items[i].item1, find.byType(ReorderableListView), () => find.text(items[i].item1), LIST_DRAG_OFFSET);
      await contextMenu(items[i].item1, "Edit",
          ensureAfter: () => find.text("CANCEL"),
          checkItems: [items[i].item1 + ":", "Edit", "Delete", "Copy to clipboard"]);
      if (path.isNotEmpty) {
        expect(find.text(path[i]), findsOneWidget);
      }
      expect(find.text("Apply listening mode"), listeningMode ? findsOneWidget : findsNothing);
      await setText(1, 0, items[i].item2);
      await findAndTap(() => find.text("OK"));
    }
    endMethod();
  }

  Future<void> openSearchDialog(int type, String search) async {
    startMethod("Search dialog");
    await findAndTap(() => find.byTooltip("Search"), ensureAfter: () => find.text("OK"));
    expect(find.text("Search"), findsOneWidget);
    expect(find.text("Artist"), findsOneWidget);
    expect(find.text("Album"), findsOneWidget);
    expect(find.text("Track"), findsOneWidget);
    expect(find.text("CANCEL"), findsOneWidget);
    final Finder fab = find.byWidgetPredicate((widget) => widget is Radio);
    expect(fab, findsNWidgets(3));
    await findAndTap(() => fab.at(type));
    await setText(1, 0, search);
    await findAndTap(() => find.text("OK"), ensureAfter: () => find.textContaining("Search: " + search + " | items:"));
    await ensureVisibleInList(search, find.byType(ListView), () => find.text(search), Offset(0, -300));
    endMethod();
  }

  Future<void> changeListeningMode(String input, String mode, bool isToneCtrl) async {
    startMethod("Change listening mode");
    await openTab("LISTEN", swipeLeft: true, ensureAfter: () => find.text(mode.toUpperCase()));
    await findAndTap(() => find.text(mode.toUpperCase()), delay: NORMAL_DELAY);
    await ensureAvInfo(input, mode);
    await findAndTap(() => find.byTooltip(Strings.audio_control),
        ensureAfter: () => find.text(Strings.audio_control_current_zone));
    expect(find.textContaining(Strings.master_volume), findsOneWidget);
    expect(find.textContaining(Strings.tone_bass), isToneCtrl ? findsOneWidget : findsNothing);
    expect(find.textContaining(Strings.tone_treble), isToneCtrl ? findsOneWidget : findsNothing);
    expect(find.textContaining(Strings.audio_balance), isToneCtrl ? findsOneWidget : findsNothing);
    expect(find.textContaining(Strings.tone_direct), isToneCtrl ? findsNothing : findsOneWidget);
    await findAndTap(() => find.text("OK"));
    await openTab("RC", swipeRight: true, ensureAfter: () => find.text(Strings.pref_listening_modes));
    expect(find.text(mode), findsOneWidget);
    if (mode == "Stereo") {
      await findAndTap(() => find.byTooltip(Strings.listening_mode_up),
          ensureAfter: () => find.text(Strings.listening_mode_pure_direct));
      await findAndTap(() => find.byTooltip(Strings.listening_mode_down), ensureAfter: () => find.text("Stereo"));
    }
    endMethod();
  }
}
