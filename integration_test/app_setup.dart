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

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:onpc/main.dart' as app;
import 'package:onpc/utils/Pair.dart';

import 'onpc_test_utils.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Initial configuration of the app', (tester) async {
    final OnpcTestUtils tu = OnpcTestUtils();
    tu.setStepDelay(OnpcTestUtils.SHORT_DELAY);

    app.main();
    await tu.stepDelay(tester);

    if (find.text("Search").evaluate().isNotEmpty) {
      // Device search is opened
      expect(find.text("Not connected"), findsOneWidget);
      await tu.findAndTap(tester, "Connect to Onkyo Player", () => find.text("192.168.1.80:60128"), waitFor: true);
    } else {
      await tu.openTab(tester, "LISTEN");
    }

    if (find.text("Onkyo Player (Standby)").evaluate().isNotEmpty) {
      // Player is off - call power on
      await tu.findAndTap(tester, "Power-off", () => find.byTooltip("On/Standby"));
    }

    await tu.openDrawer(tester);
    if (find.text("My Onkyo Player").evaluate().isEmpty) {
      await tu.findAndTap(tester, "Open connect dialog", () => find.text("Connect"));
      await _saveConnection(tu, tester, "My Onkyo Player", "192.168.1.80");
      await tu.stepDelay(tester);
    }

    await _aboutScreen(tu, tester);
    await _changeOnkyoSettings(tu, tester);
    await _changeListenLayout(tu, tester);
    await tu.openTab(tester, "SHORTCUTS");
    if (find.text("Deezer Flow").evaluate().isEmpty) {
      await _buildFavourites(tu, tester, dlna: true, deezer: true, tuneIn: true, usbMusic: true);
    }
    await _addRiDevices(tu, tester);
  });
}

Future<void> _saveConnection(final OnpcTestUtils tu, WidgetTester tester, String name, String address) async {
  expect(find.text("Connect"), findsOneWidget);
  expect(find.text("Onkyo/Pioneer/Integra"), findsOneWidget);
  expect(find.text("Denon/Marantz"), findsOneWidget);
  expect(find.text("Address"), findsOneWidget);
  expect(find.text(address), findsOneWidget);
  expect(find.text("Port (optional)"), findsOneWidget);
  await tu.findAndTap(tester, "Save connection", () => find.text("Save connection"));
  await tu.setText(tester, 3, 2, name);
  await tu.stepDelay(tester);
  await tu.findAndTap(tester, "Close connect dialog", () => find.text("OK"));
}

Future<void> _aboutScreen(OnpcTestUtils tu, WidgetTester tester) async {
  await tu.openDrawer(tester);
  await tu.findAndTap(tester, "Open About", () => find.text("About"));
  await tu.previousScreen(tester);
}

Future<void> _changeOnkyoSettings(final OnpcTestUtils tu, WidgetTester tester) async {
  await tu.openDrawer(tester);
  await tu.findAndTap(tester, "Open Settings", () => find.text("Settings"));

  if (find.text("Light (Purple and Green)").evaluate().isEmpty) {
    await tu.findAndTap(tester, "Change Theme1", () => find.text("Theme"));
    await tu.findAndTap(tester, "Change Theme2", () => find.text("Light (Purple and Green)"));
  }

  if (find.text("English").evaluate().isEmpty) {
    await tu.findAndTap(tester, "Change App language1", () => find.text("App language"));
    await tu.findAndTap(tester, "Change App language2", () => find.text("English"));
  }

  if (find.text("Small").evaluate().isEmpty) {
    await tu.findAndTap(tester, "Change Text and buttons size1", () => find.text("Text and buttons size"));
    await tu.findAndTap(tester, "Change Text and buttons size2", () => find.text("Small"));
  }

  await tu.findAndTap(tester, "Change inputs", () => find.text("Input selectors"));
  await tu.changeReorderableItem(tester, "USB(F)");
  await tu.dragReorderableItem(tester, "USB(F)", Offset(0, 600));
  if (find.text("USB Disk").evaluate().isEmpty) {
    await tu.findAndTap(tester, "Select USB(R)", () => find.text("USB(R)"), rightClick: true);
    await tu.findAndTap(tester, "Open edit dialog", () => find.text("Edit"));
    await tu.setText(tester, 1, 0, "USB Disk");
    await tu.findAndTap(tester, "Close edit dialog", () => find.text("OK"));
  }
  await tu.previousScreen(tester);

  await tu.findAndTap(tester, "Change services", () => find.text("Network services"));
  await tu.changeReorderableItem(tester, "Tidal");
  await tu.changeReorderableItem(tester, "Amazon Music");
  await tu.changeReorderableItem(tester, "Spotify");
  await tu.dragReorderableItem(tester, "Music Server (DLNA)", Offset(0, -600));
  await tu.previousScreen(tester);

  await tester.dragUntilVisible(find.text("Sound control"), find.byType(ListView), OnpcTestUtils.LIST_DRAG_OFFSET);
  if (find.text("Automatic").evaluate().isEmpty) {
    await tu.findAndTap(tester, "Change Sound control1", () => find.text("Sound control"));
    await tu.findAndTap(tester, "Change Sound control2", () => find.text("Automatic"));
  }
  await tu.previousScreen(tester);
}

