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
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:onpc/main.dart' as app;
import 'package:onpc/utils/Pair.dart';
import 'package:onpc/utils/Platform.dart';

import 'onpc_test_utils.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Initial configuration of the app', (tester) async {
    final OnpcTestUtils tu = OnpcTestUtils();
    tu.setStepDelay(1);

    app.main();
    await tu.stepDelayMs(tester);
    if (find.text("Search").evaluate().isNotEmpty) {
      // Device search is opened
      expect(find.text("Not connected"), findsOneWidget);
      await tu.findAndTap(tester, "Connect to Onkyo Player", () => find.text("192.168.1.80:60128"), waitFor: true);
    }

    await _aboutScreen(tu, tester);
    await _changeAppSettings(tu, tester);
    await _changeListenLayout(tu, tester);
    await _setupDenon(tu, tester);
    await _setupOnkyoBox(tu, tester);
    await _setupOnkyoPlayer(tu, tester);
  });
}

Future<void> _setupDenon(OnpcTestUtils tu, WidgetTester tester) async {
  await _saveConnection(tu, tester, "My Denon AVR", "192.168.1.82", isDCP: true);
  await _changeInputs(tester, tu, [
    Pair("HEOS MUSIC", "NET"),
    Pair("BLUETOOTH", "BT"),
    Pair("DVD", ""),
    Pair("Blu-ray", ""),
    Pair("TV Audio", ""),
    Pair("Onkyo", "ONKYO"),
    Pair("Media Player", ""),
    Pair("Game", ""),
    Pair("C7030", "CD"),
    Pair("Phono", ""),
  ]);
  await _changeServices(tester, tu, [
    Pair("Deezer", true),
    Pair("Local Music", true),
    Pair("Spotify", false),
    Pair("Tidal", false),
    Pair("Amazon Music", false),
    Pair("Napster", false),
    Pair("Soundcloud", false),
    Pair("Play List", false),
    Pair("History", false),
  ]);
  await _changeListeningModes(tester, tu, [
    Pair("Stereo", true),
    Pair("Auto", false),
    Pair("Dolby Digital", false),
    Pair("DTS Surround", false),
    Pair("Auro 3D", false),
    Pair("Auro 2D SURR", false),
    Pair("MCH Stereo", false),
    Pair("Wide Screen", false),
    Pair("Super Stadium", false),
    Pair("Rock Arena", false),
    Pair("Jazz Club", false),
    Pair("Classic Concert", false),
    Pair("Mono Movie", false),
    Pair("Matrix", false),
    Pair("Video Game", false),
    Pair("Virtual", false),
  ]);
  await _renameZone(tu, tester, 1, "To Onkyo");
}

Future<void> _setupOnkyoBox(OnpcTestUtils tu, WidgetTester tester) async {
  await _saveConnection(tu, tester, "My Onkyo Box", "192.168.1.81");
  await _changeServices(tester, tu, [
    Pair("Deezer", true),
    Pair("Music Server (DLNA)", true),
    Pair("Spotify", false),
    Pair("Tidal", false),
    Pair("Amazon Music", false),
  ]);
  await _changeListeningModes(tester, tu, [
    Pair("Mono", false),
    Pair("Stereo", false),
    Pair("Direct", false),
    Pair("Unplugged", false),
    Pair("Orchestra", false),
    Pair("Studio-Mix", false),
    Pair("Pure Audio", false),
    Pair("Full Mono", false),
    Pair("All Ch Stereo", false),
    Pair("TV Logic", false),
    Pair("Theater-Dimensional", false),
    Pair("Dolby Digital", false),
    Pair("Dolby Surround", false),
    Pair("Dolby THX Cinema", false),
    Pair("Dolby THX Music", false),
    Pair("Dolby THX Games", false),
    Pair("DTS Neural:X", false),
    Pair("DTS Virtual:X", false),
    Pair("Game-RPG", false),
    Pair("Game-Action", false),
    Pair("Game-Rock", false),
    Pair("Game-Sports", false),
  ]);
}

