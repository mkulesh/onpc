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

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:onpc/constants/Strings.dart';
import 'package:onpc/iscp/EISCPMessage.dart';
import 'package:onpc/iscp/StateManager.dart';
import 'package:onpc/main.dart' as app;
import 'package:onpc/utils/Pair.dart';

import 'onpc_test_utils.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Simulation of the device display', (tester) async {
    final OnpcTestUtils tu = OnpcTestUtils(tester);
    app.main();

    await tu.stepDelayMs();
    await tu.openTab("LISTEN");
    if (find.text("Onkyo Player (Standby)").evaluate().isNotEmpty) {
      // Player is off - call power on
      await tu.findAndTap("Power-off", () => find.byTooltip("On/Standby"));
    }

    final StateManager sm = tu.getStateManager();

    // Initial settings
    final List<Pair<String, String>> initialMsg = [
      Pair("MVL", "1C"),
      Pair("ACE", "000000000000000000000000000"),
      Pair("TCL", "000000000000000000000000000000000000000"),
    ];
    for (Pair<String, String> element in initialMsg) {
      final EISCPMessage raw = EISCPMessage.outputCat("s", element.item1, element.item2);
      sm.injectIscpMessage(raw);
    }
    await tu.stepDelayMs(delay: 2000);

    await _testEqualizer(sm, tu);
    await _testChannelLevel(sm, tu);
  });
}

Future<void> _testEqualizer(final StateManager sm, final OnpcTestUtils tu) async {
  await tu.findAndTap("Test equalizer", () => find.byTooltip(Strings.audio_control_equalizer), delay: OnpcTestUtils.NORMAL_DELAY);
  expect(find.text(Strings.audio_control_equalizer), findsOneWidget);
  expect(find.text("-12dB"), findsOneWidget);
  expect(find.text("+12dB"), findsOneWidget);
  final List<Pair<String, String>> messages = [
    Pair("ACE", "-18000000000000000000000000"),
    Pair("ACE", "-18-14000000000000000000000"),
    Pair("ACE", "-18-14-10000000000000000000"),
    Pair("ACE", "-18-14-10-05000000000000000"),
    Pair("ACE", "-18-14-10-05-01000000000000"),
    Pair("ACE", "-18-14-10-05-01+05000000000"),
    Pair("ACE", "-18-14-10-05-01+05+10000000"),
    Pair("ACE", "-18-14-10-05-01+05+10+14000"),
    Pair("ACE", "-18-14-10-05-01+05+10+14+18"),
  ];
  for (Pair<String, String> element in messages) {
    final EISCPMessage raw = EISCPMessage.outputCat("s", element.item1, element.item2);
    sm.injectIscpMessage(raw);
    await tu.stepDelayMs(delay: 501);
  }
  await tu.findAndTap("Confirm", () => find.text(Strings.action_ok));
}

Future<void> _testChannelLevel(final StateManager sm, final OnpcTestUtils tu) async {
  await tu.findAndTap("Test channel level1", () => find.byTooltip(Strings.app_control_audio_control),
      delay: OnpcTestUtils.NORMAL_DELAY);
  expect(find.text(Strings.app_control_audio_control), findsOneWidget);
  expect(find.textContaining(Strings.master_volume), findsOneWidget);
  expect(find.text(Strings.audio_control_channel_level.toUpperCase()), findsOneWidget);
  await tu.findAndTap("Test channel level2", () => find.text(Strings.audio_control_channel_level.toUpperCase()),
      delay: OnpcTestUtils.NORMAL_DELAY);
  final List<Pair<String, String>> messages = [
    Pair("TCL", "-18000000000000000000000000000000000000"),
    Pair("TCL", "-18-14000000000000000000000000000000000"),
    Pair("TCL", "-18-14-0E000000000000000000000000000000"),
    Pair("TCL", "-18-14-0E-08000000000000000000000000000"),
    Pair("TCL", "-18-14-0E-08-06000000000000000000000000"),
    Pair("TCL", "-18-14-0E-08-06000000000000000000000000"),
    Pair("TCL", "-18-14-0E-08-06-04000000000000000000000"),
    Pair("TCL", "-18-14-0E-08-06-04+01000000000000000000"),
    Pair("TCL", "-18-14-0E-08-06-04+01+04000000000000000"),
    Pair("TCL", "-18-14-0E-08-06-04+01+04+06000000000000"),
    Pair("TCL", "-18-14-0E-08-06-04+01+04+06+08000000000"),
    Pair("TCL", "-18-14-0E-08-06-04+01+04+06+08+0D000000"),
    Pair("TCL", "-18-14-0E-08-06-04+01+04+06+08+0D+14000"),
    Pair("TCL", "-18-14-0E-08-06-04+01+04+06+08+0D+14+18"),
    Pair("TCL", "-03+01-02000-02000000000-18+0C000000000"),
  ];
  for (Pair<String, String> element in messages) {
    final EISCPMessage raw = EISCPMessage.outputCat("s", element.item1, element.item2);
    sm.injectIscpMessage(raw);
    await tu.stepDelayMs(delay: 501);
  }
}
