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
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:onpc/main.dart' as app;
import 'package:onpc/utils/Logging.dart';
import 'package:onpc/utils/Pair.dart';

import 'onpc_test_utils.dart';

final String DENON_AVR = "Denon AVR";
final String FRIENDLY_NAME = "My Denon AVR";

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Automatic test of ' + FRIENDLY_NAME, (tester) async {
    final OnpcTestUtils tu = OnpcTestUtils(tester);

    app.main();
    await tu.connect(FRIENDLY_NAME, DENON_AVR);

    await _playFromUsb(tu);
    await _playFromQueue(tu);
    await _playFromDeezer(tu);
    await _playFromDAB(tu);
    await _changeListeningModes(tu);
    await _changeDeviceSettings(tu);

    // Power-off
    await tu.findAndTap("Power-off", () => find.byTooltip("On/Standby"));

    // Write log
    await tu.writeLog("auto-test-denon");
  });
}

Future<void> _playFromUsb(final OnpcTestUtils tu) async {
  await tu.openTab("MEDIA", ensureAfter: () => find.text("NET"));

  // Navigate to USB
  await tu.findAndTap("Select NET", () => find.text("NET"));
  await tu.navigateToMedia([OnpcTestUtils.TOP_LAYER, "Local Music"]);
  await tu.findAndTap("Navigate to: " + DENON_AVR, () => find.widgetWithText(ListTile, DENON_AVR),
      ensureAfter: () => find.byTooltip("Search"));

  // Search Accept
  final String artist1 = "Accept";
  await _openSearchDialog(tu, 0, artist1);

  // Add first albums to the queue
  final String album1 = "Metal Heart";
  await tu.findAndTap("Select " + artist1, () => find.widgetWithText(ListTile, artist1),
      ensureAfter: () => find.widgetWithText(ListTile, album1));
  await tu.contextMenu(album1, "Replace and play",
      checkItems: ["Play queue", "Replace and play", "Add", "Add and play", "Create shortcut"]);

  // Search and add second album to the queue
  final String artist2 = "Muse";
  final String album2 = "Absolution";
  await _openSearchDialog(tu, 1, album2);
  expect(find.text(artist1), findsNothing);
  expect(find.text(album1), findsNothing);
  await tu.contextMenu(album2, "Add");

  // Inspect queue
  await tu.findAndTap("Top Menu", () => find.byTooltip("Top Menu"), ensureAfter: () => find.text("Play Queue"));
  await tu.findAndTap("Open Play Queue", () => find.text("Play Queue"),
      ensureAfter: () => find.textContaining("Play Queue | items: 27"));

  // Inspect playing
  await tu.openTab("LISTEN", ensureAfter: () => find.text(artist1));
  expect(find.byTooltip("Play Queue"), findsOneWidget);
  expect(find.text(album1), findsExactly(2));

  // Play mode
  await tu.findAndTap("Random", () => find.byTooltip("Random"), delay: OnpcTestUtils.NORMAL_DELAY);
  await tu.findAndTap("Repeat", () => find.byTooltip("Repeat"), delay: OnpcTestUtils.NORMAL_DELAY);
  await tu.findAndTap("Repeat", () => find.byTooltip("Repeat"), delay: OnpcTestUtils.NORMAL_DELAY);
  await tu.findAndTap("Repeat", () => find.byTooltip("Repeat"), delay: OnpcTestUtils.NORMAL_DELAY);
  await tu.findAndTap("Random", () => find.byTooltip("Random"), delay: OnpcTestUtils.NORMAL_DELAY);

  // Next track
  await tu.findAndTap("Next track", () => find.byTooltip("Track Up"), ensureAfter: () => find.text("Midnight Mover"));
  expect(find.text(artist1), findsOneWidget);
  expect(find.text(album1), findsOneWidget);

  // Pause
  await tu.ensureVisible(() => find.byTooltip("Pause"));
  await tu.findAndTap("Pause", () => find.byTooltip("Pause"), ensureAfter: () => find.byTooltip("Play"));
  expect(find.byTooltip("Pause"), findsNothing);
  await tu.findAndTap("Play", () => find.byTooltip("Play"));

  // Stop
  await tu.findAndTap("Stop playback", () => find.byTooltip("Stop"));

  // Start from play queue
  await tu.findAndTap("Open queue", () => find.byTooltip("Play Queue"),
      ensureAfter: () => find.textContaining("Play Queue | items: 27"));
  await tu.ensureVisibleInList("Ensure " + artist2, find.byType(ReorderableListView),
      () => find.text("Muse - Endlessly"), OnpcTestUtils.LIST_DRAG_OFFSET);
  await tu.findAndTap("Start " + artist2, () => find.text("Muse - Fury"));
  await tu.openTab("LISTEN", ensureAfter: () => find.text(artist2));
  expect(find.text("Fury"), findsOneWidget);
  expect(find.text(album2), findsOneWidget);
}