Future<void> _setupOnkyoPlayer(OnpcTestUtils tu, WidgetTester tester) async{
  await _saveConnection(tu, tester, "My Onkyo Player", "192.168.1.80");
  if (find.text("Onkyo Player (Standby)").evaluate().isNotEmpty) {
    // Player is off - call power on
    await tu.findAndTap(tester, "Power-off", () => find.byTooltip("On/Standby"));
  }
  await _changeInputs(tester, tu, [Pair("USB(R)", "USB Disk"), Pair("USB(F)", "")]);
  await _changeServices(tester, tu, [
    Pair("Deezer", true),
    Pair("Music Server (DLNA)", true),
    Pair("Spotify", false),
    Pair("Tidal", false),
    Pair("Amazon Music", false),
  ]);
  await tu.openTab(tester, "SHORTCUTS");
  if (find.text("Deezer Flow").evaluate().isEmpty) {
    await _buildOnkyoFavourites(tu, tester, dlna: true, deezer: true, tuneIn: true, usbMusic: true, radio: true);
  }
  if (Platform.isDesktop) {
    await _addRiDevices(tu, tester);
  }
}

Future<void> _saveConnection(final OnpcTestUtils tu, WidgetTester tester, String name, String address,
    {bool isDCP = false}) async {
  await tu.openDrawerMenu(tester, "Connect", ensureAfter: () => find.text("Onkyo/Pioneer/Integra"));
  expect(find.text("Connect"), findsOneWidget);
  expect(find.text("Denon/Marantz"), findsOneWidget);
  expect(find.text("Address"), findsOneWidget);
  expect(find.text("Port (optional)"), findsOneWidget);
  await tu.setText(tester, 3, 0, address);
  final Finder fab = find.byWidgetPredicate((widget) => widget is Radio);
  expect(fab, findsNWidgets(2));
  await tu.findAndTap(tester, "Set protocol", () => fab.at(isDCP ? 1 : 0));
  await tu.findAndTap(tester, "Save connection", () => find.text("Save connection"));
  await tu.setText(tester, 3, 2, name);
  await tu.findAndTap(tester, "Close connect dialog", () => find.text("OK"), delay: OnpcTestUtils.LONG_DELAY);
}

Future<void> _aboutScreen(OnpcTestUtils tu, WidgetTester tester) async {
  await tu.openDrawerMenu(tester, "About", ensureAfter: () => find.byType(Markdown));
  await tu.previousScreen(tester);
}

Future<void> _changeAppSettings(final OnpcTestUtils tu, WidgetTester tester) async {
  await tu.openDrawerMenu(tester, "Settings", ensureAfter: () => find.text("Theme"));

  final String THEME = "Light (Purple and Green)";
  if (find.text(THEME).evaluate().isEmpty) {
    await tu.findAndTap(tester, "Change Theme1", () => find.text("Theme"), ensureAfter: () => find.text(THEME));
    await tu.findAndTap(tester, "Change Theme2", () => find.text(THEME));
  }

  final String LANGUAGE = "English";
  if (find.text(LANGUAGE).evaluate().isEmpty) {
    await tu.findAndTap(tester, "Change App language1", () => find.text("App language"), ensureAfter: () => find.text(LANGUAGE));
    await tu.findAndTap(tester, "Change App language2", () => find.text(LANGUAGE));
  }

  final String SIZE = Platform.isIOS ? "Big" : "Small";
  if (find.text(SIZE).evaluate().isEmpty) {
    await tu.findAndTap(tester, "Change Text and buttons size1", () => find.text("Text and buttons size"), ensureAfter: () => find.text(SIZE));
    await tu.findAndTap(tester, "Change Text and buttons size2", () => find.text(SIZE));
  }

  await tester.dragUntilVisible(find.text("Sound control"), find.byType(ListView), OnpcTestUtils.LIST_DRAG_OFFSET);
  final String SOUND = "Automatic";
  if (find.text(SOUND).evaluate().isEmpty) {
    await tu.findAndTap(tester, "Change Sound control1", () => find.text("Sound control"), ensureAfter: () => find.text(SOUND));
    await tu.findAndTap(tester, "Change Sound control2", () => find.text(SOUND));
  }

  // RI-USB
  if (Platform.isDesktop) {
    await tester.dragUntilVisible(find.text("Use USB-RI interface"), find.byType(ListView), OnpcTestUtils.LIST_DRAG_OFFSET);
    final String USB_RI = "OnkioRI FT231X";
    if (find.textContaining(USB_RI).evaluate().isEmpty) {
      await tu.findAndTap(tester, "Change Use USB-RI interface1", () => find.text("Use USB-RI interface"), ensureAfter: () => find.textContaining(USB_RI));
      await tu.findAndTap(tester, "Change Use USB-RI interface2", () => find.textContaining(USB_RI));
    }
  }

  await tu.previousScreen(tester);
}

