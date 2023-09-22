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
// @dart=2.9

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:onpc/main.dart' as app;
import 'package:onpc/utils/Logging.dart';

typedef OnFind = Finder Function();

const int STEP_DELAY = 5;
const String STEP_HEADER = "=================================> ";

final String PLAYER = "Onkyo Player";

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Automatic test of ' + PLAYER, (tester) async {

    app.main();
    await _stepDelay(tester, STEP_DELAY);

    await _openTab(tester, "LISTEN", delay: 2 * STEP_DELAY);

    await _openDrawer(tester);
    await _findAndTap(tester, "Find and connect", () => find.text(PLAYER), delay: 3 * STEP_DELAY);

    Logging.logSize = 5000; // After reconnect, increase log size

    await _playFromUsb(tester);
    await _playFromDeezer(tester);
    await _changeVolume(tester);
    await _playFromQueue(tester);
    await _playFromDAB(tester);
    await _groupUngroup(tester, true); // group
    await _groupUngroup(tester, false); // ungroup

    // Power-off
    await _findAndTap(tester, "Power-off", () => find.byTooltip("On/Standby"));

    // Write log
    await _writeLog("onkyo_player_test");
  });
}

Future<void> _playFromUsb(WidgetTester tester) async {
  await _openTab(tester, "MEDIA");
  await _findAndTap(tester, "Select USB", () => find.text("USB Disk"));
  await _findAndTap(tester, "Open onkyo_music", () => find.text("onkyo_music"), waitFor: true);
  await _findAndTap(tester, "Open Rock", () => find.text("Blues"));
  await _findAndTap(tester, "Open interpret", () => find.text("Ayo"));
  await _findAndTap(tester, "Open context menu", () => find.text("Joyful (2000)"), buttons: 0x02);
  await _findAndTap(tester, "Replace and play", () => find.text("Replace and play"));
  await _openTab(tester, "LISTEN", delay: 2 * STEP_DELAY);
  await _findAndTap(tester, "Next track", () => find.byTooltip("Track Up"), delay: 2 * STEP_DELAY);
  await _findAndTap(tester, "Random", () => find.byTooltip("Random"));
  await _findAndTap(tester, "Repeat", () => find.byTooltip("Repeat"));
  await _findAndTap(tester, "Repeat", () => find.byTooltip("Repeat"));
  await _findAndTap(tester, "Random", () => find.byTooltip("Random"));
  await _findAndTap(tester, "Stop playback", () => find.byTooltip("Stop"));
  await _openTab(tester, "MEDIA");
  await _findAndTap(tester, "Return to top layer", () => find.text("Return"));
}

Future<void> _playFromDeezer(WidgetTester tester) async {
  await _openTab(tester, "SHORTCUTS");
  await _findAndTap(tester, "Deezer Playlist", () => find.text("Deezer Playlist"), delay: 2 * STEP_DELAY);
  await _openTab(tester, "LISTEN");
  await _findAndTap(tester, "Pause", () => find.byTooltip("Pause"));
  await _findAndTap(tester, "Resume pause", () => find.byTooltip("Play"));
  await _findAndTap(tester, "Open Track Menu", () => find.byTooltip("Track menu"));
  await _findAndTap(tester, "Close Track Menu", () => find.text("CANCEL"));
}

Future<void> _changeVolume(WidgetTester tester) async {
  await _openTab(tester, "LISTEN");
  await _findAndTap(tester, "Volume mute", () => find.byTooltip("Sets amplifier audio muting wrap-around"));
  await _findAndTap(tester, "Volume down", () => find.byTooltip("Volume level down"));
  await _findAndTap(tester, "Volume up", () => find.byTooltip("Volume level up"));
}

Future<void> _playFromQueue(WidgetTester tester) async {
  await _openTab(tester, "MEDIA");
  await _findAndTap(tester, "Select top level", () => find.byTooltip("Top Menu"));
  await _findAndTap(tester, "Select Play Queue", () => find.text("Play Queue"));
  expect(find.text("Play Queue | items: 12"), findsOneWidget);
  await _findAndTap(tester, "Start track", () => find.text("03-Letter By Letter.flac"));
  await _findAndTap(tester, "Open context menu", () => find.text("04-How Many Times.flac"), buttons: 0x02);
  await _findAndTap(tester, "Remove one item", () => find.text("Remove item"));
  await _findAndTap(tester, "Open context menu", () => find.text("07-Only You.flac"), buttons: 0x02);
  await _findAndTap(tester, "Clear queue", () => find.text("Remove all"));
  await _findAndTap(tester, "Return to top layer", () => find.text("Return"));
}

Future<void> _playFromDAB(WidgetTester tester) async {
  await _openTab(tester, "MEDIA");
  await _findAndTap(tester, "Select DAB", () => find.text("DAB"));
  await _openTab(tester, "LISTEN");
  await _findAndTap(tester, "Next station", () => find.byTooltip("Sets tuning frequency wrap-around up"),
      delay: 2 * STEP_DELAY);
  await _findAndTap(tester, "Previous station", () => find.byTooltip("Sets tuning frequency wrap-around down"),
      delay: 2 * STEP_DELAY);
  await _findAndTap(tester, "Change RDS info", () => find.byTooltip("RDS info"));
}

Future<void> _groupUngroup(WidgetTester tester, bool group) async {
  await _openTab(tester, "LISTEN");
  await _findAndTap(tester, "Open group dialog", () => find.byTooltip("Group/Ungroup devices"));
  await _findAndTap(tester, "Select Onkyo Box", () => find.text("Onkyo Box"), delay: 2 * STEP_DELAY);
  await _findAndTap(tester, "Close group dialog", () => find.text("OK"));
  if (group) {
    await _findAndTap(tester, "Change speakers", () => find.byTooltip("Change speaker channel"));
  }
}

Future<void> _openDrawer(WidgetTester tester) async {
  Logging.info(tester, STEP_HEADER + "Open application drawer");
  await tester.tapAt(Offset(30, 30));
  await _stepDelay(tester, STEP_DELAY);
}

Future<void> _openTab(WidgetTester tester, String s, {int delay = STEP_DELAY}) async {
  await _findAndTap(tester, "Open " + s + " tab", () => find.text(s), delay: delay);
}

Future<void> _findAndTap(WidgetTester tester, String title, OnFind finder,
    {int buttons = 0x01, bool waitFor = false, int delay = STEP_DELAY}) async {
  while (waitFor && finder().evaluate().isEmpty) {
    await _stepDelay(tester, 1);
  }
  Logging.info(tester, STEP_HEADER + title);
  final Finder fab = finder();
  expect(fab, findsOneWidget);
  await tester.tap(fab, buttons: buttons);
  await _stepDelay(tester, delay);
}

Future<void> _stepDelay(WidgetTester tester, int step_delay) async {
  for (int i = 0; i < step_delay; i++) {
    await tester.pumpAndSettle();
    await Future.delayed(Duration(milliseconds: 900));
  }
}

Future<void> _writeLog(String s) async {
  final StringBuffer outContent = StringBuffer();
  final DateTime now = DateTime.now();
  Logging.latestLogging.forEach((str) => outContent.writeln(str));
  await File("onkyo_player_test_" + now.toString().replaceAll(":", "-") + ".log").writeAsString(outContent.toString());
}