Future<void> _playFromQueue(OnpcTestUtils tu) async {
  await tu.openTab("MEDIA", ensureAfter: () => find.text("NET"));

  // Navigate to play queue
  await tu.findAndTap("Select NET", () => find.text("NET"));
  await tu.navigateToMedia([OnpcTestUtils.TOP_LAYER, "Play Queue"]);
  expect(find.text("Play Queue | items: 27"), findsOneWidget);

  // Get initial list
  List<Pair<String, String>> list = tu.getListContent();
  Logging.info(tu, "Initial list: " + list.toString());

  // Start playing first item
  final String toPlay = "Accept - Metal Heart";
  assert(list.elementAt(1).item1.contains("media_item_music.svg"));
  assert(list.elementAt(1).item2 == toPlay);
  await tu.findAndTap("Start " + toPlay, () => find.text(list.elementAt(1).item2));
  await tu.waitMediaItemPlaying(toPlay);

  // Reorder list
  final String toReorder = "Accept - Too High To Get It Right";
  await tu.dragReorderableItem(toReorder, Offset(0, -600), dragIndex: 2);
  await tu.stepDelaySec(OnpcTestUtils.NORMAL_DELAY);
  list = tu.getListContent();
  assert(list.elementAt(1).item1.contains("media_item_music.svg"));
  assert(list.elementAt(1).item2 == toReorder);

  // Remove item
  final String toDelete = "Accept - Up To The Limit";
  expect(find.text(toDelete), findsOneWidget);
  await tu.contextMenu(toDelete, "Remove item",
      checkItems: ["Play queue", "Remove item", "Remove all", "Create shortcut"],
      ensureAfter: () => find.text("Play Queue | items: 26"));
  await tu.stepDelaySec(OnpcTestUtils.NORMAL_DELAY);
  expect(find.text(toDelete), findsNothing);

  // Remove all
  final String toDeleteAll = "Accept - Dogs On Leads";
  expect(find.text(toDeleteAll), findsOneWidget);
  await tu.contextMenu(toDeleteAll, "Remove all",
      checkItems: ["Play queue", "Remove item", "Remove all", "Create shortcut"],
      ensureAfter: () => find.text("Play Queue | items: 0"));
  await tu.stepDelaySec(OnpcTestUtils.NORMAL_DELAY);

  await tu.findAndTap("Return to top layer", () => find.text("Return"),
      ensureAfter: () => find.textContaining("HEOS MUSIC | items:"));
}

Future<void> _playFromDeezer(OnpcTestUtils tu) async {
  final String shortcut = "Flow";

  // Start playing
  await tu.openTab("SHORTCUTS", ensureAfter: () => find.text(shortcut));
  await tu.findAndTap("Start " + shortcut, () => find.text(shortcut),
      ensureAfter: () => find.textContaining("Favorite | items:"));
  expect(find.text(shortcut), findsOneWidget);

  // Remove from HEOS
  await tu.contextMenu(shortcut, "Remove from HEOS Favorites", checkItems: [
    "Play queue",
    "Replace and play",
    "Add",
    "Add and play",
    "Remove from HEOS Favorites",
    "Create shortcut"
  ]);
  await tu.ensureDeleted(() => find.text(shortcut));
  expect(find.text(shortcut), findsNothing);

  // Add to HEOS again
  await tu.navigateToMedia([OnpcTestUtils.TOP_LAYER, "Deezer", "Flow"]);
  await tu.ensureVisible(() => find.text("Flow | items: 1"));
  await tu.contextMenu(shortcut, "Add to HEOS Favorites", checkItems: [
    "Play queue",
    "Replace and play",
    "Add",
    "Add and play",
    "Add to HEOS Favorites",
    "Create shortcut"
  ]);

  // Check that item is added
  await tu.navigateToMedia([OnpcTestUtils.TOP_LAYER, "Favorite"]);
  expect(find.text(shortcut), findsOneWidget);
}