Future<void> _changeServices(WidgetTester tester, OnpcTestUtils tu, List<Pair<String, bool>> items) async {
  await tu.openSettings(tester, "Network services");
  for (int i = 0; i < items.length; i++) {
    final Pair<String, bool> item = items[i];
    await tu.changeReorderableItem(tester, item.item1, state: item.item2);
    await tu.dragReorderableItem(tester, item.item1, Offset(0, item.item2 ? -600 : 600));
  }
  await tu.previousScreen(tester);
  await tu.previousScreen(tester);
}

Future<void> _changeInputs(WidgetTester tester, OnpcTestUtils tu, List<Pair<String, String>> items) async {
  await tu.openSettings(tester, "Input selectors");
  for (int i = 0; i < items.length; i++) {
    final Pair<String, String> item = items[i];
    if (item.item2.isEmpty) {
      await tu.changeReorderableItem(tester, item.item1);
      await tu.dragReorderableItem(tester, item.item1, Offset(0, 600));
    } else {
      await tu.contextMenu(tester, item.item1, "Edit", ensureAfter: () => find.text("CANCEL"));
      await tu.setText(tester, 1, 0, item.item2);
      await tu.findAndTap(tester, "Close edit dialog", () => find.text("OK"));
    }
  }
  await tu.previousScreen(tester);
  await tu.previousScreen(tester);
}

Future<void> _changeListeningModes(WidgetTester tester, OnpcTestUtils tu, List<Pair<String, bool>> items) async {
  await tu.openSettings(tester, "Listening modes");
  for (int i = 0; i < items.length; i++) {
    final Pair<String, bool> item = items[i];
    await tester.ensureVisible(find.text(item.item1));
    await tu.changeReorderableItem(tester, item.item1, state: item.item2);
    if (item.item2) {
      await tu.dragReorderableItem(tester, item.item1, Offset(0, -600));
    }
  }
  await tu.previousScreen(tester);
  await tu.previousScreen(tester);
}

Future<void> _changeListenLayout(final OnpcTestUtils tu, WidgetTester tester) async {
  final String s = "File information";
  await tu.openDrawerMenu(tester, "Tab layout", ensureAfter: () => find.text(s));
  await tu.dragReorderableItem(tester, s, Offset(0, -600));
  await tu.previousScreen(tester);
}