Future<void> _changeListenLayout(final OnpcTestUtils tu, WidgetTester tester) async {
  await tu.openDrawer(tester);
  await tu.findAndTap(tester, "Open Tab layout", () => find.text("Tab layout"));
  await tu.dragReorderableItem(tester, "File information", Offset(0, -600));
  await tu.previousScreen(tester);
}

Future<void> _buildFavourites(final OnpcTestUtils tu, WidgetTester tester,
    {bool dlna = false, bool deezer = false, bool tuneIn = false, bool usbMusic = false}) async {
  final DRAG_OFFSET_DOWN = Offset(0, -300);
  final DRAG_OFFSET_UP = Offset(0, 300);
  final Pair<String, String> FLOW = Pair<String, String>("Flow", "Deezer Flow");
  final Pair<String, String> FAVOURITES = Pair<String, String>("The Dancer", "Deezer Favourites");
  final Pair<String, String> PLAYLIST = Pair<String, String>("Personal Jesus / Depeche Mode", "Deezer Playlist");

  await tu.openTab(tester, "MEDIA");
  await tu.findAndTap(tester, "Select NET", () => find.text("NET"), delay: OnpcTestUtils.LONG_DELAY);

  if (dlna) {
    await tu.findAndTap(tester, "Select top level", () => find.byTooltip("Top Menu"));
    await tu.findAndTap(tester, "Select Music Server1", () => find.text("Music Server (DLNA)"), waitFor: true);
    await tu.findAndTap(tester, "Select Music Server2", () => find.text("Supermicro DLNA Server"), waitFor: true);
    await tu.findAndTap(tester, "Select Music Server3", () => find.text("Music"), waitFor: true);
    await tu.findAndTap(tester, "Select Artist", () => find.text("Artist"), waitFor: true, rightClick: true);
    await tu.findAndTap(tester, "Create shortcut", () => find.text("Create shortcut"));
  }

  if (deezer) {
    await tu.findAndTap(tester, "Select top level", () => find.byTooltip("Top Menu"));
    await tu.findAndTap(tester, "Select Deezer", () => find.text("Deezer"),
        waitFor: true, delay: OnpcTestUtils.LONG_DELAY);
    await tu.findAndTap(tester, "Select Flow", () => find.text(FLOW.item1), waitFor: true, rightClick: true);
    await tu.findAndTap(tester, "Create shortcut1", () => find.text("Create shortcut"));
    await tu.findAndTap(tester, "Select My Music", () => find.text("My Music"), waitFor: true);
    await tu.findAndTap(tester, "Select Favourite tracks", () => find.text("Favourite tracks"), waitFor: true);
    await tu.ensureVisibleInList(
        tester, "Ensure song", find.byType(ListView), () => find.text(FAVOURITES.item1), DRAG_OFFSET_DOWN);
    await tu.findAndTap(tester, "Select song", () => find.text(FAVOURITES.item1), waitFor: true, rightClick: true);
    await tu.findAndTap(tester, "Create shortcut2", () => find.text("Create shortcut"));
    await tu.ensureVisibleInList(
        tester, "Ensure return", find.byType(ListView), () => find.text("Return"), DRAG_OFFSET_UP);
    await tu.findAndTap(tester, "Select Return", () => find.text("Return"));
    await tu.findAndTap(tester, "Select My Playlists", () => find.text("My Playlists"), waitFor: true);
    await tu.findAndTap(tester, "Select Onkyo playlist", () => find.text("Onkyo playlist"),
        waitFor: true, delay: OnpcTestUtils.NORMAL_DELAY);
    await tu.ensureVisibleInList(
        tester, "Ensure song", find.byType(ListView), () => find.text(PLAYLIST.item1), DRAG_OFFSET_DOWN);
    await tu.findAndTap(tester, "Select song", () => find.text(PLAYLIST.item1), waitFor: true, rightClick: true);
    await tu.findAndTap(tester, "Create shortcut3", () => find.text("Create shortcut"));

    await tu.openTab(tester, "SHORTCUTS");
    final List<Pair<String, String>> items = [FLOW, FAVOURITES, PLAYLIST];
    for (int i = 0; i < items.length; i++) {
      await tu.findAndTap(tester, "Select shortcut", () => find.text(items[i].item1), rightClick: true);
      await tu.findAndTap(tester, "Open edit dialog", () => find.text("Edit"));
      await tu.setText(tester, 1, 0, items[i].item2);
      await tu.findAndTap(tester, "Close edit dialog", () => find.text("OK"));
    }
  }

  if (tuneIn) {
    await tu.openTab(tester, "MEDIA");
    await tu.findAndTap(tester, "Select top level", () => find.byTooltip("Top Menu"));
    await tu.findAndTap(tester, "Select TuneIn", () => find.text("TuneIn Radio"), waitFor: true);
    await tu.findAndTap(tester, "Select My Presets", () => find.text("My Presets"), waitFor: true);
    await tu.findAndTap(tester, "Select Absolut relax", () => find.text("Absolut relax (Easy Listening)"),
        waitFor: true, rightClick: true);
    await tu.findAndTap(tester, "Create shortcut1", () => find.text("Create shortcut"));
    await tu.findAndTap(tester, "Select PureRock", () => find.text("PureRock.US (Metal)"), rightClick: true);
    await tu.findAndTap(tester, "Create shortcut1", () => find.text("Create shortcut"));
  }

  if (usbMusic) {
    await tu.openTab(tester, "MEDIA");
    await tu.findAndTap(tester, "Select USB", () => find.text("USB Disk"), delay: OnpcTestUtils.LONG_DELAY);
    await tu.findAndTap(tester, "Select top level", () => find.byTooltip("Top Menu"));
    await tu.findAndTap(tester, "Select onkyo_music", () => find.text("onkyo_music"), waitFor: true);
    await tu.findAndTap(tester, "Select Disco", () => find.text("Disco"), waitFor: true, rightClick: true);
    await tu.findAndTap(tester, "Create shortcut1", () => find.text("Create shortcut"));
    await tu.findAndTap(tester, "Select Power Metall", () => find.text("Power Metall"), rightClick: true);
    await tu.findAndTap(tester, "Create shortcut2", () => find.text("Create shortcut"));
    await tu.findAndTap(tester, "Select Rock", () => find.text("Rock"), rightClick: true);
    await tu.findAndTap(tester, "Create shortcut3", () => find.text("Create shortcut"));
    await tu.ensureVisibleInList(
        tester, "Ensure Русский рок", find.byType(ListView), () => find.text("Русский рок"), DRAG_OFFSET_DOWN);
    await tu.findAndTap(tester, "Select Русский рок", () => find.text("Русский рок"), waitFor: true, rightClick: true);
    await tu.findAndTap(tester, "Create shortcut4", () => find.text("Create shortcut"));
  }

  await tu.openTab(tester, "SHORTCUTS", delay: OnpcTestUtils.LONG_DELAY);
  await tu.findAndTap(tester, "Start Deezer", () => find.text(FAVOURITES.item2));
}

