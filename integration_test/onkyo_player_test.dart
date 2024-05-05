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
import 'package:onpc/utils/Logging.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

import 'onpc_test_utils.dart';

final String PLAYER = "My Onkyo Player";

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Automatic test of ' + PLAYER, (tester) async {
    final OnpcTestUtils tu = OnpcTestUtils();
    tu.setStepDelay(OnpcTestUtils.NORMAL_DELAY);

    app.main();
    await tu.stepDelayMs(tester);

    await tu.openTab(tester, "LISTEN", swipeLeft: true,
        ensureAfter: () => find.byTooltip("Volume level down"));

    if (find.text("Onkyo Player").evaluate().isEmpty &&
        find.text("Onkyo Player (Standby)").evaluate().isEmpty) {
      await tu.openDrawer(tester);
      await tu.findAndTap(tester, "Find and connect", () => find.text(PLAYER), delay: OnpcTestUtils.HUGE_DELAY);
    }

    Logging.logSize = 5000; // After reconnect, increase log size

    await _playFromUsb(tu, tester);
    await _playFromDeezer(tu, tester);
    await _playFromQueue(tu, tester);
    await _playFromDAB(tu, tester);
    await _changeVolume(tu, tester);
    await _groupUngroup(tu, tester, true); // group
    await _groupUngroup(tu, tester, false); // ungroup
    await _changeDeviceSettings(tu, tester);

    // Power-off
    await tu.findAndTap(tester, "Power-off", () => find.byTooltip("On/Standby"));

    // Write log
    await tu.writeLog("onkyo_player_test");
  });
}

Future<void> _playFromUsb(final OnpcTestUtils tu, WidgetTester tester) async {
  await tu.openTab(tester, "MEDIA",
      ensureAfter: () => find.text("USB Disk"));
  await tu.findAndTap(tester, "Select USB Disk", () => find.text("USB Disk"));
  await tu.navigateToMedia(tester, [OnpcTestUtils.TOP_LAYER, "onkyo_music", "Blues", "Ayo"]);

  // Start playing
  await tu.contextMenu(tester, "Joyful (2000)", "Replace and play", waitFor: true);
  await tu.openTab(tester, "LISTEN",
      ensureAfter: () => find.text("Down On My Knees"));
  expect(find.text("FLAC/44.1kHz/16bit"), findsOneWidget);
  expect(find.text("Ayo"), findsOneWidget);
  expect(find.text("Joyful"), findsOneWidget);

  // Play mode
  await tu.findAndTap(tester, "Random", () => find.byTooltip("Random"));
  await tu.findAndTap(tester, "Repeat", () => find.byTooltip("Repeat"));
  await tu.findAndTap(tester, "Repeat", () => find.byTooltip("Repeat"));
  await tu.findAndTap(tester, "Random", () => find.byTooltip("Random"));

  // Time seek slider
  final Finder pBar = find.byType(SfSlider);
  expect(pBar, findsOneWidget);
  await tu.slideByValue(tester, pBar, 120);
  await tu.slideByValue(tester, pBar, -60);

  // Audio info dialog
  await tu.findAndTap(tester, "Open Audio/Video info", () => find.byTooltip("Audio/Video info"),
      ensureAfter: () => find.text("Input: UNKNOWN, UNKNOWN, All Ch Stereo"));
  await tu.findAndTap(tester, "Close Audio/Video info", () => find.text("OK"));

  // New track
  await tu.findAndTap(tester, "Next track", () => find.byTooltip("Track Up"), delay: OnpcTestUtils.LONG_DELAY);
  expect(find.text("Ayo"), findsOneWidget);
  expect(find.text("Joyful"), findsOneWidget);
  expect(find.text("Without You"), findsOneWidget);

  // Pause
  expect(find.byTooltip("Pause"), findsOneWidget);
  await tu.findAndTap(tester, "Pause", () => find.byTooltip("Pause"));
  expect(find.byTooltip("Pause"), findsNothing);
  expect(find.byTooltip("Play"), findsOneWidget);
  await tu.findAndTap(tester, "Play", () => find.byTooltip("Play"));

  // Stop
  await tu.findAndTap(tester, "Stop playback", () => find.byTooltip("Stop"));
  expect(find.text("Ayo"), findsNothing);
  expect(find.byTooltip("Pause"), findsNothing);
  expect(find.byTooltip("Play"), findsOneWidget);

  // Return to parent level
  await tu.openTab(tester, "MEDIA",
      ensureAfter: () => find.text("Return"));
  await tu.findAndTap(tester, "Return to parent layer", () => find.text("Return"));
  expect(find.textContaining("Blues | items:"), findsOneWidget);
}

