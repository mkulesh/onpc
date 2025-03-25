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
import 'package:onpc/iscp/EISCPMessage.dart';
import 'package:onpc/iscp/StateManager.dart';
import 'package:onpc/main.dart' as app;
import 'package:onpc/utils/Logging.dart';
import 'package:onpc/utils/Pair.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

import 'onpc_test_utils.dart';

final String FRIENDLY_NAME = "My Onkyo Player";

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Automatic test of ' + FRIENDLY_NAME, (tester) async {
    final OnpcTestUtils tu = OnpcTestUtils(tester);

    app.main();
    await tu.connect(FRIENDLY_NAME, "Onkyo Player");

    await _playFromUsb(tu);
    await _playFromQueue(tu);
    await _playFromDeezer(tu);
    await _playFromDAB(tu);
    await _changeVolume(tu);
    await _groupUngroup(tu, true); // group
    await _groupUngroup(tu, false); // ungroup
    await _changeDeviceSettings(tu);
    await _deviceDisplay(tu);

    // Power-off
    await tu.findAndTap("Power-off", () => find.byTooltip("On/Standby"));

    // Write log
    await tu.writeLog("auto-test-onkyo");
  });
}

Future<void> _playFromUsb(final OnpcTestUtils tu) async {
  await tu.openTab("MEDIA", ensureAfter: () => find.text("USB Disk"));

  // Navigate to USB
  await tu.findAndTap("Select USB Disk", () => find.text("USB Disk"));

  // Search Accept
  final String artist1 = "Accept";
  final String album1 = "Metal Heart";
  await tu.navigateToMedia([OnpcTestUtils.TOP_LAYER, "onkyo_music", "Hard Rock", artist1]);

  // Add first albums to the queue
  await tu.contextMenu(album1 + " (1985)", "Replace and play",
      waitFor: true, checkItems: ["Play queue", "Replace and play", "Add", "Add and play", "Create shortcut"]);

  // Search and add second album to the queue
  final String artist2 = "Muse";
  final String album2 = "Absolution";
  await tu.navigateToMedia([OnpcTestUtils.TOP_LAYER, "onkyo_music", "Rock", artist2], ensureVisible: true);
  await tu.contextMenu(album2 + " (2003)", "Add", waitFor: true);

  // Inspect queue
  await tu.findAndTap("Select Net", () => find.text("NET"), ensureAfter: () => find.text("Play Queue"));
  await tu.findAndTap("Open Play Queue", () => find.text("Play Queue"),
      ensureAfter: () => find.text("Play Queue | items: 27"));
  await tu.waitMediaItemPlaying("01-Metal Heart.flac");

  // Inspect playing
  await tu.openTab("LISTEN", ensureAfter: () => find.text(artist1));
  expect(find.text(album1), findsExactly(2));
  expect(find.text("FLAC/44.1kHz/16bit"), findsOneWidget);

  // Play mode
  await tu.findAndTap("Random", () => find.byTooltip("Random"), delay: OnpcTestUtils.NORMAL_DELAY);
  await tu.findAndTap("Repeat", () => find.byTooltip("Repeat"), delay: OnpcTestUtils.NORMAL_DELAY);
  await tu.findAndTap("Repeat", () => find.byTooltip("Repeat"), delay: OnpcTestUtils.NORMAL_DELAY);
  await tu.findAndTap("Random", () => find.byTooltip("Random"), delay: OnpcTestUtils.NORMAL_DELAY);

  // Time seek slider
  final Finder pBar = find.byType(SfSlider);
  expect(pBar, findsOneWidget);
  await tu.slideByValue(pBar, 120);
  await tu.slideByValue(pBar, -60);

  // New track
  await tu.findAndTap("Next track", () => find.byTooltip("Track Up"), ensureAfter: () => find.text("Midnight Mover"));
  expect(find.text(artist1), findsOneWidget);
  expect(find.text(album1), findsOneWidget);

  // Pause
  await tu.ensureVisible(() => find.byTooltip("Pause"));
  await tu.findAndTap("Pause", () => find.byTooltip("Pause"), ensureAfter: () => find.byTooltip("Play"));
  expect(find.byTooltip("Pause"), findsNothing);
  await tu.findAndTap("Play", () => find.byTooltip("Play"));

  // Stop
  await tu.findAndTap("Stop playback", () => find.byTooltip("Stop"), ensureAfter: () => find.byTooltip("Play"));
  await tu.ensureDeleted(() => find.text(artist1));
  await tu.ensureDeleted(() => find.text(album1));

  // Start from play queue
  await tu.openTab("MEDIA", ensureAfter: () => find.text("Play Queue | items: 27"));
  await tu.ensureVisibleInList("Ensure " + artist2, find.byType(ReorderableListView),
      () => find.textContaining("Endlessly"), OnpcTestUtils.LIST_DRAG_OFFSET);
  await tu.findAndTap("Start " + artist2, () => find.textContaining("Fury"));
  await tu.openTab("LISTEN", ensureAfter: () => find.text(artist2));
  expect(find.text(album2), findsOneWidget);
  expect(find.text("Fury"), findsOneWidget);

  // Audio info dialog
  await tu.ensureAvInfo("NETWORK, All Ch Stereo", "", video: false);
}

