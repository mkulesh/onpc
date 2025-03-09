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

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:onpc/main.dart' as app;
import 'package:onpc/utils/Logging.dart';
import 'package:onpc/utils/Pair.dart';
import 'package:onpc/utils/Platform.dart';

import 'onpc_test_utils.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Initial configuration of the app', (tester) async {
    final OnpcTestUtils tu = OnpcTestUtils(tester);

    app.main();
    await tu.stepDelayMs();
    if (find.text("Search").evaluate().isNotEmpty) {
      // Device search is opened
      expect(find.text("Not connected"), findsOneWidget);
      await tu.findAndTap("Connect to Onkyo Player", () => find.text("192.168.1.80:60128"), waitFor: true);
    }

    await _aboutScreen(tu);
    await _changeAppSettings(tu);
    await _changeListenLayout(tu);
    await _setupDenon(tu);
    await _setupOnkyoBox(tu);
    await _setupOnkyoPlayer(tu);

    // Write log
    await tu.writeLog("auto-test-setup");
  });
}

Future<void> _setupDenon(OnpcTestUtils tu) async {
  await _saveConnection(tu, "My Denon AVR", "192.168.1.82", isDCP: true);
  await _changeInputs(tu, [
    Pair("HEOS MUSIC", "NET"),
    Pair("BLUETOOTH", "BT"),
    Pair("DVD", ""),
    Pair("Blu-ray", ""),
    Pair("TV Audio", "PC"),
    Pair("Onkyo", "ONKYO"),
    Pair("Media Player", ""),
    Pair("Game", ""),
    Pair("DRS610", "TAPE"),
    Pair("Phono", ""),
  ]);
  await _changeServices(tu, [
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
  await _changeListeningModes(tu, [
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
  await tu.openTab("SHORTCUTS");
  if (find.text("Deezer Flow").evaluate().isEmpty) {
    await _buildDenonFavourites(tu,
        dlna: true, deezer: true, tuneIn: true, usbMusic: true, favorite: true, radio: true);
  }
  await _renameZone(tu, 1, "To Onkyo");
}

Future<void> _setupOnkyoBox(OnpcTestUtils tu) async {
  await _saveConnection(tu, "My Onkyo Box", "192.168.1.81");
  await _changeServices(tu, [
    Pair("Deezer", true),
    Pair("Music Server (DLNA)", true),
    Pair("Spotify", false),
    Pair("Tidal", false),
    Pair("Amazon Music", false),
  ]);
  await _changeListeningModes(tu, [
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

Future<void> _setupOnkyoPlayer(OnpcTestUtils tu) async {
  await _saveConnection(tu, "My Onkyo Player", "192.168.1.80");
  if (find.text("Onkyo Player (Standby)").evaluate().isNotEmpty) {
    // Player is off - call power on
    await tu.findAndTap("Power-off", () => find.byTooltip("On/Standby"));
  }
  await _changeInputs(tu, [Pair("USB(R)", "USB Disk"), Pair("USB(F)", "")]);
  await _changeServices(tu, [
    Pair("Deezer", true),
    Pair("Music Server (DLNA)", true),
    Pair("Spotify", false),
    Pair("Tidal", false),
    Pair("Amazon Music", false),
  ]);
  await _changeListeningModes(tu, [
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
  await tu.openTab("SHORTCUTS");
  if (find.text("Deezer Flow").evaluate().isEmpty) {
    await _buildOnkyoFavourites(tu, dlna: true, deezer: true, tuneIn: true, usbMusic: true, radio: true);
  }
  if (Platform.isDesktop) {
    await _addRiDevices(tu);
  }
}

Future<void> _saveConnection(final OnpcTestUtils tu, String name, String address, {bool isDCP = false}) async {
  await tu.openDrawerMenu("Connect", ensureAfter: () => find.text("Onkyo/Pioneer/Integra"));
  expect(find.text("Connect"), findsOneWidget);
  expect(find.text("Denon/Marantz"), findsOneWidget);
  expect(find.text("Address"), findsOneWidget);
  expect(find.text("Port (optional)"), findsOneWidget);
  await tu.setText(3, 0, address);
  final Finder fab = find.byWidgetPredicate((widget) => widget is Radio);
  expect(fab, findsNWidgets(2));
  await tu.findAndTap("Set protocol", () => fab.at(isDCP ? 1 : 0));
  await tu.findAndTap("Save connection", () => find.text("Save connection"));
  await tu.setText(3, 2, name);
  await tu.findAndTap("Close connect dialog", () => find.text("OK"), delay: OnpcTestUtils.LONG_DELAY);
  Logging.logSize = 5000; // After reconnect, increase log size
}

Future<void> _aboutScreen(OnpcTestUtils tu) async {
  await tu.openDrawerMenu("About", ensureAfter: () => find.byType(Markdown));
  await tu.previousScreen();
}

Future<void> _changeAppSettings(final OnpcTestUtils tu) async {
  await tu.openDrawerMenu("Settings", ensureAfter: () => find.text("Theme"));

  await _changeParameter(tu, "Theme", "Light (Purple and Green)");
  await _changeParameter(tu, "App language", "English");
  await _changeParameter(tu, "Text and buttons size", Platform.isIOS ? "Big" : "Small");

  // Audio control
  await _changeParameter(tu, "Sound control", "Automatic");
  await _changeParameter(tu, "Master volume unit", "Relative (dB)", pressOk: true);

  // RI-USB
  if (Platform.isDesktop) {
    final String USB_RI = Platform.isWindows ? "USB Serial Port" : "OnkioRI FT231X";
    await _changeParameter(tu, "Use USB-RI interface", USB_RI);
  }

  await _changeParameter(tu, "Album's cover click behaviour", "Audio muting");

  await tu.previousScreen();
}

Future<void> _changeParameter(OnpcTestUtils tu, String PARAM_NAME, String PARAM_VALUE, {bool pressOk = false}) async {
  await tu.tester.dragUntilVisible(find.text(PARAM_NAME), find.byType(ListView), OnpcTestUtils.LIST_DRAG_OFFSET);
  if (find.textContaining(PARAM_VALUE).evaluate().isEmpty) {
    await tu.findAndTap("Change " + PARAM_NAME + "1", () => find.text(PARAM_NAME),
        ensureAfter: () => find.textContaining(PARAM_VALUE));
    await tu.findAndTap("Change " + PARAM_NAME + "2", () => find.textContaining(PARAM_VALUE));
    if (pressOk) {
      await tu.findAndTap("Change " + PARAM_NAME + "3", () => find.text("OK"));
    }
    await tu.stepDelayMs();
    expect(find.textContaining(PARAM_VALUE), findsOneWidget);
  }
}

Future<void> _changeServices(OnpcTestUtils tu, List<Pair<String, bool>> items) async {
  await tu.openSettings("Network services");
  for (int i = 0; i < items.length; i++) {
    final Pair<String, bool> item = items[i];
    await tu.changeReorderableItem(item.item1, state: item.item2);
    await tu.dragReorderableItem(item.item1, Offset(0, item.item2 ? -600 : 600));
  }
  await tu.previousScreen();
  await tu.previousScreen();
}

Future<void> _changeInputs(OnpcTestUtils tu, List<Pair<String, String>> items) async {
  await tu.openSettings("Input selectors");
  for (int i = 0; i < items.length; i++) {
    final Pair<String, String> item = items[i];
    if (item.item2.isEmpty) {
      await tu.changeReorderableItem(item.item1);
      await tu.dragReorderableItem(item.item1, Offset(0, 600));
    } else {
      await tu.contextMenu(item.item1, "Edit", ensureAfter: () => find.text("CANCEL"));
      await tu.setText(1, 0, item.item2);
      await tu.findAndTap("Close edit dialog", () => find.text("OK"));
    }
  }
  await tu.previousScreen();
  await tu.previousScreen();
}

Future<void> _changeListeningModes(OnpcTestUtils tu, List<Pair<String, bool>> items) async {
  await tu.openSettings("Listening modes");
  for (int i = 0; i < items.length; i++) {
    final Pair<String, bool> item = items[i];
    await tu.tester.ensureVisible(find.text(item.item1));
    await tu.changeReorderableItem(item.item1, state: item.item2);
    if (item.item2) {
      await tu.dragReorderableItem(item.item1, Offset(0, -600));
    }
  }
  await tu.previousScreen();
  await tu.previousScreen();
}

Future<void> _changeListenLayout(final OnpcTestUtils tu) async {
  final String s = "File information";
  await tu.openDrawerMenu("Tab layout", ensureAfter: () => find.text(s));
  await tu.dragReorderableItem(s, Offset(0, -600));
  await tu.previousScreen();
}

Future<void> _buildOnkyoFavourites(final OnpcTestUtils tu,
    {bool dlna = false, bool deezer = false, bool tuneIn = false, bool usbMusic = false, bool radio = false}) async {
  final DRAG_OFFSET_UP = Offset(0, 300);
  final Pair<String, String> FAVOURITES = Pair<String, String>("The Dancer", "Deezer Favourites");

  await tu.openTab("MEDIA");

  if (dlna) {
    await tu.findAndTap("Select NET", () => find.text("NET"), delay: OnpcTestUtils.NORMAL_DELAY);
    await tu.navigateToMedia([OnpcTestUtils.TOP_LAYER, "Music Server (DLNA)", "Kontron DLNA Server", "Music"]);
    await tu.contextMenu("Artist", "Create shortcut", waitFor: true);
  }

  if (deezer) {
    final Pair<String, String> FLOW = Pair<String, String>("Flow", "Deezer Flow");
    final Pair<String, String> PLAYLIST = Pair<String, String>("Personal Jesus / Depeche Mode", "Deezer Playlist");
    await tu.findAndTap("Select NET", () => find.text("NET"), delay: OnpcTestUtils.NORMAL_DELAY);
    await tu.navigateToMedia([OnpcTestUtils.TOP_LAYER, "Deezer"]);
    await tu.stepDelaySec(OnpcTestUtils.NORMAL_DELAY);
    await tu.navigateToMedia([OnpcTestUtils.TOP_LAYER, "Deezer", "My Music", "My Music | items: 6"]);
    await tu.contextMenu(FLOW.item1, "Create shortcut", waitFor: true);
    await tu.navigateToMedia(["My Music", "Favourite tracks"], ensureAfter: () => find.text("Lady In Black"));
    await tu.contextMenu(FAVOURITES.item1, "Create shortcut");
    await tu.ensureVisibleInList("Ensure return", find.byType(ListView), () => find.text("Return"), DRAG_OFFSET_UP);
    await tu
        .navigateToMedia(["Return", "My Playlists", "Onkyo playlist"], ensureAfter: () => find.text("Forever / Y&T"));
    await tu.contextMenu(PLAYLIST.item1, "Create shortcut", waitFor: true);
    await _renameShortcuts(tu, [
      FLOW,
      FAVOURITES,
      PLAYLIST
    ], [
      "NET/Deezer/Flow",
      "NET/Deezer/My Music/Favourite tracks/The Dancer",
      "NET/Deezer/My Music/My Playlists/Onkyo playlist/Personal Jesus / Depeche Mode"
    ], false);
  }

  if (tuneIn) {
    await tu.openTab("MEDIA");
    await tu.findAndTap("Select NET", () => find.text("NET"), delay: OnpcTestUtils.NORMAL_DELAY);
    await tu.navigateToMedia([OnpcTestUtils.TOP_LAYER, "TuneIn Radio", "My Presets"]);
    await tu.contextMenu("Absolute Classic Hits (Classic Hits)", "Create shortcut", waitFor: true);
    await tu.contextMenu("PureRock.US (Metal)", "Create shortcut", waitFor: true);
  }

  if (usbMusic) {
    await tu.openTab("MEDIA");
    await tu.findAndTap("Select USB Disk", () => find.text("USB Disk"), delay: OnpcTestUtils.NORMAL_DELAY);
    await tu.navigateToMedia([OnpcTestUtils.TOP_LAYER, "onkyo_music"]);
    await tu.contextMenu("Disco", "Create shortcut", waitFor: true);
    await tu.contextMenu("Power Metall", "Create shortcut", waitFor: true);
    await tu.contextMenu("Rock", "Create shortcut", waitFor: true);
    await tu.ensureVisibleInList(
        "Ensure Эстрада", find.byType(ListView), () => find.text("Эстрада"), OnpcTestUtils.LIST_DRAG_OFFSET);
    await tu.contextMenu("Русский рок", "Create shortcut", waitFor: true);
  }

  if (radio) {
    final Pair<String, String> DAB = Pair<String, String>("Playback mode", "DAB");
    final Pair<String, String> FM = Pair<String, String>("2 - ENERGY - 89.80 MHz", "ENERGY");
    await tu.openTab("MEDIA");
    await tu.findAndTap("Select DAB", () => find.text("DAB"), ensureAfter: () => find.text(DAB.item1));
    await tu.contextMenu(DAB.item1, "Create shortcut", waitFor: true);
    await tu.findAndTap("Select FM", () => find.text("FM"), ensureAfter: () => find.text(FM.item1));
    await tu.contextMenu(FM.item1, "Create shortcut", waitFor: true);
    await tu.openTab("SHORTCUTS");
    await _renameShortcuts(tu, [DAB, FM], [], false);
  }

  await tu.findAndTap("Start Deezer", () => find.text(FAVOURITES.item2), delay: OnpcTestUtils.NORMAL_DELAY);
}

Future<void> _buildDenonFavourites(OnpcTestUtils tu,
    {required bool dlna,
    required bool deezer,
    required bool tuneIn,
    required bool usbMusic,
    required bool favorite,
    required bool radio}) async {
  final DRAG_OFFSET_UP = Offset(0, 300);
  await tu.openTab("MEDIA");
  await tu.findAndTap("Select NET", () => find.text("NET"));

  if (dlna) {
    await tu.openTab("MEDIA");
    final Pair<String, String> ARTISTS = Pair<String, String>("Artist", "Artists on DLNA");
    await tu.navigateToMedia([OnpcTestUtils.TOP_LAYER, "Local Music", "Kontron DLNA Server", "Music"],
        ensureVisible: true);
    await tu.contextMenu(ARTISTS.item1, "Create shortcut", waitFor: true);
    final Pair<String, String> MUSE = Pair<String, String>("- All Albums -", "Muse on DLNA");
    await tu.navigateToMedia(
        [OnpcTestUtils.TOP_LAYER, "Local Music", "Kontron DLNA Server", "Music", "Artist", "Muse<S>Mylene Farmer"],
        ensureVisible: true);
    await tu.contextMenu(MUSE.item1, "Create shortcut", waitFor: true);
    await _renameShortcuts(tu, [
      ARTISTS,
      MUSE
    ], [
      "NET/Local Music/Kontron DLNA Server/Music/Artist",
      "NET/Local Music/Kontron DLNA Server/Music/Artist/Muse/- All Albums -"
    ], true);
  }

  if (deezer) {
    await tu.openTab("MEDIA");
    final Pair<String, String> PLAYLIST = Pair<String, String>("Onkyo playlist", "Deezer Playlist");
    final Pair<String, String> FAVOURITES = Pair<String, String>("Favourite tracks", "Deezer Favourites");
    final Pair<String, String> ROCK_STATION = Pair<String, String>("Rock classics", "Deezer Classic Rock");
    await tu.navigateToMedia([OnpcTestUtils.TOP_LAYER, "Deezer", "My Playlists"]);
    await tu.contextMenu(PLAYLIST.item1, "Create shortcut", waitFor: true);
    await tu.contextMenu(FAVOURITES.item1, "Create shortcut", waitFor: true);
    await tu.navigateToMedia(["Return", "Radio Channels", "Rock<S>Soul & Funk"],
        ensureVisible: true, ensureAfter: () => find.text(ROCK_STATION.item1));
    await tu.contextMenu(ROCK_STATION.item1, "Create shortcut", waitFor: true);
    await _renameShortcuts(tu, [
      PLAYLIST,
      FAVOURITES,
      ROCK_STATION
    ], [
      "NET/Deezer/My Playlists/Onkyo playlist",
      "NET/Deezer/My Playlists/Favourite tracks",
      "NET/Deezer/Radio Channels/Rock/Rock classics"
    ], true);
  }

  if (tuneIn) {
    await tu.openTab("MEDIA");
    await tu.navigateToMedia([OnpcTestUtils.TOP_LAYER, "TuneIn Radio", "Favorites"]);
    await tu.contextMenu("Absolute Classic Hits (Classic Hits)", "Create shortcut", waitFor: true);
  }

  if (usbMusic) {
    final String DENON_AVR = "Denon AVR";
    await tu.openTab("MEDIA");
    await tu.navigateToMedia([OnpcTestUtils.TOP_LAYER, "Local Music"]);
    await tu.findAndTap("Navigate to: " + DENON_AVR, () => find.widgetWithText(ListTile, DENON_AVR));
    await tu.navigateToMedia(["Genres"]);
    await tu.contextMenu("Disco", "Create shortcut", waitFor: true);
    await tu.contextMenu("Power Metall", "Create shortcut", waitFor: true);
    await tu.contextMenu("Rock", "Create shortcut", waitFor: true);
    await tu.ensureVisibleInList(
        "Ensure Русский рок", find.byType(ListView), () => find.text("Сборники"), OnpcTestUtils.LIST_DRAG_OFFSET);
    await tu.contextMenu("Русский рок", "Create shortcut", waitFor: true);
  }

  if (favorite) {
    await tu.openTab("MEDIA");
    await tu.navigateToMedia([OnpcTestUtils.TOP_LAYER, "Favorite"]);
    await tu.contextMenu("Flow", "Create shortcut");
    await tu.contextMenu("Hard Rock", "Create shortcut");
    await tu.contextMenu("PureRock.US (Metal)", "Create shortcut");
  }

  if (radio) {
    final Pair<String, String> DAB = Pair<String, String>("17 - BOB!", "BOB! on DAB");
    final Pair<String, String> FM = Pair<String, String>("2 - 89.80 MHz", "ENERGY on FM");
    await tu.openTab("MEDIA");
    await tu.findAndTap("Select TUNER", () => find.text("TUNER"));
    await tu.ensureVisibleInList("Ensure return", find.byType(ListView), () => find.text("DAB"), DRAG_OFFSET_UP);
    await tu.findAndTap("Select DAB", () => find.text("DAB"));
    await tu.contextMenu(DAB.item1, "Create shortcut", waitFor: true);
    await tu.findAndTap("Select FM", () => find.text("FM"));
    await tu.contextMenu(FM.item1, "Create shortcut", waitFor: true);
    await tu.openTab("SHORTCUTS");
    await _renameShortcuts(tu, [DAB, FM], [], true);
  }

  await tu.findAndTap("Start Deezer", () => find.text("Flow"), delay: OnpcTestUtils.NORMAL_DELAY);
}

Future<void> _renameShortcuts(OnpcTestUtils tu, final List<Pair<String, String>> items, final List<String> path, final listeningMode) async {
  await tu.openTab("SHORTCUTS");
  if (path.isNotEmpty) {
    assert(items.length == path.length);
  }
  for (int i = 0; i < items.length; i++) {
    await tu.ensureVisibleInList("Ensure " + items[i].item1, find.byType(ReorderableListView),
        () => find.text(items[i].item1), OnpcTestUtils.LIST_DRAG_OFFSET);
    await tu.contextMenu(items[i].item1, "Edit",
        ensureAfter: () => find.text("CANCEL"), checkItems: ["Edit shortcut", "Edit", "Delete", "Copy to clipboard"]);
    if (path.isNotEmpty) {
      expect(find.text(path[i]), findsOneWidget);
    }
    expect(find.text("Apply listening mode"), listeningMode ? findsOneWidget : findsNothing);
    await tu.setText(1, 0, items[i].item2);
    await tu.findAndTap("Close edit dialog", () => find.text("OK"));
  }
}

Future<void> _addRiDevices(OnpcTestUtils tu) async {
  final String TD = "Tape Deck (RI)";
  final String MD = "MD Player (RI)";
  await tu.openTab("RI", swipeRight: true);

  // Tab layout
  await tu.openDrawerMenu("Tab layout", ensureAfter: () => find.text("Divider"));
  await tu.changeReorderableItem("Divider");
  await tu.ensureVisibleInList(
      "Ensure " + TD, find.byType(ReorderableListView), () => find.text(TD), OnpcTestUtils.LIST_DRAG_OFFSET);
  await tu.tester.drag(find.text(MD), OnpcTestUtils.LIST_DRAG_OFFSET, warnIfMissed: false);
  await tu.stepDelayMs();
  await tu.changeReorderableItem(MD, state: true);
  await tu.changeReorderableItem(TD, state: true);
  await tu.previousScreen();
}

Future<void> _renameZone(OnpcTestUtils tu, int zone, String newName) async {
  await tu.openDrawer();
  await tu.findAndTap("Search Edit Button", () => find.byTooltip("Edit"), num: 2, idx: zone);
  expect(find.text("Edit"), findsOneWidget);
  await tu.setText(1, 0, newName);
  await tu.findAndTap("Close Rename dialog", () => find.text("OK"));
  await tu.previousScreen();
  await tu.openDrawerMenu(newName, ensureAfter: () => find.textContaining("Denon AVR/" + newName));
}
