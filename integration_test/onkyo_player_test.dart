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
    await tu.stepDelay(tester);

    await tu.openTab(tester, "LISTEN", swipeLeft: true, delay: OnpcTestUtils.LONG_DELAY);

    if (find.text("Onkyo Player").evaluate().isEmpty &&
        find.text("Onkyo Player (Standby)").evaluate().isEmpty) {
      await tu.openDrawer(tester);
      await tu.findAndTap(tester, "Find and connect", () => find.text(PLAYER), delay: OnpcTestUtils.HUGE_DELAY);
    }

    Logging.logSize = 5000; // After reconnect, increase log size

    await _playFromUsb(tu, tester);
    await _playFromDeezer(tu, tester);
    await _changeVolume(tu, tester);
    await _playFromQueue(tu, tester);
    await _playFromDAB(tu, tester);
    await _groupUngroup(tu, tester, true); // group
    await _groupUngroup(tu, tester, false); // ungroup

    // Power-off
    await tu.findAndTap(tester, "Power-off", () => find.byTooltip("On/Standby"));

    // Write log
    await tu.writeLog("onkyo_player_test");
  });
}

Future<void> _playFromUsb(final OnpcTestUtils tu, WidgetTester tester) async {
  await tu.openTab(tester, "MEDIA");
  await tu.navigateToMedia(tester, ["USB Disk", OnpcTestUtils.TOP_LAYER, "onkyo_music", "Blues", "Ayo"]);
  await tu.contextMenu(tester, "Joyful (2000)", "Replace and play", waitFor: true);
  await tu.openTab(tester, "LISTEN", delay: OnpcTestUtils.LONG_DELAY);

  expect(find.text("FLAC/44.1kHz/16bit"), findsOneWidget);
  expect(find.text("Ayo"), findsOneWidget);
  expect(find.text("Joyful"), findsOneWidget);

  final Finder pBar = find.byType(SfSlider);
  expect(pBar, findsOneWidget);
  await tu.slideByValue(tester, pBar, 120);
  await tu.slideByValue(tester, pBar, -60);

  await tu.findAndTap(tester, "Open Audio/Video info", () => find.byTooltip("Audio/Video info"));
  await tu.findAndTap(tester, "Close Audio/Video info", () => find.text("OK"));

  await tu.findAndTap(tester, "Next track", () => find.byTooltip("Track Up"), delay: OnpcTestUtils.LONG_DELAY);
  await tu.findAndTap(tester, "Random", () => find.byTooltip("Random"));
  await tu.findAndTap(tester, "Repeat", () => find.byTooltip("Repeat"));
  await tu.findAndTap(tester, "Repeat", () => find.byTooltip("Repeat"));
  await tu.findAndTap(tester, "Random", () => find.byTooltip("Random"));
  await tu.findAndTap(tester, "Stop playback", () => find.byTooltip("Stop"));
  await tu.openTab(tester, "MEDIA");
  await tu.findAndTap(tester, "Return to top layer", () => find.text("Return"));
}

Future<void> _playFromDeezer(final OnpcTestUtils tu, WidgetTester tester) async {
  await tu.openTab(tester, "SHORTCUTS");
  await tu.findAndTap(tester, "Deezer Playlist", () => find.text("Deezer Playlist"), delay: OnpcTestUtils.LONG_DELAY);
  await tu.openTab(tester, "LISTEN");
  await tu.findAndTap(tester, "Pause", () => find.byTooltip("Pause"));
  await tu.findAndTap(tester, "Resume pause", () => find.byTooltip("Play"));
  await tu.findAndTap(tester, "Open Track Menu", () => find.byTooltip("Track menu"));
  await tu.findAndTap(tester, "Close Track Menu", () => find.text("CANCEL"));
}

Future<void> _changeVolume(final OnpcTestUtils tu, WidgetTester tester) async {
  await tu.openTab(tester, "LISTEN");
  await tu.findAndTap(tester, "Volume mute", () => find.byTooltip("Sets amplifier audio muting wrap-around"));
  await tu.findAndTap(tester, "Volume down", () => find.byTooltip("Volume level down"));
  await tu.findAndTap(tester, "Volume up", () => find.byTooltip("Volume level up"));
}

Future<void> _playFromQueue(final OnpcTestUtils tu, WidgetTester tester) async {
  await tu.openTab(tester, "MEDIA");
  await tu.navigateToMedia(tester, ["NET", OnpcTestUtils.TOP_LAYER, "Play Queue"]);
  expect(find.text("Play Queue | items: 12"), findsOneWidget);
  await tu.findAndTap(tester, "Start track", () => find.text("03-Letter By Letter.flac"));
  await tu.contextMenu(tester, "04-How Many Times.flac", "Remove item");
  await tu.dragReorderableItem(tester, "06-Watching You.flac", Offset(0, 600), dragIndex: 2);
  await tu.contextMenu(tester, "07-Only You.flac", "Remove all");
  await tu.findAndTap(tester, "Return to top layer", () => find.text("Return"));
}

Future<void> _playFromDAB(final OnpcTestUtils tu, WidgetTester tester) async {
  await tu.openTab(tester, "MEDIA");
  await tu.findAndTap(tester, "Select DAB", () => find.text("DAB"));
  await tu.openTab(tester, "LISTEN");
  await tu.findAndTap(tester, "Next station", () => find.byTooltip("Sets tuning frequency wrap-around up"),
      delay: OnpcTestUtils.LONG_DELAY);
  await tu.findAndTap(tester, "Previous station", () => find.byTooltip("Sets tuning frequency wrap-around down"),
      delay: OnpcTestUtils.LONG_DELAY);
  await tu.findAndTap(tester, "Change RDS info", () => find.byTooltip("RDS info"));
}

Future<void> _groupUngroup(final OnpcTestUtils tu, WidgetTester tester, bool group) async {
  await tu.openTab(tester, "LISTEN");
  await tu.findAndTap(tester, "Open group dialog", () => find.byTooltip("Group/Ungroup devices"));
  await tu.findAndTap(tester, "Select Onkyo Box", () => find.text("My Onkyo Box"), delay: OnpcTestUtils.LONG_DELAY);
  await tu.findAndTap(tester, "Close group dialog", () => find.text("OK"));
  if (group) {
    await tu.findAndTap(tester, "Change speakers", () => find.byTooltip("Change speaker channel"));
  }
}