Future<void> _addRiDevices(OnpcTestUtils tu, WidgetTester tester) async {
  final String TD = "Tape Deck (RI)";
  final String MD = "MD Player (RI)";
  await tester.drag(find.widgetWithText(Tab, "DEVICE"), Offset(-200, 0), warnIfMissed: false);
  await tu.stepDelay(tester);
  await tu.openTab(tester, "RI");

  // Tab layout
  await tu.openDrawer(tester);
  await tu.findAndTap(tester, "Open Tab layout", () => find.text("Tab layout"));
  await tu.changeReorderableItem(tester, "Divider");
  await tu.ensureVisibleInList(
      tester, "Ensure " + TD, find.byType(ReorderableListView), () => find.text(TD), OnpcTestUtils.LIST_DRAG_OFFSET);
  await tester.drag(find.text(MD), OnpcTestUtils.LIST_DRAG_OFFSET, warnIfMissed: false);
  await tu.stepDelay(tester);
  await tu.changeReorderableItem(tester, MD, state: true);
  await tu.changeReorderableItem(tester, TD, state: true);
  await tu.previousScreen(tester);

  // RI-USB
  final String USB_RI = "OnkioRI FT231X - D30AWI99";
  await tu.openDrawer(tester);
  await tu.findAndTap(tester, "Open Settings", () => find.text("Settings"));
  await tester.dragUntilVisible(
      find.text("Use USB-RI interface"), find.byType(ListView), OnpcTestUtils.LIST_DRAG_OFFSET);
  if (find.text(USB_RI).evaluate().isEmpty) {
    await tu.findAndTap(tester, "Change Use USB-RI interface", () => find.text("Use USB-RI interface"));
    if (find.text(USB_RI).evaluate().isNotEmpty) {
      await tu.findAndTap(tester, "Select " + USB_RI, () => find.text(USB_RI));
    }
  }
}