Future<void> _playFromDAB(final OnpcTestUtils tu) async {
  final String shortcut = "BOB! on DAB";

  // Start playing
  await tu.openTab("SHORTCUTS", ensureAfter: () => find.text(shortcut));
  await tu.findAndTap("Start " + shortcut, () => find.text(shortcut), ensureAfter: () => find.text("17 - BOB!"));
  await tu.waitMediaItemPlaying("BOB!");
  expect(find.text("TUNER"), findsOneWidget);

  // Check station data
  await tu.openTab("LISTEN", ensureAfter: () => find.text("STEREO"));
  expect(find.byTooltip("Sets tuning frequency wrap-around up"), findsOneWidget);
  expect(find.byTooltip("Sets tuning frequency wrap-around down"), findsOneWidget);
  expect(find.byTooltip("Sets preset wrap-around up"), findsOneWidget);
  expect(find.byTooltip("Sets preset wrap-around down"), findsOneWidget);
  await tu.ensureVisible(() => find.text("5C:178.352MHz"));
  expect(find.text("BOB!"), findsOneWidget);
  expect(find.text("RADIO BOB!"), findsOneWidget);

  // Change station by preset
  await tu.findAndTap("Next preset", () => find.byTooltip("Sets preset wrap-around up"),
      ensureAfter: () => find.text("6A:181.936MHz"));
  expect(find.text("ROLAND"), findsOneWidget);
  expect(find.text("RADIO ROLAND"), findsOneWidget);

  // Seek station
  await tu.findAndTap("Next station", () => find.byTooltip("Sets tuning frequency wrap-around up"),
      ensureAfter: () => find.text("5D:180.064MHz"));
  expect(find.text("ROCK ANTENNE"), findsOneWidget);

  // Change station by list
  final String station = "OldieAnt";
  await tu.openTab("MEDIA", ensureAfter: () => find.textContaining(station));
  await tu.findAndTap("Start " + station, () => find.textContaining(station));
  await tu.waitMediaItemPlaying(station);
  await tu.openTab("LISTEN", ensureAfter: () => find.text("STEREO"));
  expect(find.text(station), findsOneWidget);
  expect(find.text("OLDIE ANTENNE"), findsOneWidget);
}

Future<void> _changeListeningModes(OnpcTestUtils tu) async {
  await _changeListeningMode(tu, "Pure Direct");
  await _changeListeningMode(tu, "Direct");
  await _changeListeningMode(tu, "Stereo");
}

Future<void> _changeDeviceSettings(OnpcTestUtils tu) async {
  // New friendly name
  await tu.openTab("DEVICE", ensureAfter: () => find.byTooltip("Change friendly name"));
  await tu.changeFriendlyName(tu, "New Player Name");

  // Restore friendly name
  await tu.openTab("LISTEN", ensureAfter: () => find.text("STEREO"));
  await tu.openTab("DEVICE", ensureAfter: () => find.byTooltip("Change friendly name"));
  await tu.changeFriendlyName(tu, "Denon AVR");

  // Rename dimmer level
  final String DIM_NAME = "Super-Bright";
  await tu.contextMenu("Bright", "Edit");
  await tu.setText(2, 1, DIM_NAME);
  await tu.findAndTap("Dimmer level: confirm change", () => find.text("OK"));
  expect(find.text(DIM_NAME), findsOneWidget);

  // Restore dimmer level name
  await tu.contextMenu(DIM_NAME, "Edit");
  await tu.findAndTap("Dimmer level: delete", () => find.byTooltip("Delete"));
  await tu.findAndTap("Dimmer level: confirm change", () => find.text("OK"));
  expect(find.text(DIM_NAME), findsNothing);
  expect(find.text("Bright"), findsOneWidget);
}

Future<void> _changeListeningMode(OnpcTestUtils tu, String mode) async {
  await tu.openTab("LISTEN", ensureAfter: () => find.text(mode.toUpperCase()));
  await tu.findAndTap("Set " + mode, () => find.text(mode.toUpperCase()), delay: OnpcTestUtils.NORMAL_DELAY);
  await tu.openTab("RC", swipeRight: true, ensureAfter: () => find.text("Listening modes"));
  expect(find.text(mode), findsOneWidget);
  if (mode == "Stereo") {
    await tu.findAndTap("Mode Up", () => find.byTooltip("Sets listening mode wrap-around up"),
        ensureAfter: () => find.text("Pure Direct"));
    await tu.findAndTap("Mode Down", () => find.byTooltip("Sets listening mode wrap-around down"),
        ensureAfter: () => find.text("Stereo"));
  }
}

Future<void> _openSearchDialog(OnpcTestUtils tu, int type, String search) async {
  await tu.findAndTap("Open Search dialog", () => find.byTooltip("Search"), ensureAfter: () => find.text("OK"));
  expect(find.text("Search"), findsOneWidget);
  expect(find.text("Artist"), findsOneWidget);
  expect(find.text("Album"), findsOneWidget);
  expect(find.text("Track"), findsOneWidget);
  expect(find.text("CANCEL"), findsOneWidget);
  final Finder fab = find.byWidgetPredicate((widget) => widget is Radio);
  expect(fab, findsNWidgets(3));
  await tu.findAndTap("Search for type: " + type.toString(), () => fab.at(type));
  await tu.setText(1, 0, search);
  await tu.findAndTap("Start search for: " + search, () => find.text("OK"),
      ensureAfter: () => find.widgetWithText(ListTile, search));
}