Future<void> _playFromDeezer(final OnpcTestUtils tu, WidgetTester tester) async {
  final String PL_LIST = "Test Playlist";
  await tu.openTab(tester, "SHORTCUTS",
      ensureAfter: () => find.text("Deezer Flow"));

  // Start playing
  await tu.findAndTap(tester, "Deezer Flow", () => find.text("Deezer Flow"), delay: OnpcTestUtils.LONG_DELAY);

  // Check Feed buttons
  await tu.openTab(tester, "LISTEN",
      ensureAfter: () => find.byTooltip("Negative Feed"));
  expect(find.byTooltip("Positive Feed Or Mark/Unmark"), findsOneWidget);

  // Add to Test Playlist
  await tu.findAndTap(tester, "Open Track Menu", () => find.byTooltip("Track menu"),
      ensureAfter: () => find.text("Add to a playlist"));
  await tu.findAndTap(tester, "Add to a playlist", () => find.text("Add to a playlist"),
      ensureAfter: () => find.text(PL_LIST));
  await tu.findAndTap(tester, "Add to " + PL_LIST, () => find.text(PL_LIST));
  expect(find.text("Track menu"), findsNothing);

  // Navigate to newly added item
  await tu.openTab(tester, "MEDIA",
      ensureAfter: () => find.text("NET"));
  await tu.navigateToMedia(tester, [OnpcTestUtils.TOP_LAYER, "Deezer", "My Music", "My Playlists", PL_LIST],
      ensureAfter: () => find.textContaining(PL_LIST + " | items:"));
  expect(find.text(PL_LIST + " | items: 1"), findsOneWidget);

  // Playback mode and context menu
  await tu.findAndTap(tester, "Start playing", () => find.byType(ListTile), num: 2, idx: 1);
  await tu.findAndTap(tester, "Select context menu", () => find.byType(ListTile), num: 2, idx: 1, rightClick: true,
      ensureAfter: () => find.text("Playback mode"));
  await tu.findAndTap(tester, "Select Playback mode", () => find.text("Playback mode"),
      ensureAfter: () => find.widgetWithText(ListTile, "Playback mode"));
  await tu.findAndTap(tester, "Select context menu", () => find.widgetWithText(ListTile, "Playback mode"), rightClick: true,
      ensureAfter: () => find.text("Track menu"));
  await tu.findAndTap(tester, "Select Track menu", () => find.text("Track menu"),
      ensureAfter: () => find.widgetWithText(ListTile, "Remove from My Playlists"));
  await tu.findAndTap(tester, "Select Remove from My Playlists", () => find.widgetWithText(ListTile, "Remove from My Playlists"),
      ensureAfter: () => find.text("Back"));
  await tu.findAndTap(tester, "Confirm", () => find.text("OK"));
}

Future<void> _changeVolume(final OnpcTestUtils tu, WidgetTester tester) async {
  await tu.openTab(tester, "LISTEN",
      ensureAfter: () => find.byTooltip("Volume level down"));
  await tu.findAndTap(tester, "Volume mute", () => find.byTooltip("Sets amplifier audio muting wrap-around"));
  await tu.findAndTap(tester, "Volume down", () => find.byTooltip("Volume level down"));
  await tu.findAndTap(tester, "Volume up", () => find.byTooltip("Volume level up"));
}

Future<void> _playFromQueue(final OnpcTestUtils tu, WidgetTester tester) async {
  await tu.openTab(tester, "MEDIA",
      ensureAfter: () => find.text("NET"));
  await tu.findAndTap(tester, "Start NET", () => find.text("NET"));
  await tu.navigateToMedia(tester, [OnpcTestUtils.TOP_LAYER, "Play Queue"]);
  expect(find.text("Play Queue | items: 12"), findsOneWidget);
  await tu.findAndTap(tester, "Start track", () => find.text("03-Letter By Letter.flac"));
  await tu.ensureElement(tester, () => find.text("03-Letter By Letter.flac"));
  await tu.contextMenu(tester, "04-How Many Times.flac", "Remove item");
  expect(find.text("Play Queue | items: 11"), findsOneWidget);
  await tu.dragReorderableItem(tester, "06-Watching You.flac", Offset(0, 600), dragIndex: 2);
  await tu.stepDelayMs(tester);
  await tu.contextMenu(tester, "07-Only You.flac", "Remove all");
  expect(find.text("Play Queue | items: 0"), findsOneWidget);
  await tu.findAndTap(tester, "Return to top layer", () => find.text("Return"));
}