Future<void> _buildOnkyoFavourites(final OnpcTestUtils tu, WidgetTester tester,
    {bool dlna = false, bool deezer = false, bool tuneIn = false, bool usbMusic = false, bool radio = false}) async {
  final DRAG_OFFSET_UP = Offset(0, 300);
  final Pair<String, String> FAVOURITES = Pair<String, String>("The Dancer", "Deezer Favourites");

  await tu.openTab(tester, "MEDIA");
  await tu.findAndTap(tester, "Select NET", () => find.text("NET"), ensureAfter: () => find.text("Music Server (DLNA)"));

  if (dlna) {
    await tu
        .navigateToMedia(tester, [OnpcTestUtils.TOP_LAYER, "Music Server (DLNA)", "Supermicro DLNA Server", "Music"]);
    await tu.contextMenu(tester, "Artist", "Create shortcut", waitFor: true);
  }

  if (deezer) {
    final Pair<String, String> FLOW = Pair<String, String>("Flow", "Deezer Flow");
    final Pair<String, String> PLAYLIST = Pair<String, String>("Personal Jesus / Depeche Mode", "Deezer Playlist");
    await tu.navigateToMedia(tester, [OnpcTestUtils.TOP_LAYER, "Deezer", "My Music", "My Music | items: 6"]);
    await tu.contextMenu(tester, FLOW.item1, "Create shortcut", waitFor: true);
    await tu.navigateToMedia(tester, ["My Music", "Favourite tracks"], ensureAfter: () => find.text(FAVOURITES.item1));
    await tu.contextMenu(tester, FAVOURITES.item1, "Create shortcut");
    await tu.ensureVisibleInList(
        tester, "Ensure return", find.byType(ListView), () => find.text("Return"), DRAG_OFFSET_UP);
    await tu.navigateToMedia(tester, ["Return", "My Playlists", "Onkyo playlist"], ensureAfter: () => find.text("Forever / Y&T"));
    await tu.contextMenu(tester, PLAYLIST.item1, "Create shortcut", waitFor: true);
    await _renameShortcuts(tu, tester, [FLOW, FAVOURITES, PLAYLIST]);
  }

  if (tuneIn) {
    await tu.openTab(tester, "MEDIA");
    await tu.navigateToMedia(tester, [OnpcTestUtils.TOP_LAYER, "TuneIn Radio", "My Presets"]);
    await tu.contextMenu(tester, "Absolut relax (Easy Listening)", "Create shortcut", waitFor: true);
    await tu.contextMenu(tester, "PureRock.US (Metal)", "Create shortcut", waitFor: true);
  }

  if (usbMusic) {
    await tu.openTab(tester, "MEDIA");
    await tu.navigateToMedia(tester, ["USB Disk", OnpcTestUtils.TOP_LAYER, "onkyo_music"]);
    await tu.contextMenu(tester, "Disco", "Create shortcut", waitFor: true);
    await tu.contextMenu(tester, "Power Metall", "Create shortcut", waitFor: true);
    await tu.contextMenu(tester, "Rock", "Create shortcut", waitFor: true);
    await tu.ensureVisibleInList(
        tester, "Ensure Русский рок", find.byType(ListView), () => find.text("Русский рок"), OnpcTestUtils.LIST_DRAG_OFFSET);
    await tu.contextMenu(tester, "Русский рок", "Create shortcut", waitFor: true);
  }

  if (radio) {
    final Pair<String, String> DAB = Pair<String, String>("Playback mode", "DAB");
    final Pair<String, String> FM = Pair<String, String>("2 - ENERGY - 89.80 MHz", "ENERGY");
    await tu.openTab(tester, "MEDIA");
    await tu.findAndTap(tester, "Select DAB", () => find.text("DAB"), ensureAfter: () => find.text(DAB.item1));
    await tu.contextMenu(tester, DAB.item1, "Create shortcut", waitFor: true);
    await tu.findAndTap(tester, "Select FM", () => find.text("FM"), ensureAfter: () => find.text(FM.item1));
    await tu.contextMenu(tester, FM.item1, "Create shortcut", waitFor: true);
    await tu.openTab(tester, "SHORTCUTS");
    await _renameShortcuts(tu, tester, [DAB, FM]);
  }

  await tu.findAndTap(tester, "Start Deezer", () => find.text(FAVOURITES.item2), delay: OnpcTestUtils.NORMAL_DELAY);
}

Future<void> _renameShortcuts(OnpcTestUtils tu, WidgetTester tester, final List<Pair<String, String>> items) async {
  await tu.openTab(tester, "SHORTCUTS");
  for (int i = 0; i < items.length; i++) {
    await tu.contextMenu(tester, items[i].item1, "Edit", ensureAfter: () => find.text("CANCEL"));
    await tu.setText(tester, 1, 0, items[i].item2);
    await tu.findAndTap(tester, "Close edit dialog", () => find.text("OK"));
  }
}

Future<void> _addRiDevices(OnpcTestUtils tu, WidgetTester tester) async {
  final String TD = "Tape Deck (RI)";
  final String MD = "MD Player (RI)";
  await tu.openTab(tester, "RI", swipeRight: true);

  // Tab layout
  await tu.openDrawerMenu(tester, "Tab layout", ensureAfter: () => find.text("Divider"));
  await tu.changeReorderableItem(tester, "Divider");
  await tu.ensureVisibleInList(
      tester, "Ensure " + TD, find.byType(ReorderableListView), () => find.text(TD), OnpcTestUtils.LIST_DRAG_OFFSET);
  await tester.drag(find.text(MD), OnpcTestUtils.LIST_DRAG_OFFSET, warnIfMissed: false);
  await tu.stepDelayMs(tester);
  await tu.changeReorderableItem(tester, MD, state: true);
  await tu.changeReorderableItem(tester, TD, state: true);
  await tu.previousScreen(tester);
}

Future<void> _renameZone(OnpcTestUtils tu, WidgetTester tester, int zone, String newName) async{
  await tu.openDrawer(tester);
  await tu.findAndTap(tester, "Search Edit Button", () => find.byTooltip("Edit"), num: 2, idx: zone);
  expect(find.text("Edit"), findsOneWidget);
  await tu.setText(tester, 1, 0, newName);
  await tu.findAndTap(tester, "Close Rename dialog", () => find.text("OK"));
  await tu.previousScreen(tester);
  await tu.openDrawerMenu(tester, newName, ensureAfter: () => find.textContaining("Denon AVR/" + newName));
}