Future<void> _playFromQueue(OnpcTestUtils tu) async {
  await tu.openTab("MEDIA", ensureAfter: () => find.text("Play Queue | items: 27"));
  await tu.ensureVisibleInList(
      "Ensure Return", find.byType(ReorderableListView), () => find.text("Return"), OnpcTestUtils.LIST_DRAG_OFFSET_UP);

  // Get initial list
  List<Pair<String, String>> list = tu.getListContent();
  Logging.info(tu, "Initial list: " + list.toString());

  // Start playing first item
  final String toPlay = "01-Metal Heart.flac";
  assert(list.elementAt(1).item1.contains("media_item_music.svg"));
  assert(list.elementAt(1).item2 == toPlay);
  await tu.findAndTap("Start " + toPlay, () => find.text(list.elementAt(1).item2));
  await tu.waitMediaItemPlaying(toPlay);

  // Reorder list
  final String toReorder = "06-Too High To Get It Right.flac";
  await tu.dragReorderableItem(toReorder, Offset(0, -600), dragIndex: 2);
  await tu.stepDelaySec(OnpcTestUtils.NORMAL_DELAY);
  list = tu.getListContent();
  assert(list.elementAt(1).item1.contains("media_item_music.svg"));
  assert(list.elementAt(1).item2 == toReorder);

  // Remove item
  final String toDelete = "03-Up To The Limit.flac";
  expect(find.text(toDelete), findsOneWidget);
  await tu.contextMenu(toDelete, "Remove item",
      checkItems: ["Play queue", "Remove item", "Remove all", "Create shortcut"],
      ensureAfter: () => find.text("Play Queue | items: 26"));
  await tu.stepDelaySec(OnpcTestUtils.NORMAL_DELAY);
  expect(find.text(toDelete), findsNothing);

  // Remove all
  final String toDeleteAll = "07-Dogs On Leads.flac";
  expect(find.text(toDeleteAll), findsOneWidget);
  await tu.contextMenu(toDeleteAll, "Remove all",
      checkItems: ["Play queue", "Remove item", "Remove all", "Create shortcut"],
      ensureAfter: () => find.text("Play Queue | items: 0"));
  await tu.stepDelaySec(OnpcTestUtils.NORMAL_DELAY);

  await tu.findAndTap("Return to top layer", () => find.text("Return"),
      ensureAfter: () => find.textContaining("NET | items:"));
}