Future<void> _playFromDAB(final OnpcTestUtils tu, WidgetTester tester) async {
  await tu.openTab(tester, "MEDIA",
      ensureAfter: () => find.text("DAB"));
  await tu.findAndTap(tester, "Select DAB", () => find.text("DAB"));
  await tu.openTab(tester, "LISTEN",
      ensureAfter: () => find.byTooltip("Sets tuning frequency wrap-around up"));
  await tu.findAndTap(tester, "Next station", () => find.byTooltip("Sets tuning frequency wrap-around up"),
      delay: OnpcTestUtils.LONG_DELAY);
  await tu.findAndTap(tester, "Previous station", () => find.byTooltip("Sets tuning frequency wrap-around down"),
      delay: OnpcTestUtils.LONG_DELAY);
  await tu.findAndTap(tester, "Change RDS info", () => find.byTooltip("RDS info"));
}

Future<void> _groupUngroup(final OnpcTestUtils tu, WidgetTester tester, bool group) async {
  await tu.openTab(tester, "LISTEN",
      ensureAfter: () => find.byTooltip("Group/Ungroup devices"));
  await tu.findAndTap(tester, "Open group dialog", () => find.byTooltip("Group/Ungroup devices"));
  final bool isGrouped = find.text("Not attached").evaluate().isEmpty;
  if (group && isGrouped) {
    await tu.findAndTap(tester, "Select Onkyo Box", () => find.text("My Onkyo Box"), 
        ensureAfter: () => find.text("Not attached"));
  }
  if (group) {
    await tu.findAndTap(tester, "Select Onkyo Box", () => find.text("My Onkyo Box"),
        ensureAfter: () => find.textContaining("Group 1"));
    expect(find.text("Group 1: Master, Channel ST"), findsOneWidget);
    expect(find.text("Group 1: Slave, Channel ST"), findsOneWidget);
  } else {
    await tu.findAndTap(tester, "Select Onkyo Box", () => find.text("My Onkyo Box"),
        ensureAfter: () => find.text("Not attached"));
    expect(find.text("Not attached"), findsExactly(2));
  }
  await tu.findAndTap(tester, "Close group dialog", () => find.text("OK"));
  if (group) {
    await tu.findAndTap(tester, "Change speakers", () => find.byTooltip("Change speaker channel"));
    expect(find.text("FL"), findsOneWidget);
    await tu.findAndTap(tester, "Change speakers", () => find.byTooltip("Change speaker channel"));
    expect(find.text("FR"), findsOneWidget);
    await tu.findAndTap(tester, "Change speakers", () => find.byTooltip("Change speaker channel"));
    expect(find.text("ST"), findsOneWidget);
  }
}

Future<void> _changeDeviceSettings(OnpcTestUtils tu, WidgetTester tester) async {
  // New friendly name
  await tu.openTab(tester, "DEVICE",
      ensureAfter: () => find.byTooltip("Change friendly name"));
  await _changeFriendlyName(tu, tester, "New Player Name");

  // Restore friendly name
  await tu.openTab(tester, "LISTEN",
      ensureAfter: () => find.byTooltip("Volume level down"));
  await tu.openTab(tester, "DEVICE",
      ensureAfter: () => find.byTooltip("Change friendly name"));
  await _changeFriendlyName(tu, tester, "Onkyo Player");

  // Rename dimmer level
  final String DIM_NAME = "Super-Bright";
  await tu.findAndTap(tester, "Dimmer level context menu", () => find.text("Bright"), rightClick: true,
      ensureAfter: () => find.text("Edit"));
  await tu.findAndTap(tester, "Dimmer level: change name", () => find.text("Edit"));
  await tu.setText(tester, 2, 1, DIM_NAME);
  await tu.findAndTap(tester, "Dimmer level: confirm change", () => find.text("OK"));
  expect(find.text(DIM_NAME), findsOneWidget);

  // Restore dimmer level name
  await tu.findAndTap(tester, "Dimmer level context menu", () => find.text(DIM_NAME), rightClick: true,
      ensureAfter: () => find.text("Edit"));
  await tu.findAndTap(tester, "Dimmer level: change name", () => find.text("Edit"));
  await tu.findAndTap(tester, "Dimmer level: delete", () => find.byTooltip("Delete"));
  await tu.findAndTap(tester, "Dimmer level: confirm change", () => find.text("OK"));
  expect(find.text(DIM_NAME), findsNothing);
  expect(find.text("Bright"), findsOneWidget);
}

Future<void> _changeFriendlyName(OnpcTestUtils tu, WidgetTester tester, String name) async {
  await tu.setText(tester, 1, 0, name);
  await tu.findAndTap(tester, "Change friendly name", () => find.byTooltip("Change friendly name"));
  expect(find.text(name), findsExactly(2));
}