Future<void> _playFromDeezer(final OnpcTestUtils tu) async {
  final String PL_LIST = "Test Playlist";
  final String shortcut = "Deezer Flow";

  // Start playing
  await tu.openTab("SHORTCUTS", ensureAfter: () => find.text(shortcut));
  await tu.findAndTap("Start " + shortcut, () => find.text(shortcut), delay: OnpcTestUtils.LONG_DELAY);

  // Check Feed buttons
  await tu.openTab("LISTEN", ensureAfter: () => find.byTooltip("Negative Feed"));
  expect(find.byTooltip("Positive Feed Or Mark/Unmark"), findsOneWidget);

  // Add to Test Playlist
  await tu.stepDelaySec(OnpcTestUtils.NORMAL_DELAY);
  await tu.findAndTap("Open Track Menu", () => find.byTooltip("Track menu"),
      ensureAfter: () => find.text("Add to a playlist"));
  await tu.findAndTap("Add to a playlist", () => find.text("Add to a playlist"), ensureAfter: () => find.text(PL_LIST));
  await tu.findAndTap("Add to " + PL_LIST, () => find.text(PL_LIST));
  expect(find.text("Track menu"), findsNothing);

  // Navigate to newly added item
  await tu.openTab("MEDIA", ensureAfter: () => find.text("NET"));
  await tu.navigateToMedia([OnpcTestUtils.TOP_LAYER, "Deezer", "My Music", "My Playlists", PL_LIST],
      ensureAfter: () => find.textContaining(PL_LIST + " | items:"));
  expect(find.text(PL_LIST + " | items: 1"), findsOneWidget);

  // Playback mode and context menu
  await tu.findAndTap("Start playing", () => find.byType(ListTile), num: 2, idx: 1, delay: OnpcTestUtils.NORMAL_DELAY);
  await tu.findAndTap("Select context menu", () => find.byType(ListTile),
      num: 2, idx: 1, rightClick: true, ensureAfter: () => find.text("Playback mode"));
  await tu.findAndTap("Select Playback mode", () => find.text("Playback mode"),
      ensureAfter: () => find.widgetWithText(ListTile, "Playback mode"));
  await tu.findAndTap("Select context menu", () => find.widgetWithText(ListTile, "Playback mode"),
      rightClick: true, ensureAfter: () => find.text("Track menu"));
  await tu.findAndTap("Select Track menu", () => find.text("Track menu"),
      ensureAfter: () => find.widgetWithText(ListTile, "Remove from My Playlists"));
  await tu.findAndTap(
      "Select Remove from My Playlists", () => find.widgetWithText(ListTile, "Remove from My Playlists"),
      ensureAfter: () => find.text("Back"));
  await tu.findAndTap("Confirm", () => find.text("OK"));
  await tu.stepDelaySec(OnpcTestUtils.NORMAL_DELAY);
  if (find.text("Back").evaluate().isNotEmpty && find.text("OK").evaluate().isNotEmpty) {
    await tu.findAndTap("Confirm", () => find.text("Back"));
  }
}

Future<void> _playFromDAB(final OnpcTestUtils tu) async {
  final String shortcut = "DAB";

  // Start playing
  await tu.openTab("SHORTCUTS", ensureAfter: () => find.text(shortcut));
  await tu.findAndTap("Start " + shortcut, () => find.text(shortcut));
  await tu.openTab("MEDIA", ensureAfter: () => find.text("DAB"));
  await tu.waitMediaItemPlaying("Playback mode");
  expect(find.text("DAB | items: 1"), findsOneWidget);

  // Check station data
  await tu.openTab("LISTEN", ensureAfter: () => find.byTooltip("RDS info"));
  expect(find.byTooltip("Sets tuning frequency wrap-around up"), findsOneWidget);
  expect(find.byTooltip("Sets tuning frequency wrap-around down"), findsOneWidget);
  expect(find.byTooltip("Sets preset wrap-around up"), findsOneWidget);
  expect(find.byTooltip("Sets preset wrap-around down"), findsOneWidget);
  await tu.ensureAvInfo("ANALOG, All Ch Stereo", "", video: false);

  // Change station
  await tu.findAndTap("Next station", () => find.byTooltip("Sets tuning frequency wrap-around up"),
      delay: OnpcTestUtils.LONG_DELAY);
  await tu.findAndTap("Previous station", () => find.byTooltip("Sets tuning frequency wrap-around down"),
      delay: OnpcTestUtils.LONG_DELAY);
  await tu.findAndTap("Change RDS info", () => find.byTooltip("RDS info"));
}

Future<void> _changeVolume(final OnpcTestUtils tu) async {
  await tu.openTab("LISTEN", ensureAfter: () => find.byTooltip("Volume level down"));
  await tu.findAndTap("Volume mute", () => find.byTooltip("Sets amplifier audio muting wrap-around"),
      delay: OnpcTestUtils.NORMAL_DELAY, num: 2);
  await tu.findAndTap("Volume down", () => find.byTooltip("Volume level down"), delay: OnpcTestUtils.NORMAL_DELAY);
  await tu.findAndTap("Volume up", () => find.byTooltip("Volume level up"), delay: OnpcTestUtils.NORMAL_DELAY);
}

Future<void> _groupUngroup(final OnpcTestUtils tu, bool group) async {
  await tu.openTab("LISTEN", ensureAfter: () => find.byTooltip("Group/Ungroup devices"));
  await tu.findAndTap("Open group dialog", () => find.byTooltip("Group/Ungroup devices"));
  final bool isGrouped = find.text("Not attached").evaluate().isEmpty;
  if (group && isGrouped) {
    await tu.findAndTap("Select Onkyo Box", () => find.text("My Onkyo Box"),
        ensureAfter: () => find.text("Not attached"));
  }
  if (group) {
    await tu.findAndTap("Select Onkyo Box", () => find.text("My Onkyo Box"),
        ensureAfter: () => find.textContaining("Group 1"));
    await tu.stepDelaySec(OnpcTestUtils.NORMAL_DELAY);
    expect(find.text("Group 1: Master, Channel ST"), findsOneWidget);
  } else {
    await tu.findAndTap("Select Onkyo Box", () => find.text("My Onkyo Box"),
        ensureAfter: () => find.text("Not attached"));
    await tu.stepDelaySec(OnpcTestUtils.NORMAL_DELAY);
    expect(find.text("Not attached"), findsExactly(2));
  }
  await tu.findAndTap("Close group dialog", () => find.text("OK"));
  if (group) {
    await tu.findAndTap("Change speakers", () => find.byTooltip("Change speaker channel"),
        ensureAfter: () => find.text("FL"));
    await tu.findAndTap("Change speakers", () => find.byTooltip("Change speaker channel"),
        ensureAfter: () => find.text("FR"));
    await tu.findAndTap("Change speakers", () => find.byTooltip("Change speaker channel"),
        ensureAfter: () => find.text("ST"));
  }
}

Future<void> _changeDeviceSettings(OnpcTestUtils tu) async {
  // New friendly name
  await tu.openTab("DEVICE", ensureAfter: () => find.byTooltip("Change friendly name"));
  await tu.changeFriendlyName(tu, "New Player Name");

  // Restore friendly name
  await tu.openTab("LISTEN", swipeLeft: true, ensureAfter: () => find.byTooltip("Volume level down"));
  await tu.openTab("DEVICE", swipeRight: true, ensureAfter: () => find.byTooltip("Change friendly name"));
  await tu.changeFriendlyName(tu, "Onkyo Player");

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

Future<void> _deviceDisplay(OnpcTestUtils tu) async {
  await tu.openTab("RC", ensureAfter: () => find.text("Setup"), swipeRight: true);
  expect(find.text("Setup"), findsExactly(1));
  expect(find.text("Return"), findsExactly(1));
  final StateManager sm = tu.getStateManager();
  final EISCPMessage raw = EISCPMessage.outputCat("s", "FLD", "5456206541524320202D34352E30");
  sm.injectIscpMessage(raw);
  await tu.stepDelayMs(delay: 2000);
  expect(find.text("TV eARC  -45.0"), findsExactly(1));
}
